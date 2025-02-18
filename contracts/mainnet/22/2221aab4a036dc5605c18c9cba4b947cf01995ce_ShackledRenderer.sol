// // SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./ShackledCoords.sol";
import "./ShackledRasteriser.sol";
import "./ShackledUtils.sol";
import "./ShackledStructs.sol";

library ShackledRenderer {
    uint256 constant outputHeight = 512;
    uint256 constant outputWidth = 512;

    /** @dev take any geometry, render it, and return a bitmap image inside an SVG 
    this can be called to render the Shackled art collection (the output of ShackledGenesis.sol)
    or any other custom made geometry

    */
    function render(
        ShackledStructs.RenderParams memory renderParams,
        int256 canvasDim,
        bool returnSVG
    ) public view returns (string memory) {
        /// prepare the fragments
        int256[12][3][] memory trisFragments = prepareGeometryForRender(
            renderParams,
            canvasDim
        );

        /// run Bresenham's line algorithm to rasterize the fragments
        int256[12][] memory fragments = ShackledRasteriser.rasterise(
            trisFragments,
            canvasDim,
            renderParams.wireframe
        );

        fragments = ShackledRasteriser.depthTesting(fragments, canvasDim);

        if (renderParams.lightingParams.applyLighting) {
            /// apply lighting (Blinn phong)
            fragments = ShackledRasteriser.lightScene(
                fragments,
                renderParams.lightingParams
            );
        }

        /// get the background
        int256[5][] memory background = ShackledRasteriser.getBackground(
            canvasDim,
            renderParams.backgroundColor
        );

        /// place each fragment in an encoded bitmap
        string memory encodedBitmap = ShackledUtils.getEncodedBitmap(
            fragments,
            background,
            canvasDim,
            renderParams.invert
        );

        if (returnSVG) {
            /// insert the bitmap into an encoded svg (to be accepted by OpenSea)
            return
                ShackledUtils.getSVGContainer(
                    encodedBitmap,
                    canvasDim,
                    outputHeight,
                    outputWidth
                );
        } else {
            return encodedBitmap;
        }
    }

    /** @dev prepare the triangles and colors for rasterization
     */
    function prepareGeometryForRender(
        ShackledStructs.RenderParams memory renderParams,
        int256 canvasDim
    ) internal view returns (int256[12][3][] memory) {
        /// convert geometry and colors from PLY standard into Shackled format
        /// create the final triangles and colors that will be rendered
        /// by pulling the numbers out of the faces array
        /// and using them to index into the verts and colors arrays
        /// make copies of each coordinate and color
        int256[3][3][] memory tris = new int256[3][3][](
            renderParams.faces.length
        );
        int256[3][3][] memory trisCols = new int256[3][3][](
            renderParams.faces.length
        );

        for (uint256 i = 0; i < renderParams.faces.length; i++) {
            for (uint256 j = 0; j < 3; j++) {
                for (uint256 k = 0; k < 3; k++) {
                    /// copy the values from verts and cols arrays
                    /// using the faces lookup array to index into them
                    tris[i][j][k] = renderParams.verts[
                        renderParams.faces[i][j]
                    ][k];
                    trisCols[i][j][k] = renderParams.cols[
                        renderParams.faces[i][j]
                    ][k];
                }
            }
        }

        /// convert the fragments from model to world space
        int256[3][] memory vertsWorldSpace = ShackledCoords
            .convertToWorldSpaceWithModelTransform(
                tris,
                renderParams.objScale,
                renderParams.objPosition
            );

        /// convert the vertices back to triangles in world space
        int256[3][3][] memory trisWorldSpace = ShackledUtils
            .unflattenVertsToTris(vertsWorldSpace);

        /// implement backface culling
        if (renderParams.backfaceCulling) {
            (trisWorldSpace, trisCols) = ShackledCoords.backfaceCulling(
                trisWorldSpace,
                trisCols
            );
        }

        /// update vertsWorldSpace
        vertsWorldSpace = ShackledUtils.flattenTris(trisWorldSpace);

        /// convert the fragments from world to camera space
        int256[3][] memory vertsCameraSpace = ShackledCoords
            .convertToCameraSpaceViaVertexShader(
                vertsWorldSpace,
                canvasDim,
                renderParams.perspCamera
            );

        /// convert the vertices back to triangles in camera space
        int256[3][3][] memory trisCameraSpace = ShackledUtils
            .unflattenVertsToTris(vertsCameraSpace);

        int256[12][3][] memory trisFragments = ShackledRasteriser
            .initialiseFragments(
                trisCameraSpace,
                trisWorldSpace,
                trisCols,
                canvasDim
            );

        return trisFragments;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./ShackledUtils.sol";
import "./ShackledMath.sol";

library ShackledCoords {
    /** @dev scale and translate the verts
    this can be effectively disabled with a scale of 1 and translate of [0, 0, 0]
     */
    function convertToWorldSpaceWithModelTransform(
        int256[3][3][] memory tris,
        int256 scale,
        int256[3] memory position
    ) external view returns (int256[3][] memory) {
        int256[3][] memory verts = ShackledUtils.flattenTris(tris);

        // Scale model matrices are easy, just multiply through by the scale value
        int256[3][] memory scaledVerts = new int256[3][](verts.length);

        for (uint256 i = 0; i < verts.length; i++) {
            scaledVerts[i][0] = verts[i][0] * scale + position[0];
            scaledVerts[i][1] = verts[i][1] * scale + position[1];
            scaledVerts[i][2] = verts[i][2] * scale + position[2];
        }
        return scaledVerts;
    }

    /** @dev run backfaceCulling to save future operations on faces that aren't seen by the camera*/
    function backfaceCulling(
        int256[3][3][] memory trisWorldSpace,
        int256[3][3][] memory trisCols
    )
        external
        view
        returns (
            int256[3][3][] memory culledTrisWorldSpace,
            int256[3][3][] memory culledTrisCols
        )
    {
        culledTrisWorldSpace = new int256[3][3][](trisWorldSpace.length);
        culledTrisCols = new int256[3][3][](trisCols.length);

        uint256 nextIx;

        for (uint256 i = 0; i < trisWorldSpace.length; i++) {
            int256[3] memory v1 = trisWorldSpace[i][0];
            int256[3] memory v2 = trisWorldSpace[i][1];
            int256[3] memory v3 = trisWorldSpace[i][2];
            int256[3] memory norm = ShackledMath.crossProduct(
                ShackledMath.vector3Sub(v1, v2),
                ShackledMath.vector3Sub(v2, v3)
            );
            /// since shackled has a static positioned camera at the origin,
            /// the points are already in view space, relaxing the backfaceCullingCond
            int256 backfaceCullingCond = ShackledMath.vector3Dot(v1, norm);
            if (backfaceCullingCond < 0) {
                culledTrisWorldSpace[nextIx] = trisWorldSpace[i];
                culledTrisCols[nextIx] = trisCols[i];
                nextIx++;
            }
        }
        /// remove any empty slots
        uint256 nToCull = culledTrisWorldSpace.length - nextIx;
        /// cull uneeded tris
        assembly {
            mstore(
                culledTrisWorldSpace,
                sub(mload(culledTrisWorldSpace), nToCull)
            )
        }
        /// cull uneeded cols
        assembly {
            mstore(culledTrisCols, sub(mload(culledTrisCols), nToCull))
        }
    }

    /**@dev calculate verts in camera space */
    function convertToCameraSpaceViaVertexShader(
        int256[3][] memory vertsWorldSpace,
        int256 canvasDim,
        bool perspCamera
    ) external view returns (int256[3][] memory) {
        // get the camera matrix as a numerator and denominator
        int256[4][4][2] memory cameraMatrix;
        if (perspCamera) {
            cameraMatrix = getCameraMatrixPersp();
        } else {
            cameraMatrix = getCameraMatrixOrth(canvasDim);
        }

        int256[4][4] memory nM = cameraMatrix[0]; // camera matrix numerator
        int256[4][4] memory dM = cameraMatrix[1]; // camera matrix denominator

        int256[3][] memory verticesCameraSpace = new int256[3][](
            vertsWorldSpace.length
        );

        for (uint256 i = 0; i < vertsWorldSpace.length; i++) {
            // Convert from 3D to 4D homogenous coordinate system
            int256[3] memory vert = vertsWorldSpace[i];

            // Make a copy of vert ("homoVertex")
            int256[] memory hv = new int256[](vert.length + 1);

            for (uint256 j = 0; j < vert.length; j++) {
                hv[j] = vert[j];
            }

            // Insert 1 at final position in copy of vert
            hv[hv.length - 1] = 1;

            int256 x = ((hv[0] * nM[0][0]) / dM[0][0]) +
                ((hv[1] * nM[0][1]) / dM[0][1]) +
                ((hv[2] * nM[0][2]) / dM[0][2]) +
                (nM[0][3] / dM[0][3]);

            int256 y = ((hv[0] * nM[1][0]) / dM[1][0]) +
                ((hv[1] * nM[1][1]) / dM[1][1]) +
                ((hv[2] * nM[1][2]) / dM[1][2]) +
                (nM[1][3] / dM[1][0]);

            int256 z = ((hv[0] * nM[2][0]) / dM[2][0]) +
                ((hv[1] * nM[2][1]) / dM[2][1]) +
                ((hv[2] * nM[2][2]) / dM[2][2]) +
                (nM[2][3] / dM[2][3]);

            int256 w = ((hv[0] * nM[3][0]) / dM[3][0]) +
                ((hv[1] * nM[3][1]) / dM[3][1]) +
                ((hv[2] * nM[3][2]) / dM[3][2]) +
                (nM[3][3] / dM[3][3]);

            if (w != 1) {
                x = (x * 1e3) / w;
                y = (y * 1e3) / w;
                z = (z * 1e3) / w;
            }

            // Turn it back into a 3-vector
            // Add it to the ordered list
            verticesCameraSpace[i] = [x, y, z];
        }

        return verticesCameraSpace;
    }

    /** @dev generate an orthographic camera matrix */
    function getCameraMatrixOrth(int256 canvasDim)
        internal
        pure
        returns (int256[4][4][2] memory)
    {
        int256 canvasHalf = canvasDim / 2;

        // Left, right, top, bottom
        int256 r = ShackledMath.abs(canvasHalf);
        int256 l = -canvasHalf;
        int256 t = ShackledMath.abs(canvasHalf);
        int256 b = -canvasHalf;

        // Z settings (near and far)
        /// multiplied by 1e3
        int256 n = 1;
        int256 f = 1024;

        // Get the orthographic transform matrix
        // as a numerator and denominator

        int256[4][4] memory cameraMatrixNum = [
            [int256(2), 0, 0, -(r + l)],
            [int256(0), 2, 0, -(t + b)],
            [int256(0), 0, -2, -(f + n)],
            [int256(0), 0, 0, 1]
        ];

        int256[4][4] memory cameraMatrixDen = [
            [int256(r - l), 1, 1, (r - l)],
            [int256(1), (t - b), 1, (t - b)],
            [int256(1), 1, (f - n), (f - n)],
            [int256(1), 1, 1, 1]
        ];

        int256[4][4][2] memory cameraMatrix = [
            cameraMatrixNum,
            cameraMatrixDen
        ];

        return cameraMatrix;
    }

    /** @dev generate a perspective camera matrix */
    function getCameraMatrixPersp()
        internal
        pure
        returns (int256[4][4][2] memory)
    {
        // Z settings (near and far)
        /// multiplied by 1e3
        int256 n = 500;
        int256 f = 501;

        // Get the perspective transform matrix
        // as a numerator and denominator

        // parameter = 1 / tan(fov in degrees / 2)
        // 0.1763 = 1 / tan(160 / 2)
        // 1.428 = 1 / tan(70 / 2)
        // 1.732 = 1 / tan(60 / 2)
        // 2.145 = 1 / tan(50 / 2)

        int256[4][4] memory cameraMatrixNum = [
            [int256(2145), 0, 0, 0],
            [int256(0), 2145, 0, 0],
            [int256(0), 0, f, -f * n],
            [int256(0), 0, 1, 0]
        ];

        int256[4][4] memory cameraMatrixDen = [
            [int256(1000), 1, 1, 1],
            [int256(1), 1000, 1, 1],
            [int256(1), 1, f - n, f - n],
            [int256(1), 1, 1, 1]
        ];

        int256[4][4][2] memory cameraMatrix = [
            cameraMatrixNum,
            cameraMatrixDen
        ];

        return cameraMatrix;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./ShackledUtils.sol";
import "./ShackledMath.sol";
import "./ShackledStructs.sol";

library ShackledRasteriser {
    /// define some constant lighting parameters
    int256 constant fidelity = int256(100); /// an extra paramater to improve numeric resolution
    int256 constant lightAmbiPower = int256(1); // Base light colour // was 0.5
    int256 constant lightDiffPower = int256(3e9); // Diffused light on surface relative strength
    int256 constant lightSpecPower = int256(1e7); // Specular reflection on surface relative strength
    uint256 constant inverseShininess = 10; // 'sharpness' of specular light on surface

    /// define a scale factor to use in lerp to avoid rounding errors
    int256 constant lerpScaleFactor = 1e3;

    /// storing variables used in the fragment lighting
    struct LightingVars {
        int256[3] fragCol;
        int256[3] fragNorm;
        int256[3] fragPos;
        int256[3] V;
        int256 vMag;
        int256[3] N;
        int256 nMag;
        int256[3] L;
        int256 lMag;
        int256 falloff;
        int256 lnDot;
        int256 lambertian;
    }

    /// store variables used in Bresenham's line algorithm
    struct BresenhamsVars {
        int256 x;
        int256 y;
        int256 dx;
        int256 dy;
        int256 sx;
        int256 sy;
        int256 err;
        int256 e2;
    }

    /// store variables used when running the scanline algorithm
    struct ScanlineVars {
        int256 left;
        int256 right;
        int256[12] leftFrag;
        int256[12] rightFrag;
        int256 dx;
        int256 ir;
        int256 newFragRow;
        int256 newFragCol;
    }

    /** @dev initialise the fragments
        fragments are defined as:
        [
            canvas_x, canvas_y, depth,
            col_x, col_y, col_z,
            normal_x, normal_y, normal_z,
            world_x, world_y, world_z
        ]
        
     */
    function initialiseFragments(
        int256[3][3][] memory trisCameraSpace,
        int256[3][3][] memory trisWorldSpace,
        int256[3][3][] memory trisCols,
        int256 canvasDim
    ) external view returns (int256[12][3][] memory) {
        /// make an array containing the fragments of each triangle (groups of 3 frags)
        int256[12][3][] memory trisFragments = new int256[12][3][](
            trisCameraSpace.length
        );

        // First convert from camera space to screen space within each triangle
        for (uint256 t = 0; t < trisCameraSpace.length; t++) {
            int256[3][3] memory tri = trisCameraSpace[t];

            /// initialise an array for three fragments, each of len 9
            int256[12][3] memory triFragments;

            // First calculate the fragments that belong to defined vertices
            for (uint256 v = 0; v < 3; v++) {
                int256[12] memory fragment;

                // first convert to screen space
                // mapping from -1e3 -> 1e3 to account for the original geom being on order of 1e3
                fragment[0] = ShackledMath.mapRangeToRange(
                    tri[v][0],
                    -1e3,
                    1e3,
                    0,
                    canvasDim
                );
                fragment[1] = ShackledMath.mapRangeToRange(
                    tri[v][1],
                    -1e3,
                    1e3,
                    0,
                    canvasDim
                );

                fragment[2] = tri[v][2];

                // Now calculate the normal using the cross product of the edge vectors. This needs to be
                // done in world space coordinates
                int256[3] memory thisV = trisWorldSpace[t][(v + 0) % 3];
                int256[3] memory nextV = trisWorldSpace[t][(v + 1) % 3];
                int256[3] memory prevV = trisWorldSpace[t][(v + 2) % 3];

                int256[3] memory norm = ShackledMath.crossProduct(
                    ShackledMath.vector3Sub(prevV, thisV),
                    ShackledMath.vector3Sub(thisV, nextV)
                );

                // Now attach the colour (in 0 -> 255 space)
                fragment[3] = (trisCols[t][v][0]);
                fragment[4] = (trisCols[t][v][1]);
                fragment[5] = (trisCols[t][v][2]);

                // And the normal (inverted)
                fragment[6] = -norm[0];
                fragment[7] = -norm[1];
                fragment[8] = -norm[2];

                // And the world position of this vertex to the frag
                fragment[9] = thisV[0];
                fragment[10] = thisV[1];
                fragment[11] = thisV[2];

                // These are just the fragments attached to
                // the given vertices
                triFragments[v] = fragment;
            }

            trisFragments[t] = triFragments;
        }

        return trisFragments;
    }

    /** @dev rasterize fragments onto a canvas
     */
    function rasterise(
        int256[12][3][] memory trisFragments,
        int256 canvasDim,
        bool wireframe
    ) external view returns (int256[12][] memory) {
        /// determine the upper limits of the inner Bresenham's result
        uint256 canvasHypot = uint256(ShackledMath.hypot(canvasDim, canvasDim));

        /// initialise a new array
        /// for each trisFragments we will get 3 results from bresenhams
        /// maximum of 1 per pixel (canvasDim**2)
        int256[12][] memory fragments = new int256[12][](
            3 * uint256(canvasDim)**2
        );
        uint256 nextFragmentsIx = 0;

        for (uint256 t = 0; t < trisFragments.length; t++) {
            // prepare the variables required
            int256[12] memory fa;
            int256[12] memory fb;
            uint256 nextBresTriFragmentIx = 0;

            /// create an array to hold the bresenham results
            /// this may cause an out of bounds error if there are a very large number of fragments
            /// (e.g. many that are 'off screen')
            int256[12][] memory bresTriFragments = new int256[12][](
                canvasHypot * 10
            );

            // for each pair of fragments, run bresenhams and extend bresTriFragments with the output
            // this replaces the three push(...modified_bresenhams_algorhtm) statements in JS
            for (uint256 i = 0; i < 3; i++) {
                if (i == 0) {
                    fa = trisFragments[t][0];
                    fb = trisFragments[t][1];
                } else if (i == 1) {
                    fa = trisFragments[t][1];
                    fb = trisFragments[t][2];
                } else {
                    fa = trisFragments[t][2];
                    fb = trisFragments[t][0];
                }

                // run the bresenhams algorithm
                (
                    bresTriFragments,
                    nextBresTriFragmentIx
                ) = runBresenhamsAlgorithm(
                    fa,
                    fb,
                    canvasDim,
                    bresTriFragments,
                    nextBresTriFragmentIx
                );
            }

            bresTriFragments = ShackledUtils.clipArray12ToLength(
                bresTriFragments,
                nextBresTriFragmentIx
            );

            if (wireframe) {
                /// only store the edges
                for (uint256 j = 0; j < bresTriFragments.length; j++) {
                    fragments[nextFragmentsIx] = bresTriFragments[j];
                    nextFragmentsIx++;
                }
            } else {
                /// fill the triangle
                (fragments, nextFragmentsIx) = runScanline(
                    bresTriFragments,
                    fragments,
                    nextFragmentsIx,
                    canvasDim
                );
            }
        }

        fragments = ShackledUtils.clipArray12ToLength(
            fragments,
            nextFragmentsIx
        );

        return fragments;
    }

    /** @dev run Bresenham's line algorithm on a pair of fragments
     */
    function runBresenhamsAlgorithm(
        int256[12] memory f1,
        int256[12] memory f2,
        int256 canvasDim,
        int256[12][] memory bresTriFragments,
        uint256 nextBresTriFragmentIx
    ) internal view returns (int256[12][] memory, uint256) {
        /// initiate a new set of vars
        BresenhamsVars memory vars;

        int256[12] memory fa;
        int256[12] memory fb;

        /// determine which fragment has a greater magnitude
        /// and set it as the destination (always order a given pair of edges the same)
        if (
            (f1[0]**2 + f1[1]**2 + f1[2]**2) < (f2[0]**2 + f2[1]**2 + f2[2]**2)
        ) {
            fa = f1;
            fb = f2;
        } else {
            fa = f2;
            fb = f1;
        }

        vars.x = fa[0];
        vars.y = fa[1];

        vars.dx = ShackledMath.abs(fb[0] - fa[0]);
        vars.dy = -ShackledMath.abs(fb[1] - fa[1]);
        int256 mag = ShackledMath.hypot(vars.dx, -vars.dy);

        if (fa[0] < fb[0]) {
            vars.sx = 1;
        } else {
            vars.sx = -1;
        }

        if (fa[1] < fb[1]) {
            vars.sy = 1;
        } else {
            vars.sy = -1;
        }

        vars.err = vars.dx + vars.dy;
        vars.e2 = 0;

        // get the bresenhams output for this fragment pair (fa & fb)

        if (mag == 0) {
            bresTriFragments[nextBresTriFragmentIx] = fa;
            bresTriFragments[nextBresTriFragmentIx + 1] = fb;
            nextBresTriFragmentIx += 2;
        } else {
            // when mag is not 0,
            // the length of the result will be max of upperLimitInner
            // but will be clipped to remove any empty slots
            (bresTriFragments, nextBresTriFragmentIx) = bresenhamsInner(
                vars,
                mag,
                fa,
                fb,
                canvasDim,
                bresTriFragments,
                nextBresTriFragmentIx
            );
        }
        return (bresTriFragments, nextBresTriFragmentIx);
    }

    /** @dev run the inner loop of Bresenham's line algorithm on a pair of fragments
     * (preventing stack too deep)
     */
    function bresenhamsInner(
        BresenhamsVars memory vars,
        int256 mag,
        int256[12] memory fa,
        int256[12] memory fb,
        int256 canvasDim,
        int256[12][] memory bresTriFragments,
        uint256 nextBresTriFragmentIx
    ) internal view returns (int256[12][] memory, uint256) {
        // define variables to be used in the inner loop
        int256 ir;
        int256 h;

        /// loop through all fragments
        while (!(vars.x == fb[0] && vars.y == fb[1])) {
            /// get hypotenuse length of fragment a
            h = ShackledMath.hypot(fa[0] - vars.x, fa[1] - vars.y);
            assembly {
                ir := div(mul(lerpScaleFactor, h), mag)
            }

            // only add the fragment if it falls within the canvas

            /// create a new fragment by linear interpolation between a and b
            int256[12] memory newFragment = ShackledMath.vector12Lerp(
                fa,
                fb,
                ir,
                lerpScaleFactor
            );
            newFragment[0] = vars.x;
            newFragment[1] = vars.y;

            /// save this fragment
            bresTriFragments[nextBresTriFragmentIx] = newFragment;
            ++nextBresTriFragmentIx;

            /// update variables to use in next iteration
            vars.e2 = 2 * vars.err;
            if (vars.e2 >= vars.dy) {
                vars.err += vars.dy;
                vars.x += vars.sx;
            }
            if (vars.e2 <= vars.dx) {
                vars.err += vars.dx;
                vars.y += vars.sy;
            }
        }

        /// save fragment 2
        bresTriFragments[nextBresTriFragmentIx] = fb;
        ++nextBresTriFragmentIx;

        return (bresTriFragments, nextBresTriFragmentIx);
    }

    /** @dev run the scan line algorithm to fill the raster
     */
    function runScanline(
        int256[12][] memory bresTriFragments,
        int256[12][] memory fragments,
        uint256 nextFragmentsIx,
        int256 canvasDim
    ) internal view returns (int256[12][] memory, uint256) {
        /// make a 2d array with length = num of output rows

        (
            int256[][] memory rowFragIndices,
            uint256[] memory nextIxFragRows
        ) = getRowFragIndices(bresTriFragments, canvasDim);

        /// initialise a struct to hold the scanline vars
        ScanlineVars memory slVars;

        // Now iterate through the list of fragments that live in a single row
        for (uint256 i = 0; i < rowFragIndices.length; i++) {
            /// Get the left most fragment
            slVars.left = 4096;

            /// Get the right most fragment
            slVars.right = -4096;

            /// loop through the fragments in this row
            /// and check that a fragment was written to this row
            for (uint256 j = 0; j < nextIxFragRows[i]; j++) {
                /// What's the current fragment that we're looking at
                int256 fragX = bresTriFragments[uint256(rowFragIndices[i][j])][
                    0
                ];

                // if it's lefter than our current most left frag then its the new left frag
                if (fragX < slVars.left) {
                    slVars.left = fragX;
                    slVars.leftFrag = bresTriFragments[
                        uint256(rowFragIndices[i][j])
                    ];
                }
                // if it's righter than our current most right frag then its the new right frag
                if (fragX > slVars.right) {
                    slVars.right = fragX;
                    slVars.rightFrag = bresTriFragments[
                        uint256(rowFragIndices[i][j])
                    ];
                }
            }

            /// now we need to scan from the left to the right fragment
            /// and interpolate as we go
            slVars.dx = slVars.right - slVars.left + 1;

            /// get the row that we're on
            slVars.newFragRow = slVars.leftFrag[1];

            /// check that the new frag's row will be in the canvas bounds
            if (slVars.newFragRow >= 0 && slVars.newFragRow < canvasDim) {
                if (slVars.dx > int256(0)) {
                    for (int256 j = 0; j < slVars.dx; j++) {
                        /// calculate the column of the new fragment (its position in the scan)
                        slVars.newFragCol = slVars.leftFrag[0] + j;

                        /// check that the new frag's column will be in the canvas bounds
                        if (
                            slVars.newFragCol >= 0 &&
                            slVars.newFragCol < canvasDim
                        ) {
                            slVars.ir = (j * lerpScaleFactor) / slVars.dx;

                            /// make a new fragment by linear interpolation between left and right frags
                            fragments[nextFragmentsIx] = ShackledMath
                                .vector12Lerp(
                                    slVars.leftFrag,
                                    slVars.rightFrag,
                                    slVars.ir,
                                    lerpScaleFactor
                                );
                            /// update its position
                            fragments[nextFragmentsIx][0] = slVars.newFragCol;
                            fragments[nextFragmentsIx][1] = slVars.newFragRow;
                            nextFragmentsIx++;
                        }
                    }
                }
            }
        }

        return (fragments, nextFragmentsIx);
    }

    /** @dev get the row indices of each fragment in preparation for the scanline alg
     */
    function getRowFragIndices(
        int256[12][] memory bresTriFragments,
        int256 canvasDim
    )
        internal
        view
        returns (int256[][] memory, uint256[] memory nextIxFragRows)
    {
        uint256 canvasDimUnsigned = uint256(canvasDim);

        // define the length of each outer array so we can push items into it using nextIxFragRows
        int256[][] memory rowFragIndices = new int256[][](canvasDimUnsigned);

        // the inner rows can't be longer than bresTriFragments
        for (uint256 i = 0; i < canvasDimUnsigned; i++) {
            rowFragIndices[i] = new int256[](bresTriFragments.length);
        }

        // make an array the tracks for each row how many items have been pushed into it
        uint256[] memory nextIxFragRows = new uint256[](canvasDimUnsigned);

        for (uint256 f = 0; f < bresTriFragments.length; f++) {
            // get the row index
            uint256 rowIx = uint256(bresTriFragments[f][1]); // canvas_y

            if (rowIx >= 0 && rowIx < canvasDimUnsigned) {
                // get the ix of the next item to be added to the row

                rowFragIndices[rowIx][nextIxFragRows[rowIx]] = int256(f);
                ++nextIxFragRows[rowIx];
            }
        }
        return (rowFragIndices, nextIxFragRows);
    }

    /** @dev run depth-testing on all fragments
     */
    function depthTesting(int256[12][] memory fragments, int256 canvasDim)
        external
        view
        returns (int256[12][] memory)
    {
        uint256 canvasDimUnsigned = uint256(canvasDim);
        /// create a 2d array to hold the zValues of the fragments
        int256[][] memory zValues = ShackledMath.get2dArray(
            canvasDimUnsigned,
            canvasDimUnsigned,
            0
        );

        /// create a 2d array to hold the fragIndex of the fragments
        /// as their depth is compared
        int256[][] memory fragIndex = ShackledMath.get2dArray(
            canvasDimUnsigned,
            canvasDimUnsigned,
            -1 /// -1 so we can check if a fragment was written to this location
        );

        int256[12][] memory culledFrags = new int256[12][](fragments.length);
        uint256 nextFragIx = 0;

        /// iterate through all fragments
        /// and store the index of the fragment with the largest z value
        /// at each x, y coordinate

        for (uint256 i = 0; i < fragments.length; i++) {
            int256[12] memory frag = fragments[i];

            /// x and y must be uint for indexing
            uint256 fragX = uint256(frag[0]);
            uint256 fragY = uint256(frag[1]);

            // console.log("checking frag", i, "z:");
            // console.logInt(frag[2]);

            if (
                (fragX < canvasDimUnsigned) &&
                (fragY < canvasDimUnsigned) &&
                fragX >= 0 &&
                fragY >= 0
            ) {
                // if this is the first fragment seen at (fragX, fragY), ie if fragIndex == 0, add it
                // or if this frag is closer (lower z value) than the current frag at (fragX, fragY), add it
                if (
                    fragIndex[fragX][fragY] == -1 ||
                    frag[2] >= zValues[fragX][fragY]
                ) {
                    zValues[fragX][fragY] = frag[2];
                    fragIndex[fragX][fragY] = int256(i);
                }
            }
        }

        /// save only the fragments with prefered z values
        for (uint256 x = 0; x < canvasDimUnsigned; x++) {
            for (uint256 y = 0; y < canvasDimUnsigned; y++) {
                int256 fragIx = fragIndex[x][y];
                /// ensure we have a valid index
                if (fragIndex[x][y] != -1) {
                    culledFrags[nextFragIx] = fragments[uint256(fragIx)];
                    nextFragIx++;
                }
            }
        }

        return ShackledUtils.clipArray12ToLength(culledFrags, nextFragIx);
    }

    /** @dev apply lighting to the scene and update fragments accordingly
     */
    function lightScene(
        int256[12][] memory fragments,
        ShackledStructs.LightingParams memory lp
    ) external view returns (int256[12][] memory) {
        /// create a struct for the variables to prevent stack too deep
        LightingVars memory lv;

        // calculate a constant lighting vector and its magniture
        lv.L = lp.lightPos;
        lv.lMag = ShackledMath.vector3Len(lv.L);

        for (uint256 f = 0; f < fragments.length; f++) {
            /// get the fragment's color, norm and position
            lv.fragCol = [fragments[f][3], fragments[f][4], fragments[f][5]];
            lv.fragNorm = [fragments[f][6], fragments[f][7], fragments[f][8]];
            lv.fragPos = [fragments[f][9], fragments[f][10], fragments[f][11]];

            /// calculate the direction to camera / viewer and its magnitude
            lv.V = ShackledMath.vector3MulScalar(lv.fragPos, -1);
            lv.vMag = ShackledMath.vector3Len(lv.V);

            /// calculate the direction of the fragment normaland its magnitude
            lv.N = lv.fragNorm;
            lv.nMag = ShackledMath.vector3Len(lv.N);

            /// calculate the light vector per-fragment
            // lv.L = ShackledMath.vector3Sub(lp.lightPos, lv.fragPos);
            // lv.lMag = ShackledMath.vector3Len(lv.L);
            lv.falloff = lv.lMag**2; /// lighting intensity fall over the scene
            lv.lnDot = ShackledMath.vector3Dot(lv.L, lv.N);

            /// implement double-side rendering to account for flipped normals
            lv.lambertian = ShackledMath.abs(lv.lnDot);

            int256 specular;

            if (lv.lambertian > 0) {
                int256[3] memory normedL = ShackledMath.vector3NormX(
                    lv.L,
                    fidelity
                );
                int256[3] memory normedV = ShackledMath.vector3NormX(
                    lv.V,
                    fidelity
                );

                int256[3] memory H = ShackledMath.vector3Add(normedL, normedV);

                int256 hnDot = int256(
                    ShackledMath.vector3Dot(
                        ShackledMath.vector3NormX(H, fidelity),
                        ShackledMath.vector3NormX(lv.N, fidelity)
                    )
                );

                specular = calculateSpecular(
                    lp.lightSpecPower,
                    hnDot,
                    fidelity,
                    lp.inverseShininess
                );
            }

            // Calculate the colour and write it into the fragment
            int256[3] memory colAmbi = ShackledMath.vector3Add(
                lv.fragCol,
                ShackledMath.vector3MulScalar(
                    lp.lightColAmbi,
                    lp.lightAmbiPower
                )
            );

            /// finalise and color the diffuse lighting
            int256[3] memory colDiff = ShackledMath.vector3MulScalar(
                lp.lightColDiff,
                ((lp.lightDiffPower * lv.lambertian) / (lv.lMag * lv.nMag)) /
                    lv.falloff
            );

            /// finalise and color the specular lighting
            int256[3] memory colSpec = ShackledMath.vector3DivScalar(
                ShackledMath.vector3MulScalar(lp.lightColSpec, specular),
                lv.falloff
            );

            // add up the colour components
            int256[3] memory col = ShackledMath.vector3Add(
                ShackledMath.vector3Add(colAmbi, colDiff),
                colSpec
            );

            /// update the fragment's colour in place
            fragments[f][3] = col[0];
            fragments[f][4] = col[1];
            fragments[f][5] = col[2];
        }
        return fragments;
    }

    /** @dev calculate the specular lighting parameter */
    function calculateSpecular(
        int256 lightSpecPower,
        int256 hnDot,
        int256 fidelity,
        uint256 inverseShininess
    ) internal pure returns (int256 specular) {
        int256 specAngle = hnDot > int256(0) ? hnDot : int256(0);
        assembly {
            specular := sdiv(
                mul(lightSpecPower, exp(specAngle, inverseShininess)),
                exp(fidelity, mul(inverseShininess, 2))
            )
        }
    }

    /** @dev get background gradient that fills the canvas */
    function getBackground(
        int256 canvasDim,
        int256[3][2] memory backgroundColor
    ) external view returns (int256[5][] memory) {
        int256[5][] memory background = new int256[5][](uint256(canvasDim**2));

        int256 w = canvasDim;
        uint256 nextIx = 0;

        for (int256 i = 0; i < canvasDim; i++) {
            for (int256 j = 0; j < canvasDim; j++) {
                // / write coordinates of background pixel
                background[nextIx][0] = j; /// x
                background[nextIx][1] = i; /// y

                // / write colours of background pixel
                // / get weighted average of top and bottom color according to row (i)
                background[nextIx][2] = /// r
                    ((backgroundColor[0][0] * i) +
                        (backgroundColor[1][0] * (w - i))) /
                    w;

                background[nextIx][3] = /// g
                    ((backgroundColor[0][1] * i) +
                        (backgroundColor[1][1] * (w - i))) /
                    w;

                background[nextIx][4] = /// b
                    ((backgroundColor[0][2] * i) +
                        (backgroundColor[1][2] * (w - i))) /
                    w;

                ++nextIx;
            }
        }
        return background;
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

import "./ShackledStructs.sol";

library ShackledUtils {
    string internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /** @dev Flatten 3d tris array into 2d verts */
    function flattenTris(int256[3][3][] memory tris)
        internal
        pure
        returns (int256[3][] memory)
    {
        /// initialize a dynamic in-memory array
        int256[3][] memory flattened = new int256[3][](3 * tris.length);

        for (uint256 i = 0; i < tris.length; i++) {
            /// tris.length == N
            // add values to specific index, as cannot push to array in memory
            flattened[(i * 3) + 0] = tris[i][0];
            flattened[(i * 3) + 1] = tris[i][1];
            flattened[(i * 3) + 2] = tris[i][2];
        }
        return flattened;
    }

    /** @dev Unflatten 2d verts array into 3d tries (inverse of flattenTris function) */
    function unflattenVertsToTris(int256[3][] memory verts)
        internal
        pure
        returns (int256[3][3][] memory)
    {
        /// initialize an array with length = 1/3 length of verts
        int256[3][3][] memory tris = new int256[3][3][](verts.length / 3);

        for (uint256 i = 0; i < verts.length; i += 3) {
            tris[i / 3] = [verts[i], verts[i + 1], verts[i + 2]];
        }
        return tris;
    }

    /** @dev clip an array to a certain length (to trim empty tail slots) */
    function clipArray12ToLength(int256[12][] memory arr, uint256 desiredLen)
        internal
        pure
        returns (int256[12][] memory)
    {
        uint256 nToCull = arr.length - desiredLen;
        assembly {
            mstore(arr, sub(mload(arr), nToCull))
        }
        return arr;
    }

    /** @dev convert an unsigned int to a string */
    function uint2str(uint256 _i)
        internal
        pure
        returns (string memory _uintAsString)
    {
        if (_i == 0) {
            return "0";
        }
        uint256 j = _i;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint256 k = len;
        while (_i != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(_i - (_i / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    /** @dev get the hex encoding of various powers of 2 (canvas size options) */
    function getHex(uint256 _i) internal pure returns (bytes memory _hex) {
        if (_i == 8) {
            return hex"08_00_00_00";
        } else if (_i == 16) {
            return hex"10_00_00_00";
        } else if (_i == 32) {
            return hex"20_00_00_00";
        } else if (_i == 64) {
            return hex"40_00_00_00";
        } else if (_i == 128) {
            return hex"80_00_00_00";
        } else if (_i == 256) {
            return hex"00_01_00_00";
        } else if (_i == 512) {
            return hex"00_02_00_00";
        }
    }

    /** @dev create an svg container for a bitmap (for display on svg-only platforms) */
    function getSVGContainer(
        string memory encodedBitmap,
        int256 canvasDim,
        uint256 outputHeight,
        uint256 outputWidth
    ) internal view returns (string memory) {
        uint256 canvasDimUnsigned = uint256(canvasDim);
        // construct some elements in memory prior to return string to avoid stack too deep
        bytes memory imgSize = abi.encodePacked(
            "width='",
            ShackledUtils.uint2str(canvasDimUnsigned),
            "' height='",
            ShackledUtils.uint2str(canvasDimUnsigned),
            "'"
        );
        bytes memory canvasSize = abi.encodePacked(
            "width='",
            ShackledUtils.uint2str(outputWidth),
            "' height='",
            ShackledUtils.uint2str(outputHeight),
            "'"
        );
        bytes memory scaleStartTag = abi.encodePacked(
            "<g transform='scale(",
            ShackledUtils.uint2str(outputWidth / canvasDimUnsigned),
            ")'>"
        );

        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            "<svg xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink' ",
                            "shape-rendering='crispEdges' ",
                            canvasSize,
                            ">",
                            scaleStartTag,
                            "<image ",
                            imgSize,
                            " style='image-rendering: pixelated; image-rendering: crisp-edges;' ",
                            "href='",
                            encodedBitmap,
                            "'/></g></svg>"
                        )
                    )
                )
            );
    }

    /** @dev converts raw metadata into */
    function getAttributes(ShackledStructs.Metadata memory metadata)
        internal
        pure
        returns (bytes memory)
    {
        return
            abi.encodePacked(
                "{",
                '"Structure": "',
                metadata.geomSpec,
                '", "Chroma": "',
                metadata.colorScheme,
                '", "Pseudosymmetry": "',
                metadata.pseudoSymmetry,
                '", "Wireframe": "',
                metadata.wireframe,
                '", "Inversion": "',
                metadata.inversion,
                '", "Prisms": "',
                uint2str(metadata.nPrisms),
                '"}'
            );
    }

    /** @dev create and encode the token's metadata */
    function getEncodedMetadata(
        string memory image,
        ShackledStructs.Metadata memory metadata,
        uint256 tokenId
    ) internal view returns (string memory) {
        /// get attributes and description here to avoid stack too deep
        string
            memory description = '"description": "Shackled is the first general-purpose 3D renderer'
            " running on the Ethereum blockchain."
            ' Each piece represents a leap forward in on-chain computer graphics, and the collection itself is an NFT first."';
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        bytes(
                            string(
                                abi.encodePacked(
                                    '{"name": "Shackled Genesis #',
                                    uint2str(tokenId),
                                    '", ',
                                    description,
                                    ', "attributes":',
                                    getAttributes(metadata),
                                    ', "image":"',
                                    image,
                                    '"}'
                                )
                            )
                        )
                    )
                )
            );
    }

    // fragment =
    // [ canvas_x, canvas_y, depth, col_x, col_y, col_z, normal_x, normal_y, normal_z, world_x, world_y, world_z ],
    /** @dev get an encoded 2d bitmap by combining the object and background fragments */
    function getEncodedBitmap(
        int256[12][] memory fragments,
        int256[5][] memory background,
        int256 canvasDim,
        bool invert
    ) internal view returns (string memory) {
        uint256 canvasDimUnsigned = uint256(canvasDim);
        bytes memory fileHeader = abi.encodePacked(
            hex"42_4d", // BM
            hex"36_04_00_00", // size of the bitmap file in bytes (14 (file header) + 40 (info header) + size of raw data (1024))
            hex"00_00_00_00", // 2x2 bytes reserved
            hex"36_00_00_00" // offset of pixels in bytes
        );
        bytes memory infoHeader = abi.encodePacked(
            hex"28_00_00_00", // size of the header in bytes (40)
            getHex(canvasDimUnsigned), // width in pixels 32
            getHex(canvasDimUnsigned), // height in pixels 32
            hex"01_00", // number of color plans (must be 1)
            hex"18_00", // number of bits per pixel (24)
            hex"00_00_00_00", // type of compression (none)
            hex"00_04_00_00", // size of the raw bitmap data (1024)
            hex"C4_0E_00_00", // horizontal resolution
            hex"C4_0E_00_00", // vertical resolution
            hex"00_00_00_00", // number of used colours
            hex"05_00_00_00" // number of important colours
        );
        bytes memory headers = abi.encodePacked(fileHeader, infoHeader);

        /// create a container for the bitmap's bytes
        bytes memory bytesArray = new bytes(3 * canvasDimUnsigned**2);

        /// write the background first so it is behind the fragments
        bytesArray = writeBackgroundToBytesArray(
            background,
            bytesArray,
            canvasDimUnsigned,
            invert
        );
        bytesArray = writeFragmentsToBytesArray(
            fragments,
            bytesArray,
            canvasDimUnsigned,
            invert
        );

        return
            string(
                abi.encodePacked(
                    "data:image/bmp;base64,",
                    Base64.encode(BytesUtils.MergeBytes(headers, bytesArray))
                )
            );
    }

    /** @dev write the fragments to the bytes array */
    function writeFragmentsToBytesArray(
        int256[12][] memory fragments,
        bytes memory bytesArray,
        uint256 canvasDimUnsigned,
        bool invert
    ) internal pure returns (bytes memory) {
        /// loop through each fragment
        /// and write it's color into bytesArray in its canvas equivelant position
        for (uint256 i = 0; i < fragments.length; i++) {
            /// check if x and y are both greater than 0
            if (
                uint256(fragments[i][0]) >= 0 && uint256(fragments[i][1]) >= 0
            ) {
                /// calculating the starting bytesArray ix for this fragment's colors
                uint256 flatIx = ((canvasDimUnsigned -
                    uint256(fragments[i][1]) -
                    1) *
                    canvasDimUnsigned +
                    (canvasDimUnsigned - uint256(fragments[i][0]) - 1)) * 3;

                /// red
                uint256 r = fragments[i][3] > 255
                    ? 255
                    : uint256(fragments[i][3]);

                /// green
                uint256 g = fragments[i][4] > 255
                    ? 255
                    : uint256(fragments[i][4]);

                /// blue
                uint256 b = fragments[i][5] > 255
                    ? 255
                    : uint256(fragments[i][5]);

                if (invert) {
                    r = 255 - r;
                    g = 255 - g;
                    b = 255 - b;
                }

                bytesArray[flatIx + 0] = bytes1(uint8(b));
                bytesArray[flatIx + 1] = bytes1(uint8(g));
                bytesArray[flatIx + 2] = bytes1(uint8(r));
            }
        }
        return bytesArray;
    }

    /** @dev write the fragments to the bytes array 
    using a separate function from above to account for variable input size
    */
    function writeBackgroundToBytesArray(
        int256[5][] memory background,
        bytes memory bytesArray,
        uint256 canvasDimUnsigned,
        bool invert
    ) internal pure returns (bytes memory) {
        /// loop through each fragment
        /// and write it's color into bytesArray in its canvas equivelant position
        for (uint256 i = 0; i < background.length; i++) {
            /// check if x and y are both greater than 0
            if (
                uint256(background[i][0]) >= 0 && uint256(background[i][1]) >= 0
            ) {
                /// calculating the starting bytesArray ix for this fragment's colors
                uint256 flatIx = (uint256(background[i][1]) *
                    canvasDimUnsigned +
                    uint256(background[i][0])) * 3;

                // red
                uint256 r = background[i][2] > 255
                    ? 255
                    : uint256(background[i][2]);

                /// green
                uint256 g = background[i][3] > 255
                    ? 255
                    : uint256(background[i][3]);

                // blue
                uint256 b = background[i][4] > 255
                    ? 255
                    : uint256(background[i][4]);

                if (invert) {
                    r = 255 - r;
                    g = 255 - g;
                    b = 255 - b;
                }

                bytesArray[flatIx + 0] = bytes1(uint8(b));
                bytesArray[flatIx + 1] = bytes1(uint8(g));
                bytesArray[flatIx + 2] = bytes1(uint8(r));
            }
        }
        return bytesArray;
    }
}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <[email protected]>
library Base64 {
    bytes internal constant TABLE =
        "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal view returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF)
                )
                out := shl(8, out)
                out := add(
                    out,
                    and(mload(add(tablePtr, and(input, 0x3F))), 0xFF)
                )
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}

library BytesUtils {
    function char(bytes1 b) internal view returns (bytes1 c) {
        if (uint8(b) < 10) return bytes1(uint8(b) + 0x30);
        else return bytes1(uint8(b) + 0x57);
    }

    function bytes32string(bytes32 b32)
        internal
        view
        returns (string memory out)
    {
        bytes memory s = new bytes(64);
        for (uint32 i = 0; i < 32; i++) {
            bytes1 b = bytes1(b32[i]);
            bytes1 hi = bytes1(uint8(b) / 16);
            bytes1 lo = bytes1(uint8(b) - 16 * uint8(hi));
            s[i * 2] = char(hi);
            s[i * 2 + 1] = char(lo);
        }
        out = string(s);
    }

    function hach(string memory value) internal view returns (string memory) {
        return bytes32string(sha256(abi.encodePacked(value)));
    }

    function MergeBytes(bytes memory a, bytes memory b)
        internal
        pure
        returns (bytes memory c)
    {
        // Store the length of the first array
        uint256 alen = a.length;
        // Store the length of BOTH arrays
        uint256 totallen = alen + b.length;
        // Count the loops required for array a (sets of 32 bytes)
        uint256 loopsa = (a.length + 31) / 32;
        // Count the loops required for array b (sets of 32 bytes)
        uint256 loopsb = (b.length + 31) / 32;
        assembly {
            let m := mload(0x40)
            // Load the length of both arrays to the head of the new bytes array
            mstore(m, totallen)
            // Add the contents of a to the array
            for {
                let i := 0
            } lt(i, loopsa) {
                i := add(1, i)
            } {
                mstore(
                    add(m, mul(32, add(1, i))),
                    mload(add(a, mul(32, add(1, i))))
                )
            }
            // Add the contents of b to the array
            for {
                let i := 0
            } lt(i, loopsb) {
                i := add(1, i)
            } {
                mstore(
                    add(m, add(mul(32, add(1, i)), alen)),
                    mload(add(b, mul(32, add(1, i))))
                )
            }
            mstore(0x40, add(m, add(32, totallen)))
            c := m
        }
    }
}

// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

library ShackledStructs {
    struct Metadata {
        string colorScheme; /// name of the color scheme
        string geomSpec; /// name of the geometry specification
        uint256 nPrisms; /// number of prisms made
        string pseudoSymmetry; /// horizontal, vertical, diagonal
        string wireframe; /// enabled or disabled
        string inversion; /// enabled or disabled
    }

    struct RenderParams {
        uint256[3][] faces; /// index of verts and colorss used for each face (triangle)
        int256[3][] verts; /// x, y, z coordinates used in the geometry
        int256[3][] cols; /// colors of each vert
        int256[3] objPosition; /// position to place the object
        int256 objScale; /// scalar for the object
        int256[3][2] backgroundColor; /// color of the background (gradient)
        LightingParams lightingParams; /// parameters for the lighting
        bool perspCamera; /// true = perspective camera, false = orthographic
        bool backfaceCulling; /// whether to implement backface culling (saves gas!)
        bool invert; /// whether to invert colors in the final encoding stage
        bool wireframe; /// whether to only render edges
    }

    /// struct for testing lighting
    struct LightingParams {
        bool applyLighting; /// true = apply lighting, false = don't apply lighting
        int256 lightAmbiPower; /// power of the ambient light
        int256 lightDiffPower; /// power of the diffuse light
        int256 lightSpecPower; /// power of the specular light
        uint256 inverseShininess; /// shininess of the material
        int256[3] lightPos; /// position of the light
        int256[3] lightColSpec; /// color of the specular light
        int256[3] lightColDiff; /// color of the diffuse light
        int256[3] lightColAmbi; /// color of the ambient light
    }
}

// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

library ShackledMath {
    /** @dev Get the minimum of two numbers */
    function min(int256 a, int256 b) internal pure returns (int256) {
        return a < b ? a : b;
    }

    /** @dev Get the maximum of two numbers */
    function max(int256 a, int256 b) internal pure returns (int256) {
        return a > b ? a : b;
    }

    /** @dev perform a modulo operation, with support for negative numbers */
    function mod(int256 n, int256 m) internal pure returns (int256) {
        if (n < 0) {
            return ((n % m) + m) % m;
        } else {
            return n % m;
        }
    }

    /** @dev 'randomly' select n numbers between 0 and m 
    (useful for getting a randomly sampled index)
    */
    function randomIdx(
        bytes32 seedModifier,
        uint256 n, // number of elements to select
        uint256 m // max value of elements
    ) internal pure returns (uint256[] memory) {
        uint256[] memory result = new uint256[](n);
        for (uint256 i = 0; i < n; i++) {
            result[i] =
                uint256(keccak256(abi.encodePacked(seedModifier, i))) %
                m;
        }
        return result;
    }

    /** @dev create a 2d array and fill with a single value */
    function get2dArray(
        uint256 m,
        uint256 q,
        int256 value
    ) internal pure returns (int256[][] memory) {
        /// Create a matrix of values with dimensions (m, q)
        int256[][] memory rows = new int256[][](m);
        for (uint256 i = 0; i < m; i++) {
            int256[] memory row = new int256[](q);
            for (uint256 j = 0; j < q; j++) {
                row[j] = value;
            }
            rows[i] = row;
        }
        return rows;
    }

    /** @dev get the absolute of a number
     */
    function abs(int256 x) internal pure returns (int256) {
        assembly {
            if slt(x, 0) {
                x := sub(0, x)
            }
        }
        return x;
    }

    /** @dev get the square root of a number
     */
    function sqrt(int256 y) internal pure returns (int256 z) {
        assembly {
            if sgt(y, 3) {
                z := y
                let x := add(div(y, 2), 1)
                for {

                } slt(x, z) {

                } {
                    z := x
                    x := div(add(div(y, x), x), 2)
                }
            }
            if and(slt(y, 4), sgt(y, 0)) {
                z := 1
            }
        }
    }

    /** @dev get the hypotenuse of a triangle given the length of 2 sides
     */
    function hypot(int256 x, int256 y) internal pure returns (int256) {
        int256 sumsq;
        assembly {
            let xsq := mul(x, x)
            let ysq := mul(y, y)
            sumsq := add(xsq, ysq)
        }

        return sqrt(sumsq);
    }

    /** @dev addition between two vectors (size 3)
     */
    function vector3Add(int256[3] memory v1, int256[3] memory v2)
        internal
        pure
        returns (int256[3] memory result)
    {
        assembly {
            mstore(result, add(mload(v1), mload(v2)))
            mstore(
                add(result, 0x20),
                add(mload(add(v1, 0x20)), mload(add(v2, 0x20)))
            )
            mstore(
                add(result, 0x40),
                add(mload(add(v1, 0x40)), mload(add(v2, 0x40)))
            )
        }
    }

    /** @dev subtraction between two vectors (size 3)
     */
    function vector3Sub(int256[3] memory v1, int256[3] memory v2)
        internal
        pure
        returns (int256[3] memory result)
    {
        assembly {
            mstore(result, sub(mload(v1), mload(v2)))
            mstore(
                add(result, 0x20),
                sub(mload(add(v1, 0x20)), mload(add(v2, 0x20)))
            )
            mstore(
                add(result, 0x40),
                sub(mload(add(v1, 0x40)), mload(add(v2, 0x40)))
            )
        }
    }

    /** @dev multiply a vector (size 3) by a constant
     */
    function vector3MulScalar(int256[3] memory v, int256 a)
        internal
        pure
        returns (int256[3] memory result)
    {
        assembly {
            mstore(result, mul(mload(v), a))
            mstore(add(result, 0x20), mul(mload(add(v, 0x20)), a))
            mstore(add(result, 0x40), mul(mload(add(v, 0x40)), a))
        }
    }

    /** @dev divide a vector (size 3) by a constant
     */
    function vector3DivScalar(int256[3] memory v, int256 a)
        internal
        pure
        returns (int256[3] memory result)
    {
        assembly {
            mstore(result, sdiv(mload(v), a))
            mstore(add(result, 0x20), sdiv(mload(add(v, 0x20)), a))
            mstore(add(result, 0x40), sdiv(mload(add(v, 0x40)), a))
        }
    }

    /** @dev get the length of a vector (size 3)
     */
    function vector3Len(int256[3] memory v) internal pure returns (int256) {
        int256 res;
        assembly {
            let x := mload(v)
            let y := mload(add(v, 0x20))
            let z := mload(add(v, 0x40))
            res := add(add(mul(x, x), mul(y, y)), mul(z, z))
        }
        return sqrt(res);
    }

    /** @dev scale and then normalise a vector (size 3)
     */
    function vector3NormX(int256[3] memory v, int256 fidelity)
        internal
        pure
        returns (int256[3] memory result)
    {
        int256 l = vector3Len(v);
        assembly {
            mstore(result, sdiv(mul(fidelity, mload(add(v, 0x40))), l))
            mstore(
                add(result, 0x20),
                sdiv(mul(fidelity, mload(add(v, 0x20))), l)
            )
            mstore(add(result, 0x40), sdiv(mul(fidelity, mload(v)), l))
        }
    }

    /** @dev get the dot-product of two vectors (size 3)
     */
    function vector3Dot(int256[3] memory v1, int256[3] memory v2)
        internal
        view
        returns (int256 result)
    {
        assembly {
            result := add(
                add(
                    mul(mload(v1), mload(v2)),
                    mul(mload(add(v1, 0x20)), mload(add(v2, 0x20)))
                ),
                mul(mload(add(v1, 0x40)), mload(add(v2, 0x40)))
            )
        }
    }

    /** @dev get the cross product of two vectors (size 3)
     */
    function crossProduct(int256[3] memory v1, int256[3] memory v2)
        internal
        pure
        returns (int256[3] memory result)
    {
        assembly {
            mstore(
                result,
                sub(
                    mul(mload(add(v1, 0x20)), mload(add(v2, 0x40))),
                    mul(mload(add(v1, 0x40)), mload(add(v2, 0x20)))
                )
            )
            mstore(
                add(result, 0x20),
                sub(
                    mul(mload(add(v1, 0x40)), mload(v2)),
                    mul(mload(v1), mload(add(v2, 0x40)))
                )
            )
            mstore(
                add(result, 0x40),
                sub(
                    mul(mload(v1), mload(add(v2, 0x20))),
                    mul(mload(add(v1, 0x20)), mload(v2))
                )
            )
        }
    }

    /** @dev linearly interpolate between two vectors (size 12)
     */
    function vector12Lerp(
        int256[12] memory v1,
        int256[12] memory v2,
        int256 ir,
        int256 scaleFactor
    ) internal view returns (int256[12] memory result) {
        int256[12] memory vd = vector12Sub(v2, v1);
        // loop through all 12 items
        assembly {
            let ix
            for {
                let i := 0
            } lt(i, 0xC) {
                // (i < 12)
                i := add(i, 1)
            } {
                /// get index of the next element
                ix := mul(i, 0x20)

                /// store into the result array
                mstore(
                    add(result, ix),
                    add(
                        // v1[i] + (ir * vd[i]) / 1e3
                        mload(add(v1, ix)),
                        sdiv(mul(ir, mload(add(vd, ix))), 1000)
                    )
                )
            }
        }
    }

    /** @dev subtraction between two vectors (size 12)
     */
    function vector12Sub(int256[12] memory v1, int256[12] memory v2)
        internal
        view
        returns (int256[12] memory result)
    {
        // loop through all 12 items
        assembly {
            let ix
            for {
                let i := 0
            } lt(i, 0xC) {
                // (i < 12)
                i := add(i, 1)
            } {
                /// get index of the next element
                ix := mul(i, 0x20)
                /// store into the result array
                mstore(
                    add(result, ix),
                    sub(
                        // v1[ix] - v2[ix]
                        mload(add(v1, ix)),
                        mload(add(v2, ix))
                    )
                )
            }
        }
    }

    /** @dev map a number from one range into another
     */
    function mapRangeToRange(
        int256 num,
        int256 inMin,
        int256 inMax,
        int256 outMin,
        int256 outMax
    ) internal pure returns (int256 res) {
        assembly {
            res := add(
                sdiv(
                    mul(sub(outMax, outMin), sub(num, inMin)),
                    sub(inMax, inMin)
                ),
                outMin
            )
        }
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../contracts/ShackledCoords.sol";

contract XShackledCoords {
    constructor() {}

    function xconvertToWorldSpaceWithModelTransform(int256[3][3][] calldata tris,int256 scale,int256[3] calldata position) external view returns (int256[3][] memory) {
        return ShackledCoords.convertToWorldSpaceWithModelTransform(tris,scale,position);
    }

    function xbackfaceCulling(int256[3][3][] calldata trisWorldSpace,int256[3][3][] calldata trisCols) external view returns (int256[3][3][] memory, int256[3][3][] memory) {
        return ShackledCoords.backfaceCulling(trisWorldSpace,trisCols);
    }

    function xconvertToCameraSpaceViaVertexShader(int256[3][] calldata vertsWorldSpace,int256 canvasDim,bool perspCamera) external view returns (int256[3][] memory) {
        return ShackledCoords.convertToCameraSpaceViaVertexShader(vertsWorldSpace,canvasDim,perspCamera);
    }

    function xgetCameraMatrixOrth(int256 canvasDim) external pure returns (int256[4][4][2] memory) {
        return ShackledCoords.getCameraMatrixOrth(canvasDim);
    }

    function xgetCameraMatrixPersp() external pure returns (int256[4][4][2] memory) {
        return ShackledCoords.getCameraMatrixPersp();
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../contracts/ShackledMath.sol";

contract XShackledMath {
    constructor() {}

    function xmin(int256 a,int256 b) external pure returns (int256) {
        return ShackledMath.min(a,b);
    }

    function xmax(int256 a,int256 b) external pure returns (int256) {
        return ShackledMath.max(a,b);
    }

    function xmod(int256 n,int256 m) external pure returns (int256) {
        return ShackledMath.mod(n,m);
    }

    function xrandomIdx(bytes32 seedModifier,uint256 n,uint256 m) external pure returns (uint256[] memory) {
        return ShackledMath.randomIdx(seedModifier,n,m);
    }

    function xget2dArray(uint256 m,uint256 q,int256 value) external pure returns (int256[][] memory) {
        return ShackledMath.get2dArray(m,q,value);
    }

    function xabs(int256 x) external pure returns (int256) {
        return ShackledMath.abs(x);
    }

    function xsqrt(int256 y) external pure returns (int256) {
        return ShackledMath.sqrt(y);
    }

    function xhypot(int256 x,int256 y) external pure returns (int256) {
        return ShackledMath.hypot(x,y);
    }

    function xvector3Add(int256[3] calldata v1,int256[3] calldata v2) external pure returns (int256[3] memory) {
        return ShackledMath.vector3Add(v1,v2);
    }

    function xvector3Sub(int256[3] calldata v1,int256[3] calldata v2) external pure returns (int256[3] memory) {
        return ShackledMath.vector3Sub(v1,v2);
    }

    function xvector3MulScalar(int256[3] calldata v,int256 a) external pure returns (int256[3] memory) {
        return ShackledMath.vector3MulScalar(v,a);
    }

    function xvector3DivScalar(int256[3] calldata v,int256 a) external pure returns (int256[3] memory) {
        return ShackledMath.vector3DivScalar(v,a);
    }

    function xvector3Len(int256[3] calldata v) external pure returns (int256) {
        return ShackledMath.vector3Len(v);
    }

    function xvector3NormX(int256[3] calldata v,int256 fidelity) external pure returns (int256[3] memory) {
        return ShackledMath.vector3NormX(v,fidelity);
    }

    function xvector3Dot(int256[3] calldata v1,int256[3] calldata v2) external view returns (int256) {
        return ShackledMath.vector3Dot(v1,v2);
    }

    function xcrossProduct(int256[3] calldata v1,int256[3] calldata v2) external pure returns (int256[3] memory) {
        return ShackledMath.crossProduct(v1,v2);
    }

    function xvector12Lerp(int256[12] calldata v1,int256[12] calldata v2,int256 ir,int256 scaleFactor) external view returns (int256[12] memory) {
        return ShackledMath.vector12Lerp(v1,v2,ir,scaleFactor);
    }

    function xvector12Sub(int256[12] calldata v1,int256[12] calldata v2) external view returns (int256[12] memory) {
        return ShackledMath.vector12Sub(v1,v2);
    }

    function xmapRangeToRange(int256 num,int256 inMin,int256 inMax,int256 outMin,int256 outMax) external pure returns (int256) {
        return ShackledMath.mapRangeToRange(num,inMin,inMax,outMin,outMax);
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../contracts/ShackledRasteriser.sol";

contract XShackledRasteriser {
    constructor() {}

    function xinitialiseFragments(int256[3][3][] calldata trisCameraSpace,int256[3][3][] calldata trisWorldSpace,int256[3][3][] calldata trisCols,int256 canvasDim) external view returns (int256[12][3][] memory) {
        return ShackledRasteriser.initialiseFragments(trisCameraSpace,trisWorldSpace,trisCols,canvasDim);
    }

    function xrasterise(int256[12][3][] calldata trisFragments,int256 canvasDim,bool wireframe) external view returns (int256[12][] memory) {
        return ShackledRasteriser.rasterise(trisFragments,canvasDim,wireframe);
    }

    function xrunBresenhamsAlgorithm(int256[12] calldata f1,int256[12] calldata f2,int256 canvasDim,int256[12][] calldata bresTriFragments,uint256 nextBresTriFragmentIx) external view returns (int256[12][] memory, uint256) {
        return ShackledRasteriser.runBresenhamsAlgorithm(f1,f2,canvasDim,bresTriFragments,nextBresTriFragmentIx);
    }

    function xbresenhamsInner(ShackledRasteriser.BresenhamsVars calldata vars,int256 mag,int256[12] calldata fa,int256[12] calldata fb,int256 canvasDim,int256[12][] calldata bresTriFragments,uint256 nextBresTriFragmentIx) external view returns (int256[12][] memory, uint256) {
        return ShackledRasteriser.bresenhamsInner(vars,mag,fa,fb,canvasDim,bresTriFragments,nextBresTriFragmentIx);
    }

    function xrunScanline(int256[12][] calldata bresTriFragments,int256[12][] calldata fragments,uint256 nextFragmentsIx,int256 canvasDim) external view returns (int256[12][] memory, uint256) {
        return ShackledRasteriser.runScanline(bresTriFragments,fragments,nextFragmentsIx,canvasDim);
    }

    function xgetRowFragIndices(int256[12][] calldata bresTriFragments,int256 canvasDim) external view returns (int256[][] memory, uint256[] memory) {
        return ShackledRasteriser.getRowFragIndices(bresTriFragments,canvasDim);
    }

    function xdepthTesting(int256[12][] calldata fragments,int256 canvasDim) external view returns (int256[12][] memory) {
        return ShackledRasteriser.depthTesting(fragments,canvasDim);
    }

    function xlightScene(int256[12][] calldata fragments,ShackledStructs.LightingParams calldata lp) external view returns (int256[12][] memory) {
        return ShackledRasteriser.lightScene(fragments,lp);
    }

    function xcalculateSpecular(int256 lightSpecPower,int256 hnDot,int256 fidelity,uint256 inverseShininess) external pure returns (int256) {
        return ShackledRasteriser.calculateSpecular(lightSpecPower,hnDot,fidelity,inverseShininess);
    }

    function xgetBackground(int256 canvasDim,int256[3][2] calldata backgroundColor) external view returns (int256[5][] memory) {
        return ShackledRasteriser.getBackground(canvasDim,backgroundColor);
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../contracts/ShackledRenderer.sol";

contract XShackledRenderer {
    constructor() {}

    function xrender(ShackledStructs.RenderParams calldata renderParams,int256 canvasDim,bool returnSVG) external view returns (string memory) {
        return ShackledRenderer.render(renderParams,canvasDim,returnSVG);
    }

    function xprepareGeometryForRender(ShackledStructs.RenderParams calldata renderParams,int256 canvasDim) external view returns (int256[12][3][] memory) {
        return ShackledRenderer.prepareGeometryForRender(renderParams,canvasDim);
    }
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../contracts/ShackledStructs.sol";

contract XShackledStructs {
    constructor() {}
}

// SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.6.0;

import "../contracts/ShackledUtils.sol";

contract XShackledUtils {
    constructor() {}

    function xflattenTris(int256[3][3][] calldata tris) external pure returns (int256[3][] memory) {
        return ShackledUtils.flattenTris(tris);
    }

    function xunflattenVertsToTris(int256[3][] calldata verts) external pure returns (int256[3][3][] memory) {
        return ShackledUtils.unflattenVertsToTris(verts);
    }

    function xclipArray12ToLength(int256[12][] calldata arr,uint256 desiredLen) external pure returns (int256[12][] memory) {
        return ShackledUtils.clipArray12ToLength(arr,desiredLen);
    }

    function xuint2str(uint256 _i) external pure returns (string memory) {
        return ShackledUtils.uint2str(_i);
    }

    function xgetHex(uint256 _i) external pure returns (bytes memory) {
        return ShackledUtils.getHex(_i);
    }

    function xgetSVGContainer(string calldata encodedBitmap,int256 canvasDim,uint256 outputHeight,uint256 outputWidth) external view returns (string memory) {
        return ShackledUtils.getSVGContainer(encodedBitmap,canvasDim,outputHeight,outputWidth);
    }

    function xgetAttributes(ShackledStructs.Metadata calldata metadata) external pure returns (bytes memory) {
        return ShackledUtils.getAttributes(metadata);
    }

    function xgetEncodedMetadata(string calldata image,ShackledStructs.Metadata calldata metadata,uint256 tokenId) external view returns (string memory) {
        return ShackledUtils.getEncodedMetadata(image,metadata,tokenId);
    }

    function xgetEncodedBitmap(int256[12][] calldata fragments,int256[5][] calldata background,int256 canvasDim,bool invert) external view returns (string memory) {
        return ShackledUtils.getEncodedBitmap(fragments,background,canvasDim,invert);
    }

    function xwriteFragmentsToBytesArray(int256[12][] calldata fragments,bytes calldata bytesArray,uint256 canvasDimUnsigned,bool invert) external pure returns (bytes memory) {
        return ShackledUtils.writeFragmentsToBytesArray(fragments,bytesArray,canvasDimUnsigned,invert);
    }

    function xwriteBackgroundToBytesArray(int256[5][] calldata background,bytes calldata bytesArray,uint256 canvasDimUnsigned,bool invert) external pure returns (bytes memory) {
        return ShackledUtils.writeBackgroundToBytesArray(background,bytesArray,canvasDimUnsigned,invert);
    }
}

contract XBase64 {
    constructor() {}

    function xencode(bytes calldata data) external view returns (string memory) {
        return Base64.encode(data);
    }
}

contract XBytesUtils {
    constructor() {}

    function xchar(bytes1 b) external view returns (bytes1) {
        return BytesUtils.char(b);
    }

    function xbytes32string(bytes32 b32) external view returns (string memory) {
        return BytesUtils.bytes32string(b32);
    }

    function xhach(string calldata value) external view returns (string memory) {
        return BytesUtils.hach(value);
    }

    function xMergeBytes(bytes calldata a,bytes calldata b) external pure returns (bytes memory) {
        return BytesUtils.MergeBytes(a,b);
    }
}