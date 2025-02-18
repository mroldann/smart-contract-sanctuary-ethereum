/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

abstract contract CairoVerifierContract {
    function verifyProofExternal(
        uint256[] calldata proofParams,
        uint256[] calldata proof,
        uint256[] calldata publicInput
    ) external virtual;

    /*
      Returns information that is related to the layout.

      publicMemoryOffset is the offset of the public memory pages' information in the public input.
      selectedBuiltins is a bit-map of builtins that are present in the layout.
    */
    function getLayoutInfo()
        external
        pure
        virtual
        returns (uint256 publicMemoryOffset, uint256 selectedBuiltins);

    uint256 internal constant OUTPUT_BUILTIN_BIT = 0;
    uint256 internal constant PEDERSEN_BUILTIN_BIT = 1;
    uint256 internal constant RANGE_CHECK_BUILTIN_BIT = 2;
    uint256 internal constant ECDSA_BUILTIN_BIT = 3;
    uint256 internal constant BITWISE_BUILTIN_BIT = 4;
    uint256 internal constant EC_OP_BUILTIN_BIT = 5;
    uint256 internal constant KECCAK_BUILTIN_BIT = 6;
    uint256 internal constant POSEIDON_BUILTIN_BIT = 7;
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// ---------- The following code was auto-generated. PLEASE DO NOT EDIT. ----------
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

contract CpuConstraintPoly {
    // The Memory map during the execution of this contract is as follows:
    // [0x0, 0x20) - periodic_column/pedersen/points/x.
    // [0x20, 0x40) - periodic_column/pedersen/points/y.
    // [0x40, 0x60) - periodic_column/ecdsa/generator_points/x.
    // [0x60, 0x80) - periodic_column/ecdsa/generator_points/y.
    // [0x80, 0xa0) - periodic_column/poseidon/poseidon/full_round_key0.
    // [0xa0, 0xc0) - periodic_column/poseidon/poseidon/full_round_key1.
    // [0xc0, 0xe0) - periodic_column/poseidon/poseidon/full_round_key2.
    // [0xe0, 0x100) - periodic_column/poseidon/poseidon/partial_round_key0.
    // [0x100, 0x120) - periodic_column/poseidon/poseidon/partial_round_key1.
    // [0x120, 0x140) - trace_length.
    // [0x140, 0x160) - offset_size.
    // [0x160, 0x180) - half_offset_size.
    // [0x180, 0x1a0) - initial_ap.
    // [0x1a0, 0x1c0) - initial_pc.
    // [0x1c0, 0x1e0) - final_ap.
    // [0x1e0, 0x200) - final_pc.
    // [0x200, 0x220) - memory/multi_column_perm/perm/interaction_elm.
    // [0x220, 0x240) - memory/multi_column_perm/hash_interaction_elm0.
    // [0x240, 0x260) - memory/multi_column_perm/perm/public_memory_prod.
    // [0x260, 0x280) - rc16/perm/interaction_elm.
    // [0x280, 0x2a0) - rc16/perm/public_memory_prod.
    // [0x2a0, 0x2c0) - rc_min.
    // [0x2c0, 0x2e0) - rc_max.
    // [0x2e0, 0x300) - diluted_check/permutation/interaction_elm.
    // [0x300, 0x320) - diluted_check/permutation/public_memory_prod.
    // [0x320, 0x340) - diluted_check/first_elm.
    // [0x340, 0x360) - diluted_check/interaction_z.
    // [0x360, 0x380) - diluted_check/interaction_alpha.
    // [0x380, 0x3a0) - diluted_check/final_cum_val.
    // [0x3a0, 0x3c0) - pedersen/shift_point.x.
    // [0x3c0, 0x3e0) - pedersen/shift_point.y.
    // [0x3e0, 0x400) - initial_pedersen_addr.
    // [0x400, 0x420) - initial_rc_addr.
    // [0x420, 0x440) - ecdsa/sig_config.alpha.
    // [0x440, 0x460) - ecdsa/sig_config.shift_point.x.
    // [0x460, 0x480) - ecdsa/sig_config.shift_point.y.
    // [0x480, 0x4a0) - ecdsa/sig_config.beta.
    // [0x4a0, 0x4c0) - initial_ecdsa_addr.
    // [0x4c0, 0x4e0) - initial_bitwise_addr.
    // [0x4e0, 0x500) - initial_ec_op_addr.
    // [0x500, 0x520) - ec_op/curve_config.alpha.
    // [0x520, 0x540) - initial_poseidon_addr.
    // [0x540, 0x560) - trace_generator.
    // [0x560, 0x580) - oods_point.
    // [0x580, 0x640) - interaction_elements.
    // [0x640, 0x660) - composition_alpha.
    // [0x660, 0x2800) - oods_values.
    // ----------------------- end of input data - -------------------------
    // [0x2800, 0x2820) - intermediate_value/cpu/decode/opcode_rc/bit_0.
    // [0x2820, 0x2840) - intermediate_value/cpu/decode/opcode_rc/bit_2.
    // [0x2840, 0x2860) - intermediate_value/cpu/decode/opcode_rc/bit_4.
    // [0x2860, 0x2880) - intermediate_value/cpu/decode/opcode_rc/bit_3.
    // [0x2880, 0x28a0) - intermediate_value/cpu/decode/flag_op1_base_op0_0.
    // [0x28a0, 0x28c0) - intermediate_value/cpu/decode/opcode_rc/bit_5.
    // [0x28c0, 0x28e0) - intermediate_value/cpu/decode/opcode_rc/bit_6.
    // [0x28e0, 0x2900) - intermediate_value/cpu/decode/opcode_rc/bit_9.
    // [0x2900, 0x2920) - intermediate_value/cpu/decode/flag_res_op1_0.
    // [0x2920, 0x2940) - intermediate_value/cpu/decode/opcode_rc/bit_7.
    // [0x2940, 0x2960) - intermediate_value/cpu/decode/opcode_rc/bit_8.
    // [0x2960, 0x2980) - intermediate_value/cpu/decode/flag_pc_update_regular_0.
    // [0x2980, 0x29a0) - intermediate_value/cpu/decode/opcode_rc/bit_12.
    // [0x29a0, 0x29c0) - intermediate_value/cpu/decode/opcode_rc/bit_13.
    // [0x29c0, 0x29e0) - intermediate_value/cpu/decode/fp_update_regular_0.
    // [0x29e0, 0x2a00) - intermediate_value/cpu/decode/opcode_rc/bit_1.
    // [0x2a00, 0x2a20) - intermediate_value/npc_reg_0.
    // [0x2a20, 0x2a40) - intermediate_value/cpu/decode/opcode_rc/bit_10.
    // [0x2a40, 0x2a60) - intermediate_value/cpu/decode/opcode_rc/bit_11.
    // [0x2a60, 0x2a80) - intermediate_value/cpu/decode/opcode_rc/bit_14.
    // [0x2a80, 0x2aa0) - intermediate_value/memory/address_diff_0.
    // [0x2aa0, 0x2ac0) - intermediate_value/rc16/diff_0.
    // [0x2ac0, 0x2ae0) - intermediate_value/pedersen/hash0/ec_subset_sum/bit_0.
    // [0x2ae0, 0x2b00) - intermediate_value/pedersen/hash0/ec_subset_sum/bit_neg_0.
    // [0x2b00, 0x2b20) - intermediate_value/rc_builtin/value0_0.
    // [0x2b20, 0x2b40) - intermediate_value/rc_builtin/value1_0.
    // [0x2b40, 0x2b60) - intermediate_value/rc_builtin/value2_0.
    // [0x2b60, 0x2b80) - intermediate_value/rc_builtin/value3_0.
    // [0x2b80, 0x2ba0) - intermediate_value/rc_builtin/value4_0.
    // [0x2ba0, 0x2bc0) - intermediate_value/rc_builtin/value5_0.
    // [0x2bc0, 0x2be0) - intermediate_value/rc_builtin/value6_0.
    // [0x2be0, 0x2c00) - intermediate_value/rc_builtin/value7_0.
    // [0x2c00, 0x2c20) - intermediate_value/ecdsa/signature0/doubling_key/x_squared.
    // [0x2c20, 0x2c40) - intermediate_value/ecdsa/signature0/exponentiate_generator/bit_0.
    // [0x2c40, 0x2c60) - intermediate_value/ecdsa/signature0/exponentiate_generator/bit_neg_0.
    // [0x2c60, 0x2c80) - intermediate_value/ecdsa/signature0/exponentiate_key/bit_0.
    // [0x2c80, 0x2ca0) - intermediate_value/ecdsa/signature0/exponentiate_key/bit_neg_0.
    // [0x2ca0, 0x2cc0) - intermediate_value/bitwise/sum_var_0_0.
    // [0x2cc0, 0x2ce0) - intermediate_value/bitwise/sum_var_8_0.
    // [0x2ce0, 0x2d00) - intermediate_value/ec_op/doubling_q/x_squared_0.
    // [0x2d00, 0x2d20) - intermediate_value/ec_op/ec_subset_sum/bit_0.
    // [0x2d20, 0x2d40) - intermediate_value/ec_op/ec_subset_sum/bit_neg_0.
    // [0x2d40, 0x2d60) - intermediate_value/poseidon/poseidon/full_rounds_state0_cubed_0.
    // [0x2d60, 0x2d80) - intermediate_value/poseidon/poseidon/full_rounds_state1_cubed_0.
    // [0x2d80, 0x2da0) - intermediate_value/poseidon/poseidon/full_rounds_state2_cubed_0.
    // [0x2da0, 0x2dc0) - intermediate_value/poseidon/poseidon/full_rounds_state0_cubed_7.
    // [0x2dc0, 0x2de0) - intermediate_value/poseidon/poseidon/full_rounds_state1_cubed_7.
    // [0x2de0, 0x2e00) - intermediate_value/poseidon/poseidon/full_rounds_state2_cubed_7.
    // [0x2e00, 0x2e20) - intermediate_value/poseidon/poseidon/full_rounds_state0_cubed_3.
    // [0x2e20, 0x2e40) - intermediate_value/poseidon/poseidon/full_rounds_state1_cubed_3.
    // [0x2e40, 0x2e60) - intermediate_value/poseidon/poseidon/full_rounds_state2_cubed_3.
    // [0x2e60, 0x2e80) - intermediate_value/poseidon/poseidon/partial_rounds_state0_cubed_0.
    // [0x2e80, 0x2ea0) - intermediate_value/poseidon/poseidon/partial_rounds_state0_cubed_1.
    // [0x2ea0, 0x2ec0) - intermediate_value/poseidon/poseidon/partial_rounds_state0_cubed_2.
    // [0x2ec0, 0x2ee0) - intermediate_value/poseidon/poseidon/partial_rounds_state1_cubed_0.
    // [0x2ee0, 0x2f00) - intermediate_value/poseidon/poseidon/partial_rounds_state1_cubed_1.
    // [0x2f00, 0x2f20) - intermediate_value/poseidon/poseidon/partial_rounds_state1_cubed_2.
    // [0x2f20, 0x2f40) - intermediate_value/poseidon/poseidon/partial_rounds_state1_cubed_19.
    // [0x2f40, 0x2f60) - intermediate_value/poseidon/poseidon/partial_rounds_state1_cubed_20.
    // [0x2f60, 0x2f80) - intermediate_value/poseidon/poseidon/partial_rounds_state1_cubed_21.
    // [0x2f80, 0x3640) - expmods.
    // [0x3640, 0x3b60) - domains.
    // [0x3b60, 0x3ea0) - denominator_invs.
    // [0x3ea0, 0x41e0) - denominators.
    // [0x41e0, 0x42a0) - expmod_context.

    fallback() external {
        uint256 res;
        assembly {
            let PRIME := 0x800000000000011000000000000000000000000000000000000000000000001
            // Copy input from calldata to memory.
            calldatacopy(0x0, 0x0, /*Input data size*/ 0x2800)
            let point := /*oods_point*/ mload(0x560)
            function expmod(base, exponent, modulus) -> result {
              let p := /*expmod_context*/ 0x41e0
              mstore(p, 0x20)                 // Length of Base.
              mstore(add(p, 0x20), 0x20)      // Length of Exponent.
              mstore(add(p, 0x40), 0x20)      // Length of Modulus.
              mstore(add(p, 0x60), base)      // Base.
              mstore(add(p, 0x80), exponent)  // Exponent.
              mstore(add(p, 0xa0), modulus)   // Modulus.
              // Call modexp precompile.
              if iszero(staticcall(not(0), 0x05, p, 0xc0, p, 0x20)) {
                revert(0, 0)
              }
              result := mload(p)
            }
            {
              // Prepare expmods for denominators and numerators.

              // expmods[0] = point^(trace_length / 32768).
              mstore(0x2f80, expmod(point, div(/*trace_length*/ mload(0x120), 32768), PRIME))

              // expmods[1] = point^(trace_length / 16384).
              mstore(0x2fa0, mulmod(
                /*point^(trace_length / 32768)*/ mload(0x2f80),
                /*point^(trace_length / 32768)*/ mload(0x2f80),
                PRIME))

              // expmods[2] = point^(trace_length / 1024).
              mstore(0x2fc0, expmod(point, div(/*trace_length*/ mload(0x120), 1024), PRIME))

              // expmods[3] = point^(trace_length / 512).
              mstore(0x2fe0, mulmod(
                /*point^(trace_length / 1024)*/ mload(0x2fc0),
                /*point^(trace_length / 1024)*/ mload(0x2fc0),
                PRIME))

              // expmods[4] = point^(trace_length / 256).
              mstore(0x3000, mulmod(
                /*point^(trace_length / 512)*/ mload(0x2fe0),
                /*point^(trace_length / 512)*/ mload(0x2fe0),
                PRIME))

              // expmods[5] = point^(trace_length / 128).
              mstore(0x3020, mulmod(
                /*point^(trace_length / 256)*/ mload(0x3000),
                /*point^(trace_length / 256)*/ mload(0x3000),
                PRIME))

              // expmods[6] = point^(trace_length / 64).
              mstore(0x3040, mulmod(
                /*point^(trace_length / 128)*/ mload(0x3020),
                /*point^(trace_length / 128)*/ mload(0x3020),
                PRIME))

              // expmods[7] = point^(trace_length / 16).
              mstore(0x3060, expmod(point, div(/*trace_length*/ mload(0x120), 16), PRIME))

              // expmods[8] = point^(trace_length / 8).
              mstore(0x3080, mulmod(
                /*point^(trace_length / 16)*/ mload(0x3060),
                /*point^(trace_length / 16)*/ mload(0x3060),
                PRIME))

              // expmods[9] = point^(trace_length / 4).
              mstore(0x30a0, mulmod(
                /*point^(trace_length / 8)*/ mload(0x3080),
                /*point^(trace_length / 8)*/ mload(0x3080),
                PRIME))

              // expmods[10] = point^(trace_length / 2).
              mstore(0x30c0, mulmod(
                /*point^(trace_length / 4)*/ mload(0x30a0),
                /*point^(trace_length / 4)*/ mload(0x30a0),
                PRIME))

              // expmods[11] = point^trace_length.
              mstore(0x30e0, mulmod(
                /*point^(trace_length / 2)*/ mload(0x30c0),
                /*point^(trace_length / 2)*/ mload(0x30c0),
                PRIME))

              // expmods[12] = trace_generator^(trace_length / 64).
              mstore(0x3100, expmod(/*trace_generator*/ mload(0x540), div(/*trace_length*/ mload(0x120), 64), PRIME))

              // expmods[13] = trace_generator^(trace_length / 32).
              mstore(0x3120, mulmod(
                /*trace_generator^(trace_length / 64)*/ mload(0x3100),
                /*trace_generator^(trace_length / 64)*/ mload(0x3100),
                PRIME))

              // expmods[14] = trace_generator^(3 * trace_length / 64).
              mstore(0x3140, mulmod(
                /*trace_generator^(trace_length / 64)*/ mload(0x3100),
                /*trace_generator^(trace_length / 32)*/ mload(0x3120),
                PRIME))

              // expmods[15] = trace_generator^(trace_length / 16).
              mstore(0x3160, mulmod(
                /*trace_generator^(trace_length / 64)*/ mload(0x3100),
                /*trace_generator^(3 * trace_length / 64)*/ mload(0x3140),
                PRIME))

              // expmods[16] = trace_generator^(5 * trace_length / 64).
              mstore(0x3180, mulmod(
                /*trace_generator^(trace_length / 64)*/ mload(0x3100),
                /*trace_generator^(trace_length / 16)*/ mload(0x3160),
                PRIME))

              // expmods[17] = trace_generator^(3 * trace_length / 32).
              mstore(0x31a0, mulmod(
                /*trace_generator^(trace_length / 64)*/ mload(0x3100),
                /*trace_generator^(5 * trace_length / 64)*/ mload(0x3180),
                PRIME))

              // expmods[18] = trace_generator^(7 * trace_length / 64).
              mstore(0x31c0, mulmod(
                /*trace_generator^(trace_length / 64)*/ mload(0x3100),
                /*trace_generator^(3 * trace_length / 32)*/ mload(0x31a0),
                PRIME))

              // expmods[19] = trace_generator^(trace_length / 8).
              mstore(0x31e0, mulmod(
                /*trace_generator^(trace_length / 64)*/ mload(0x3100),
                /*trace_generator^(7 * trace_length / 64)*/ mload(0x31c0),
                PRIME))

              // expmods[20] = trace_generator^(9 * trace_length / 64).
              mstore(0x3200, mulmod(
                /*trace_generator^(trace_length / 64)*/ mload(0x3100),
                /*trace_generator^(trace_length / 8)*/ mload(0x31e0),
                PRIME))

              // expmods[21] = trace_generator^(5 * trace_length / 32).
              mstore(0x3220, mulmod(
                /*trace_generator^(trace_length / 64)*/ mload(0x3100),
                /*trace_generator^(9 * trace_length / 64)*/ mload(0x3200),
                PRIME))

              // expmods[22] = trace_generator^(11 * trace_length / 64).
              mstore(0x3240, mulmod(
                /*trace_generator^(trace_length / 64)*/ mload(0x3100),
                /*trace_generator^(5 * trace_length / 32)*/ mload(0x3220),
                PRIME))

              // expmods[23] = trace_generator^(3 * trace_length / 16).
              mstore(0x3260, mulmod(
                /*trace_generator^(trace_length / 64)*/ mload(0x3100),
                /*trace_generator^(11 * trace_length / 64)*/ mload(0x3240),
                PRIME))

              // expmods[24] = trace_generator^(13 * trace_length / 64).
              mstore(0x3280, mulmod(
                /*trace_generator^(trace_length / 64)*/ mload(0x3100),
                /*trace_generator^(3 * trace_length / 16)*/ mload(0x3260),
                PRIME))

              // expmods[25] = trace_generator^(7 * trace_length / 32).
              mstore(0x32a0, mulmod(
                /*trace_generator^(trace_length / 64)*/ mload(0x3100),
                /*trace_generator^(13 * trace_length / 64)*/ mload(0x3280),
                PRIME))

              // expmods[26] = trace_generator^(15 * trace_length / 64).
              mstore(0x32c0, mulmod(
                /*trace_generator^(trace_length / 64)*/ mload(0x3100),
                /*trace_generator^(7 * trace_length / 32)*/ mload(0x32a0),
                PRIME))

              // expmods[27] = trace_generator^(trace_length / 2).
              mstore(0x32e0, expmod(/*trace_generator*/ mload(0x540), div(/*trace_length*/ mload(0x120), 2), PRIME))

              // expmods[28] = trace_generator^(19 * trace_length / 32).
              mstore(0x3300, mulmod(
                /*trace_generator^(3 * trace_length / 32)*/ mload(0x31a0),
                /*trace_generator^(trace_length / 2)*/ mload(0x32e0),
                PRIME))

              // expmods[29] = trace_generator^(5 * trace_length / 8).
              mstore(0x3320, mulmod(
                /*trace_generator^(trace_length / 32)*/ mload(0x3120),
                /*trace_generator^(19 * trace_length / 32)*/ mload(0x3300),
                PRIME))

              // expmods[30] = trace_generator^(21 * trace_length / 32).
              mstore(0x3340, mulmod(
                /*trace_generator^(trace_length / 32)*/ mload(0x3120),
                /*trace_generator^(5 * trace_length / 8)*/ mload(0x3320),
                PRIME))

              // expmods[31] = trace_generator^(11 * trace_length / 16).
              mstore(0x3360, mulmod(
                /*trace_generator^(trace_length / 32)*/ mload(0x3120),
                /*trace_generator^(21 * trace_length / 32)*/ mload(0x3340),
                PRIME))

              // expmods[32] = trace_generator^(23 * trace_length / 32).
              mstore(0x3380, mulmod(
                /*trace_generator^(trace_length / 32)*/ mload(0x3120),
                /*trace_generator^(11 * trace_length / 16)*/ mload(0x3360),
                PRIME))

              // expmods[33] = trace_generator^(3 * trace_length / 4).
              mstore(0x33a0, mulmod(
                /*trace_generator^(trace_length / 32)*/ mload(0x3120),
                /*trace_generator^(23 * trace_length / 32)*/ mload(0x3380),
                PRIME))

              // expmods[34] = trace_generator^(25 * trace_length / 32).
              mstore(0x33c0, mulmod(
                /*trace_generator^(trace_length / 32)*/ mload(0x3120),
                /*trace_generator^(3 * trace_length / 4)*/ mload(0x33a0),
                PRIME))

              // expmods[35] = trace_generator^(13 * trace_length / 16).
              mstore(0x33e0, mulmod(
                /*trace_generator^(trace_length / 32)*/ mload(0x3120),
                /*trace_generator^(25 * trace_length / 32)*/ mload(0x33c0),
                PRIME))

              // expmods[36] = trace_generator^(27 * trace_length / 32).
              mstore(0x3400, mulmod(
                /*trace_generator^(trace_length / 32)*/ mload(0x3120),
                /*trace_generator^(13 * trace_length / 16)*/ mload(0x33e0),
                PRIME))

              // expmods[37] = trace_generator^(7 * trace_length / 8).
              mstore(0x3420, mulmod(
                /*trace_generator^(trace_length / 32)*/ mload(0x3120),
                /*trace_generator^(27 * trace_length / 32)*/ mload(0x3400),
                PRIME))

              // expmods[38] = trace_generator^(29 * trace_length / 32).
              mstore(0x3440, mulmod(
                /*trace_generator^(trace_length / 32)*/ mload(0x3120),
                /*trace_generator^(7 * trace_length / 8)*/ mload(0x3420),
                PRIME))

              // expmods[39] = trace_generator^(15 * trace_length / 16).
              mstore(0x3460, mulmod(
                /*trace_generator^(trace_length / 32)*/ mload(0x3120),
                /*trace_generator^(29 * trace_length / 32)*/ mload(0x3440),
                PRIME))

              // expmods[40] = trace_generator^(61 * trace_length / 64).
              mstore(0x3480, mulmod(
                /*trace_generator^(trace_length / 64)*/ mload(0x3100),
                /*trace_generator^(15 * trace_length / 16)*/ mload(0x3460),
                PRIME))

              // expmods[41] = trace_generator^(31 * trace_length / 32).
              mstore(0x34a0, mulmod(
                /*trace_generator^(trace_length / 64)*/ mload(0x3100),
                /*trace_generator^(61 * trace_length / 64)*/ mload(0x3480),
                PRIME))

              // expmods[42] = trace_generator^(251 * trace_length / 256).
              mstore(0x34c0, expmod(/*trace_generator*/ mload(0x540), div(mul(251, /*trace_length*/ mload(0x120)), 256), PRIME))

              // expmods[43] = trace_generator^(63 * trace_length / 64).
              mstore(0x34e0, mulmod(
                /*trace_generator^(trace_length / 64)*/ mload(0x3100),
                /*trace_generator^(31 * trace_length / 32)*/ mload(0x34a0),
                PRIME))

              // expmods[44] = trace_generator^(255 * trace_length / 256).
              mstore(0x3500, mulmod(
                /*trace_generator^(trace_length / 64)*/ mload(0x3100),
                /*trace_generator^(251 * trace_length / 256)*/ mload(0x34c0),
                PRIME))

              // expmods[45] = trace_generator^(16 * (trace_length / 16 - 1)).
              mstore(0x3520, expmod(/*trace_generator*/ mload(0x540), mul(16, sub(div(/*trace_length*/ mload(0x120), 16), 1)), PRIME))

              // expmods[46] = trace_generator^(2 * (trace_length / 2 - 1)).
              mstore(0x3540, expmod(/*trace_generator*/ mload(0x540), mul(2, sub(div(/*trace_length*/ mload(0x120), 2), 1)), PRIME))

              // expmods[47] = trace_generator^(4 * (trace_length / 4 - 1)).
              mstore(0x3560, expmod(/*trace_generator*/ mload(0x540), mul(4, sub(div(/*trace_length*/ mload(0x120), 4), 1)), PRIME))

              // expmods[48] = trace_generator^(8 * (trace_length / 8 - 1)).
              mstore(0x3580, expmod(/*trace_generator*/ mload(0x540), mul(8, sub(div(/*trace_length*/ mload(0x120), 8), 1)), PRIME))

              // expmods[49] = trace_generator^(512 * (trace_length / 512 - 1)).
              mstore(0x35a0, expmod(/*trace_generator*/ mload(0x540), mul(512, sub(div(/*trace_length*/ mload(0x120), 512), 1)), PRIME))

              // expmods[50] = trace_generator^(256 * (trace_length / 256 - 1)).
              mstore(0x35c0, expmod(/*trace_generator*/ mload(0x540), mul(256, sub(div(/*trace_length*/ mload(0x120), 256), 1)), PRIME))

              // expmods[51] = trace_generator^(32768 * (trace_length / 32768 - 1)).
              mstore(0x35e0, expmod(/*trace_generator*/ mload(0x540), mul(32768, sub(div(/*trace_length*/ mload(0x120), 32768), 1)), PRIME))

              // expmods[52] = trace_generator^(1024 * (trace_length / 1024 - 1)).
              mstore(0x3600, expmod(/*trace_generator*/ mload(0x540), mul(1024, sub(div(/*trace_length*/ mload(0x120), 1024), 1)), PRIME))

              // expmods[53] = trace_generator^(16384 * (trace_length / 16384 - 1)).
              mstore(0x3620, expmod(/*trace_generator*/ mload(0x540), mul(16384, sub(div(/*trace_length*/ mload(0x120), 16384), 1)), PRIME))

            }

            {
              // Compute domains.

              // Denominator for constraints: 'cpu/decode/opcode_rc/bit', 'pedersen/hash0/ec_subset_sum/booleanity_test', 'pedersen/hash0/ec_subset_sum/add_points/slope', 'pedersen/hash0/ec_subset_sum/add_points/x', 'pedersen/hash0/ec_subset_sum/add_points/y', 'pedersen/hash0/ec_subset_sum/copy_point/x', 'pedersen/hash0/ec_subset_sum/copy_point/y'.
              // domains[0] = point^trace_length - 1.
              mstore(0x3640,
                     addmod(/*point^trace_length*/ mload(0x30e0), sub(PRIME, 1), PRIME))

              // Denominator for constraints: 'memory/multi_column_perm/perm/step0', 'memory/diff_is_bit', 'memory/is_func'.
              // domains[1] = point^(trace_length / 2) - 1.
              mstore(0x3660,
                     addmod(/*point^(trace_length / 2)*/ mload(0x30c0), sub(PRIME, 1), PRIME))

              // Denominator for constraints: 'rc16/perm/step0', 'rc16/diff_is_bit'.
              // domains[2] = point^(trace_length / 4) - 1.
              mstore(0x3680,
                     addmod(/*point^(trace_length / 4)*/ mload(0x30a0), sub(PRIME, 1), PRIME))

              // Denominator for constraints: 'public_memory_addr_zero', 'public_memory_value_zero', 'diluted_check/permutation/step0', 'diluted_check/step', 'poseidon/poseidon/partial_rounds_state0_squaring', 'poseidon/poseidon/partial_round0'.
              // domains[3] = point^(trace_length / 8) - 1.
              mstore(0x36a0,
                     addmod(/*point^(trace_length / 8)*/ mload(0x3080), sub(PRIME, 1), PRIME))

              // Denominator for constraints: 'cpu/decode/opcode_rc/zero'.
              // Numerator for constraints: 'cpu/decode/opcode_rc/bit'.
              // domains[4] = point^(trace_length / 16) - trace_generator^(15 * trace_length / 16).
              mstore(0x36c0,
                     addmod(
                       /*point^(trace_length / 16)*/ mload(0x3060),
                       sub(PRIME, /*trace_generator^(15 * trace_length / 16)*/ mload(0x3460)),
                       PRIME))

              // Denominator for constraints: 'cpu/decode/opcode_rc_input', 'cpu/decode/flag_op1_base_op0_bit', 'cpu/decode/flag_res_op1_bit', 'cpu/decode/flag_pc_update_regular_bit', 'cpu/decode/fp_update_regular_bit', 'cpu/operands/mem_dst_addr', 'cpu/operands/mem0_addr', 'cpu/operands/mem1_addr', 'cpu/operands/ops_mul', 'cpu/operands/res', 'cpu/update_registers/update_pc/tmp0', 'cpu/update_registers/update_pc/tmp1', 'cpu/update_registers/update_pc/pc_cond_negative', 'cpu/update_registers/update_pc/pc_cond_positive', 'cpu/update_registers/update_ap/ap_update', 'cpu/update_registers/update_fp/fp_update', 'cpu/opcodes/call/push_fp', 'cpu/opcodes/call/push_pc', 'cpu/opcodes/call/off0', 'cpu/opcodes/call/off1', 'cpu/opcodes/call/flags', 'cpu/opcodes/ret/off0', 'cpu/opcodes/ret/off2', 'cpu/opcodes/ret/flags', 'cpu/opcodes/assert_eq/assert_eq', 'poseidon/poseidon/partial_rounds_state1_squaring', 'poseidon/poseidon/partial_round1'.
              // domains[5] = point^(trace_length / 16) - 1.
              mstore(0x36e0,
                     addmod(/*point^(trace_length / 16)*/ mload(0x3060), sub(PRIME, 1), PRIME))

              // Denominator for constraints: 'ecdsa/signature0/doubling_key/slope', 'ecdsa/signature0/doubling_key/x', 'ecdsa/signature0/doubling_key/y', 'ecdsa/signature0/exponentiate_key/booleanity_test', 'ecdsa/signature0/exponentiate_key/add_points/slope', 'ecdsa/signature0/exponentiate_key/add_points/x', 'ecdsa/signature0/exponentiate_key/add_points/y', 'ecdsa/signature0/exponentiate_key/add_points/x_diff_inv', 'ecdsa/signature0/exponentiate_key/copy_point/x', 'ecdsa/signature0/exponentiate_key/copy_point/y', 'ec_op/doubling_q/slope', 'ec_op/doubling_q/x', 'ec_op/doubling_q/y', 'ec_op/ec_subset_sum/booleanity_test', 'ec_op/ec_subset_sum/add_points/slope', 'ec_op/ec_subset_sum/add_points/x', 'ec_op/ec_subset_sum/add_points/y', 'ec_op/ec_subset_sum/add_points/x_diff_inv', 'ec_op/ec_subset_sum/copy_point/x', 'ec_op/ec_subset_sum/copy_point/y', 'poseidon/addr_input_output_step_inner', 'poseidon/poseidon/full_rounds_state0_squaring', 'poseidon/poseidon/full_rounds_state1_squaring', 'poseidon/poseidon/full_rounds_state2_squaring', 'poseidon/poseidon/full_round0', 'poseidon/poseidon/full_round1', 'poseidon/poseidon/full_round2'.
              // domains[6] = point^(trace_length / 64) - 1.
              mstore(0x3700,
                     addmod(/*point^(trace_length / 64)*/ mload(0x3040), sub(PRIME, 1), PRIME))

              // Denominator for constraints: 'ecdsa/signature0/exponentiate_generator/booleanity_test', 'ecdsa/signature0/exponentiate_generator/add_points/slope', 'ecdsa/signature0/exponentiate_generator/add_points/x', 'ecdsa/signature0/exponentiate_generator/add_points/y', 'ecdsa/signature0/exponentiate_generator/add_points/x_diff_inv', 'ecdsa/signature0/exponentiate_generator/copy_point/x', 'ecdsa/signature0/exponentiate_generator/copy_point/y'.
              // domains[7] = point^(trace_length / 128) - 1.
              mstore(0x3720,
                     addmod(/*point^(trace_length / 128)*/ mload(0x3020), sub(PRIME, 1), PRIME))

              // Denominator for constraints: 'pedersen/hash0/ec_subset_sum/bit_unpacking/last_one_is_zero', 'pedersen/hash0/ec_subset_sum/bit_unpacking/zeroes_between_ones0', 'pedersen/hash0/ec_subset_sum/bit_unpacking/cumulative_bit192', 'pedersen/hash0/ec_subset_sum/bit_unpacking/zeroes_between_ones192', 'pedersen/hash0/ec_subset_sum/bit_unpacking/cumulative_bit196', 'pedersen/hash0/ec_subset_sum/bit_unpacking/zeroes_between_ones196', 'pedersen/hash0/copy_point/x', 'pedersen/hash0/copy_point/y', 'rc_builtin/value', 'rc_builtin/addr_step', 'bitwise/step_var_pool_addr', 'bitwise/partition'.
              // domains[8] = point^(trace_length / 256) - 1.
              mstore(0x3740,
                     addmod(/*point^(trace_length / 256)*/ mload(0x3000), sub(PRIME, 1), PRIME))

              // Denominator for constraints: 'pedersen/hash0/ec_subset_sum/zeros_tail'.
              // Numerator for constraints: 'pedersen/hash0/ec_subset_sum/booleanity_test', 'pedersen/hash0/ec_subset_sum/add_points/slope', 'pedersen/hash0/ec_subset_sum/add_points/x', 'pedersen/hash0/ec_subset_sum/add_points/y', 'pedersen/hash0/ec_subset_sum/copy_point/x', 'pedersen/hash0/ec_subset_sum/copy_point/y'.
              // domains[9] = point^(trace_length / 256) - trace_generator^(255 * trace_length / 256).
              mstore(0x3760,
                     addmod(
                       /*point^(trace_length / 256)*/ mload(0x3000),
                       sub(PRIME, /*trace_generator^(255 * trace_length / 256)*/ mload(0x3500)),
                       PRIME))

              // Denominator for constraints: 'pedersen/hash0/ec_subset_sum/bit_extraction_end'.
              // domains[10] = point^(trace_length / 256) - trace_generator^(63 * trace_length / 64).
              mstore(0x3780,
                     addmod(
                       /*point^(trace_length / 256)*/ mload(0x3000),
                       sub(PRIME, /*trace_generator^(63 * trace_length / 64)*/ mload(0x34e0)),
                       PRIME))

              // Numerator for constraints: 'poseidon/poseidon/full_round0', 'poseidon/poseidon/full_round1', 'poseidon/poseidon/full_round2'.
              // domains[11] = point^(trace_length / 256) - trace_generator^(3 * trace_length / 4).
              mstore(0x37a0,
                     addmod(
                       /*point^(trace_length / 256)*/ mload(0x3000),
                       sub(PRIME, /*trace_generator^(3 * trace_length / 4)*/ mload(0x33a0)),
                       PRIME))

              // Numerator for constraints: 'pedersen/hash0/copy_point/x', 'pedersen/hash0/copy_point/y'.
              // domains[12] = point^(trace_length / 512) - trace_generator^(trace_length / 2).
              mstore(0x37c0,
                     addmod(
                       /*point^(trace_length / 512)*/ mload(0x2fe0),
                       sub(PRIME, /*trace_generator^(trace_length / 2)*/ mload(0x32e0)),
                       PRIME))

              // Denominator for constraints: 'pedersen/hash0/init/x', 'pedersen/hash0/init/y', 'pedersen/input0_value0', 'pedersen/input0_addr', 'pedersen/input1_value0', 'pedersen/input1_addr', 'pedersen/output_value0', 'pedersen/output_addr', 'poseidon/addr_input_output_step_outter', 'poseidon/poseidon/add_first_round_key0', 'poseidon/poseidon/add_first_round_key1', 'poseidon/poseidon/add_first_round_key2', 'poseidon/poseidon/last_full_round0', 'poseidon/poseidon/last_full_round1', 'poseidon/poseidon/last_full_round2', 'poseidon/poseidon/copy_partial_rounds0_i0', 'poseidon/poseidon/copy_partial_rounds0_i1', 'poseidon/poseidon/copy_partial_rounds0_i2', 'poseidon/poseidon/margin_full_to_partial0', 'poseidon/poseidon/margin_full_to_partial1', 'poseidon/poseidon/margin_full_to_partial2', 'poseidon/poseidon/margin_partial_to_full0', 'poseidon/poseidon/margin_partial_to_full1', 'poseidon/poseidon/margin_partial_to_full2'.
              // domains[13] = point^(trace_length / 512) - 1.
              mstore(0x37e0,
                     addmod(/*point^(trace_length / 512)*/ mload(0x2fe0), sub(PRIME, 1), PRIME))

              // domains[14] = (point^(trace_length / 512) - trace_generator^(3 * trace_length / 4)) * (point^(trace_length / 512) - trace_generator^(7 * trace_length / 8)).
              mstore(0x3800,
                     mulmod(
                       addmod(
                         /*point^(trace_length / 512)*/ mload(0x2fe0),
                         sub(PRIME, /*trace_generator^(3 * trace_length / 4)*/ mload(0x33a0)),
                         PRIME),
                       addmod(
                         /*point^(trace_length / 512)*/ mload(0x2fe0),
                         sub(PRIME, /*trace_generator^(7 * trace_length / 8)*/ mload(0x3420)),
                         PRIME),
                       PRIME))

              // Numerator for constraints: 'poseidon/addr_input_output_step_inner'.
              // domains[15] = (point^(trace_length / 512) - trace_generator^(5 * trace_length / 8)) * domain14.
              mstore(0x3820,
                     mulmod(
                       addmod(
                         /*point^(trace_length / 512)*/ mload(0x2fe0),
                         sub(PRIME, /*trace_generator^(5 * trace_length / 8)*/ mload(0x3320)),
                         PRIME),
                       /*domains[14]*/ mload(0x3800),
                       PRIME))

              // domains[16] = point^(trace_length / 512) - trace_generator^(31 * trace_length / 32).
              mstore(0x3840,
                     addmod(
                       /*point^(trace_length / 512)*/ mload(0x2fe0),
                       sub(PRIME, /*trace_generator^(31 * trace_length / 32)*/ mload(0x34a0)),
                       PRIME))

              // domains[17] = (point^(trace_length / 512) - trace_generator^(11 * trace_length / 16)) * (point^(trace_length / 512) - trace_generator^(23 * trace_length / 32)) * (point^(trace_length / 512) - trace_generator^(25 * trace_length / 32)) * (point^(trace_length / 512) - trace_generator^(13 * trace_length / 16)) * (point^(trace_length / 512) - trace_generator^(27 * trace_length / 32)) * (point^(trace_length / 512) - trace_generator^(29 * trace_length / 32)) * (point^(trace_length / 512) - trace_generator^(15 * trace_length / 16)) * domain16.
              {
                let domain := mulmod(
                    mulmod(
                      mulmod(
                        addmod(
                          /*point^(trace_length / 512)*/ mload(0x2fe0),
                          sub(PRIME, /*trace_generator^(11 * trace_length / 16)*/ mload(0x3360)),
                          PRIME),
                        addmod(
                          /*point^(trace_length / 512)*/ mload(0x2fe0),
                          sub(PRIME, /*trace_generator^(23 * trace_length / 32)*/ mload(0x3380)),
                          PRIME),
                        PRIME),
                      addmod(
                        /*point^(trace_length / 512)*/ mload(0x2fe0),
                        sub(PRIME, /*trace_generator^(25 * trace_length / 32)*/ mload(0x33c0)),
                        PRIME),
                      PRIME),
                    addmod(
                      /*point^(trace_length / 512)*/ mload(0x2fe0),
                      sub(PRIME, /*trace_generator^(13 * trace_length / 16)*/ mload(0x33e0)),
                      PRIME),
                    PRIME)
                domain := mulmod(
                  domain,
                  mulmod(
                    mulmod(
                      mulmod(
                        addmod(
                          /*point^(trace_length / 512)*/ mload(0x2fe0),
                          sub(PRIME, /*trace_generator^(27 * trace_length / 32)*/ mload(0x3400)),
                          PRIME),
                        addmod(
                          /*point^(trace_length / 512)*/ mload(0x2fe0),
                          sub(PRIME, /*trace_generator^(29 * trace_length / 32)*/ mload(0x3440)),
                          PRIME),
                        PRIME),
                      addmod(
                        /*point^(trace_length / 512)*/ mload(0x2fe0),
                        sub(PRIME, /*trace_generator^(15 * trace_length / 16)*/ mload(0x3460)),
                        PRIME),
                      PRIME),
                    /*domains[16]*/ mload(0x3840),
                    PRIME),
                  PRIME)
                mstore(0x3860, domain)
              }

              // Numerator for constraints: 'poseidon/poseidon/partial_rounds_state1_squaring'.
              // domains[18] = domain14 * domain17.
              mstore(0x3880,
                     mulmod(/*domains[14]*/ mload(0x3800), /*domains[17]*/ mload(0x3860), PRIME))

              // Numerator for constraints: 'poseidon/poseidon/partial_round0'.
              // domains[19] = (point^(trace_length / 512) - trace_generator^(61 * trace_length / 64)) * (point^(trace_length / 512) - trace_generator^(63 * trace_length / 64)) * domain16.
              mstore(0x38a0,
                     mulmod(
                       mulmod(
                         addmod(
                           /*point^(trace_length / 512)*/ mload(0x2fe0),
                           sub(PRIME, /*trace_generator^(61 * trace_length / 64)*/ mload(0x3480)),
                           PRIME),
                         addmod(
                           /*point^(trace_length / 512)*/ mload(0x2fe0),
                           sub(PRIME, /*trace_generator^(63 * trace_length / 64)*/ mload(0x34e0)),
                           PRIME),
                         PRIME),
                       /*domains[16]*/ mload(0x3840),
                       PRIME))

              // Numerator for constraints: 'poseidon/poseidon/partial_round1'.
              // domains[20] = (point^(trace_length / 512) - trace_generator^(19 * trace_length / 32)) * (point^(trace_length / 512) - trace_generator^(21 * trace_length / 32)) * domain15 * domain17.
              mstore(0x38c0,
                     mulmod(
                       mulmod(
                         mulmod(
                           addmod(
                             /*point^(trace_length / 512)*/ mload(0x2fe0),
                             sub(PRIME, /*trace_generator^(19 * trace_length / 32)*/ mload(0x3300)),
                             PRIME),
                           addmod(
                             /*point^(trace_length / 512)*/ mload(0x2fe0),
                             sub(PRIME, /*trace_generator^(21 * trace_length / 32)*/ mload(0x3340)),
                             PRIME),
                           PRIME),
                         /*domains[15]*/ mload(0x3820),
                         PRIME),
                       /*domains[17]*/ mload(0x3860),
                       PRIME))

              // Numerator for constraints: 'bitwise/step_var_pool_addr'.
              // domains[21] = point^(trace_length / 1024) - trace_generator^(3 * trace_length / 4).
              mstore(0x38e0,
                     addmod(
                       /*point^(trace_length / 1024)*/ mload(0x2fc0),
                       sub(PRIME, /*trace_generator^(3 * trace_length / 4)*/ mload(0x33a0)),
                       PRIME))

              // Denominator for constraints: 'bitwise/x_or_y_addr', 'bitwise/next_var_pool_addr', 'bitwise/or_is_and_plus_xor', 'bitwise/unique_unpacking192', 'bitwise/unique_unpacking193', 'bitwise/unique_unpacking194', 'bitwise/unique_unpacking195'.
              // domains[22] = point^(trace_length / 1024) - 1.
              mstore(0x3900,
                     addmod(/*point^(trace_length / 1024)*/ mload(0x2fc0), sub(PRIME, 1), PRIME))

              // Denominator for constraints: 'bitwise/addition_is_xor_with_and'.
              // domains[23] = (point^(trace_length / 1024) - trace_generator^(trace_length / 64)) * (point^(trace_length / 1024) - trace_generator^(trace_length / 32)) * (point^(trace_length / 1024) - trace_generator^(3 * trace_length / 64)) * (point^(trace_length / 1024) - trace_generator^(trace_length / 16)) * (point^(trace_length / 1024) - trace_generator^(5 * trace_length / 64)) * (point^(trace_length / 1024) - trace_generator^(3 * trace_length / 32)) * (point^(trace_length / 1024) - trace_generator^(7 * trace_length / 64)) * (point^(trace_length / 1024) - trace_generator^(trace_length / 8)) * (point^(trace_length / 1024) - trace_generator^(9 * trace_length / 64)) * (point^(trace_length / 1024) - trace_generator^(5 * trace_length / 32)) * (point^(trace_length / 1024) - trace_generator^(11 * trace_length / 64)) * (point^(trace_length / 1024) - trace_generator^(3 * trace_length / 16)) * (point^(trace_length / 1024) - trace_generator^(13 * trace_length / 64)) * (point^(trace_length / 1024) - trace_generator^(7 * trace_length / 32)) * (point^(trace_length / 1024) - trace_generator^(15 * trace_length / 64)) * domain22.
              {
                let domain := mulmod(
                    mulmod(
                      mulmod(
                        addmod(
                          /*point^(trace_length / 1024)*/ mload(0x2fc0),
                          sub(PRIME, /*trace_generator^(trace_length / 64)*/ mload(0x3100)),
                          PRIME),
                        addmod(
                          /*point^(trace_length / 1024)*/ mload(0x2fc0),
                          sub(PRIME, /*trace_generator^(trace_length / 32)*/ mload(0x3120)),
                          PRIME),
                        PRIME),
                      addmod(
                        /*point^(trace_length / 1024)*/ mload(0x2fc0),
                        sub(PRIME, /*trace_generator^(3 * trace_length / 64)*/ mload(0x3140)),
                        PRIME),
                      PRIME),
                    addmod(
                      /*point^(trace_length / 1024)*/ mload(0x2fc0),
                      sub(PRIME, /*trace_generator^(trace_length / 16)*/ mload(0x3160)),
                      PRIME),
                    PRIME)
                domain := mulmod(
                  domain,
                  mulmod(
                    mulmod(
                      mulmod(
                        addmod(
                          /*point^(trace_length / 1024)*/ mload(0x2fc0),
                          sub(PRIME, /*trace_generator^(5 * trace_length / 64)*/ mload(0x3180)),
                          PRIME),
                        addmod(
                          /*point^(trace_length / 1024)*/ mload(0x2fc0),
                          sub(PRIME, /*trace_generator^(3 * trace_length / 32)*/ mload(0x31a0)),
                          PRIME),
                        PRIME),
                      addmod(
                        /*point^(trace_length / 1024)*/ mload(0x2fc0),
                        sub(PRIME, /*trace_generator^(7 * trace_length / 64)*/ mload(0x31c0)),
                        PRIME),
                      PRIME),
                    addmod(
                      /*point^(trace_length / 1024)*/ mload(0x2fc0),
                      sub(PRIME, /*trace_generator^(trace_length / 8)*/ mload(0x31e0)),
                      PRIME),
                    PRIME),
                  PRIME)
                domain := mulmod(
                  domain,
                  mulmod(
                    mulmod(
                      mulmod(
                        addmod(
                          /*point^(trace_length / 1024)*/ mload(0x2fc0),
                          sub(PRIME, /*trace_generator^(9 * trace_length / 64)*/ mload(0x3200)),
                          PRIME),
                        addmod(
                          /*point^(trace_length / 1024)*/ mload(0x2fc0),
                          sub(PRIME, /*trace_generator^(5 * trace_length / 32)*/ mload(0x3220)),
                          PRIME),
                        PRIME),
                      addmod(
                        /*point^(trace_length / 1024)*/ mload(0x2fc0),
                        sub(PRIME, /*trace_generator^(11 * trace_length / 64)*/ mload(0x3240)),
                        PRIME),
                      PRIME),
                    addmod(
                      /*point^(trace_length / 1024)*/ mload(0x2fc0),
                      sub(PRIME, /*trace_generator^(3 * trace_length / 16)*/ mload(0x3260)),
                      PRIME),
                    PRIME),
                  PRIME)
                domain := mulmod(
                  domain,
                  mulmod(
                    mulmod(
                      mulmod(
                        addmod(
                          /*point^(trace_length / 1024)*/ mload(0x2fc0),
                          sub(PRIME, /*trace_generator^(13 * trace_length / 64)*/ mload(0x3280)),
                          PRIME),
                        addmod(
                          /*point^(trace_length / 1024)*/ mload(0x2fc0),
                          sub(PRIME, /*trace_generator^(7 * trace_length / 32)*/ mload(0x32a0)),
                          PRIME),
                        PRIME),
                      addmod(
                        /*point^(trace_length / 1024)*/ mload(0x2fc0),
                        sub(PRIME, /*trace_generator^(15 * trace_length / 64)*/ mload(0x32c0)),
                        PRIME),
                      PRIME),
                    /*domains[22]*/ mload(0x3900),
                    PRIME),
                  PRIME)
                mstore(0x3920, domain)
              }

              // Denominator for constraints: 'ecdsa/signature0/exponentiate_key/zeros_tail', 'ec_op/ec_subset_sum/zeros_tail'.
              // Numerator for constraints: 'ecdsa/signature0/doubling_key/slope', 'ecdsa/signature0/doubling_key/x', 'ecdsa/signature0/doubling_key/y', 'ecdsa/signature0/exponentiate_key/booleanity_test', 'ecdsa/signature0/exponentiate_key/add_points/slope', 'ecdsa/signature0/exponentiate_key/add_points/x', 'ecdsa/signature0/exponentiate_key/add_points/y', 'ecdsa/signature0/exponentiate_key/add_points/x_diff_inv', 'ecdsa/signature0/exponentiate_key/copy_point/x', 'ecdsa/signature0/exponentiate_key/copy_point/y', 'ec_op/doubling_q/slope', 'ec_op/doubling_q/x', 'ec_op/doubling_q/y', 'ec_op/ec_subset_sum/booleanity_test', 'ec_op/ec_subset_sum/add_points/slope', 'ec_op/ec_subset_sum/add_points/x', 'ec_op/ec_subset_sum/add_points/y', 'ec_op/ec_subset_sum/add_points/x_diff_inv', 'ec_op/ec_subset_sum/copy_point/x', 'ec_op/ec_subset_sum/copy_point/y'.
              // domains[24] = point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              mstore(0x3940,
                     addmod(
                       /*point^(trace_length / 16384)*/ mload(0x2fa0),
                       sub(PRIME, /*trace_generator^(255 * trace_length / 256)*/ mload(0x3500)),
                       PRIME))

              // Denominator for constraints: 'ecdsa/signature0/exponentiate_key/bit_extraction_end'.
              // domains[25] = point^(trace_length / 16384) - trace_generator^(251 * trace_length / 256).
              mstore(0x3960,
                     addmod(
                       /*point^(trace_length / 16384)*/ mload(0x2fa0),
                       sub(PRIME, /*trace_generator^(251 * trace_length / 256)*/ mload(0x34c0)),
                       PRIME))

              // Denominator for constraints: 'ecdsa/signature0/init_key/x', 'ecdsa/signature0/init_key/y', 'ecdsa/signature0/r_and_w_nonzero', 'ec_op/p_x_addr', 'ec_op/p_y_addr', 'ec_op/q_x_addr', 'ec_op/q_y_addr', 'ec_op/m_addr', 'ec_op/r_x_addr', 'ec_op/r_y_addr', 'ec_op/get_q_x', 'ec_op/get_q_y', 'ec_op/ec_subset_sum/bit_unpacking/last_one_is_zero', 'ec_op/ec_subset_sum/bit_unpacking/zeroes_between_ones0', 'ec_op/ec_subset_sum/bit_unpacking/cumulative_bit192', 'ec_op/ec_subset_sum/bit_unpacking/zeroes_between_ones192', 'ec_op/ec_subset_sum/bit_unpacking/cumulative_bit196', 'ec_op/ec_subset_sum/bit_unpacking/zeroes_between_ones196', 'ec_op/get_m', 'ec_op/get_p_x', 'ec_op/get_p_y', 'ec_op/set_r_x', 'ec_op/set_r_y'.
              // domains[26] = point^(trace_length / 16384) - 1.
              mstore(0x3980,
                     addmod(/*point^(trace_length / 16384)*/ mload(0x2fa0), sub(PRIME, 1), PRIME))

              // Denominator for constraints: 'ec_op/ec_subset_sum/bit_extraction_end'.
              // domains[27] = point^(trace_length / 16384) - trace_generator^(63 * trace_length / 64).
              mstore(0x39a0,
                     addmod(
                       /*point^(trace_length / 16384)*/ mload(0x2fa0),
                       sub(PRIME, /*trace_generator^(63 * trace_length / 64)*/ mload(0x34e0)),
                       PRIME))

              // Denominator for constraints: 'ecdsa/signature0/exponentiate_generator/zeros_tail'.
              // Numerator for constraints: 'ecdsa/signature0/exponentiate_generator/booleanity_test', 'ecdsa/signature0/exponentiate_generator/add_points/slope', 'ecdsa/signature0/exponentiate_generator/add_points/x', 'ecdsa/signature0/exponentiate_generator/add_points/y', 'ecdsa/signature0/exponentiate_generator/add_points/x_diff_inv', 'ecdsa/signature0/exponentiate_generator/copy_point/x', 'ecdsa/signature0/exponentiate_generator/copy_point/y'.
              // domains[28] = point^(trace_length / 32768) - trace_generator^(255 * trace_length / 256).
              mstore(0x39c0,
                     addmod(
                       /*point^(trace_length / 32768)*/ mload(0x2f80),
                       sub(PRIME, /*trace_generator^(255 * trace_length / 256)*/ mload(0x3500)),
                       PRIME))

              // Denominator for constraints: 'ecdsa/signature0/exponentiate_generator/bit_extraction_end'.
              // domains[29] = point^(trace_length / 32768) - trace_generator^(251 * trace_length / 256).
              mstore(0x39e0,
                     addmod(
                       /*point^(trace_length / 32768)*/ mload(0x2f80),
                       sub(PRIME, /*trace_generator^(251 * trace_length / 256)*/ mload(0x34c0)),
                       PRIME))

              // Denominator for constraints: 'ecdsa/signature0/init_gen/x', 'ecdsa/signature0/init_gen/y', 'ecdsa/signature0/add_results/slope', 'ecdsa/signature0/add_results/x', 'ecdsa/signature0/add_results/y', 'ecdsa/signature0/add_results/x_diff_inv', 'ecdsa/signature0/extract_r/slope', 'ecdsa/signature0/extract_r/x', 'ecdsa/signature0/extract_r/x_diff_inv', 'ecdsa/signature0/z_nonzero', 'ecdsa/signature0/q_on_curve/x_squared', 'ecdsa/signature0/q_on_curve/on_curve', 'ecdsa/message_addr', 'ecdsa/pubkey_addr', 'ecdsa/message_value0', 'ecdsa/pubkey_value0'.
              // domains[30] = point^(trace_length / 32768) - 1.
              mstore(0x3a00,
                     addmod(/*point^(trace_length / 32768)*/ mload(0x2f80), sub(PRIME, 1), PRIME))

              // Denominator for constraints: 'final_ap', 'final_fp', 'final_pc'.
              // Numerator for constraints: 'cpu/update_registers/update_pc/tmp0', 'cpu/update_registers/update_pc/tmp1', 'cpu/update_registers/update_pc/pc_cond_negative', 'cpu/update_registers/update_pc/pc_cond_positive', 'cpu/update_registers/update_ap/ap_update', 'cpu/update_registers/update_fp/fp_update'.
              // domains[31] = point - trace_generator^(16 * (trace_length / 16 - 1)).
              mstore(0x3a20,
                     addmod(
                       point,
                       sub(PRIME, /*trace_generator^(16 * (trace_length / 16 - 1))*/ mload(0x3520)),
                       PRIME))

              // Denominator for constraints: 'initial_ap', 'initial_fp', 'initial_pc', 'memory/multi_column_perm/perm/init0', 'memory/initial_addr', 'rc16/perm/init0', 'rc16/minimum', 'diluted_check/permutation/init0', 'diluted_check/init', 'diluted_check/first_element', 'pedersen/init_addr', 'rc_builtin/init_addr', 'ecdsa/init_addr', 'bitwise/init_var_pool_addr', 'ec_op/init_addr', 'poseidon/init_input_output_addr'.
              // domains[32] = point - 1.
              mstore(0x3a40,
                     addmod(point, sub(PRIME, 1), PRIME))

              // Denominator for constraints: 'memory/multi_column_perm/perm/last'.
              // Numerator for constraints: 'memory/multi_column_perm/perm/step0', 'memory/diff_is_bit', 'memory/is_func'.
              // domains[33] = point - trace_generator^(2 * (trace_length / 2 - 1)).
              mstore(0x3a60,
                     addmod(
                       point,
                       sub(PRIME, /*trace_generator^(2 * (trace_length / 2 - 1))*/ mload(0x3540)),
                       PRIME))

              // Denominator for constraints: 'rc16/perm/last', 'rc16/maximum'.
              // Numerator for constraints: 'rc16/perm/step0', 'rc16/diff_is_bit'.
              // domains[34] = point - trace_generator^(4 * (trace_length / 4 - 1)).
              mstore(0x3a80,
                     addmod(
                       point,
                       sub(PRIME, /*trace_generator^(4 * (trace_length / 4 - 1))*/ mload(0x3560)),
                       PRIME))

              // Denominator for constraints: 'diluted_check/permutation/last', 'diluted_check/last'.
              // Numerator for constraints: 'diluted_check/permutation/step0', 'diluted_check/step'.
              // domains[35] = point - trace_generator^(8 * (trace_length / 8 - 1)).
              mstore(0x3aa0,
                     addmod(
                       point,
                       sub(PRIME, /*trace_generator^(8 * (trace_length / 8 - 1))*/ mload(0x3580)),
                       PRIME))

              // Numerator for constraints: 'pedersen/input0_addr', 'poseidon/addr_input_output_step_outter'.
              // domains[36] = point - trace_generator^(512 * (trace_length / 512 - 1)).
              mstore(0x3ac0,
                     addmod(
                       point,
                       sub(PRIME, /*trace_generator^(512 * (trace_length / 512 - 1))*/ mload(0x35a0)),
                       PRIME))

              // Numerator for constraints: 'rc_builtin/addr_step'.
              // domains[37] = point - trace_generator^(256 * (trace_length / 256 - 1)).
              mstore(0x3ae0,
                     addmod(
                       point,
                       sub(PRIME, /*trace_generator^(256 * (trace_length / 256 - 1))*/ mload(0x35c0)),
                       PRIME))

              // Numerator for constraints: 'ecdsa/pubkey_addr'.
              // domains[38] = point - trace_generator^(32768 * (trace_length / 32768 - 1)).
              mstore(0x3b00,
                     addmod(
                       point,
                       sub(PRIME, /*trace_generator^(32768 * (trace_length / 32768 - 1))*/ mload(0x35e0)),
                       PRIME))

              // Numerator for constraints: 'bitwise/next_var_pool_addr'.
              // domains[39] = point - trace_generator^(1024 * (trace_length / 1024 - 1)).
              mstore(0x3b20,
                     addmod(
                       point,
                       sub(PRIME, /*trace_generator^(1024 * (trace_length / 1024 - 1))*/ mload(0x3600)),
                       PRIME))

              // Numerator for constraints: 'ec_op/p_x_addr'.
              // domains[40] = point - trace_generator^(16384 * (trace_length / 16384 - 1)).
              mstore(0x3b40,
                     addmod(
                       point,
                       sub(PRIME, /*trace_generator^(16384 * (trace_length / 16384 - 1))*/ mload(0x3620)),
                       PRIME))

            }

            {
              // Prepare denominators for batch inverse.

              // denominators[0] = domains[0].
              mstore(0x3ea0, /*domains[0]*/ mload(0x3640))

              // denominators[1] = domains[4].
              mstore(0x3ec0, /*domains[4]*/ mload(0x36c0))

              // denominators[2] = domains[5].
              mstore(0x3ee0, /*domains[5]*/ mload(0x36e0))

              // denominators[3] = domains[31].
              mstore(0x3f00, /*domains[31]*/ mload(0x3a20))

              // denominators[4] = domains[32].
              mstore(0x3f20, /*domains[32]*/ mload(0x3a40))

              // denominators[5] = domains[1].
              mstore(0x3f40, /*domains[1]*/ mload(0x3660))

              // denominators[6] = domains[33].
              mstore(0x3f60, /*domains[33]*/ mload(0x3a60))

              // denominators[7] = domains[3].
              mstore(0x3f80, /*domains[3]*/ mload(0x36a0))

              // denominators[8] = domains[2].
              mstore(0x3fa0, /*domains[2]*/ mload(0x3680))

              // denominators[9] = domains[34].
              mstore(0x3fc0, /*domains[34]*/ mload(0x3a80))

              // denominators[10] = domains[35].
              mstore(0x3fe0, /*domains[35]*/ mload(0x3aa0))

              // denominators[11] = domains[8].
              mstore(0x4000, /*domains[8]*/ mload(0x3740))

              // denominators[12] = domains[9].
              mstore(0x4020, /*domains[9]*/ mload(0x3760))

              // denominators[13] = domains[10].
              mstore(0x4040, /*domains[10]*/ mload(0x3780))

              // denominators[14] = domains[13].
              mstore(0x4060, /*domains[13]*/ mload(0x37e0))

              // denominators[15] = domains[6].
              mstore(0x4080, /*domains[6]*/ mload(0x3700))

              // denominators[16] = domains[24].
              mstore(0x40a0, /*domains[24]*/ mload(0x3940))

              // denominators[17] = domains[7].
              mstore(0x40c0, /*domains[7]*/ mload(0x3720))

              // denominators[18] = domains[28].
              mstore(0x40e0, /*domains[28]*/ mload(0x39c0))

              // denominators[19] = domains[29].
              mstore(0x4100, /*domains[29]*/ mload(0x39e0))

              // denominators[20] = domains[25].
              mstore(0x4120, /*domains[25]*/ mload(0x3960))

              // denominators[21] = domains[30].
              mstore(0x4140, /*domains[30]*/ mload(0x3a00))

              // denominators[22] = domains[26].
              mstore(0x4160, /*domains[26]*/ mload(0x3980))

              // denominators[23] = domains[22].
              mstore(0x4180, /*domains[22]*/ mload(0x3900))

              // denominators[24] = domains[23].
              mstore(0x41a0, /*domains[23]*/ mload(0x3920))

              // denominators[25] = domains[27].
              mstore(0x41c0, /*domains[27]*/ mload(0x39a0))

            }

            {
              // Compute the inverses of the denominators into denominatorInvs using batch inverse.

              // Start by computing the cumulative product.
              // Let (d_0, d_1, d_2, ..., d_{n-1}) be the values in denominators. After this loop
              // denominatorInvs will be (1, d_0, d_0 * d_1, ...) and prod will contain the value of
              // d_0 * ... * d_{n-1}.
              // Compute the offset between the partialProducts array and the input values array.
              let productsToValuesOffset := 0x340
              let prod := 1
              let partialProductEndPtr := 0x3ea0
              for { let partialProductPtr := 0x3b60 }
                  lt(partialProductPtr, partialProductEndPtr)
                  { partialProductPtr := add(partialProductPtr, 0x20) } {
                  mstore(partialProductPtr, prod)
                  // prod *= d_{i}.
                  prod := mulmod(prod,
                                 mload(add(partialProductPtr, productsToValuesOffset)),
                                 PRIME)
              }

              let firstPartialProductPtr := 0x3b60
              // Compute the inverse of the product.
              let prodInv := expmod(prod, sub(PRIME, 2), PRIME)

              if eq(prodInv, 0) {
                  // Solidity generates reverts with reason that look as follows:
                  // 1. 4 bytes with the constant 0x08c379a0 (== Keccak256(b'Error(string)')[:4]).
                  // 2. 32 bytes offset bytes (always 0x20 as far as i can tell).
                  // 3. 32 bytes with the length of the revert reason.
                  // 4. Revert reason string.

                  mstore(0, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                  mstore(0x4, 0x20)
                  mstore(0x24, 0x1e)
                  mstore(0x44, "Batch inverse product is zero.")
                  revert(0, 0x62)
              }

              // Compute the inverses.
              // Loop over denominator_invs in reverse order.
              // currentPartialProductPtr is initialized to one past the end.
              let currentPartialProductPtr := 0x3ea0
              for { } gt(currentPartialProductPtr, firstPartialProductPtr) { } {
                  currentPartialProductPtr := sub(currentPartialProductPtr, 0x20)
                  // Store 1/d_{i} = (d_0 * ... * d_{i-1}) * 1/(d_0 * ... * d_{i}).
                  mstore(currentPartialProductPtr,
                         mulmod(mload(currentPartialProductPtr), prodInv, PRIME))
                  // Update prodInv to be 1/(d_0 * ... * d_{i-1}) by multiplying by d_i.
                  prodInv := mulmod(prodInv,
                                     mload(add(currentPartialProductPtr, productsToValuesOffset)),
                                     PRIME)
              }
            }

            {
              // Compute the result of the composition polynomial.

              {
              // cpu/decode/opcode_rc/bit_0 = column0_row0 - (column0_row1 + column0_row1).
              let val := addmod(
                /*column0_row0*/ mload(0x660),
                sub(
                  PRIME,
                  addmod(/*column0_row1*/ mload(0x680), /*column0_row1*/ mload(0x680), PRIME)),
                PRIME)
              mstore(0x2800, val)
              }


              {
              // cpu/decode/opcode_rc/bit_2 = column0_row2 - (column0_row3 + column0_row3).
              let val := addmod(
                /*column0_row2*/ mload(0x6a0),
                sub(
                  PRIME,
                  addmod(/*column0_row3*/ mload(0x6c0), /*column0_row3*/ mload(0x6c0), PRIME)),
                PRIME)
              mstore(0x2820, val)
              }


              {
              // cpu/decode/opcode_rc/bit_4 = column0_row4 - (column0_row5 + column0_row5).
              let val := addmod(
                /*column0_row4*/ mload(0x6e0),
                sub(
                  PRIME,
                  addmod(/*column0_row5*/ mload(0x700), /*column0_row5*/ mload(0x700), PRIME)),
                PRIME)
              mstore(0x2840, val)
              }


              {
              // cpu/decode/opcode_rc/bit_3 = column0_row3 - (column0_row4 + column0_row4).
              let val := addmod(
                /*column0_row3*/ mload(0x6c0),
                sub(
                  PRIME,
                  addmod(/*column0_row4*/ mload(0x6e0), /*column0_row4*/ mload(0x6e0), PRIME)),
                PRIME)
              mstore(0x2860, val)
              }


              {
              // cpu/decode/flag_op1_base_op0_0 = 1 - (cpu__decode__opcode_rc__bit_2 + cpu__decode__opcode_rc__bit_4 + cpu__decode__opcode_rc__bit_3).
              let val := addmod(
                1,
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      /*intermediate_value/cpu/decode/opcode_rc/bit_2*/ mload(0x2820),
                      /*intermediate_value/cpu/decode/opcode_rc/bit_4*/ mload(0x2840),
                      PRIME),
                    /*intermediate_value/cpu/decode/opcode_rc/bit_3*/ mload(0x2860),
                    PRIME)),
                PRIME)
              mstore(0x2880, val)
              }


              {
              // cpu/decode/opcode_rc/bit_5 = column0_row5 - (column0_row6 + column0_row6).
              let val := addmod(
                /*column0_row5*/ mload(0x700),
                sub(
                  PRIME,
                  addmod(/*column0_row6*/ mload(0x720), /*column0_row6*/ mload(0x720), PRIME)),
                PRIME)
              mstore(0x28a0, val)
              }


              {
              // cpu/decode/opcode_rc/bit_6 = column0_row6 - (column0_row7 + column0_row7).
              let val := addmod(
                /*column0_row6*/ mload(0x720),
                sub(
                  PRIME,
                  addmod(/*column0_row7*/ mload(0x740), /*column0_row7*/ mload(0x740), PRIME)),
                PRIME)
              mstore(0x28c0, val)
              }


              {
              // cpu/decode/opcode_rc/bit_9 = column0_row9 - (column0_row10 + column0_row10).
              let val := addmod(
                /*column0_row9*/ mload(0x780),
                sub(
                  PRIME,
                  addmod(/*column0_row10*/ mload(0x7a0), /*column0_row10*/ mload(0x7a0), PRIME)),
                PRIME)
              mstore(0x28e0, val)
              }


              {
              // cpu/decode/flag_res_op1_0 = 1 - (cpu__decode__opcode_rc__bit_5 + cpu__decode__opcode_rc__bit_6 + cpu__decode__opcode_rc__bit_9).
              let val := addmod(
                1,
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      /*intermediate_value/cpu/decode/opcode_rc/bit_5*/ mload(0x28a0),
                      /*intermediate_value/cpu/decode/opcode_rc/bit_6*/ mload(0x28c0),
                      PRIME),
                    /*intermediate_value/cpu/decode/opcode_rc/bit_9*/ mload(0x28e0),
                    PRIME)),
                PRIME)
              mstore(0x2900, val)
              }


              {
              // cpu/decode/opcode_rc/bit_7 = column0_row7 - (column0_row8 + column0_row8).
              let val := addmod(
                /*column0_row7*/ mload(0x740),
                sub(
                  PRIME,
                  addmod(/*column0_row8*/ mload(0x760), /*column0_row8*/ mload(0x760), PRIME)),
                PRIME)
              mstore(0x2920, val)
              }


              {
              // cpu/decode/opcode_rc/bit_8 = column0_row8 - (column0_row9 + column0_row9).
              let val := addmod(
                /*column0_row8*/ mload(0x760),
                sub(
                  PRIME,
                  addmod(/*column0_row9*/ mload(0x780), /*column0_row9*/ mload(0x780), PRIME)),
                PRIME)
              mstore(0x2940, val)
              }


              {
              // cpu/decode/flag_pc_update_regular_0 = 1 - (cpu__decode__opcode_rc__bit_7 + cpu__decode__opcode_rc__bit_8 + cpu__decode__opcode_rc__bit_9).
              let val := addmod(
                1,
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      /*intermediate_value/cpu/decode/opcode_rc/bit_7*/ mload(0x2920),
                      /*intermediate_value/cpu/decode/opcode_rc/bit_8*/ mload(0x2940),
                      PRIME),
                    /*intermediate_value/cpu/decode/opcode_rc/bit_9*/ mload(0x28e0),
                    PRIME)),
                PRIME)
              mstore(0x2960, val)
              }


              {
              // cpu/decode/opcode_rc/bit_12 = column0_row12 - (column0_row13 + column0_row13).
              let val := addmod(
                /*column0_row12*/ mload(0x7e0),
                sub(
                  PRIME,
                  addmod(/*column0_row13*/ mload(0x800), /*column0_row13*/ mload(0x800), PRIME)),
                PRIME)
              mstore(0x2980, val)
              }


              {
              // cpu/decode/opcode_rc/bit_13 = column0_row13 - (column0_row14 + column0_row14).
              let val := addmod(
                /*column0_row13*/ mload(0x800),
                sub(
                  PRIME,
                  addmod(/*column0_row14*/ mload(0x820), /*column0_row14*/ mload(0x820), PRIME)),
                PRIME)
              mstore(0x29a0, val)
              }


              {
              // cpu/decode/fp_update_regular_0 = 1 - (cpu__decode__opcode_rc__bit_12 + cpu__decode__opcode_rc__bit_13).
              let val := addmod(
                1,
                sub(
                  PRIME,
                  addmod(
                    /*intermediate_value/cpu/decode/opcode_rc/bit_12*/ mload(0x2980),
                    /*intermediate_value/cpu/decode/opcode_rc/bit_13*/ mload(0x29a0),
                    PRIME)),
                PRIME)
              mstore(0x29c0, val)
              }


              {
              // cpu/decode/opcode_rc/bit_1 = column0_row1 - (column0_row2 + column0_row2).
              let val := addmod(
                /*column0_row1*/ mload(0x680),
                sub(
                  PRIME,
                  addmod(/*column0_row2*/ mload(0x6a0), /*column0_row2*/ mload(0x6a0), PRIME)),
                PRIME)
              mstore(0x29e0, val)
              }


              {
              // npc_reg_0 = column5_row0 + cpu__decode__opcode_rc__bit_2 + 1.
              let val := addmod(
                addmod(
                  /*column5_row0*/ mload(0xae0),
                  /*intermediate_value/cpu/decode/opcode_rc/bit_2*/ mload(0x2820),
                  PRIME),
                1,
                PRIME)
              mstore(0x2a00, val)
              }


              {
              // cpu/decode/opcode_rc/bit_10 = column0_row10 - (column0_row11 + column0_row11).
              let val := addmod(
                /*column0_row10*/ mload(0x7a0),
                sub(
                  PRIME,
                  addmod(/*column0_row11*/ mload(0x7c0), /*column0_row11*/ mload(0x7c0), PRIME)),
                PRIME)
              mstore(0x2a20, val)
              }


              {
              // cpu/decode/opcode_rc/bit_11 = column0_row11 - (column0_row12 + column0_row12).
              let val := addmod(
                /*column0_row11*/ mload(0x7c0),
                sub(
                  PRIME,
                  addmod(/*column0_row12*/ mload(0x7e0), /*column0_row12*/ mload(0x7e0), PRIME)),
                PRIME)
              mstore(0x2a40, val)
              }


              {
              // cpu/decode/opcode_rc/bit_14 = column0_row14 - (column0_row15 + column0_row15).
              let val := addmod(
                /*column0_row14*/ mload(0x820),
                sub(
                  PRIME,
                  addmod(/*column0_row15*/ mload(0x840), /*column0_row15*/ mload(0x840), PRIME)),
                PRIME)
              mstore(0x2a60, val)
              }


              {
              // memory/address_diff_0 = column6_row2 - column6_row0.
              let val := addmod(/*column6_row2*/ mload(0x12a0), sub(PRIME, /*column6_row0*/ mload(0x1260)), PRIME)
              mstore(0x2a80, val)
              }


              {
              // rc16/diff_0 = column7_row6 - column7_row2.
              let val := addmod(/*column7_row6*/ mload(0x13a0), sub(PRIME, /*column7_row2*/ mload(0x1320)), PRIME)
              mstore(0x2aa0, val)
              }


              {
              // pedersen/hash0/ec_subset_sum/bit_0 = column3_row0 - (column3_row1 + column3_row1).
              let val := addmod(
                /*column3_row0*/ mload(0x980),
                sub(
                  PRIME,
                  addmod(/*column3_row1*/ mload(0x9a0), /*column3_row1*/ mload(0x9a0), PRIME)),
                PRIME)
              mstore(0x2ac0, val)
              }


              {
              // pedersen/hash0/ec_subset_sum/bit_neg_0 = 1 - pedersen__hash0__ec_subset_sum__bit_0.
              let val := addmod(
                1,
                sub(PRIME, /*intermediate_value/pedersen/hash0/ec_subset_sum/bit_0*/ mload(0x2ac0)),
                PRIME)
              mstore(0x2ae0, val)
              }


              {
              // rc_builtin/value0_0 = column7_row12.
              let val := /*column7_row12*/ mload(0x1440)
              mstore(0x2b00, val)
              }


              {
              // rc_builtin/value1_0 = rc_builtin__value0_0 * offset_size + column7_row44.
              let val := addmod(
                mulmod(
                  /*intermediate_value/rc_builtin/value0_0*/ mload(0x2b00),
                  /*offset_size*/ mload(0x140),
                  PRIME),
                /*column7_row44*/ mload(0x1540),
                PRIME)
              mstore(0x2b20, val)
              }


              {
              // rc_builtin/value2_0 = rc_builtin__value1_0 * offset_size + column7_row76.
              let val := addmod(
                mulmod(
                  /*intermediate_value/rc_builtin/value1_0*/ mload(0x2b20),
                  /*offset_size*/ mload(0x140),
                  PRIME),
                /*column7_row76*/ mload(0x15a0),
                PRIME)
              mstore(0x2b40, val)
              }


              {
              // rc_builtin/value3_0 = rc_builtin__value2_0 * offset_size + column7_row108.
              let val := addmod(
                mulmod(
                  /*intermediate_value/rc_builtin/value2_0*/ mload(0x2b40),
                  /*offset_size*/ mload(0x140),
                  PRIME),
                /*column7_row108*/ mload(0x1600),
                PRIME)
              mstore(0x2b60, val)
              }


              {
              // rc_builtin/value4_0 = rc_builtin__value3_0 * offset_size + column7_row140.
              let val := addmod(
                mulmod(
                  /*intermediate_value/rc_builtin/value3_0*/ mload(0x2b60),
                  /*offset_size*/ mload(0x140),
                  PRIME),
                /*column7_row140*/ mload(0x1660),
                PRIME)
              mstore(0x2b80, val)
              }


              {
              // rc_builtin/value5_0 = rc_builtin__value4_0 * offset_size + column7_row172.
              let val := addmod(
                mulmod(
                  /*intermediate_value/rc_builtin/value4_0*/ mload(0x2b80),
                  /*offset_size*/ mload(0x140),
                  PRIME),
                /*column7_row172*/ mload(0x16c0),
                PRIME)
              mstore(0x2ba0, val)
              }


              {
              // rc_builtin/value6_0 = rc_builtin__value5_0 * offset_size + column7_row204.
              let val := addmod(
                mulmod(
                  /*intermediate_value/rc_builtin/value5_0*/ mload(0x2ba0),
                  /*offset_size*/ mload(0x140),
                  PRIME),
                /*column7_row204*/ mload(0x1720),
                PRIME)
              mstore(0x2bc0, val)
              }


              {
              // rc_builtin/value7_0 = rc_builtin__value6_0 * offset_size + column7_row236.
              let val := addmod(
                mulmod(
                  /*intermediate_value/rc_builtin/value6_0*/ mload(0x2bc0),
                  /*offset_size*/ mload(0x140),
                  PRIME),
                /*column7_row236*/ mload(0x1780),
                PRIME)
              mstore(0x2be0, val)
              }


              {
              // ecdsa/signature0/doubling_key/x_squared = column8_row1 * column8_row1.
              let val := mulmod(/*column8_row1*/ mload(0x1a00), /*column8_row1*/ mload(0x1a00), PRIME)
              mstore(0x2c00, val)
              }


              {
              // ecdsa/signature0/exponentiate_generator/bit_0 = column8_row59 - (column8_row187 + column8_row187).
              let val := addmod(
                /*column8_row59*/ mload(0x1ea0),
                sub(
                  PRIME,
                  addmod(/*column8_row187*/ mload(0x2100), /*column8_row187*/ mload(0x2100), PRIME)),
                PRIME)
              mstore(0x2c20, val)
              }


              {
              // ecdsa/signature0/exponentiate_generator/bit_neg_0 = 1 - ecdsa__signature0__exponentiate_generator__bit_0.
              let val := addmod(
                1,
                sub(
                  PRIME,
                  /*intermediate_value/ecdsa/signature0/exponentiate_generator/bit_0*/ mload(0x2c20)),
                PRIME)
              mstore(0x2c40, val)
              }


              {
              // ecdsa/signature0/exponentiate_key/bit_0 = column8_row9 - (column8_row73 + column8_row73).
              let val := addmod(
                /*column8_row9*/ mload(0x1b00),
                sub(
                  PRIME,
                  addmod(/*column8_row73*/ mload(0x1f40), /*column8_row73*/ mload(0x1f40), PRIME)),
                PRIME)
              mstore(0x2c60, val)
              }


              {
              // ecdsa/signature0/exponentiate_key/bit_neg_0 = 1 - ecdsa__signature0__exponentiate_key__bit_0.
              let val := addmod(
                1,
                sub(
                  PRIME,
                  /*intermediate_value/ecdsa/signature0/exponentiate_key/bit_0*/ mload(0x2c60)),
                PRIME)
              mstore(0x2c80, val)
              }


              {
              // bitwise/sum_var_0_0 = column7_row1 + column7_row17 * 2 + column7_row33 * 4 + column7_row49 * 8 + column7_row65 * 18446744073709551616 + column7_row81 * 36893488147419103232 + column7_row97 * 73786976294838206464 + column7_row113 * 147573952589676412928.
              let val := addmod(
                addmod(
                  addmod(
                    addmod(
                      addmod(
                        addmod(
                          addmod(
                            /*column7_row1*/ mload(0x1300),
                            mulmod(/*column7_row17*/ mload(0x14a0), 2, PRIME),
                            PRIME),
                          mulmod(/*column7_row33*/ mload(0x1520), 4, PRIME),
                          PRIME),
                        mulmod(/*column7_row49*/ mload(0x1560), 8, PRIME),
                        PRIME),
                      mulmod(/*column7_row65*/ mload(0x1580), 18446744073709551616, PRIME),
                      PRIME),
                    mulmod(/*column7_row81*/ mload(0x15c0), 36893488147419103232, PRIME),
                    PRIME),
                  mulmod(/*column7_row97*/ mload(0x15e0), 73786976294838206464, PRIME),
                  PRIME),
                mulmod(/*column7_row113*/ mload(0x1620), 147573952589676412928, PRIME),
                PRIME)
              mstore(0x2ca0, val)
              }


              {
              // bitwise/sum_var_8_0 = column7_row129 * 340282366920938463463374607431768211456 + column7_row145 * 680564733841876926926749214863536422912 + column7_row161 * 1361129467683753853853498429727072845824 + column7_row177 * 2722258935367507707706996859454145691648 + column7_row193 * 6277101735386680763835789423207666416102355444464034512896 + column7_row209 * 12554203470773361527671578846415332832204710888928069025792 + column7_row225 * 25108406941546723055343157692830665664409421777856138051584 + column7_row241 * 50216813883093446110686315385661331328818843555712276103168.
              let val := addmod(
                addmod(
                  addmod(
                    addmod(
                      addmod(
                        addmod(
                          addmod(
                            mulmod(/*column7_row129*/ mload(0x1640), 340282366920938463463374607431768211456, PRIME),
                            mulmod(/*column7_row145*/ mload(0x1680), 680564733841876926926749214863536422912, PRIME),
                            PRIME),
                          mulmod(/*column7_row161*/ mload(0x16a0), 1361129467683753853853498429727072845824, PRIME),
                          PRIME),
                        mulmod(/*column7_row177*/ mload(0x16e0), 2722258935367507707706996859454145691648, PRIME),
                        PRIME),
                      mulmod(
                        /*column7_row193*/ mload(0x1700),
                        6277101735386680763835789423207666416102355444464034512896,
                        PRIME),
                      PRIME),
                    mulmod(
                      /*column7_row209*/ mload(0x1740),
                      12554203470773361527671578846415332832204710888928069025792,
                      PRIME),
                    PRIME),
                  mulmod(
                    /*column7_row225*/ mload(0x1760),
                    25108406941546723055343157692830665664409421777856138051584,
                    PRIME),
                  PRIME),
                mulmod(
                  /*column7_row241*/ mload(0x17a0),
                  50216813883093446110686315385661331328818843555712276103168,
                  PRIME),
                PRIME)
              mstore(0x2cc0, val)
              }


              {
              // ec_op/doubling_q/x_squared_0 = column8_row41 * column8_row41.
              let val := mulmod(/*column8_row41*/ mload(0x1d80), /*column8_row41*/ mload(0x1d80), PRIME)
              mstore(0x2ce0, val)
              }


              {
              // ec_op/ec_subset_sum/bit_0 = column8_row21 - (column8_row85 + column8_row85).
              let val := addmod(
                /*column8_row21*/ mload(0x1c20),
                sub(
                  PRIME,
                  addmod(/*column8_row85*/ mload(0x1fa0), /*column8_row85*/ mload(0x1fa0), PRIME)),
                PRIME)
              mstore(0x2d00, val)
              }


              {
              // ec_op/ec_subset_sum/bit_neg_0 = 1 - ec_op__ec_subset_sum__bit_0.
              let val := addmod(
                1,
                sub(PRIME, /*intermediate_value/ec_op/ec_subset_sum/bit_0*/ mload(0x2d00)),
                PRIME)
              mstore(0x2d20, val)
              }


              {
              // poseidon/poseidon/full_rounds_state0_cubed_0 = column8_row53 * column8_row29.
              let val := mulmod(/*column8_row53*/ mload(0x1e40), /*column8_row29*/ mload(0x1cc0), PRIME)
              mstore(0x2d40, val)
              }


              {
              // poseidon/poseidon/full_rounds_state1_cubed_0 = column8_row13 * column8_row61.
              let val := mulmod(/*column8_row13*/ mload(0x1b80), /*column8_row61*/ mload(0x1ec0), PRIME)
              mstore(0x2d60, val)
              }


              {
              // poseidon/poseidon/full_rounds_state2_cubed_0 = column8_row45 * column8_row3.
              let val := mulmod(/*column8_row45*/ mload(0x1dc0), /*column8_row3*/ mload(0x1a40), PRIME)
              mstore(0x2d80, val)
              }


              {
              // poseidon/poseidon/full_rounds_state0_cubed_7 = column8_row501 * column8_row477.
              let val := mulmod(/*column8_row501*/ mload(0x23a0), /*column8_row477*/ mload(0x2360), PRIME)
              mstore(0x2da0, val)
              }


              {
              // poseidon/poseidon/full_rounds_state1_cubed_7 = column8_row461 * column8_row509.
              let val := mulmod(/*column8_row461*/ mload(0x2340), /*column8_row509*/ mload(0x23c0), PRIME)
              mstore(0x2dc0, val)
              }


              {
              // poseidon/poseidon/full_rounds_state2_cubed_7 = column8_row493 * column8_row451.
              let val := mulmod(/*column8_row493*/ mload(0x2380), /*column8_row451*/ mload(0x2320), PRIME)
              mstore(0x2de0, val)
              }


              {
              // poseidon/poseidon/full_rounds_state0_cubed_3 = column8_row245 * column8_row221.
              let val := mulmod(/*column8_row245*/ mload(0x21c0), /*column8_row221*/ mload(0x2180), PRIME)
              mstore(0x2e00, val)
              }


              {
              // poseidon/poseidon/full_rounds_state1_cubed_3 = column8_row205 * column8_row253.
              let val := mulmod(/*column8_row205*/ mload(0x2140), /*column8_row253*/ mload(0x21e0), PRIME)
              mstore(0x2e20, val)
              }


              {
              // poseidon/poseidon/full_rounds_state2_cubed_3 = column8_row237 * column8_row195.
              let val := mulmod(/*column8_row237*/ mload(0x21a0), /*column8_row195*/ mload(0x2120), PRIME)
              mstore(0x2e40, val)
              }


              {
              // poseidon/poseidon/partial_rounds_state0_cubed_0 = column7_row3 * column7_row7.
              let val := mulmod(/*column7_row3*/ mload(0x1340), /*column7_row7*/ mload(0x13c0), PRIME)
              mstore(0x2e60, val)
              }


              {
              // poseidon/poseidon/partial_rounds_state0_cubed_1 = column7_row11 * column7_row15.
              let val := mulmod(/*column7_row11*/ mload(0x1420), /*column7_row15*/ mload(0x1480), PRIME)
              mstore(0x2e80, val)
              }


              {
              // poseidon/poseidon/partial_rounds_state0_cubed_2 = column7_row19 * column7_row23.
              let val := mulmod(/*column7_row19*/ mload(0x14c0), /*column7_row23*/ mload(0x14e0), PRIME)
              mstore(0x2ea0, val)
              }


              {
              // poseidon/poseidon/partial_rounds_state1_cubed_0 = column8_row6 * column8_row14.
              let val := mulmod(/*column8_row6*/ mload(0x1aa0), /*column8_row14*/ mload(0x1ba0), PRIME)
              mstore(0x2ec0, val)
              }


              {
              // poseidon/poseidon/partial_rounds_state1_cubed_1 = column8_row22 * column8_row30.
              let val := mulmod(/*column8_row22*/ mload(0x1c40), /*column8_row30*/ mload(0x1ce0), PRIME)
              mstore(0x2ee0, val)
              }


              {
              // poseidon/poseidon/partial_rounds_state1_cubed_2 = column8_row38 * column8_row46.
              let val := mulmod(/*column8_row38*/ mload(0x1d60), /*column8_row46*/ mload(0x1de0), PRIME)
              mstore(0x2f00, val)
              }


              {
              // poseidon/poseidon/partial_rounds_state1_cubed_19 = column8_row310 * column8_row318.
              let val := mulmod(/*column8_row310*/ mload(0x2260), /*column8_row318*/ mload(0x2280), PRIME)
              mstore(0x2f20, val)
              }


              {
              // poseidon/poseidon/partial_rounds_state1_cubed_20 = column8_row326 * column8_row334.
              let val := mulmod(/*column8_row326*/ mload(0x22a0), /*column8_row334*/ mload(0x22c0), PRIME)
              mstore(0x2f40, val)
              }


              {
              // poseidon/poseidon/partial_rounds_state1_cubed_21 = column8_row342 * column8_row350.
              let val := mulmod(/*column8_row342*/ mload(0x22e0), /*column8_row350*/ mload(0x2300), PRIME)
              mstore(0x2f60, val)
              }


              let composition_alpha_pow := 1
              let composition_alpha := /*composition_alpha*/ mload(0x640)
              {
              // Constraint expression for cpu/decode/opcode_rc/bit: cpu__decode__opcode_rc__bit_0 * cpu__decode__opcode_rc__bit_0 - cpu__decode__opcode_rc__bit_0.
              let val := addmod(
                mulmod(
                  /*intermediate_value/cpu/decode/opcode_rc/bit_0*/ mload(0x2800),
                  /*intermediate_value/cpu/decode/opcode_rc/bit_0*/ mload(0x2800),
                  PRIME),
                sub(PRIME, /*intermediate_value/cpu/decode/opcode_rc/bit_0*/ mload(0x2800)),
                PRIME)

              // Numerator: point^(trace_length / 16) - trace_generator^(15 * trace_length / 16).
              // val *= domains[4].
              val := mulmod(val, /*domains[4]*/ mload(0x36c0), PRIME)
              // Denominator: point^trace_length - 1.
              // val *= denominator_invs[0].
              val := mulmod(val, /*denominator_invs[0]*/ mload(0x3b60), PRIME)

              // res += val * alpha ** 0.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/decode/opcode_rc/zero: column0_row0.
              let val := /*column0_row0*/ mload(0x660)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - trace_generator^(15 * trace_length / 16).
              // val *= denominator_invs[1].
              val := mulmod(val, /*denominator_invs[1]*/ mload(0x3b80), PRIME)

              // res += val * alpha ** 1.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/decode/opcode_rc_input: column5_row1 - (((column0_row0 * offset_size + column7_row4) * offset_size + column7_row8) * offset_size + column7_row0).
              let val := addmod(
                /*column5_row1*/ mload(0xb00),
                sub(
                  PRIME,
                  addmod(
                    mulmod(
                      addmod(
                        mulmod(
                          addmod(
                            mulmod(/*column0_row0*/ mload(0x660), /*offset_size*/ mload(0x140), PRIME),
                            /*column7_row4*/ mload(0x1360),
                            PRIME),
                          /*offset_size*/ mload(0x140),
                          PRIME),
                        /*column7_row8*/ mload(0x13e0),
                        PRIME),
                      /*offset_size*/ mload(0x140),
                      PRIME),
                    /*column7_row0*/ mload(0x12e0),
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 2.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/decode/flag_op1_base_op0_bit: cpu__decode__flag_op1_base_op0_0 * cpu__decode__flag_op1_base_op0_0 - cpu__decode__flag_op1_base_op0_0.
              let val := addmod(
                mulmod(
                  /*intermediate_value/cpu/decode/flag_op1_base_op0_0*/ mload(0x2880),
                  /*intermediate_value/cpu/decode/flag_op1_base_op0_0*/ mload(0x2880),
                  PRIME),
                sub(PRIME, /*intermediate_value/cpu/decode/flag_op1_base_op0_0*/ mload(0x2880)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 3.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/decode/flag_res_op1_bit: cpu__decode__flag_res_op1_0 * cpu__decode__flag_res_op1_0 - cpu__decode__flag_res_op1_0.
              let val := addmod(
                mulmod(
                  /*intermediate_value/cpu/decode/flag_res_op1_0*/ mload(0x2900),
                  /*intermediate_value/cpu/decode/flag_res_op1_0*/ mload(0x2900),
                  PRIME),
                sub(PRIME, /*intermediate_value/cpu/decode/flag_res_op1_0*/ mload(0x2900)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 4.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/decode/flag_pc_update_regular_bit: cpu__decode__flag_pc_update_regular_0 * cpu__decode__flag_pc_update_regular_0 - cpu__decode__flag_pc_update_regular_0.
              let val := addmod(
                mulmod(
                  /*intermediate_value/cpu/decode/flag_pc_update_regular_0*/ mload(0x2960),
                  /*intermediate_value/cpu/decode/flag_pc_update_regular_0*/ mload(0x2960),
                  PRIME),
                sub(PRIME, /*intermediate_value/cpu/decode/flag_pc_update_regular_0*/ mload(0x2960)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 5.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/decode/fp_update_regular_bit: cpu__decode__fp_update_regular_0 * cpu__decode__fp_update_regular_0 - cpu__decode__fp_update_regular_0.
              let val := addmod(
                mulmod(
                  /*intermediate_value/cpu/decode/fp_update_regular_0*/ mload(0x29c0),
                  /*intermediate_value/cpu/decode/fp_update_regular_0*/ mload(0x29c0),
                  PRIME),
                sub(PRIME, /*intermediate_value/cpu/decode/fp_update_regular_0*/ mload(0x29c0)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 6.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/operands/mem_dst_addr: column5_row8 + half_offset_size - (cpu__decode__opcode_rc__bit_0 * column8_row8 + (1 - cpu__decode__opcode_rc__bit_0) * column8_row0 + column7_row0).
              let val := addmod(
                addmod(/*column5_row8*/ mload(0xbe0), /*half_offset_size*/ mload(0x160), PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      mulmod(
                        /*intermediate_value/cpu/decode/opcode_rc/bit_0*/ mload(0x2800),
                        /*column8_row8*/ mload(0x1ae0),
                        PRIME),
                      mulmod(
                        addmod(
                          1,
                          sub(PRIME, /*intermediate_value/cpu/decode/opcode_rc/bit_0*/ mload(0x2800)),
                          PRIME),
                        /*column8_row0*/ mload(0x19e0),
                        PRIME),
                      PRIME),
                    /*column7_row0*/ mload(0x12e0),
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 7.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/operands/mem0_addr: column5_row4 + half_offset_size - (cpu__decode__opcode_rc__bit_1 * column8_row8 + (1 - cpu__decode__opcode_rc__bit_1) * column8_row0 + column7_row8).
              let val := addmod(
                addmod(/*column5_row4*/ mload(0xb60), /*half_offset_size*/ mload(0x160), PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      mulmod(
                        /*intermediate_value/cpu/decode/opcode_rc/bit_1*/ mload(0x29e0),
                        /*column8_row8*/ mload(0x1ae0),
                        PRIME),
                      mulmod(
                        addmod(
                          1,
                          sub(PRIME, /*intermediate_value/cpu/decode/opcode_rc/bit_1*/ mload(0x29e0)),
                          PRIME),
                        /*column8_row0*/ mload(0x19e0),
                        PRIME),
                      PRIME),
                    /*column7_row8*/ mload(0x13e0),
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 8.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/operands/mem1_addr: column5_row12 + half_offset_size - (cpu__decode__opcode_rc__bit_2 * column5_row0 + cpu__decode__opcode_rc__bit_4 * column8_row0 + cpu__decode__opcode_rc__bit_3 * column8_row8 + cpu__decode__flag_op1_base_op0_0 * column5_row5 + column7_row4).
              let val := addmod(
                addmod(/*column5_row12*/ mload(0xc20), /*half_offset_size*/ mload(0x160), PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      addmod(
                        addmod(
                          mulmod(
                            /*intermediate_value/cpu/decode/opcode_rc/bit_2*/ mload(0x2820),
                            /*column5_row0*/ mload(0xae0),
                            PRIME),
                          mulmod(
                            /*intermediate_value/cpu/decode/opcode_rc/bit_4*/ mload(0x2840),
                            /*column8_row0*/ mload(0x19e0),
                            PRIME),
                          PRIME),
                        mulmod(
                          /*intermediate_value/cpu/decode/opcode_rc/bit_3*/ mload(0x2860),
                          /*column8_row8*/ mload(0x1ae0),
                          PRIME),
                        PRIME),
                      mulmod(
                        /*intermediate_value/cpu/decode/flag_op1_base_op0_0*/ mload(0x2880),
                        /*column5_row5*/ mload(0xb80),
                        PRIME),
                      PRIME),
                    /*column7_row4*/ mload(0x1360),
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 9.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/operands/ops_mul: column8_row4 - column5_row5 * column5_row13.
              let val := addmod(
                /*column8_row4*/ mload(0x1a60),
                sub(
                  PRIME,
                  mulmod(/*column5_row5*/ mload(0xb80), /*column5_row13*/ mload(0xc40), PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 10.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/operands/res: (1 - cpu__decode__opcode_rc__bit_9) * column8_row12 - (cpu__decode__opcode_rc__bit_5 * (column5_row5 + column5_row13) + cpu__decode__opcode_rc__bit_6 * column8_row4 + cpu__decode__flag_res_op1_0 * column5_row13).
              let val := addmod(
                mulmod(
                  addmod(
                    1,
                    sub(PRIME, /*intermediate_value/cpu/decode/opcode_rc/bit_9*/ mload(0x28e0)),
                    PRIME),
                  /*column8_row12*/ mload(0x1b60),
                  PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      mulmod(
                        /*intermediate_value/cpu/decode/opcode_rc/bit_5*/ mload(0x28a0),
                        addmod(/*column5_row5*/ mload(0xb80), /*column5_row13*/ mload(0xc40), PRIME),
                        PRIME),
                      mulmod(
                        /*intermediate_value/cpu/decode/opcode_rc/bit_6*/ mload(0x28c0),
                        /*column8_row4*/ mload(0x1a60),
                        PRIME),
                      PRIME),
                    mulmod(
                      /*intermediate_value/cpu/decode/flag_res_op1_0*/ mload(0x2900),
                      /*column5_row13*/ mload(0xc40),
                      PRIME),
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 11.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/update_registers/update_pc/tmp0: column8_row2 - cpu__decode__opcode_rc__bit_9 * column5_row9.
              let val := addmod(
                /*column8_row2*/ mload(0x1a20),
                sub(
                  PRIME,
                  mulmod(
                    /*intermediate_value/cpu/decode/opcode_rc/bit_9*/ mload(0x28e0),
                    /*column5_row9*/ mload(0xc00),
                    PRIME)),
                PRIME)

              // Numerator: point - trace_generator^(16 * (trace_length / 16 - 1)).
              // val *= domains[31].
              val := mulmod(val, /*domains[31]*/ mload(0x3a20), PRIME)
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 12.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/update_registers/update_pc/tmp1: column8_row10 - column8_row2 * column8_row12.
              let val := addmod(
                /*column8_row10*/ mload(0x1b20),
                sub(
                  PRIME,
                  mulmod(/*column8_row2*/ mload(0x1a20), /*column8_row12*/ mload(0x1b60), PRIME)),
                PRIME)

              // Numerator: point - trace_generator^(16 * (trace_length / 16 - 1)).
              // val *= domains[31].
              val := mulmod(val, /*domains[31]*/ mload(0x3a20), PRIME)
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 13.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/update_registers/update_pc/pc_cond_negative: (1 - cpu__decode__opcode_rc__bit_9) * column5_row16 + column8_row2 * (column5_row16 - (column5_row0 + column5_row13)) - (cpu__decode__flag_pc_update_regular_0 * npc_reg_0 + cpu__decode__opcode_rc__bit_7 * column8_row12 + cpu__decode__opcode_rc__bit_8 * (column5_row0 + column8_row12)).
              let val := addmod(
                addmod(
                  mulmod(
                    addmod(
                      1,
                      sub(PRIME, /*intermediate_value/cpu/decode/opcode_rc/bit_9*/ mload(0x28e0)),
                      PRIME),
                    /*column5_row16*/ mload(0xc60),
                    PRIME),
                  mulmod(
                    /*column8_row2*/ mload(0x1a20),
                    addmod(
                      /*column5_row16*/ mload(0xc60),
                      sub(
                        PRIME,
                        addmod(/*column5_row0*/ mload(0xae0), /*column5_row13*/ mload(0xc40), PRIME)),
                      PRIME),
                    PRIME),
                  PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      mulmod(
                        /*intermediate_value/cpu/decode/flag_pc_update_regular_0*/ mload(0x2960),
                        /*intermediate_value/npc_reg_0*/ mload(0x2a00),
                        PRIME),
                      mulmod(
                        /*intermediate_value/cpu/decode/opcode_rc/bit_7*/ mload(0x2920),
                        /*column8_row12*/ mload(0x1b60),
                        PRIME),
                      PRIME),
                    mulmod(
                      /*intermediate_value/cpu/decode/opcode_rc/bit_8*/ mload(0x2940),
                      addmod(/*column5_row0*/ mload(0xae0), /*column8_row12*/ mload(0x1b60), PRIME),
                      PRIME),
                    PRIME)),
                PRIME)

              // Numerator: point - trace_generator^(16 * (trace_length / 16 - 1)).
              // val *= domains[31].
              val := mulmod(val, /*domains[31]*/ mload(0x3a20), PRIME)
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 14.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/update_registers/update_pc/pc_cond_positive: (column8_row10 - cpu__decode__opcode_rc__bit_9) * (column5_row16 - npc_reg_0).
              let val := mulmod(
                addmod(
                  /*column8_row10*/ mload(0x1b20),
                  sub(PRIME, /*intermediate_value/cpu/decode/opcode_rc/bit_9*/ mload(0x28e0)),
                  PRIME),
                addmod(
                  /*column5_row16*/ mload(0xc60),
                  sub(PRIME, /*intermediate_value/npc_reg_0*/ mload(0x2a00)),
                  PRIME),
                PRIME)

              // Numerator: point - trace_generator^(16 * (trace_length / 16 - 1)).
              // val *= domains[31].
              val := mulmod(val, /*domains[31]*/ mload(0x3a20), PRIME)
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 15.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/update_registers/update_ap/ap_update: column8_row16 - (column8_row0 + cpu__decode__opcode_rc__bit_10 * column8_row12 + cpu__decode__opcode_rc__bit_11 + cpu__decode__opcode_rc__bit_12 * 2).
              let val := addmod(
                /*column8_row16*/ mload(0x1bc0),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      addmod(
                        /*column8_row0*/ mload(0x19e0),
                        mulmod(
                          /*intermediate_value/cpu/decode/opcode_rc/bit_10*/ mload(0x2a20),
                          /*column8_row12*/ mload(0x1b60),
                          PRIME),
                        PRIME),
                      /*intermediate_value/cpu/decode/opcode_rc/bit_11*/ mload(0x2a40),
                      PRIME),
                    mulmod(/*intermediate_value/cpu/decode/opcode_rc/bit_12*/ mload(0x2980), 2, PRIME),
                    PRIME)),
                PRIME)

              // Numerator: point - trace_generator^(16 * (trace_length / 16 - 1)).
              // val *= domains[31].
              val := mulmod(val, /*domains[31]*/ mload(0x3a20), PRIME)
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 16.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/update_registers/update_fp/fp_update: column8_row24 - (cpu__decode__fp_update_regular_0 * column8_row8 + cpu__decode__opcode_rc__bit_13 * column5_row9 + cpu__decode__opcode_rc__bit_12 * (column8_row0 + 2)).
              let val := addmod(
                /*column8_row24*/ mload(0x1c60),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      mulmod(
                        /*intermediate_value/cpu/decode/fp_update_regular_0*/ mload(0x29c0),
                        /*column8_row8*/ mload(0x1ae0),
                        PRIME),
                      mulmod(
                        /*intermediate_value/cpu/decode/opcode_rc/bit_13*/ mload(0x29a0),
                        /*column5_row9*/ mload(0xc00),
                        PRIME),
                      PRIME),
                    mulmod(
                      /*intermediate_value/cpu/decode/opcode_rc/bit_12*/ mload(0x2980),
                      addmod(/*column8_row0*/ mload(0x19e0), 2, PRIME),
                      PRIME),
                    PRIME)),
                PRIME)

              // Numerator: point - trace_generator^(16 * (trace_length / 16 - 1)).
              // val *= domains[31].
              val := mulmod(val, /*domains[31]*/ mload(0x3a20), PRIME)
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 17.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/opcodes/call/push_fp: cpu__decode__opcode_rc__bit_12 * (column5_row9 - column8_row8).
              let val := mulmod(
                /*intermediate_value/cpu/decode/opcode_rc/bit_12*/ mload(0x2980),
                addmod(/*column5_row9*/ mload(0xc00), sub(PRIME, /*column8_row8*/ mload(0x1ae0)), PRIME),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 18.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/opcodes/call/push_pc: cpu__decode__opcode_rc__bit_12 * (column5_row5 - (column5_row0 + cpu__decode__opcode_rc__bit_2 + 1)).
              let val := mulmod(
                /*intermediate_value/cpu/decode/opcode_rc/bit_12*/ mload(0x2980),
                addmod(
                  /*column5_row5*/ mload(0xb80),
                  sub(
                    PRIME,
                    addmod(
                      addmod(
                        /*column5_row0*/ mload(0xae0),
                        /*intermediate_value/cpu/decode/opcode_rc/bit_2*/ mload(0x2820),
                        PRIME),
                      1,
                      PRIME)),
                  PRIME),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 19.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/opcodes/call/off0: cpu__decode__opcode_rc__bit_12 * (column7_row0 - half_offset_size).
              let val := mulmod(
                /*intermediate_value/cpu/decode/opcode_rc/bit_12*/ mload(0x2980),
                addmod(
                  /*column7_row0*/ mload(0x12e0),
                  sub(PRIME, /*half_offset_size*/ mload(0x160)),
                  PRIME),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 20.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/opcodes/call/off1: cpu__decode__opcode_rc__bit_12 * (column7_row8 - (half_offset_size + 1)).
              let val := mulmod(
                /*intermediate_value/cpu/decode/opcode_rc/bit_12*/ mload(0x2980),
                addmod(
                  /*column7_row8*/ mload(0x13e0),
                  sub(PRIME, addmod(/*half_offset_size*/ mload(0x160), 1, PRIME)),
                  PRIME),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 21.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/opcodes/call/flags: cpu__decode__opcode_rc__bit_12 * (cpu__decode__opcode_rc__bit_12 + cpu__decode__opcode_rc__bit_12 + 1 + 1 - (cpu__decode__opcode_rc__bit_0 + cpu__decode__opcode_rc__bit_1 + 4)).
              let val := mulmod(
                /*intermediate_value/cpu/decode/opcode_rc/bit_12*/ mload(0x2980),
                addmod(
                  addmod(
                    addmod(
                      addmod(
                        /*intermediate_value/cpu/decode/opcode_rc/bit_12*/ mload(0x2980),
                        /*intermediate_value/cpu/decode/opcode_rc/bit_12*/ mload(0x2980),
                        PRIME),
                      1,
                      PRIME),
                    1,
                    PRIME),
                  sub(
                    PRIME,
                    addmod(
                      addmod(
                        /*intermediate_value/cpu/decode/opcode_rc/bit_0*/ mload(0x2800),
                        /*intermediate_value/cpu/decode/opcode_rc/bit_1*/ mload(0x29e0),
                        PRIME),
                      4,
                      PRIME)),
                  PRIME),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 22.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/opcodes/ret/off0: cpu__decode__opcode_rc__bit_13 * (column7_row0 + 2 - half_offset_size).
              let val := mulmod(
                /*intermediate_value/cpu/decode/opcode_rc/bit_13*/ mload(0x29a0),
                addmod(
                  addmod(/*column7_row0*/ mload(0x12e0), 2, PRIME),
                  sub(PRIME, /*half_offset_size*/ mload(0x160)),
                  PRIME),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 23.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/opcodes/ret/off2: cpu__decode__opcode_rc__bit_13 * (column7_row4 + 1 - half_offset_size).
              let val := mulmod(
                /*intermediate_value/cpu/decode/opcode_rc/bit_13*/ mload(0x29a0),
                addmod(
                  addmod(/*column7_row4*/ mload(0x1360), 1, PRIME),
                  sub(PRIME, /*half_offset_size*/ mload(0x160)),
                  PRIME),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 24.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/opcodes/ret/flags: cpu__decode__opcode_rc__bit_13 * (cpu__decode__opcode_rc__bit_7 + cpu__decode__opcode_rc__bit_0 + cpu__decode__opcode_rc__bit_3 + cpu__decode__flag_res_op1_0 - 4).
              let val := mulmod(
                /*intermediate_value/cpu/decode/opcode_rc/bit_13*/ mload(0x29a0),
                addmod(
                  addmod(
                    addmod(
                      addmod(
                        /*intermediate_value/cpu/decode/opcode_rc/bit_7*/ mload(0x2920),
                        /*intermediate_value/cpu/decode/opcode_rc/bit_0*/ mload(0x2800),
                        PRIME),
                      /*intermediate_value/cpu/decode/opcode_rc/bit_3*/ mload(0x2860),
                      PRIME),
                    /*intermediate_value/cpu/decode/flag_res_op1_0*/ mload(0x2900),
                    PRIME),
                  sub(PRIME, 4),
                  PRIME),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 25.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for cpu/opcodes/assert_eq/assert_eq: cpu__decode__opcode_rc__bit_14 * (column5_row9 - column8_row12).
              let val := mulmod(
                /*intermediate_value/cpu/decode/opcode_rc/bit_14*/ mload(0x2a60),
                addmod(/*column5_row9*/ mload(0xc00), sub(PRIME, /*column8_row12*/ mload(0x1b60)), PRIME),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 26.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for initial_ap: column8_row0 - initial_ap.
              let val := addmod(/*column8_row0*/ mload(0x19e0), sub(PRIME, /*initial_ap*/ mload(0x180)), PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - 1.
              // val *= denominator_invs[4].
              val := mulmod(val, /*denominator_invs[4]*/ mload(0x3be0), PRIME)

              // res += val * alpha ** 27.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for initial_fp: column8_row8 - initial_ap.
              let val := addmod(/*column8_row8*/ mload(0x1ae0), sub(PRIME, /*initial_ap*/ mload(0x180)), PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - 1.
              // val *= denominator_invs[4].
              val := mulmod(val, /*denominator_invs[4]*/ mload(0x3be0), PRIME)

              // res += val * alpha ** 28.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for initial_pc: column5_row0 - initial_pc.
              let val := addmod(/*column5_row0*/ mload(0xae0), sub(PRIME, /*initial_pc*/ mload(0x1a0)), PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - 1.
              // val *= denominator_invs[4].
              val := mulmod(val, /*denominator_invs[4]*/ mload(0x3be0), PRIME)

              // res += val * alpha ** 29.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for final_ap: column8_row0 - final_ap.
              let val := addmod(/*column8_row0*/ mload(0x19e0), sub(PRIME, /*final_ap*/ mload(0x1c0)), PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - trace_generator^(16 * (trace_length / 16 - 1)).
              // val *= denominator_invs[3].
              val := mulmod(val, /*denominator_invs[3]*/ mload(0x3bc0), PRIME)

              // res += val * alpha ** 30.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for final_fp: column8_row8 - initial_ap.
              let val := addmod(/*column8_row8*/ mload(0x1ae0), sub(PRIME, /*initial_ap*/ mload(0x180)), PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - trace_generator^(16 * (trace_length / 16 - 1)).
              // val *= denominator_invs[3].
              val := mulmod(val, /*denominator_invs[3]*/ mload(0x3bc0), PRIME)

              // res += val * alpha ** 31.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for final_pc: column5_row0 - final_pc.
              let val := addmod(/*column5_row0*/ mload(0xae0), sub(PRIME, /*final_pc*/ mload(0x1e0)), PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - trace_generator^(16 * (trace_length / 16 - 1)).
              // val *= denominator_invs[3].
              val := mulmod(val, /*denominator_invs[3]*/ mload(0x3bc0), PRIME)

              // res += val * alpha ** 32.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for memory/multi_column_perm/perm/init0: (memory/multi_column_perm/perm/interaction_elm - (column6_row0 + memory/multi_column_perm/hash_interaction_elm0 * column6_row1)) * column9_inter1_row0 + column5_row0 + memory/multi_column_perm/hash_interaction_elm0 * column5_row1 - memory/multi_column_perm/perm/interaction_elm.
              let val := addmod(
                addmod(
                  addmod(
                    mulmod(
                      addmod(
                        /*memory/multi_column_perm/perm/interaction_elm*/ mload(0x200),
                        sub(
                          PRIME,
                          addmod(
                            /*column6_row0*/ mload(0x1260),
                            mulmod(
                              /*memory/multi_column_perm/hash_interaction_elm0*/ mload(0x220),
                              /*column6_row1*/ mload(0x1280),
                              PRIME),
                            PRIME)),
                        PRIME),
                      /*column9_inter1_row0*/ mload(0x2700),
                      PRIME),
                    /*column5_row0*/ mload(0xae0),
                    PRIME),
                  mulmod(
                    /*memory/multi_column_perm/hash_interaction_elm0*/ mload(0x220),
                    /*column5_row1*/ mload(0xb00),
                    PRIME),
                  PRIME),
                sub(PRIME, /*memory/multi_column_perm/perm/interaction_elm*/ mload(0x200)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - 1.
              // val *= denominator_invs[4].
              val := mulmod(val, /*denominator_invs[4]*/ mload(0x3be0), PRIME)

              // res += val * alpha ** 33.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for memory/multi_column_perm/perm/step0: (memory/multi_column_perm/perm/interaction_elm - (column6_row2 + memory/multi_column_perm/hash_interaction_elm0 * column6_row3)) * column9_inter1_row2 - (memory/multi_column_perm/perm/interaction_elm - (column5_row2 + memory/multi_column_perm/hash_interaction_elm0 * column5_row3)) * column9_inter1_row0.
              let val := addmod(
                mulmod(
                  addmod(
                    /*memory/multi_column_perm/perm/interaction_elm*/ mload(0x200),
                    sub(
                      PRIME,
                      addmod(
                        /*column6_row2*/ mload(0x12a0),
                        mulmod(
                          /*memory/multi_column_perm/hash_interaction_elm0*/ mload(0x220),
                          /*column6_row3*/ mload(0x12c0),
                          PRIME),
                        PRIME)),
                    PRIME),
                  /*column9_inter1_row2*/ mload(0x2740),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                    addmod(
                      /*memory/multi_column_perm/perm/interaction_elm*/ mload(0x200),
                      sub(
                        PRIME,
                        addmod(
                          /*column5_row2*/ mload(0xb20),
                          mulmod(
                            /*memory/multi_column_perm/hash_interaction_elm0*/ mload(0x220),
                            /*column5_row3*/ mload(0xb40),
                            PRIME),
                          PRIME)),
                      PRIME),
                    /*column9_inter1_row0*/ mload(0x2700),
                    PRIME)),
                PRIME)

              // Numerator: point - trace_generator^(2 * (trace_length / 2 - 1)).
              // val *= domains[33].
              val := mulmod(val, /*domains[33]*/ mload(0x3a60), PRIME)
              // Denominator: point^(trace_length / 2) - 1.
              // val *= denominator_invs[5].
              val := mulmod(val, /*denominator_invs[5]*/ mload(0x3c00), PRIME)

              // res += val * alpha ** 34.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for memory/multi_column_perm/perm/last: column9_inter1_row0 - memory/multi_column_perm/perm/public_memory_prod.
              let val := addmod(
                /*column9_inter1_row0*/ mload(0x2700),
                sub(PRIME, /*memory/multi_column_perm/perm/public_memory_prod*/ mload(0x240)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - trace_generator^(2 * (trace_length / 2 - 1)).
              // val *= denominator_invs[6].
              val := mulmod(val, /*denominator_invs[6]*/ mload(0x3c20), PRIME)

              // res += val * alpha ** 35.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for memory/diff_is_bit: memory__address_diff_0 * memory__address_diff_0 - memory__address_diff_0.
              let val := addmod(
                mulmod(
                  /*intermediate_value/memory/address_diff_0*/ mload(0x2a80),
                  /*intermediate_value/memory/address_diff_0*/ mload(0x2a80),
                  PRIME),
                sub(PRIME, /*intermediate_value/memory/address_diff_0*/ mload(0x2a80)),
                PRIME)

              // Numerator: point - trace_generator^(2 * (trace_length / 2 - 1)).
              // val *= domains[33].
              val := mulmod(val, /*domains[33]*/ mload(0x3a60), PRIME)
              // Denominator: point^(trace_length / 2) - 1.
              // val *= denominator_invs[5].
              val := mulmod(val, /*denominator_invs[5]*/ mload(0x3c00), PRIME)

              // res += val * alpha ** 36.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for memory/is_func: (memory__address_diff_0 - 1) * (column6_row1 - column6_row3).
              let val := mulmod(
                addmod(/*intermediate_value/memory/address_diff_0*/ mload(0x2a80), sub(PRIME, 1), PRIME),
                addmod(/*column6_row1*/ mload(0x1280), sub(PRIME, /*column6_row3*/ mload(0x12c0)), PRIME),
                PRIME)

              // Numerator: point - trace_generator^(2 * (trace_length / 2 - 1)).
              // val *= domains[33].
              val := mulmod(val, /*domains[33]*/ mload(0x3a60), PRIME)
              // Denominator: point^(trace_length / 2) - 1.
              // val *= denominator_invs[5].
              val := mulmod(val, /*denominator_invs[5]*/ mload(0x3c00), PRIME)

              // res += val * alpha ** 37.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for memory/initial_addr: column6_row0 - 1.
              let val := addmod(/*column6_row0*/ mload(0x1260), sub(PRIME, 1), PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - 1.
              // val *= denominator_invs[4].
              val := mulmod(val, /*denominator_invs[4]*/ mload(0x3be0), PRIME)

              // res += val * alpha ** 38.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for public_memory_addr_zero: column5_row2.
              let val := /*column5_row2*/ mload(0xb20)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 8) - 1.
              // val *= denominator_invs[7].
              val := mulmod(val, /*denominator_invs[7]*/ mload(0x3c40), PRIME)

              // res += val * alpha ** 39.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for public_memory_value_zero: column5_row3.
              let val := /*column5_row3*/ mload(0xb40)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 8) - 1.
              // val *= denominator_invs[7].
              val := mulmod(val, /*denominator_invs[7]*/ mload(0x3c40), PRIME)

              // res += val * alpha ** 40.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for rc16/perm/init0: (rc16/perm/interaction_elm - column7_row2) * column9_inter1_row1 + column7_row0 - rc16/perm/interaction_elm.
              let val := addmod(
                addmod(
                  mulmod(
                    addmod(
                      /*rc16/perm/interaction_elm*/ mload(0x260),
                      sub(PRIME, /*column7_row2*/ mload(0x1320)),
                      PRIME),
                    /*column9_inter1_row1*/ mload(0x2720),
                    PRIME),
                  /*column7_row0*/ mload(0x12e0),
                  PRIME),
                sub(PRIME, /*rc16/perm/interaction_elm*/ mload(0x260)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - 1.
              // val *= denominator_invs[4].
              val := mulmod(val, /*denominator_invs[4]*/ mload(0x3be0), PRIME)

              // res += val * alpha ** 41.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for rc16/perm/step0: (rc16/perm/interaction_elm - column7_row6) * column9_inter1_row5 - (rc16/perm/interaction_elm - column7_row4) * column9_inter1_row1.
              let val := addmod(
                mulmod(
                  addmod(
                    /*rc16/perm/interaction_elm*/ mload(0x260),
                    sub(PRIME, /*column7_row6*/ mload(0x13a0)),
                    PRIME),
                  /*column9_inter1_row5*/ mload(0x2780),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                    addmod(
                      /*rc16/perm/interaction_elm*/ mload(0x260),
                      sub(PRIME, /*column7_row4*/ mload(0x1360)),
                      PRIME),
                    /*column9_inter1_row1*/ mload(0x2720),
                    PRIME)),
                PRIME)

              // Numerator: point - trace_generator^(4 * (trace_length / 4 - 1)).
              // val *= domains[34].
              val := mulmod(val, /*domains[34]*/ mload(0x3a80), PRIME)
              // Denominator: point^(trace_length / 4) - 1.
              // val *= denominator_invs[8].
              val := mulmod(val, /*denominator_invs[8]*/ mload(0x3c60), PRIME)

              // res += val * alpha ** 42.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for rc16/perm/last: column9_inter1_row1 - rc16/perm/public_memory_prod.
              let val := addmod(
                /*column9_inter1_row1*/ mload(0x2720),
                sub(PRIME, /*rc16/perm/public_memory_prod*/ mload(0x280)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - trace_generator^(4 * (trace_length / 4 - 1)).
              // val *= denominator_invs[9].
              val := mulmod(val, /*denominator_invs[9]*/ mload(0x3c80), PRIME)

              // res += val * alpha ** 43.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for rc16/diff_is_bit: rc16__diff_0 * rc16__diff_0 - rc16__diff_0.
              let val := addmod(
                mulmod(
                  /*intermediate_value/rc16/diff_0*/ mload(0x2aa0),
                  /*intermediate_value/rc16/diff_0*/ mload(0x2aa0),
                  PRIME),
                sub(PRIME, /*intermediate_value/rc16/diff_0*/ mload(0x2aa0)),
                PRIME)

              // Numerator: point - trace_generator^(4 * (trace_length / 4 - 1)).
              // val *= domains[34].
              val := mulmod(val, /*domains[34]*/ mload(0x3a80), PRIME)
              // Denominator: point^(trace_length / 4) - 1.
              // val *= denominator_invs[8].
              val := mulmod(val, /*denominator_invs[8]*/ mload(0x3c60), PRIME)

              // res += val * alpha ** 44.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for rc16/minimum: column7_row2 - rc_min.
              let val := addmod(/*column7_row2*/ mload(0x1320), sub(PRIME, /*rc_min*/ mload(0x2a0)), PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - 1.
              // val *= denominator_invs[4].
              val := mulmod(val, /*denominator_invs[4]*/ mload(0x3be0), PRIME)

              // res += val * alpha ** 45.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for rc16/maximum: column7_row2 - rc_max.
              let val := addmod(/*column7_row2*/ mload(0x1320), sub(PRIME, /*rc_max*/ mload(0x2c0)), PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - trace_generator^(4 * (trace_length / 4 - 1)).
              // val *= denominator_invs[9].
              val := mulmod(val, /*denominator_invs[9]*/ mload(0x3c80), PRIME)

              // res += val * alpha ** 46.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for diluted_check/permutation/init0: (diluted_check/permutation/interaction_elm - column7_row5) * column9_inter1_row7 + column7_row1 - diluted_check/permutation/interaction_elm.
              let val := addmod(
                addmod(
                  mulmod(
                    addmod(
                      /*diluted_check/permutation/interaction_elm*/ mload(0x2e0),
                      sub(PRIME, /*column7_row5*/ mload(0x1380)),
                      PRIME),
                    /*column9_inter1_row7*/ mload(0x27a0),
                    PRIME),
                  /*column7_row1*/ mload(0x1300),
                  PRIME),
                sub(PRIME, /*diluted_check/permutation/interaction_elm*/ mload(0x2e0)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - 1.
              // val *= denominator_invs[4].
              val := mulmod(val, /*denominator_invs[4]*/ mload(0x3be0), PRIME)

              // res += val * alpha ** 47.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for diluted_check/permutation/step0: (diluted_check/permutation/interaction_elm - column7_row13) * column9_inter1_row15 - (diluted_check/permutation/interaction_elm - column7_row9) * column9_inter1_row7.
              let val := addmod(
                mulmod(
                  addmod(
                    /*diluted_check/permutation/interaction_elm*/ mload(0x2e0),
                    sub(PRIME, /*column7_row13*/ mload(0x1460)),
                    PRIME),
                  /*column9_inter1_row15*/ mload(0x27e0),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                    addmod(
                      /*diluted_check/permutation/interaction_elm*/ mload(0x2e0),
                      sub(PRIME, /*column7_row9*/ mload(0x1400)),
                      PRIME),
                    /*column9_inter1_row7*/ mload(0x27a0),
                    PRIME)),
                PRIME)

              // Numerator: point - trace_generator^(8 * (trace_length / 8 - 1)).
              // val *= domains[35].
              val := mulmod(val, /*domains[35]*/ mload(0x3aa0), PRIME)
              // Denominator: point^(trace_length / 8) - 1.
              // val *= denominator_invs[7].
              val := mulmod(val, /*denominator_invs[7]*/ mload(0x3c40), PRIME)

              // res += val * alpha ** 48.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for diluted_check/permutation/last: column9_inter1_row7 - diluted_check/permutation/public_memory_prod.
              let val := addmod(
                /*column9_inter1_row7*/ mload(0x27a0),
                sub(PRIME, /*diluted_check/permutation/public_memory_prod*/ mload(0x300)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - trace_generator^(8 * (trace_length / 8 - 1)).
              // val *= denominator_invs[10].
              val := mulmod(val, /*denominator_invs[10]*/ mload(0x3ca0), PRIME)

              // res += val * alpha ** 49.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for diluted_check/init: column9_inter1_row3 - 1.
              let val := addmod(/*column9_inter1_row3*/ mload(0x2760), sub(PRIME, 1), PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - 1.
              // val *= denominator_invs[4].
              val := mulmod(val, /*denominator_invs[4]*/ mload(0x3be0), PRIME)

              // res += val * alpha ** 50.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for diluted_check/first_element: column7_row5 - diluted_check/first_elm.
              let val := addmod(
                /*column7_row5*/ mload(0x1380),
                sub(PRIME, /*diluted_check/first_elm*/ mload(0x320)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - 1.
              // val *= denominator_invs[4].
              val := mulmod(val, /*denominator_invs[4]*/ mload(0x3be0), PRIME)

              // res += val * alpha ** 51.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for diluted_check/step: column9_inter1_row11 - (column9_inter1_row3 * (1 + diluted_check/interaction_z * (column7_row13 - column7_row5)) + diluted_check/interaction_alpha * (column7_row13 - column7_row5) * (column7_row13 - column7_row5)).
              let val := addmod(
                /*column9_inter1_row11*/ mload(0x27c0),
                sub(
                  PRIME,
                  addmod(
                    mulmod(
                      /*column9_inter1_row3*/ mload(0x2760),
                      addmod(
                        1,
                        mulmod(
                          /*diluted_check/interaction_z*/ mload(0x340),
                          addmod(/*column7_row13*/ mload(0x1460), sub(PRIME, /*column7_row5*/ mload(0x1380)), PRIME),
                          PRIME),
                        PRIME),
                      PRIME),
                    mulmod(
                      mulmod(
                        /*diluted_check/interaction_alpha*/ mload(0x360),
                        addmod(/*column7_row13*/ mload(0x1460), sub(PRIME, /*column7_row5*/ mload(0x1380)), PRIME),
                        PRIME),
                      addmod(/*column7_row13*/ mload(0x1460), sub(PRIME, /*column7_row5*/ mload(0x1380)), PRIME),
                      PRIME),
                    PRIME)),
                PRIME)

              // Numerator: point - trace_generator^(8 * (trace_length / 8 - 1)).
              // val *= domains[35].
              val := mulmod(val, /*domains[35]*/ mload(0x3aa0), PRIME)
              // Denominator: point^(trace_length / 8) - 1.
              // val *= denominator_invs[7].
              val := mulmod(val, /*denominator_invs[7]*/ mload(0x3c40), PRIME)

              // res += val * alpha ** 52.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for diluted_check/last: column9_inter1_row3 - diluted_check/final_cum_val.
              let val := addmod(
                /*column9_inter1_row3*/ mload(0x2760),
                sub(PRIME, /*diluted_check/final_cum_val*/ mload(0x380)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - trace_generator^(8 * (trace_length / 8 - 1)).
              // val *= denominator_invs[10].
              val := mulmod(val, /*denominator_invs[10]*/ mload(0x3ca0), PRIME)

              // res += val * alpha ** 53.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/hash0/ec_subset_sum/bit_unpacking/last_one_is_zero: column8_row71 * (column3_row0 - (column3_row1 + column3_row1)).
              let val := mulmod(
                /*column8_row71*/ mload(0x1f20),
                addmod(
                  /*column3_row0*/ mload(0x980),
                  sub(
                    PRIME,
                    addmod(/*column3_row1*/ mload(0x9a0), /*column3_row1*/ mload(0x9a0), PRIME)),
                  PRIME),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 256) - 1.
              // val *= denominator_invs[11].
              val := mulmod(val, /*denominator_invs[11]*/ mload(0x3cc0), PRIME)

              // res += val * alpha ** 54.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/hash0/ec_subset_sum/bit_unpacking/zeroes_between_ones0: column8_row71 * (column3_row1 - 3138550867693340381917894711603833208051177722232017256448 * column3_row192).
              let val := mulmod(
                /*column8_row71*/ mload(0x1f20),
                addmod(
                  /*column3_row1*/ mload(0x9a0),
                  sub(
                    PRIME,
                    mulmod(
                      3138550867693340381917894711603833208051177722232017256448,
                      /*column3_row192*/ mload(0x9c0),
                      PRIME)),
                  PRIME),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 256) - 1.
              // val *= denominator_invs[11].
              val := mulmod(val, /*denominator_invs[11]*/ mload(0x3cc0), PRIME)

              // res += val * alpha ** 55.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/hash0/ec_subset_sum/bit_unpacking/cumulative_bit192: column8_row71 - column4_row255 * (column3_row192 - (column3_row193 + column3_row193)).
              let val := addmod(
                /*column8_row71*/ mload(0x1f20),
                sub(
                  PRIME,
                  mulmod(
                    /*column4_row255*/ mload(0xac0),
                    addmod(
                      /*column3_row192*/ mload(0x9c0),
                      sub(
                        PRIME,
                        addmod(/*column3_row193*/ mload(0x9e0), /*column3_row193*/ mload(0x9e0), PRIME)),
                      PRIME),
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 256) - 1.
              // val *= denominator_invs[11].
              val := mulmod(val, /*denominator_invs[11]*/ mload(0x3cc0), PRIME)

              // res += val * alpha ** 56.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/hash0/ec_subset_sum/bit_unpacking/zeroes_between_ones192: column4_row255 * (column3_row193 - 8 * column3_row196).
              let val := mulmod(
                /*column4_row255*/ mload(0xac0),
                addmod(
                  /*column3_row193*/ mload(0x9e0),
                  sub(PRIME, mulmod(8, /*column3_row196*/ mload(0xa00), PRIME)),
                  PRIME),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 256) - 1.
              // val *= denominator_invs[11].
              val := mulmod(val, /*denominator_invs[11]*/ mload(0x3cc0), PRIME)

              // res += val * alpha ** 57.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/hash0/ec_subset_sum/bit_unpacking/cumulative_bit196: column4_row255 - (column3_row251 - (column3_row252 + column3_row252)) * (column3_row196 - (column3_row197 + column3_row197)).
              let val := addmod(
                /*column4_row255*/ mload(0xac0),
                sub(
                  PRIME,
                  mulmod(
                    addmod(
                      /*column3_row251*/ mload(0xa40),
                      sub(
                        PRIME,
                        addmod(/*column3_row252*/ mload(0xa60), /*column3_row252*/ mload(0xa60), PRIME)),
                      PRIME),
                    addmod(
                      /*column3_row196*/ mload(0xa00),
                      sub(
                        PRIME,
                        addmod(/*column3_row197*/ mload(0xa20), /*column3_row197*/ mload(0xa20), PRIME)),
                      PRIME),
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 256) - 1.
              // val *= denominator_invs[11].
              val := mulmod(val, /*denominator_invs[11]*/ mload(0x3cc0), PRIME)

              // res += val * alpha ** 58.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/hash0/ec_subset_sum/bit_unpacking/zeroes_between_ones196: (column3_row251 - (column3_row252 + column3_row252)) * (column3_row197 - 18014398509481984 * column3_row251).
              let val := mulmod(
                addmod(
                  /*column3_row251*/ mload(0xa40),
                  sub(
                    PRIME,
                    addmod(/*column3_row252*/ mload(0xa60), /*column3_row252*/ mload(0xa60), PRIME)),
                  PRIME),
                addmod(
                  /*column3_row197*/ mload(0xa20),
                  sub(PRIME, mulmod(18014398509481984, /*column3_row251*/ mload(0xa40), PRIME)),
                  PRIME),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 256) - 1.
              // val *= denominator_invs[11].
              val := mulmod(val, /*denominator_invs[11]*/ mload(0x3cc0), PRIME)

              // res += val * alpha ** 59.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/hash0/ec_subset_sum/booleanity_test: pedersen__hash0__ec_subset_sum__bit_0 * (pedersen__hash0__ec_subset_sum__bit_0 - 1).
              let val := mulmod(
                /*intermediate_value/pedersen/hash0/ec_subset_sum/bit_0*/ mload(0x2ac0),
                addmod(
                  /*intermediate_value/pedersen/hash0/ec_subset_sum/bit_0*/ mload(0x2ac0),
                  sub(PRIME, 1),
                  PRIME),
                PRIME)

              // Numerator: point^(trace_length / 256) - trace_generator^(255 * trace_length / 256).
              // val *= domains[9].
              val := mulmod(val, /*domains[9]*/ mload(0x3760), PRIME)
              // Denominator: point^trace_length - 1.
              // val *= denominator_invs[0].
              val := mulmod(val, /*denominator_invs[0]*/ mload(0x3b60), PRIME)

              // res += val * alpha ** 60.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/hash0/ec_subset_sum/bit_extraction_end: column3_row0.
              let val := /*column3_row0*/ mload(0x980)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 256) - trace_generator^(63 * trace_length / 64).
              // val *= denominator_invs[13].
              val := mulmod(val, /*denominator_invs[13]*/ mload(0x3d00), PRIME)

              // res += val * alpha ** 61.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/hash0/ec_subset_sum/zeros_tail: column3_row0.
              let val := /*column3_row0*/ mload(0x980)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 256) - trace_generator^(255 * trace_length / 256).
              // val *= denominator_invs[12].
              val := mulmod(val, /*denominator_invs[12]*/ mload(0x3ce0), PRIME)

              // res += val * alpha ** 62.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/hash0/ec_subset_sum/add_points/slope: pedersen__hash0__ec_subset_sum__bit_0 * (column2_row0 - pedersen__points__y) - column4_row0 * (column1_row0 - pedersen__points__x).
              let val := addmod(
                mulmod(
                  /*intermediate_value/pedersen/hash0/ec_subset_sum/bit_0*/ mload(0x2ac0),
                  addmod(
                    /*column2_row0*/ mload(0x900),
                    sub(PRIME, /*periodic_column/pedersen/points/y*/ mload(0x20)),
                    PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                    /*column4_row0*/ mload(0xaa0),
                    addmod(
                      /*column1_row0*/ mload(0x860),
                      sub(PRIME, /*periodic_column/pedersen/points/x*/ mload(0x0)),
                      PRIME),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 256) - trace_generator^(255 * trace_length / 256).
              // val *= domains[9].
              val := mulmod(val, /*domains[9]*/ mload(0x3760), PRIME)
              // Denominator: point^trace_length - 1.
              // val *= denominator_invs[0].
              val := mulmod(val, /*denominator_invs[0]*/ mload(0x3b60), PRIME)

              // res += val * alpha ** 63.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/hash0/ec_subset_sum/add_points/x: column4_row0 * column4_row0 - pedersen__hash0__ec_subset_sum__bit_0 * (column1_row0 + pedersen__points__x + column1_row1).
              let val := addmod(
                mulmod(/*column4_row0*/ mload(0xaa0), /*column4_row0*/ mload(0xaa0), PRIME),
                sub(
                  PRIME,
                  mulmod(
                    /*intermediate_value/pedersen/hash0/ec_subset_sum/bit_0*/ mload(0x2ac0),
                    addmod(
                      addmod(
                        /*column1_row0*/ mload(0x860),
                        /*periodic_column/pedersen/points/x*/ mload(0x0),
                        PRIME),
                      /*column1_row1*/ mload(0x880),
                      PRIME),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 256) - trace_generator^(255 * trace_length / 256).
              // val *= domains[9].
              val := mulmod(val, /*domains[9]*/ mload(0x3760), PRIME)
              // Denominator: point^trace_length - 1.
              // val *= denominator_invs[0].
              val := mulmod(val, /*denominator_invs[0]*/ mload(0x3b60), PRIME)

              // res += val * alpha ** 64.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/hash0/ec_subset_sum/add_points/y: pedersen__hash0__ec_subset_sum__bit_0 * (column2_row0 + column2_row1) - column4_row0 * (column1_row0 - column1_row1).
              let val := addmod(
                mulmod(
                  /*intermediate_value/pedersen/hash0/ec_subset_sum/bit_0*/ mload(0x2ac0),
                  addmod(/*column2_row0*/ mload(0x900), /*column2_row1*/ mload(0x920), PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                    /*column4_row0*/ mload(0xaa0),
                    addmod(/*column1_row0*/ mload(0x860), sub(PRIME, /*column1_row1*/ mload(0x880)), PRIME),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 256) - trace_generator^(255 * trace_length / 256).
              // val *= domains[9].
              val := mulmod(val, /*domains[9]*/ mload(0x3760), PRIME)
              // Denominator: point^trace_length - 1.
              // val *= denominator_invs[0].
              val := mulmod(val, /*denominator_invs[0]*/ mload(0x3b60), PRIME)

              // res += val * alpha ** 65.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/hash0/ec_subset_sum/copy_point/x: pedersen__hash0__ec_subset_sum__bit_neg_0 * (column1_row1 - column1_row0).
              let val := mulmod(
                /*intermediate_value/pedersen/hash0/ec_subset_sum/bit_neg_0*/ mload(0x2ae0),
                addmod(/*column1_row1*/ mload(0x880), sub(PRIME, /*column1_row0*/ mload(0x860)), PRIME),
                PRIME)

              // Numerator: point^(trace_length / 256) - trace_generator^(255 * trace_length / 256).
              // val *= domains[9].
              val := mulmod(val, /*domains[9]*/ mload(0x3760), PRIME)
              // Denominator: point^trace_length - 1.
              // val *= denominator_invs[0].
              val := mulmod(val, /*denominator_invs[0]*/ mload(0x3b60), PRIME)

              // res += val * alpha ** 66.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/hash0/ec_subset_sum/copy_point/y: pedersen__hash0__ec_subset_sum__bit_neg_0 * (column2_row1 - column2_row0).
              let val := mulmod(
                /*intermediate_value/pedersen/hash0/ec_subset_sum/bit_neg_0*/ mload(0x2ae0),
                addmod(/*column2_row1*/ mload(0x920), sub(PRIME, /*column2_row0*/ mload(0x900)), PRIME),
                PRIME)

              // Numerator: point^(trace_length / 256) - trace_generator^(255 * trace_length / 256).
              // val *= domains[9].
              val := mulmod(val, /*domains[9]*/ mload(0x3760), PRIME)
              // Denominator: point^trace_length - 1.
              // val *= denominator_invs[0].
              val := mulmod(val, /*denominator_invs[0]*/ mload(0x3b60), PRIME)

              // res += val * alpha ** 67.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/hash0/copy_point/x: column1_row256 - column1_row255.
              let val := addmod(/*column1_row256*/ mload(0x8c0), sub(PRIME, /*column1_row255*/ mload(0x8a0)), PRIME)

              // Numerator: point^(trace_length / 512) - trace_generator^(trace_length / 2).
              // val *= domains[12].
              val := mulmod(val, /*domains[12]*/ mload(0x37c0), PRIME)
              // Denominator: point^(trace_length / 256) - 1.
              // val *= denominator_invs[11].
              val := mulmod(val, /*denominator_invs[11]*/ mload(0x3cc0), PRIME)

              // res += val * alpha ** 68.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/hash0/copy_point/y: column2_row256 - column2_row255.
              let val := addmod(/*column2_row256*/ mload(0x960), sub(PRIME, /*column2_row255*/ mload(0x940)), PRIME)

              // Numerator: point^(trace_length / 512) - trace_generator^(trace_length / 2).
              // val *= domains[12].
              val := mulmod(val, /*domains[12]*/ mload(0x37c0), PRIME)
              // Denominator: point^(trace_length / 256) - 1.
              // val *= denominator_invs[11].
              val := mulmod(val, /*denominator_invs[11]*/ mload(0x3cc0), PRIME)

              // res += val * alpha ** 69.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/hash0/init/x: column1_row0 - pedersen/shift_point.x.
              let val := addmod(
                /*column1_row0*/ mload(0x860),
                sub(PRIME, /*pedersen/shift_point.x*/ mload(0x3a0)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 70.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/hash0/init/y: column2_row0 - pedersen/shift_point.y.
              let val := addmod(
                /*column2_row0*/ mload(0x900),
                sub(PRIME, /*pedersen/shift_point.y*/ mload(0x3c0)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 71.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/input0_value0: column5_row7 - column3_row0.
              let val := addmod(/*column5_row7*/ mload(0xbc0), sub(PRIME, /*column3_row0*/ mload(0x980)), PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 72.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/input0_addr: column5_row518 - (column5_row134 + 1).
              let val := addmod(
                /*column5_row518*/ mload(0xf20),
                sub(PRIME, addmod(/*column5_row134*/ mload(0xd40), 1, PRIME)),
                PRIME)

              // Numerator: point - trace_generator^(512 * (trace_length / 512 - 1)).
              // val *= domains[36].
              val := mulmod(val, /*domains[36]*/ mload(0x3ac0), PRIME)
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 73.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/init_addr: column5_row6 - initial_pedersen_addr.
              let val := addmod(
                /*column5_row6*/ mload(0xba0),
                sub(PRIME, /*initial_pedersen_addr*/ mload(0x3e0)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - 1.
              // val *= denominator_invs[4].
              val := mulmod(val, /*denominator_invs[4]*/ mload(0x3be0), PRIME)

              // res += val * alpha ** 74.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/input1_value0: column5_row263 - column3_row256.
              let val := addmod(/*column5_row263*/ mload(0xe20), sub(PRIME, /*column3_row256*/ mload(0xa80)), PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 75.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/input1_addr: column5_row262 - (column5_row6 + 1).
              let val := addmod(
                /*column5_row262*/ mload(0xe00),
                sub(PRIME, addmod(/*column5_row6*/ mload(0xba0), 1, PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 76.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/output_value0: column5_row135 - column1_row511.
              let val := addmod(/*column5_row135*/ mload(0xd60), sub(PRIME, /*column1_row511*/ mload(0x8e0)), PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 77.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for pedersen/output_addr: column5_row134 - (column5_row262 + 1).
              let val := addmod(
                /*column5_row134*/ mload(0xd40),
                sub(PRIME, addmod(/*column5_row262*/ mload(0xe00), 1, PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 78.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for rc_builtin/value: rc_builtin__value7_0 - column5_row71.
              let val := addmod(
                /*intermediate_value/rc_builtin/value7_0*/ mload(0x2be0),
                sub(PRIME, /*column5_row71*/ mload(0xce0)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 256) - 1.
              // val *= denominator_invs[11].
              val := mulmod(val, /*denominator_invs[11]*/ mload(0x3cc0), PRIME)

              // res += val * alpha ** 79.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for rc_builtin/addr_step: column5_row326 - (column5_row70 + 1).
              let val := addmod(
                /*column5_row326*/ mload(0xe60),
                sub(PRIME, addmod(/*column5_row70*/ mload(0xcc0), 1, PRIME)),
                PRIME)

              // Numerator: point - trace_generator^(256 * (trace_length / 256 - 1)).
              // val *= domains[37].
              val := mulmod(val, /*domains[37]*/ mload(0x3ae0), PRIME)
              // Denominator: point^(trace_length / 256) - 1.
              // val *= denominator_invs[11].
              val := mulmod(val, /*denominator_invs[11]*/ mload(0x3cc0), PRIME)

              // res += val * alpha ** 80.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for rc_builtin/init_addr: column5_row70 - initial_rc_addr.
              let val := addmod(/*column5_row70*/ mload(0xcc0), sub(PRIME, /*initial_rc_addr*/ mload(0x400)), PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - 1.
              // val *= denominator_invs[4].
              val := mulmod(val, /*denominator_invs[4]*/ mload(0x3be0), PRIME)

              // res += val * alpha ** 81.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/doubling_key/slope: ecdsa__signature0__doubling_key__x_squared + ecdsa__signature0__doubling_key__x_squared + ecdsa__signature0__doubling_key__x_squared + ecdsa/sig_config.alpha - (column8_row33 + column8_row33) * column8_row35.
              let val := addmod(
                addmod(
                  addmod(
                    addmod(
                      /*intermediate_value/ecdsa/signature0/doubling_key/x_squared*/ mload(0x2c00),
                      /*intermediate_value/ecdsa/signature0/doubling_key/x_squared*/ mload(0x2c00),
                      PRIME),
                    /*intermediate_value/ecdsa/signature0/doubling_key/x_squared*/ mload(0x2c00),
                    PRIME),
                  /*ecdsa/sig_config.alpha*/ mload(0x420),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                    addmod(/*column8_row33*/ mload(0x1d00), /*column8_row33*/ mload(0x1d00), PRIME),
                    /*column8_row35*/ mload(0x1d20),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 82.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/doubling_key/x: column8_row35 * column8_row35 - (column8_row1 + column8_row1 + column8_row65).
              let val := addmod(
                mulmod(/*column8_row35*/ mload(0x1d20), /*column8_row35*/ mload(0x1d20), PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(/*column8_row1*/ mload(0x1a00), /*column8_row1*/ mload(0x1a00), PRIME),
                    /*column8_row65*/ mload(0x1ee0),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 83.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/doubling_key/y: column8_row33 + column8_row97 - column8_row35 * (column8_row1 - column8_row65).
              let val := addmod(
                addmod(/*column8_row33*/ mload(0x1d00), /*column8_row97*/ mload(0x2000), PRIME),
                sub(
                  PRIME,
                  mulmod(
                    /*column8_row35*/ mload(0x1d20),
                    addmod(/*column8_row1*/ mload(0x1a00), sub(PRIME, /*column8_row65*/ mload(0x1ee0)), PRIME),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 84.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/exponentiate_generator/booleanity_test: ecdsa__signature0__exponentiate_generator__bit_0 * (ecdsa__signature0__exponentiate_generator__bit_0 - 1).
              let val := mulmod(
                /*intermediate_value/ecdsa/signature0/exponentiate_generator/bit_0*/ mload(0x2c20),
                addmod(
                  /*intermediate_value/ecdsa/signature0/exponentiate_generator/bit_0*/ mload(0x2c20),
                  sub(PRIME, 1),
                  PRIME),
                PRIME)

              // Numerator: point^(trace_length / 32768) - trace_generator^(255 * trace_length / 256).
              // val *= domains[28].
              val := mulmod(val, /*domains[28]*/ mload(0x39c0), PRIME)
              // Denominator: point^(trace_length / 128) - 1.
              // val *= denominator_invs[17].
              val := mulmod(val, /*denominator_invs[17]*/ mload(0x3d80), PRIME)

              // res += val * alpha ** 85.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/exponentiate_generator/bit_extraction_end: column8_row59.
              let val := /*column8_row59*/ mload(0x1ea0)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 32768) - trace_generator^(251 * trace_length / 256).
              // val *= denominator_invs[19].
              val := mulmod(val, /*denominator_invs[19]*/ mload(0x3dc0), PRIME)

              // res += val * alpha ** 86.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/exponentiate_generator/zeros_tail: column8_row59.
              let val := /*column8_row59*/ mload(0x1ea0)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 32768) - trace_generator^(255 * trace_length / 256).
              // val *= denominator_invs[18].
              val := mulmod(val, /*denominator_invs[18]*/ mload(0x3da0), PRIME)

              // res += val * alpha ** 87.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/exponentiate_generator/add_points/slope: ecdsa__signature0__exponentiate_generator__bit_0 * (column8_row91 - ecdsa__generator_points__y) - column8_row123 * (column8_row27 - ecdsa__generator_points__x).
              let val := addmod(
                mulmod(
                  /*intermediate_value/ecdsa/signature0/exponentiate_generator/bit_0*/ mload(0x2c20),
                  addmod(
                    /*column8_row91*/ mload(0x1fe0),
                    sub(PRIME, /*periodic_column/ecdsa/generator_points/y*/ mload(0x60)),
                    PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                    /*column8_row123*/ mload(0x20c0),
                    addmod(
                      /*column8_row27*/ mload(0x1ca0),
                      sub(PRIME, /*periodic_column/ecdsa/generator_points/x*/ mload(0x40)),
                      PRIME),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 32768) - trace_generator^(255 * trace_length / 256).
              // val *= domains[28].
              val := mulmod(val, /*domains[28]*/ mload(0x39c0), PRIME)
              // Denominator: point^(trace_length / 128) - 1.
              // val *= denominator_invs[17].
              val := mulmod(val, /*denominator_invs[17]*/ mload(0x3d80), PRIME)

              // res += val * alpha ** 88.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/exponentiate_generator/add_points/x: column8_row123 * column8_row123 - ecdsa__signature0__exponentiate_generator__bit_0 * (column8_row27 + ecdsa__generator_points__x + column8_row155).
              let val := addmod(
                mulmod(/*column8_row123*/ mload(0x20c0), /*column8_row123*/ mload(0x20c0), PRIME),
                sub(
                  PRIME,
                  mulmod(
                    /*intermediate_value/ecdsa/signature0/exponentiate_generator/bit_0*/ mload(0x2c20),
                    addmod(
                      addmod(
                        /*column8_row27*/ mload(0x1ca0),
                        /*periodic_column/ecdsa/generator_points/x*/ mload(0x40),
                        PRIME),
                      /*column8_row155*/ mload(0x20e0),
                      PRIME),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 32768) - trace_generator^(255 * trace_length / 256).
              // val *= domains[28].
              val := mulmod(val, /*domains[28]*/ mload(0x39c0), PRIME)
              // Denominator: point^(trace_length / 128) - 1.
              // val *= denominator_invs[17].
              val := mulmod(val, /*denominator_invs[17]*/ mload(0x3d80), PRIME)

              // res += val * alpha ** 89.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/exponentiate_generator/add_points/y: ecdsa__signature0__exponentiate_generator__bit_0 * (column8_row91 + column8_row219) - column8_row123 * (column8_row27 - column8_row155).
              let val := addmod(
                mulmod(
                  /*intermediate_value/ecdsa/signature0/exponentiate_generator/bit_0*/ mload(0x2c20),
                  addmod(/*column8_row91*/ mload(0x1fe0), /*column8_row219*/ mload(0x2160), PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                    /*column8_row123*/ mload(0x20c0),
                    addmod(
                      /*column8_row27*/ mload(0x1ca0),
                      sub(PRIME, /*column8_row155*/ mload(0x20e0)),
                      PRIME),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 32768) - trace_generator^(255 * trace_length / 256).
              // val *= domains[28].
              val := mulmod(val, /*domains[28]*/ mload(0x39c0), PRIME)
              // Denominator: point^(trace_length / 128) - 1.
              // val *= denominator_invs[17].
              val := mulmod(val, /*denominator_invs[17]*/ mload(0x3d80), PRIME)

              // res += val * alpha ** 90.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/exponentiate_generator/add_points/x_diff_inv: column8_row7 * (column8_row27 - ecdsa__generator_points__x) - 1.
              let val := addmod(
                mulmod(
                  /*column8_row7*/ mload(0x1ac0),
                  addmod(
                    /*column8_row27*/ mload(0x1ca0),
                    sub(PRIME, /*periodic_column/ecdsa/generator_points/x*/ mload(0x40)),
                    PRIME),
                  PRIME),
                sub(PRIME, 1),
                PRIME)

              // Numerator: point^(trace_length / 32768) - trace_generator^(255 * trace_length / 256).
              // val *= domains[28].
              val := mulmod(val, /*domains[28]*/ mload(0x39c0), PRIME)
              // Denominator: point^(trace_length / 128) - 1.
              // val *= denominator_invs[17].
              val := mulmod(val, /*denominator_invs[17]*/ mload(0x3d80), PRIME)

              // res += val * alpha ** 91.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/exponentiate_generator/copy_point/x: ecdsa__signature0__exponentiate_generator__bit_neg_0 * (column8_row155 - column8_row27).
              let val := mulmod(
                /*intermediate_value/ecdsa/signature0/exponentiate_generator/bit_neg_0*/ mload(0x2c40),
                addmod(
                  /*column8_row155*/ mload(0x20e0),
                  sub(PRIME, /*column8_row27*/ mload(0x1ca0)),
                  PRIME),
                PRIME)

              // Numerator: point^(trace_length / 32768) - trace_generator^(255 * trace_length / 256).
              // val *= domains[28].
              val := mulmod(val, /*domains[28]*/ mload(0x39c0), PRIME)
              // Denominator: point^(trace_length / 128) - 1.
              // val *= denominator_invs[17].
              val := mulmod(val, /*denominator_invs[17]*/ mload(0x3d80), PRIME)

              // res += val * alpha ** 92.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/exponentiate_generator/copy_point/y: ecdsa__signature0__exponentiate_generator__bit_neg_0 * (column8_row219 - column8_row91).
              let val := mulmod(
                /*intermediate_value/ecdsa/signature0/exponentiate_generator/bit_neg_0*/ mload(0x2c40),
                addmod(
                  /*column8_row219*/ mload(0x2160),
                  sub(PRIME, /*column8_row91*/ mload(0x1fe0)),
                  PRIME),
                PRIME)

              // Numerator: point^(trace_length / 32768) - trace_generator^(255 * trace_length / 256).
              // val *= domains[28].
              val := mulmod(val, /*domains[28]*/ mload(0x39c0), PRIME)
              // Denominator: point^(trace_length / 128) - 1.
              // val *= denominator_invs[17].
              val := mulmod(val, /*denominator_invs[17]*/ mload(0x3d80), PRIME)

              // res += val * alpha ** 93.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/exponentiate_key/booleanity_test: ecdsa__signature0__exponentiate_key__bit_0 * (ecdsa__signature0__exponentiate_key__bit_0 - 1).
              let val := mulmod(
                /*intermediate_value/ecdsa/signature0/exponentiate_key/bit_0*/ mload(0x2c60),
                addmod(
                  /*intermediate_value/ecdsa/signature0/exponentiate_key/bit_0*/ mload(0x2c60),
                  sub(PRIME, 1),
                  PRIME),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 94.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/exponentiate_key/bit_extraction_end: column8_row9.
              let val := /*column8_row9*/ mload(0x1b00)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - trace_generator^(251 * trace_length / 256).
              // val *= denominator_invs[20].
              val := mulmod(val, /*denominator_invs[20]*/ mload(0x3de0), PRIME)

              // res += val * alpha ** 95.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/exponentiate_key/zeros_tail: column8_row9.
              let val := /*column8_row9*/ mload(0x1b00)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= denominator_invs[16].
              val := mulmod(val, /*denominator_invs[16]*/ mload(0x3d60), PRIME)

              // res += val * alpha ** 96.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/exponentiate_key/add_points/slope: ecdsa__signature0__exponentiate_key__bit_0 * (column8_row49 - column8_row33) - column8_row19 * (column8_row17 - column8_row1).
              let val := addmod(
                mulmod(
                  /*intermediate_value/ecdsa/signature0/exponentiate_key/bit_0*/ mload(0x2c60),
                  addmod(/*column8_row49*/ mload(0x1e00), sub(PRIME, /*column8_row33*/ mload(0x1d00)), PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                    /*column8_row19*/ mload(0x1c00),
                    addmod(/*column8_row17*/ mload(0x1be0), sub(PRIME, /*column8_row1*/ mload(0x1a00)), PRIME),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 97.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/exponentiate_key/add_points/x: column8_row19 * column8_row19 - ecdsa__signature0__exponentiate_key__bit_0 * (column8_row17 + column8_row1 + column8_row81).
              let val := addmod(
                mulmod(/*column8_row19*/ mload(0x1c00), /*column8_row19*/ mload(0x1c00), PRIME),
                sub(
                  PRIME,
                  mulmod(
                    /*intermediate_value/ecdsa/signature0/exponentiate_key/bit_0*/ mload(0x2c60),
                    addmod(
                      addmod(/*column8_row17*/ mload(0x1be0), /*column8_row1*/ mload(0x1a00), PRIME),
                      /*column8_row81*/ mload(0x1f80),
                      PRIME),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 98.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/exponentiate_key/add_points/y: ecdsa__signature0__exponentiate_key__bit_0 * (column8_row49 + column8_row113) - column8_row19 * (column8_row17 - column8_row81).
              let val := addmod(
                mulmod(
                  /*intermediate_value/ecdsa/signature0/exponentiate_key/bit_0*/ mload(0x2c60),
                  addmod(/*column8_row49*/ mload(0x1e00), /*column8_row113*/ mload(0x2080), PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                    /*column8_row19*/ mload(0x1c00),
                    addmod(/*column8_row17*/ mload(0x1be0), sub(PRIME, /*column8_row81*/ mload(0x1f80)), PRIME),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 99.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/exponentiate_key/add_points/x_diff_inv: column8_row51 * (column8_row17 - column8_row1) - 1.
              let val := addmod(
                mulmod(
                  /*column8_row51*/ mload(0x1e20),
                  addmod(/*column8_row17*/ mload(0x1be0), sub(PRIME, /*column8_row1*/ mload(0x1a00)), PRIME),
                  PRIME),
                sub(PRIME, 1),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 100.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/exponentiate_key/copy_point/x: ecdsa__signature0__exponentiate_key__bit_neg_0 * (column8_row81 - column8_row17).
              let val := mulmod(
                /*intermediate_value/ecdsa/signature0/exponentiate_key/bit_neg_0*/ mload(0x2c80),
                addmod(/*column8_row81*/ mload(0x1f80), sub(PRIME, /*column8_row17*/ mload(0x1be0)), PRIME),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 101.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/exponentiate_key/copy_point/y: ecdsa__signature0__exponentiate_key__bit_neg_0 * (column8_row113 - column8_row49).
              let val := mulmod(
                /*intermediate_value/ecdsa/signature0/exponentiate_key/bit_neg_0*/ mload(0x2c80),
                addmod(
                  /*column8_row113*/ mload(0x2080),
                  sub(PRIME, /*column8_row49*/ mload(0x1e00)),
                  PRIME),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 102.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/init_gen/x: column8_row27 - ecdsa/sig_config.shift_point.x.
              let val := addmod(
                /*column8_row27*/ mload(0x1ca0),
                sub(PRIME, /*ecdsa/sig_config.shift_point.x*/ mload(0x440)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 32768) - 1.
              // val *= denominator_invs[21].
              val := mulmod(val, /*denominator_invs[21]*/ mload(0x3e00), PRIME)

              // res += val * alpha ** 103.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/init_gen/y: column8_row91 + ecdsa/sig_config.shift_point.y.
              let val := addmod(
                /*column8_row91*/ mload(0x1fe0),
                /*ecdsa/sig_config.shift_point.y*/ mload(0x460),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 32768) - 1.
              // val *= denominator_invs[21].
              val := mulmod(val, /*denominator_invs[21]*/ mload(0x3e00), PRIME)

              // res += val * alpha ** 104.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/init_key/x: column8_row17 - ecdsa/sig_config.shift_point.x.
              let val := addmod(
                /*column8_row17*/ mload(0x1be0),
                sub(PRIME, /*ecdsa/sig_config.shift_point.x*/ mload(0x440)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 105.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/init_key/y: column8_row49 - ecdsa/sig_config.shift_point.y.
              let val := addmod(
                /*column8_row49*/ mload(0x1e00),
                sub(PRIME, /*ecdsa/sig_config.shift_point.y*/ mload(0x460)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 106.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/add_results/slope: column8_row32731 - (column8_row16369 + column8_row32763 * (column8_row32667 - column8_row16337)).
              let val := addmod(
                /*column8_row32731*/ mload(0x2680),
                sub(
                  PRIME,
                  addmod(
                    /*column8_row16369*/ mload(0x2580),
                    mulmod(
                      /*column8_row32763*/ mload(0x26e0),
                      addmod(
                        /*column8_row32667*/ mload(0x2620),
                        sub(PRIME, /*column8_row16337*/ mload(0x24e0)),
                        PRIME),
                      PRIME),
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 32768) - 1.
              // val *= denominator_invs[21].
              val := mulmod(val, /*denominator_invs[21]*/ mload(0x3e00), PRIME)

              // res += val * alpha ** 107.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/add_results/x: column8_row32763 * column8_row32763 - (column8_row32667 + column8_row16337 + column8_row16385).
              let val := addmod(
                mulmod(/*column8_row32763*/ mload(0x26e0), /*column8_row32763*/ mload(0x26e0), PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(/*column8_row32667*/ mload(0x2620), /*column8_row16337*/ mload(0x24e0), PRIME),
                    /*column8_row16385*/ mload(0x25c0),
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 32768) - 1.
              // val *= denominator_invs[21].
              val := mulmod(val, /*denominator_invs[21]*/ mload(0x3e00), PRIME)

              // res += val * alpha ** 108.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/add_results/y: column8_row32731 + column8_row16417 - column8_row32763 * (column8_row32667 - column8_row16385).
              let val := addmod(
                addmod(/*column8_row32731*/ mload(0x2680), /*column8_row16417*/ mload(0x25e0), PRIME),
                sub(
                  PRIME,
                  mulmod(
                    /*column8_row32763*/ mload(0x26e0),
                    addmod(
                      /*column8_row32667*/ mload(0x2620),
                      sub(PRIME, /*column8_row16385*/ mload(0x25c0)),
                      PRIME),
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 32768) - 1.
              // val *= denominator_invs[21].
              val := mulmod(val, /*denominator_invs[21]*/ mload(0x3e00), PRIME)

              // res += val * alpha ** 109.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/add_results/x_diff_inv: column8_row32647 * (column8_row32667 - column8_row16337) - 1.
              let val := addmod(
                mulmod(
                  /*column8_row32647*/ mload(0x2600),
                  addmod(
                    /*column8_row32667*/ mload(0x2620),
                    sub(PRIME, /*column8_row16337*/ mload(0x24e0)),
                    PRIME),
                  PRIME),
                sub(PRIME, 1),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 32768) - 1.
              // val *= denominator_invs[21].
              val := mulmod(val, /*denominator_invs[21]*/ mload(0x3e00), PRIME)

              // res += val * alpha ** 110.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/extract_r/slope: column8_row32753 + ecdsa/sig_config.shift_point.y - column8_row16331 * (column8_row32721 - ecdsa/sig_config.shift_point.x).
              let val := addmod(
                addmod(
                  /*column8_row32753*/ mload(0x26c0),
                  /*ecdsa/sig_config.shift_point.y*/ mload(0x460),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                    /*column8_row16331*/ mload(0x24c0),
                    addmod(
                      /*column8_row32721*/ mload(0x2660),
                      sub(PRIME, /*ecdsa/sig_config.shift_point.x*/ mload(0x440)),
                      PRIME),
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 32768) - 1.
              // val *= denominator_invs[21].
              val := mulmod(val, /*denominator_invs[21]*/ mload(0x3e00), PRIME)

              // res += val * alpha ** 111.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/extract_r/x: column8_row16331 * column8_row16331 - (column8_row32721 + ecdsa/sig_config.shift_point.x + column8_row9).
              let val := addmod(
                mulmod(/*column8_row16331*/ mload(0x24c0), /*column8_row16331*/ mload(0x24c0), PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      /*column8_row32721*/ mload(0x2660),
                      /*ecdsa/sig_config.shift_point.x*/ mload(0x440),
                      PRIME),
                    /*column8_row9*/ mload(0x1b00),
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 32768) - 1.
              // val *= denominator_invs[21].
              val := mulmod(val, /*denominator_invs[21]*/ mload(0x3e00), PRIME)

              // res += val * alpha ** 112.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/extract_r/x_diff_inv: column8_row32715 * (column8_row32721 - ecdsa/sig_config.shift_point.x) - 1.
              let val := addmod(
                mulmod(
                  /*column8_row32715*/ mload(0x2640),
                  addmod(
                    /*column8_row32721*/ mload(0x2660),
                    sub(PRIME, /*ecdsa/sig_config.shift_point.x*/ mload(0x440)),
                    PRIME),
                  PRIME),
                sub(PRIME, 1),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 32768) - 1.
              // val *= denominator_invs[21].
              val := mulmod(val, /*denominator_invs[21]*/ mload(0x3e00), PRIME)

              // res += val * alpha ** 113.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/z_nonzero: column8_row59 * column8_row16363 - 1.
              let val := addmod(
                mulmod(/*column8_row59*/ mload(0x1ea0), /*column8_row16363*/ mload(0x2560), PRIME),
                sub(PRIME, 1),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 32768) - 1.
              // val *= denominator_invs[21].
              val := mulmod(val, /*denominator_invs[21]*/ mload(0x3e00), PRIME)

              // res += val * alpha ** 114.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/r_and_w_nonzero: column8_row9 * column8_row16355 - 1.
              let val := addmod(
                mulmod(/*column8_row9*/ mload(0x1b00), /*column8_row16355*/ mload(0x2520), PRIME),
                sub(PRIME, 1),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 115.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/q_on_curve/x_squared: column8_row32747 - column8_row1 * column8_row1.
              let val := addmod(
                /*column8_row32747*/ mload(0x26a0),
                sub(
                  PRIME,
                  mulmod(/*column8_row1*/ mload(0x1a00), /*column8_row1*/ mload(0x1a00), PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 32768) - 1.
              // val *= denominator_invs[21].
              val := mulmod(val, /*denominator_invs[21]*/ mload(0x3e00), PRIME)

              // res += val * alpha ** 116.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/signature0/q_on_curve/on_curve: column8_row33 * column8_row33 - (column8_row1 * column8_row32747 + ecdsa/sig_config.alpha * column8_row1 + ecdsa/sig_config.beta).
              let val := addmod(
                mulmod(/*column8_row33*/ mload(0x1d00), /*column8_row33*/ mload(0x1d00), PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      mulmod(/*column8_row1*/ mload(0x1a00), /*column8_row32747*/ mload(0x26a0), PRIME),
                      mulmod(/*ecdsa/sig_config.alpha*/ mload(0x420), /*column8_row1*/ mload(0x1a00), PRIME),
                      PRIME),
                    /*ecdsa/sig_config.beta*/ mload(0x480),
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 32768) - 1.
              // val *= denominator_invs[21].
              val := mulmod(val, /*denominator_invs[21]*/ mload(0x3e00), PRIME)

              // res += val * alpha ** 117.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/init_addr: column5_row390 - initial_ecdsa_addr.
              let val := addmod(
                /*column5_row390*/ mload(0xec0),
                sub(PRIME, /*initial_ecdsa_addr*/ mload(0x4a0)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - 1.
              // val *= denominator_invs[4].
              val := mulmod(val, /*denominator_invs[4]*/ mload(0x3be0), PRIME)

              // res += val * alpha ** 118.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/message_addr: column5_row16774 - (column5_row390 + 1).
              let val := addmod(
                /*column5_row16774*/ mload(0x11e0),
                sub(PRIME, addmod(/*column5_row390*/ mload(0xec0), 1, PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 32768) - 1.
              // val *= denominator_invs[21].
              val := mulmod(val, /*denominator_invs[21]*/ mload(0x3e00), PRIME)

              // res += val * alpha ** 119.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/pubkey_addr: column5_row33158 - (column5_row16774 + 1).
              let val := addmod(
                /*column5_row33158*/ mload(0x1240),
                sub(PRIME, addmod(/*column5_row16774*/ mload(0x11e0), 1, PRIME)),
                PRIME)

              // Numerator: point - trace_generator^(32768 * (trace_length / 32768 - 1)).
              // val *= domains[38].
              val := mulmod(val, /*domains[38]*/ mload(0x3b00), PRIME)
              // Denominator: point^(trace_length / 32768) - 1.
              // val *= denominator_invs[21].
              val := mulmod(val, /*denominator_invs[21]*/ mload(0x3e00), PRIME)

              // res += val * alpha ** 120.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/message_value0: column5_row16775 - column8_row59.
              let val := addmod(
                /*column5_row16775*/ mload(0x1200),
                sub(PRIME, /*column8_row59*/ mload(0x1ea0)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 32768) - 1.
              // val *= denominator_invs[21].
              val := mulmod(val, /*denominator_invs[21]*/ mload(0x3e00), PRIME)

              // res += val * alpha ** 121.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ecdsa/pubkey_value0: column5_row391 - column8_row1.
              let val := addmod(/*column5_row391*/ mload(0xee0), sub(PRIME, /*column8_row1*/ mload(0x1a00)), PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 32768) - 1.
              // val *= denominator_invs[21].
              val := mulmod(val, /*denominator_invs[21]*/ mload(0x3e00), PRIME)

              // res += val * alpha ** 122.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for bitwise/init_var_pool_addr: column5_row198 - initial_bitwise_addr.
              let val := addmod(
                /*column5_row198*/ mload(0xda0),
                sub(PRIME, /*initial_bitwise_addr*/ mload(0x4c0)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - 1.
              // val *= denominator_invs[4].
              val := mulmod(val, /*denominator_invs[4]*/ mload(0x3be0), PRIME)

              // res += val * alpha ** 123.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for bitwise/step_var_pool_addr: column5_row454 - (column5_row198 + 1).
              let val := addmod(
                /*column5_row454*/ mload(0xf00),
                sub(PRIME, addmod(/*column5_row198*/ mload(0xda0), 1, PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 1024) - trace_generator^(3 * trace_length / 4).
              // val *= domains[21].
              val := mulmod(val, /*domains[21]*/ mload(0x38e0), PRIME)
              // Denominator: point^(trace_length / 256) - 1.
              // val *= denominator_invs[11].
              val := mulmod(val, /*denominator_invs[11]*/ mload(0x3cc0), PRIME)

              // res += val * alpha ** 124.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for bitwise/x_or_y_addr: column5_row902 - (column5_row966 + 1).
              let val := addmod(
                /*column5_row902*/ mload(0xf80),
                sub(PRIME, addmod(/*column5_row966*/ mload(0xfc0), 1, PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 1024) - 1.
              // val *= denominator_invs[23].
              val := mulmod(val, /*denominator_invs[23]*/ mload(0x3e40), PRIME)

              // res += val * alpha ** 125.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for bitwise/next_var_pool_addr: column5_row1222 - (column5_row902 + 1).
              let val := addmod(
                /*column5_row1222*/ mload(0x1000),
                sub(PRIME, addmod(/*column5_row902*/ mload(0xf80), 1, PRIME)),
                PRIME)

              // Numerator: point - trace_generator^(1024 * (trace_length / 1024 - 1)).
              // val *= domains[39].
              val := mulmod(val, /*domains[39]*/ mload(0x3b20), PRIME)
              // Denominator: point^(trace_length / 1024) - 1.
              // val *= denominator_invs[23].
              val := mulmod(val, /*denominator_invs[23]*/ mload(0x3e40), PRIME)

              // res += val * alpha ** 126.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for bitwise/partition: bitwise__sum_var_0_0 + bitwise__sum_var_8_0 - column5_row199.
              let val := addmod(
                addmod(
                  /*intermediate_value/bitwise/sum_var_0_0*/ mload(0x2ca0),
                  /*intermediate_value/bitwise/sum_var_8_0*/ mload(0x2cc0),
                  PRIME),
                sub(PRIME, /*column5_row199*/ mload(0xdc0)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 256) - 1.
              // val *= denominator_invs[11].
              val := mulmod(val, /*denominator_invs[11]*/ mload(0x3cc0), PRIME)

              // res += val * alpha ** 127.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for bitwise/or_is_and_plus_xor: column5_row903 - (column5_row711 + column5_row967).
              let val := addmod(
                /*column5_row903*/ mload(0xfa0),
                sub(
                  PRIME,
                  addmod(/*column5_row711*/ mload(0xf60), /*column5_row967*/ mload(0xfe0), PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 1024) - 1.
              // val *= denominator_invs[23].
              val := mulmod(val, /*denominator_invs[23]*/ mload(0x3e40), PRIME)

              // res += val * alpha ** 128.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for bitwise/addition_is_xor_with_and: column7_row1 + column7_row257 - (column7_row769 + column7_row513 + column7_row513).
              let val := addmod(
                addmod(/*column7_row1*/ mload(0x1300), /*column7_row257*/ mload(0x17c0), PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(/*column7_row769*/ mload(0x1920), /*column7_row513*/ mload(0x1860), PRIME),
                    /*column7_row513*/ mload(0x1860),
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: (point^(trace_length / 1024) - trace_generator^(trace_length / 64)) * (point^(trace_length / 1024) - trace_generator^(trace_length / 32)) * (point^(trace_length / 1024) - trace_generator^(3 * trace_length / 64)) * (point^(trace_length / 1024) - trace_generator^(trace_length / 16)) * (point^(trace_length / 1024) - trace_generator^(5 * trace_length / 64)) * (point^(trace_length / 1024) - trace_generator^(3 * trace_length / 32)) * (point^(trace_length / 1024) - trace_generator^(7 * trace_length / 64)) * (point^(trace_length / 1024) - trace_generator^(trace_length / 8)) * (point^(trace_length / 1024) - trace_generator^(9 * trace_length / 64)) * (point^(trace_length / 1024) - trace_generator^(5 * trace_length / 32)) * (point^(trace_length / 1024) - trace_generator^(11 * trace_length / 64)) * (point^(trace_length / 1024) - trace_generator^(3 * trace_length / 16)) * (point^(trace_length / 1024) - trace_generator^(13 * trace_length / 64)) * (point^(trace_length / 1024) - trace_generator^(7 * trace_length / 32)) * (point^(trace_length / 1024) - trace_generator^(15 * trace_length / 64)) * domain22.
              // val *= denominator_invs[24].
              val := mulmod(val, /*denominator_invs[24]*/ mload(0x3e60), PRIME)

              // res += val * alpha ** 129.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for bitwise/unique_unpacking192: (column7_row705 + column7_row961) * 16 - column7_row9.
              let val := addmod(
                mulmod(
                  addmod(/*column7_row705*/ mload(0x18a0), /*column7_row961*/ mload(0x1960), PRIME),
                  16,
                  PRIME),
                sub(PRIME, /*column7_row9*/ mload(0x1400)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 1024) - 1.
              // val *= denominator_invs[23].
              val := mulmod(val, /*denominator_invs[23]*/ mload(0x3e40), PRIME)

              // res += val * alpha ** 130.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for bitwise/unique_unpacking193: (column7_row721 + column7_row977) * 16 - column7_row521.
              let val := addmod(
                mulmod(
                  addmod(/*column7_row721*/ mload(0x18c0), /*column7_row977*/ mload(0x1980), PRIME),
                  16,
                  PRIME),
                sub(PRIME, /*column7_row521*/ mload(0x1880)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 1024) - 1.
              // val *= denominator_invs[23].
              val := mulmod(val, /*denominator_invs[23]*/ mload(0x3e40), PRIME)

              // res += val * alpha ** 131.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for bitwise/unique_unpacking194: (column7_row737 + column7_row993) * 16 - column7_row265.
              let val := addmod(
                mulmod(
                  addmod(/*column7_row737*/ mload(0x18e0), /*column7_row993*/ mload(0x19a0), PRIME),
                  16,
                  PRIME),
                sub(PRIME, /*column7_row265*/ mload(0x17e0)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 1024) - 1.
              // val *= denominator_invs[23].
              val := mulmod(val, /*denominator_invs[23]*/ mload(0x3e40), PRIME)

              // res += val * alpha ** 132.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for bitwise/unique_unpacking195: (column7_row753 + column7_row1009) * 256 - column7_row777.
              let val := addmod(
                mulmod(
                  addmod(/*column7_row753*/ mload(0x1900), /*column7_row1009*/ mload(0x19c0), PRIME),
                  256,
                  PRIME),
                sub(PRIME, /*column7_row777*/ mload(0x1940)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 1024) - 1.
              // val *= denominator_invs[23].
              val := mulmod(val, /*denominator_invs[23]*/ mload(0x3e40), PRIME)

              // res += val * alpha ** 133.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/init_addr: column5_row8582 - initial_ec_op_addr.
              let val := addmod(
                /*column5_row8582*/ mload(0x10e0),
                sub(PRIME, /*initial_ec_op_addr*/ mload(0x4e0)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - 1.
              // val *= denominator_invs[4].
              val := mulmod(val, /*denominator_invs[4]*/ mload(0x3be0), PRIME)

              // res += val * alpha ** 134.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/p_x_addr: column5_row24966 - (column5_row8582 + 7).
              let val := addmod(
                /*column5_row24966*/ mload(0x1220),
                sub(PRIME, addmod(/*column5_row8582*/ mload(0x10e0), 7, PRIME)),
                PRIME)

              // Numerator: point - trace_generator^(16384 * (trace_length / 16384 - 1)).
              // val *= domains[40].
              val := mulmod(val, /*domains[40]*/ mload(0x3b40), PRIME)
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 135.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/p_y_addr: column5_row4486 - (column5_row8582 + 1).
              let val := addmod(
                /*column5_row4486*/ mload(0x1060),
                sub(PRIME, addmod(/*column5_row8582*/ mload(0x10e0), 1, PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 136.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/q_x_addr: column5_row12678 - (column5_row4486 + 1).
              let val := addmod(
                /*column5_row12678*/ mload(0x1160),
                sub(PRIME, addmod(/*column5_row4486*/ mload(0x1060), 1, PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 137.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/q_y_addr: column5_row2438 - (column5_row12678 + 1).
              let val := addmod(
                /*column5_row2438*/ mload(0x1020),
                sub(PRIME, addmod(/*column5_row12678*/ mload(0x1160), 1, PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 138.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/m_addr: column5_row10630 - (column5_row2438 + 1).
              let val := addmod(
                /*column5_row10630*/ mload(0x1120),
                sub(PRIME, addmod(/*column5_row2438*/ mload(0x1020), 1, PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 139.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/r_x_addr: column5_row6534 - (column5_row10630 + 1).
              let val := addmod(
                /*column5_row6534*/ mload(0x10a0),
                sub(PRIME, addmod(/*column5_row10630*/ mload(0x1120), 1, PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 140.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/r_y_addr: column5_row14726 - (column5_row6534 + 1).
              let val := addmod(
                /*column5_row14726*/ mload(0x11a0),
                sub(PRIME, addmod(/*column5_row6534*/ mload(0x10a0), 1, PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 141.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/doubling_q/slope: ec_op__doubling_q__x_squared_0 + ec_op__doubling_q__x_squared_0 + ec_op__doubling_q__x_squared_0 + ec_op/curve_config.alpha - (column8_row25 + column8_row25) * column8_row57.
              let val := addmod(
                addmod(
                  addmod(
                    addmod(
                      /*intermediate_value/ec_op/doubling_q/x_squared_0*/ mload(0x2ce0),
                      /*intermediate_value/ec_op/doubling_q/x_squared_0*/ mload(0x2ce0),
                      PRIME),
                    /*intermediate_value/ec_op/doubling_q/x_squared_0*/ mload(0x2ce0),
                    PRIME),
                  /*ec_op/curve_config.alpha*/ mload(0x500),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                    addmod(/*column8_row25*/ mload(0x1c80), /*column8_row25*/ mload(0x1c80), PRIME),
                    /*column8_row57*/ mload(0x1e80),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 142.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/doubling_q/x: column8_row57 * column8_row57 - (column8_row41 + column8_row41 + column8_row105).
              let val := addmod(
                mulmod(/*column8_row57*/ mload(0x1e80), /*column8_row57*/ mload(0x1e80), PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(/*column8_row41*/ mload(0x1d80), /*column8_row41*/ mload(0x1d80), PRIME),
                    /*column8_row105*/ mload(0x2040),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 143.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/doubling_q/y: column8_row25 + column8_row89 - column8_row57 * (column8_row41 - column8_row105).
              let val := addmod(
                addmod(/*column8_row25*/ mload(0x1c80), /*column8_row89*/ mload(0x1fc0), PRIME),
                sub(
                  PRIME,
                  mulmod(
                    /*column8_row57*/ mload(0x1e80),
                    addmod(
                      /*column8_row41*/ mload(0x1d80),
                      sub(PRIME, /*column8_row105*/ mload(0x2040)),
                      PRIME),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 144.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/get_q_x: column5_row12679 - column8_row41.
              let val := addmod(
                /*column5_row12679*/ mload(0x1180),
                sub(PRIME, /*column8_row41*/ mload(0x1d80)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 145.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/get_q_y: column5_row2439 - column8_row25.
              let val := addmod(
                /*column5_row2439*/ mload(0x1040),
                sub(PRIME, /*column8_row25*/ mload(0x1c80)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 146.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/ec_subset_sum/bit_unpacking/last_one_is_zero: column8_row16371 * (column8_row21 - (column8_row85 + column8_row85)).
              let val := mulmod(
                /*column8_row16371*/ mload(0x25a0),
                addmod(
                  /*column8_row21*/ mload(0x1c20),
                  sub(
                    PRIME,
                    addmod(/*column8_row85*/ mload(0x1fa0), /*column8_row85*/ mload(0x1fa0), PRIME)),
                  PRIME),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 147.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/ec_subset_sum/bit_unpacking/zeroes_between_ones0: column8_row16371 * (column8_row85 - 3138550867693340381917894711603833208051177722232017256448 * column8_row12309).
              let val := mulmod(
                /*column8_row16371*/ mload(0x25a0),
                addmod(
                  /*column8_row85*/ mload(0x1fa0),
                  sub(
                    PRIME,
                    mulmod(
                      3138550867693340381917894711603833208051177722232017256448,
                      /*column8_row12309*/ mload(0x23e0),
                      PRIME)),
                  PRIME),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 148.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/ec_subset_sum/bit_unpacking/cumulative_bit192: column8_row16371 - column8_row16339 * (column8_row12309 - (column8_row12373 + column8_row12373)).
              let val := addmod(
                /*column8_row16371*/ mload(0x25a0),
                sub(
                  PRIME,
                  mulmod(
                    /*column8_row16339*/ mload(0x2500),
                    addmod(
                      /*column8_row12309*/ mload(0x23e0),
                      sub(
                        PRIME,
                        addmod(/*column8_row12373*/ mload(0x2400), /*column8_row12373*/ mload(0x2400), PRIME)),
                      PRIME),
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 149.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/ec_subset_sum/bit_unpacking/zeroes_between_ones192: column8_row16339 * (column8_row12373 - 8 * column8_row12565).
              let val := mulmod(
                /*column8_row16339*/ mload(0x2500),
                addmod(
                  /*column8_row12373*/ mload(0x2400),
                  sub(PRIME, mulmod(8, /*column8_row12565*/ mload(0x2420), PRIME)),
                  PRIME),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 150.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/ec_subset_sum/bit_unpacking/cumulative_bit196: column8_row16339 - (column8_row16085 - (column8_row16149 + column8_row16149)) * (column8_row12565 - (column8_row12629 + column8_row12629)).
              let val := addmod(
                /*column8_row16339*/ mload(0x2500),
                sub(
                  PRIME,
                  mulmod(
                    addmod(
                      /*column8_row16085*/ mload(0x2460),
                      sub(
                        PRIME,
                        addmod(/*column8_row16149*/ mload(0x2480), /*column8_row16149*/ mload(0x2480), PRIME)),
                      PRIME),
                    addmod(
                      /*column8_row12565*/ mload(0x2420),
                      sub(
                        PRIME,
                        addmod(/*column8_row12629*/ mload(0x2440), /*column8_row12629*/ mload(0x2440), PRIME)),
                      PRIME),
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 151.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/ec_subset_sum/bit_unpacking/zeroes_between_ones196: (column8_row16085 - (column8_row16149 + column8_row16149)) * (column8_row12629 - 18014398509481984 * column8_row16085).
              let val := mulmod(
                addmod(
                  /*column8_row16085*/ mload(0x2460),
                  sub(
                    PRIME,
                    addmod(/*column8_row16149*/ mload(0x2480), /*column8_row16149*/ mload(0x2480), PRIME)),
                  PRIME),
                addmod(
                  /*column8_row12629*/ mload(0x2440),
                  sub(PRIME, mulmod(18014398509481984, /*column8_row16085*/ mload(0x2460), PRIME)),
                  PRIME),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 152.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/ec_subset_sum/booleanity_test: ec_op__ec_subset_sum__bit_0 * (ec_op__ec_subset_sum__bit_0 - 1).
              let val := mulmod(
                /*intermediate_value/ec_op/ec_subset_sum/bit_0*/ mload(0x2d00),
                addmod(
                  /*intermediate_value/ec_op/ec_subset_sum/bit_0*/ mload(0x2d00),
                  sub(PRIME, 1),
                  PRIME),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 153.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/ec_subset_sum/bit_extraction_end: column8_row21.
              let val := /*column8_row21*/ mload(0x1c20)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - trace_generator^(63 * trace_length / 64).
              // val *= denominator_invs[25].
              val := mulmod(val, /*denominator_invs[25]*/ mload(0x3e80), PRIME)

              // res += val * alpha ** 154.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/ec_subset_sum/zeros_tail: column8_row21.
              let val := /*column8_row21*/ mload(0x1c20)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= denominator_invs[16].
              val := mulmod(val, /*denominator_invs[16]*/ mload(0x3d60), PRIME)

              // res += val * alpha ** 155.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/ec_subset_sum/add_points/slope: ec_op__ec_subset_sum__bit_0 * (column8_row37 - column8_row25) - column8_row11 * (column8_row5 - column8_row41).
              let val := addmod(
                mulmod(
                  /*intermediate_value/ec_op/ec_subset_sum/bit_0*/ mload(0x2d00),
                  addmod(/*column8_row37*/ mload(0x1d40), sub(PRIME, /*column8_row25*/ mload(0x1c80)), PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                    /*column8_row11*/ mload(0x1b40),
                    addmod(/*column8_row5*/ mload(0x1a80), sub(PRIME, /*column8_row41*/ mload(0x1d80)), PRIME),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 156.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/ec_subset_sum/add_points/x: column8_row11 * column8_row11 - ec_op__ec_subset_sum__bit_0 * (column8_row5 + column8_row41 + column8_row69).
              let val := addmod(
                mulmod(/*column8_row11*/ mload(0x1b40), /*column8_row11*/ mload(0x1b40), PRIME),
                sub(
                  PRIME,
                  mulmod(
                    /*intermediate_value/ec_op/ec_subset_sum/bit_0*/ mload(0x2d00),
                    addmod(
                      addmod(/*column8_row5*/ mload(0x1a80), /*column8_row41*/ mload(0x1d80), PRIME),
                      /*column8_row69*/ mload(0x1f00),
                      PRIME),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 157.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/ec_subset_sum/add_points/y: ec_op__ec_subset_sum__bit_0 * (column8_row37 + column8_row101) - column8_row11 * (column8_row5 - column8_row69).
              let val := addmod(
                mulmod(
                  /*intermediate_value/ec_op/ec_subset_sum/bit_0*/ mload(0x2d00),
                  addmod(/*column8_row37*/ mload(0x1d40), /*column8_row101*/ mload(0x2020), PRIME),
                  PRIME),
                sub(
                  PRIME,
                  mulmod(
                    /*column8_row11*/ mload(0x1b40),
                    addmod(/*column8_row5*/ mload(0x1a80), sub(PRIME, /*column8_row69*/ mload(0x1f00)), PRIME),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 158.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/ec_subset_sum/add_points/x_diff_inv: column8_row43 * (column8_row5 - column8_row41) - 1.
              let val := addmod(
                mulmod(
                  /*column8_row43*/ mload(0x1da0),
                  addmod(/*column8_row5*/ mload(0x1a80), sub(PRIME, /*column8_row41*/ mload(0x1d80)), PRIME),
                  PRIME),
                sub(PRIME, 1),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 159.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/ec_subset_sum/copy_point/x: ec_op__ec_subset_sum__bit_neg_0 * (column8_row69 - column8_row5).
              let val := mulmod(
                /*intermediate_value/ec_op/ec_subset_sum/bit_neg_0*/ mload(0x2d20),
                addmod(/*column8_row69*/ mload(0x1f00), sub(PRIME, /*column8_row5*/ mload(0x1a80)), PRIME),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 160.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/ec_subset_sum/copy_point/y: ec_op__ec_subset_sum__bit_neg_0 * (column8_row101 - column8_row37).
              let val := mulmod(
                /*intermediate_value/ec_op/ec_subset_sum/bit_neg_0*/ mload(0x2d20),
                addmod(
                  /*column8_row101*/ mload(0x2020),
                  sub(PRIME, /*column8_row37*/ mload(0x1d40)),
                  PRIME),
                PRIME)

              // Numerator: point^(trace_length / 16384) - trace_generator^(255 * trace_length / 256).
              // val *= domains[24].
              val := mulmod(val, /*domains[24]*/ mload(0x3940), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 161.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/get_m: column8_row21 - column5_row10631.
              let val := addmod(
                /*column8_row21*/ mload(0x1c20),
                sub(PRIME, /*column5_row10631*/ mload(0x1140)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 162.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/get_p_x: column5_row8583 - column8_row5.
              let val := addmod(
                /*column5_row8583*/ mload(0x1100),
                sub(PRIME, /*column8_row5*/ mload(0x1a80)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 163.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/get_p_y: column5_row4487 - column8_row37.
              let val := addmod(
                /*column5_row4487*/ mload(0x1080),
                sub(PRIME, /*column8_row37*/ mload(0x1d40)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 164.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/set_r_x: column5_row6535 - column8_row16325.
              let val := addmod(
                /*column5_row6535*/ mload(0x10c0),
                sub(PRIME, /*column8_row16325*/ mload(0x24a0)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 165.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for ec_op/set_r_y: column5_row14727 - column8_row16357.
              let val := addmod(
                /*column5_row14727*/ mload(0x11c0),
                sub(PRIME, /*column8_row16357*/ mload(0x2540)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 16384) - 1.
              // val *= denominator_invs[22].
              val := mulmod(val, /*denominator_invs[22]*/ mload(0x3e20), PRIME)

              // res += val * alpha ** 166.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/init_input_output_addr: column5_row38 - initial_poseidon_addr.
              let val := addmod(
                /*column5_row38*/ mload(0xc80),
                sub(PRIME, /*initial_poseidon_addr*/ mload(0x520)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point - 1.
              // val *= denominator_invs[4].
              val := mulmod(val, /*denominator_invs[4]*/ mload(0x3be0), PRIME)

              // res += val * alpha ** 167.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/addr_input_output_step_inner: column5_row102 - (column5_row38 + 1).
              let val := addmod(
                /*column5_row102*/ mload(0xd00),
                sub(PRIME, addmod(/*column5_row38*/ mload(0xc80), 1, PRIME)),
                PRIME)

              // Numerator: (point^(trace_length / 512) - trace_generator^(5 * trace_length / 8)) * domain14.
              // val *= domains[15].
              val := mulmod(val, /*domains[15]*/ mload(0x3820), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 168.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/addr_input_output_step_outter: column5_row550 - (column5_row358 + 1).
              let val := addmod(
                /*column5_row550*/ mload(0xf40),
                sub(PRIME, addmod(/*column5_row358*/ mload(0xe80), 1, PRIME)),
                PRIME)

              // Numerator: point - trace_generator^(512 * (trace_length / 512 - 1)).
              // val *= domains[36].
              val := mulmod(val, /*domains[36]*/ mload(0x3ac0), PRIME)
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 169.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/full_rounds_state0_squaring: column8_row53 * column8_row53 - column8_row29.
              let val := addmod(
                mulmod(/*column8_row53*/ mload(0x1e40), /*column8_row53*/ mload(0x1e40), PRIME),
                sub(PRIME, /*column8_row29*/ mload(0x1cc0)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 170.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/full_rounds_state1_squaring: column8_row13 * column8_row13 - column8_row61.
              let val := addmod(
                mulmod(/*column8_row13*/ mload(0x1b80), /*column8_row13*/ mload(0x1b80), PRIME),
                sub(PRIME, /*column8_row61*/ mload(0x1ec0)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 171.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/full_rounds_state2_squaring: column8_row45 * column8_row45 - column8_row3.
              let val := addmod(
                mulmod(/*column8_row45*/ mload(0x1dc0), /*column8_row45*/ mload(0x1dc0), PRIME),
                sub(PRIME, /*column8_row3*/ mload(0x1a40)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 172.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/partial_rounds_state0_squaring: column7_row3 * column7_row3 - column7_row7.
              let val := addmod(
                mulmod(/*column7_row3*/ mload(0x1340), /*column7_row3*/ mload(0x1340), PRIME),
                sub(PRIME, /*column7_row7*/ mload(0x13c0)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 8) - 1.
              // val *= denominator_invs[7].
              val := mulmod(val, /*denominator_invs[7]*/ mload(0x3c40), PRIME)

              // res += val * alpha ** 173.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/partial_rounds_state1_squaring: column8_row6 * column8_row6 - column8_row14.
              let val := addmod(
                mulmod(/*column8_row6*/ mload(0x1aa0), /*column8_row6*/ mload(0x1aa0), PRIME),
                sub(PRIME, /*column8_row14*/ mload(0x1ba0)),
                PRIME)

              // Numerator: domain14 * domain17.
              // val *= domains[18].
              val := mulmod(val, /*domains[18]*/ mload(0x3880), PRIME)
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 174.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/add_first_round_key0: column5_row39 + 2950795762459345168613727575620414179244544320470208355568817838579231751791 - column8_row53.
              let val := addmod(
                addmod(
                  /*column5_row39*/ mload(0xca0),
                  2950795762459345168613727575620414179244544320470208355568817838579231751791,
                  PRIME),
                sub(PRIME, /*column8_row53*/ mload(0x1e40)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 175.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/add_first_round_key1: column5_row103 + 1587446564224215276866294500450702039420286416111469274423465069420553242820 - column8_row13.
              let val := addmod(
                addmod(
                  /*column5_row103*/ mload(0xd20),
                  1587446564224215276866294500450702039420286416111469274423465069420553242820,
                  PRIME),
                sub(PRIME, /*column8_row13*/ mload(0x1b80)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 176.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/add_first_round_key2: column5_row167 + 1645965921169490687904413452218868659025437693527479459426157555728339600137 - column8_row45.
              let val := addmod(
                addmod(
                  /*column5_row167*/ mload(0xd80),
                  1645965921169490687904413452218868659025437693527479459426157555728339600137,
                  PRIME),
                sub(PRIME, /*column8_row45*/ mload(0x1dc0)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 177.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/full_round0: column8_row117 - (poseidon__poseidon__full_rounds_state0_cubed_0 + poseidon__poseidon__full_rounds_state0_cubed_0 + poseidon__poseidon__full_rounds_state0_cubed_0 + poseidon__poseidon__full_rounds_state1_cubed_0 + poseidon__poseidon__full_rounds_state2_cubed_0 + poseidon__poseidon__full_round_key0).
              let val := addmod(
                /*column8_row117*/ mload(0x20a0),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      addmod(
                        addmod(
                          addmod(
                            /*intermediate_value/poseidon/poseidon/full_rounds_state0_cubed_0*/ mload(0x2d40),
                            /*intermediate_value/poseidon/poseidon/full_rounds_state0_cubed_0*/ mload(0x2d40),
                            PRIME),
                          /*intermediate_value/poseidon/poseidon/full_rounds_state0_cubed_0*/ mload(0x2d40),
                          PRIME),
                        /*intermediate_value/poseidon/poseidon/full_rounds_state1_cubed_0*/ mload(0x2d60),
                        PRIME),
                      /*intermediate_value/poseidon/poseidon/full_rounds_state2_cubed_0*/ mload(0x2d80),
                      PRIME),
                    /*periodic_column/poseidon/poseidon/full_round_key0*/ mload(0x80),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 256) - trace_generator^(3 * trace_length / 4).
              // val *= domains[11].
              val := mulmod(val, /*domains[11]*/ mload(0x37a0), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 178.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/full_round1: column8_row77 + poseidon__poseidon__full_rounds_state1_cubed_0 - (poseidon__poseidon__full_rounds_state0_cubed_0 + poseidon__poseidon__full_rounds_state2_cubed_0 + poseidon__poseidon__full_round_key1).
              let val := addmod(
                addmod(
                  /*column8_row77*/ mload(0x1f60),
                  /*intermediate_value/poseidon/poseidon/full_rounds_state1_cubed_0*/ mload(0x2d60),
                  PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      /*intermediate_value/poseidon/poseidon/full_rounds_state0_cubed_0*/ mload(0x2d40),
                      /*intermediate_value/poseidon/poseidon/full_rounds_state2_cubed_0*/ mload(0x2d80),
                      PRIME),
                    /*periodic_column/poseidon/poseidon/full_round_key1*/ mload(0xa0),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 256) - trace_generator^(3 * trace_length / 4).
              // val *= domains[11].
              val := mulmod(val, /*domains[11]*/ mload(0x37a0), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 179.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/full_round2: column8_row109 + poseidon__poseidon__full_rounds_state2_cubed_0 + poseidon__poseidon__full_rounds_state2_cubed_0 - (poseidon__poseidon__full_rounds_state0_cubed_0 + poseidon__poseidon__full_rounds_state1_cubed_0 + poseidon__poseidon__full_round_key2).
              let val := addmod(
                addmod(
                  addmod(
                    /*column8_row109*/ mload(0x2060),
                    /*intermediate_value/poseidon/poseidon/full_rounds_state2_cubed_0*/ mload(0x2d80),
                    PRIME),
                  /*intermediate_value/poseidon/poseidon/full_rounds_state2_cubed_0*/ mload(0x2d80),
                  PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      /*intermediate_value/poseidon/poseidon/full_rounds_state0_cubed_0*/ mload(0x2d40),
                      /*intermediate_value/poseidon/poseidon/full_rounds_state1_cubed_0*/ mload(0x2d60),
                      PRIME),
                    /*periodic_column/poseidon/poseidon/full_round_key2*/ mload(0xc0),
                    PRIME)),
                PRIME)

              // Numerator: point^(trace_length / 256) - trace_generator^(3 * trace_length / 4).
              // val *= domains[11].
              val := mulmod(val, /*domains[11]*/ mload(0x37a0), PRIME)
              // Denominator: point^(trace_length / 64) - 1.
              // val *= denominator_invs[15].
              val := mulmod(val, /*denominator_invs[15]*/ mload(0x3d40), PRIME)

              // res += val * alpha ** 180.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/last_full_round0: column5_row231 - (poseidon__poseidon__full_rounds_state0_cubed_7 + poseidon__poseidon__full_rounds_state0_cubed_7 + poseidon__poseidon__full_rounds_state0_cubed_7 + poseidon__poseidon__full_rounds_state1_cubed_7 + poseidon__poseidon__full_rounds_state2_cubed_7).
              let val := addmod(
                /*column5_row231*/ mload(0xde0),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      addmod(
                        addmod(
                          /*intermediate_value/poseidon/poseidon/full_rounds_state0_cubed_7*/ mload(0x2da0),
                          /*intermediate_value/poseidon/poseidon/full_rounds_state0_cubed_7*/ mload(0x2da0),
                          PRIME),
                        /*intermediate_value/poseidon/poseidon/full_rounds_state0_cubed_7*/ mload(0x2da0),
                        PRIME),
                      /*intermediate_value/poseidon/poseidon/full_rounds_state1_cubed_7*/ mload(0x2dc0),
                      PRIME),
                    /*intermediate_value/poseidon/poseidon/full_rounds_state2_cubed_7*/ mload(0x2de0),
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 181.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/last_full_round1: column5_row295 + poseidon__poseidon__full_rounds_state1_cubed_7 - (poseidon__poseidon__full_rounds_state0_cubed_7 + poseidon__poseidon__full_rounds_state2_cubed_7).
              let val := addmod(
                addmod(
                  /*column5_row295*/ mload(0xe40),
                  /*intermediate_value/poseidon/poseidon/full_rounds_state1_cubed_7*/ mload(0x2dc0),
                  PRIME),
                sub(
                  PRIME,
                  addmod(
                    /*intermediate_value/poseidon/poseidon/full_rounds_state0_cubed_7*/ mload(0x2da0),
                    /*intermediate_value/poseidon/poseidon/full_rounds_state2_cubed_7*/ mload(0x2de0),
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 182.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/last_full_round2: column5_row359 + poseidon__poseidon__full_rounds_state2_cubed_7 + poseidon__poseidon__full_rounds_state2_cubed_7 - (poseidon__poseidon__full_rounds_state0_cubed_7 + poseidon__poseidon__full_rounds_state1_cubed_7).
              let val := addmod(
                addmod(
                  addmod(
                    /*column5_row359*/ mload(0xea0),
                    /*intermediate_value/poseidon/poseidon/full_rounds_state2_cubed_7*/ mload(0x2de0),
                    PRIME),
                  /*intermediate_value/poseidon/poseidon/full_rounds_state2_cubed_7*/ mload(0x2de0),
                  PRIME),
                sub(
                  PRIME,
                  addmod(
                    /*intermediate_value/poseidon/poseidon/full_rounds_state0_cubed_7*/ mload(0x2da0),
                    /*intermediate_value/poseidon/poseidon/full_rounds_state1_cubed_7*/ mload(0x2dc0),
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 183.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/copy_partial_rounds0_i0: column7_row491 - column8_row6.
              let val := addmod(/*column7_row491*/ mload(0x1800), sub(PRIME, /*column8_row6*/ mload(0x1aa0)), PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 184.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/copy_partial_rounds0_i1: column7_row499 - column8_row22.
              let val := addmod(
                /*column7_row499*/ mload(0x1820),
                sub(PRIME, /*column8_row22*/ mload(0x1c40)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 185.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/copy_partial_rounds0_i2: column7_row507 - column8_row38.
              let val := addmod(
                /*column7_row507*/ mload(0x1840),
                sub(PRIME, /*column8_row38*/ mload(0x1d60)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 186.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/margin_full_to_partial0: column7_row3 + poseidon__poseidon__full_rounds_state2_cubed_3 + poseidon__poseidon__full_rounds_state2_cubed_3 - (poseidon__poseidon__full_rounds_state0_cubed_3 + poseidon__poseidon__full_rounds_state1_cubed_3 + 2121140748740143694053732746913428481442990369183417228688865837805149503386).
              let val := addmod(
                addmod(
                  addmod(
                    /*column7_row3*/ mload(0x1340),
                    /*intermediate_value/poseidon/poseidon/full_rounds_state2_cubed_3*/ mload(0x2e40),
                    PRIME),
                  /*intermediate_value/poseidon/poseidon/full_rounds_state2_cubed_3*/ mload(0x2e40),
                  PRIME),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      /*intermediate_value/poseidon/poseidon/full_rounds_state0_cubed_3*/ mload(0x2e00),
                      /*intermediate_value/poseidon/poseidon/full_rounds_state1_cubed_3*/ mload(0x2e20),
                      PRIME),
                    2121140748740143694053732746913428481442990369183417228688865837805149503386,
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 187.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/margin_full_to_partial1: column7_row11 - (3618502788666131213697322783095070105623107215331596699973092056135872020477 * poseidon__poseidon__full_rounds_state1_cubed_3 + 10 * poseidon__poseidon__full_rounds_state2_cubed_3 + 4 * column7_row3 + 3618502788666131213697322783095070105623107215331596699973092056135872020479 * poseidon__poseidon__partial_rounds_state0_cubed_0 + 2006642341318481906727563724340978325665491359415674592697055778067937914672).
              let val := addmod(
                /*column7_row11*/ mload(0x1420),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      addmod(
                        addmod(
                          mulmod(
                            3618502788666131213697322783095070105623107215331596699973092056135872020477,
                            /*intermediate_value/poseidon/poseidon/full_rounds_state1_cubed_3*/ mload(0x2e20),
                            PRIME),
                          mulmod(
                            10,
                            /*intermediate_value/poseidon/poseidon/full_rounds_state2_cubed_3*/ mload(0x2e40),
                            PRIME),
                          PRIME),
                        mulmod(4, /*column7_row3*/ mload(0x1340), PRIME),
                        PRIME),
                      mulmod(
                        3618502788666131213697322783095070105623107215331596699973092056135872020479,
                        /*intermediate_value/poseidon/poseidon/partial_rounds_state0_cubed_0*/ mload(0x2e60),
                        PRIME),
                      PRIME),
                    2006642341318481906727563724340978325665491359415674592697055778067937914672,
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 188.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/margin_full_to_partial2: column7_row19 - (8 * poseidon__poseidon__full_rounds_state2_cubed_3 + 4 * column7_row3 + 6 * poseidon__poseidon__partial_rounds_state0_cubed_0 + column7_row11 + column7_row11 + 3618502788666131213697322783095070105623107215331596699973092056135872020479 * poseidon__poseidon__partial_rounds_state0_cubed_1 + 427751140904099001132521606468025610873158555767197326325930641757709538586).
              let val := addmod(
                /*column7_row19*/ mload(0x14c0),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      addmod(
                        addmod(
                          addmod(
                            addmod(
                              mulmod(
                                8,
                                /*intermediate_value/poseidon/poseidon/full_rounds_state2_cubed_3*/ mload(0x2e40),
                                PRIME),
                              mulmod(4, /*column7_row3*/ mload(0x1340), PRIME),
                              PRIME),
                            mulmod(
                              6,
                              /*intermediate_value/poseidon/poseidon/partial_rounds_state0_cubed_0*/ mload(0x2e60),
                              PRIME),
                            PRIME),
                          /*column7_row11*/ mload(0x1420),
                          PRIME),
                        /*column7_row11*/ mload(0x1420),
                        PRIME),
                      mulmod(
                        3618502788666131213697322783095070105623107215331596699973092056135872020479,
                        /*intermediate_value/poseidon/poseidon/partial_rounds_state0_cubed_1*/ mload(0x2e80),
                        PRIME),
                      PRIME),
                    427751140904099001132521606468025610873158555767197326325930641757709538586,
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 189.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/partial_round0: column7_row27 - (8 * poseidon__poseidon__partial_rounds_state0_cubed_0 + 4 * column7_row11 + 6 * poseidon__poseidon__partial_rounds_state0_cubed_1 + column7_row19 + column7_row19 + 3618502788666131213697322783095070105623107215331596699973092056135872020479 * poseidon__poseidon__partial_rounds_state0_cubed_2 + poseidon__poseidon__partial_round_key0).
              let val := addmod(
                /*column7_row27*/ mload(0x1500),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      addmod(
                        addmod(
                          addmod(
                            addmod(
                              mulmod(
                                8,
                                /*intermediate_value/poseidon/poseidon/partial_rounds_state0_cubed_0*/ mload(0x2e60),
                                PRIME),
                              mulmod(4, /*column7_row11*/ mload(0x1420), PRIME),
                              PRIME),
                            mulmod(
                              6,
                              /*intermediate_value/poseidon/poseidon/partial_rounds_state0_cubed_1*/ mload(0x2e80),
                              PRIME),
                            PRIME),
                          /*column7_row19*/ mload(0x14c0),
                          PRIME),
                        /*column7_row19*/ mload(0x14c0),
                        PRIME),
                      mulmod(
                        3618502788666131213697322783095070105623107215331596699973092056135872020479,
                        /*intermediate_value/poseidon/poseidon/partial_rounds_state0_cubed_2*/ mload(0x2ea0),
                        PRIME),
                      PRIME),
                    /*periodic_column/poseidon/poseidon/partial_round_key0*/ mload(0xe0),
                    PRIME)),
                PRIME)

              // Numerator: (point^(trace_length / 512) - trace_generator^(61 * trace_length / 64)) * (point^(trace_length / 512) - trace_generator^(63 * trace_length / 64)) * domain16.
              // val *= domains[19].
              val := mulmod(val, /*domains[19]*/ mload(0x38a0), PRIME)
              // Denominator: point^(trace_length / 8) - 1.
              // val *= denominator_invs[7].
              val := mulmod(val, /*denominator_invs[7]*/ mload(0x3c40), PRIME)

              // res += val * alpha ** 190.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/partial_round1: column8_row54 - (8 * poseidon__poseidon__partial_rounds_state1_cubed_0 + 4 * column8_row22 + 6 * poseidon__poseidon__partial_rounds_state1_cubed_1 + column8_row38 + column8_row38 + 3618502788666131213697322783095070105623107215331596699973092056135872020479 * poseidon__poseidon__partial_rounds_state1_cubed_2 + poseidon__poseidon__partial_round_key1).
              let val := addmod(
                /*column8_row54*/ mload(0x1e60),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      addmod(
                        addmod(
                          addmod(
                            addmod(
                              mulmod(
                                8,
                                /*intermediate_value/poseidon/poseidon/partial_rounds_state1_cubed_0*/ mload(0x2ec0),
                                PRIME),
                              mulmod(4, /*column8_row22*/ mload(0x1c40), PRIME),
                              PRIME),
                            mulmod(
                              6,
                              /*intermediate_value/poseidon/poseidon/partial_rounds_state1_cubed_1*/ mload(0x2ee0),
                              PRIME),
                            PRIME),
                          /*column8_row38*/ mload(0x1d60),
                          PRIME),
                        /*column8_row38*/ mload(0x1d60),
                        PRIME),
                      mulmod(
                        3618502788666131213697322783095070105623107215331596699973092056135872020479,
                        /*intermediate_value/poseidon/poseidon/partial_rounds_state1_cubed_2*/ mload(0x2f00),
                        PRIME),
                      PRIME),
                    /*periodic_column/poseidon/poseidon/partial_round_key1*/ mload(0x100),
                    PRIME)),
                PRIME)

              // Numerator: (point^(trace_length / 512) - trace_generator^(19 * trace_length / 32)) * (point^(trace_length / 512) - trace_generator^(21 * trace_length / 32)) * domain15 * domain17.
              // val *= domains[20].
              val := mulmod(val, /*domains[20]*/ mload(0x38c0), PRIME)
              // Denominator: point^(trace_length / 16) - 1.
              // val *= denominator_invs[2].
              val := mulmod(val, /*denominator_invs[2]*/ mload(0x3ba0), PRIME)

              // res += val * alpha ** 191.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/margin_partial_to_full0: column8_row309 - (16 * poseidon__poseidon__partial_rounds_state1_cubed_19 + 8 * column8_row326 + 16 * poseidon__poseidon__partial_rounds_state1_cubed_20 + 6 * column8_row342 + poseidon__poseidon__partial_rounds_state1_cubed_21 + 560279373700919169769089400651532183647886248799764942664266404650165812023).
              let val := addmod(
                /*column8_row309*/ mload(0x2240),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      addmod(
                        addmod(
                          addmod(
                            mulmod(
                              16,
                              /*intermediate_value/poseidon/poseidon/partial_rounds_state1_cubed_19*/ mload(0x2f20),
                              PRIME),
                            mulmod(8, /*column8_row326*/ mload(0x22a0), PRIME),
                            PRIME),
                          mulmod(
                            16,
                            /*intermediate_value/poseidon/poseidon/partial_rounds_state1_cubed_20*/ mload(0x2f40),
                            PRIME),
                          PRIME),
                        mulmod(6, /*column8_row342*/ mload(0x22e0), PRIME),
                        PRIME),
                      /*intermediate_value/poseidon/poseidon/partial_rounds_state1_cubed_21*/ mload(0x2f60),
                      PRIME),
                    560279373700919169769089400651532183647886248799764942664266404650165812023,
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 192.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/margin_partial_to_full1: column8_row269 - (4 * poseidon__poseidon__partial_rounds_state1_cubed_20 + column8_row342 + column8_row342 + poseidon__poseidon__partial_rounds_state1_cubed_21 + 1401754474293352309994371631695783042590401941592571735921592823982231996415).
              let val := addmod(
                /*column8_row269*/ mload(0x2200),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      addmod(
                        addmod(
                          mulmod(
                            4,
                            /*intermediate_value/poseidon/poseidon/partial_rounds_state1_cubed_20*/ mload(0x2f40),
                            PRIME),
                          /*column8_row342*/ mload(0x22e0),
                          PRIME),
                        /*column8_row342*/ mload(0x22e0),
                        PRIME),
                      /*intermediate_value/poseidon/poseidon/partial_rounds_state1_cubed_21*/ mload(0x2f60),
                      PRIME),
                    1401754474293352309994371631695783042590401941592571735921592823982231996415,
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 193.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

              {
              // Constraint expression for poseidon/poseidon/margin_partial_to_full2: column8_row301 - (8 * poseidon__poseidon__partial_rounds_state1_cubed_19 + 4 * column8_row326 + 6 * poseidon__poseidon__partial_rounds_state1_cubed_20 + column8_row342 + column8_row342 + 3618502788666131213697322783095070105623107215331596699973092056135872020479 * poseidon__poseidon__partial_rounds_state1_cubed_21 + 1246177936547655338400308396717835700699368047388302793172818304164989556526).
              let val := addmod(
                /*column8_row301*/ mload(0x2220),
                sub(
                  PRIME,
                  addmod(
                    addmod(
                      addmod(
                        addmod(
                          addmod(
                            addmod(
                              mulmod(
                                8,
                                /*intermediate_value/poseidon/poseidon/partial_rounds_state1_cubed_19*/ mload(0x2f20),
                                PRIME),
                              mulmod(4, /*column8_row326*/ mload(0x22a0), PRIME),
                              PRIME),
                            mulmod(
                              6,
                              /*intermediate_value/poseidon/poseidon/partial_rounds_state1_cubed_20*/ mload(0x2f40),
                              PRIME),
                            PRIME),
                          /*column8_row342*/ mload(0x22e0),
                          PRIME),
                        /*column8_row342*/ mload(0x22e0),
                        PRIME),
                      mulmod(
                        3618502788666131213697322783095070105623107215331596699973092056135872020479,
                        /*intermediate_value/poseidon/poseidon/partial_rounds_state1_cubed_21*/ mload(0x2f60),
                        PRIME),
                      PRIME),
                    1246177936547655338400308396717835700699368047388302793172818304164989556526,
                    PRIME)),
                PRIME)

              // Numerator: 1.
              // val *= 1.
              // Denominator: point^(trace_length / 512) - 1.
              // val *= denominator_invs[14].
              val := mulmod(val, /*denominator_invs[14]*/ mload(0x3d20), PRIME)

              // res += val * alpha ** 194.
              res := addmod(res, mulmod(val, composition_alpha_pow, PRIME), PRIME)
              composition_alpha_pow := mulmod(composition_alpha_pow, composition_alpha, PRIME)
              }

            mstore(0, res)
            return(0, 0x20)
            }
        }
    }
}
// ---------- End of auto-generated code. ----------

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "CpuVerifier.sol";
import "FriStatementVerifier.sol";
import "MerkleStatementVerifier.sol";

contract CpuFrilessVerifier is CpuVerifier, MerkleStatementVerifier, FriStatementVerifier {
    constructor(
        address[] memory auxPolynomials,
        address oodsContract,
        address memoryPageFactRegistry_,
        address merkleStatementContractAddress,
        address friStatementContractAddress,
        uint256 numSecurityBits_,
        uint256 minProofOfWorkBits_
    )
        public
        MerkleStatementVerifier(merkleStatementContractAddress)
        FriStatementVerifier(friStatementContractAddress)
        CpuVerifier(
            auxPolynomials,
            oodsContract,
            memoryPageFactRegistry_,
            numSecurityBits_,
            minProofOfWorkBits_
        )
    {}

    function verifyMerkle(
        uint256 channelPtr,
        uint256 queuePtr,
        bytes32 root,
        uint256 n
    ) internal view override(MerkleStatementVerifier, MerkleVerifier) returns (bytes32) {
        return MerkleStatementVerifier.verifyMerkle(channelPtr, queuePtr, root, n);
    }

    function friVerifyLayers(uint256[] memory ctx)
        internal
        view
        override(FriStatementVerifier, Fri)
    {
        FriStatementVerifier.friVerifyLayers(ctx);
    }
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "CpuPublicInputOffsetsBase.sol";

contract CpuPublicInputOffsets is CpuPublicInputOffsetsBase {
    // The following constants are offsets of data expected in the public input.
    uint256 internal constant OFFSET_ECDSA_BEGIN_ADDR = 14;
    uint256 internal constant OFFSET_ECDSA_STOP_PTR = 15;
    uint256 internal constant OFFSET_BITWISE_BEGIN_ADDR = 16;
    uint256 internal constant OFFSET_BITWISE_STOP_ADDR = 17;
    uint256 internal constant OFFSET_EC_OP_BEGIN_ADDR = 18;
    uint256 internal constant OFFSET_EC_OP_STOP_ADDR = 19;
    uint256 internal constant OFFSET_POSEIDON_BEGIN_ADDR = 20;
    uint256 internal constant OFFSET_POSEIDON_STOP_PTR = 21;
    uint256 internal constant OFFSET_PUBLIC_MEMORY_PADDING_ADDR = 22;
    uint256 internal constant OFFSET_PUBLIC_MEMORY_PADDING_VALUE = 23;
    uint256 internal constant OFFSET_N_PUBLIC_MEMORY_PAGES = 24;
    uint256 internal constant OFFSET_PUBLIC_MEMORY = 25;
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "PageInfo.sol";

contract CpuPublicInputOffsetsBase is PageInfo {
    // The following constants are offsets of data expected in the public input.
    uint256 internal constant OFFSET_LOG_N_STEPS = 0;
    uint256 internal constant OFFSET_RC_MIN = 1;
    uint256 internal constant OFFSET_RC_MAX = 2;
    uint256 internal constant OFFSET_LAYOUT_CODE = 3;
    uint256 internal constant OFFSET_PROGRAM_BEGIN_ADDR = 4;
    uint256 internal constant OFFSET_PROGRAM_STOP_PTR = 5;
    uint256 internal constant OFFSET_EXECUTION_BEGIN_ADDR = 6;
    uint256 internal constant OFFSET_EXECUTION_STOP_PTR = 7;
    uint256 internal constant OFFSET_OUTPUT_BEGIN_ADDR = 8;
    uint256 internal constant OFFSET_OUTPUT_STOP_PTR = 9;
    uint256 internal constant OFFSET_PEDERSEN_BEGIN_ADDR = 10;
    uint256 internal constant OFFSET_PEDERSEN_STOP_PTR = 11;
    uint256 internal constant OFFSET_RANGE_CHECK_BEGIN_ADDR = 12;
    uint256 internal constant OFFSET_RANGE_CHECK_STOP_PTR = 13;

    // The program segment starts from 1, so that memory address 0 is kept for the null pointer.
    uint256 internal constant INITIAL_PC = 1;
    // The first Cairo instructions are:
    //   ap += n_args; call main; jmp rel 0.
    // As the first two instructions occupy 2 cells each, the "jmp rel 0" instruction is at
    // offset 4 relative to INITIAL_PC.
    uint256 internal constant FINAL_PC = INITIAL_PC + 4;
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "CairoVerifierContract.sol";
import "MemoryPageFactRegistry.sol";
import "PublicMemoryOffsets.sol";
import "CpuConstraintPoly.sol";
import "LayoutSpecific.sol";
import "StarkVerifier.sol";

/*
  Verifies a Cairo statement: there exists a memory assignment and a valid corresponding program
  trace satisfying the public memory requirements, for which if a program starts at pc=INITIAL_PC,
  it runs successfully and ends with pc=FINAL_PC.

  This contract verifies that:
  * Initial pc is INITIAL_PC and final pc is FINAL_PC.
  * The memory assignment satisfies the given public memory requirements.
  * The 16-bit range-checks are properly configured (0 <= rc_min <= rc_max < 2^16).
  * The segments for the builtins do not exceed their maximum length (thus
    when these builtins are properly used in the program, they will function correctly).
  * The layout is valid.

  This contract DOES NOT (those should be verified outside of this contract):
  * verify that the requested program is loaded, starting from INITIAL_PC.
  * verify that the arguments and return values for main() are properly set (e.g., the segment
    pointers).
  * check anything on the program output.
  * verify that [initial_fp - 2] = initial_fp, which is required to guarantee the "safe call"
    feature (that is, all "call" instructions will return, even if the called function is
    malicious). It guarantees that it's not possible to create a cycle in the call stack.
*/
contract CpuVerifier is
    StarkVerifier,
    MemoryPageFactRegistryConstants,
    LayoutSpecific,
    PublicMemoryOffsets
{
    CpuConstraintPoly constraintPoly;
    IFactRegistry memoryPageFactRegistry;

    constructor(
        address[] memory auxPolynomials,
        address oodsContract,
        address memoryPageFactRegistry_,
        uint256 numSecurityBits_,
        uint256 minProofOfWorkBits_
    ) public StarkVerifier(numSecurityBits_, minProofOfWorkBits_, oodsContract) {
        constraintPoly = CpuConstraintPoly(auxPolynomials[0]);
        initPeriodicColumns(auxPolynomials);
        memoryPageFactRegistry = IFactRegistry(memoryPageFactRegistry_);
    }

    function verifyProofExternal(
        uint256[] calldata proofParams,
        uint256[] calldata proof,
        uint256[] calldata publicInput
    ) external override {
        verifyProof(proofParams, proof, publicInput);
    }

    function getNColumnsInTrace() internal pure override returns (uint256) {
        return N_COLUMNS_IN_MASK;
    }

    function getNColumnsInTrace0() internal pure override returns (uint256) {
        return N_COLUMNS_IN_TRACE0;
    }

    function getNColumnsInTrace1() internal pure override returns (uint256) {
        return N_COLUMNS_IN_TRACE1;
    }

    function getNColumnsInComposition() internal pure override returns (uint256) {
        return CONSTRAINTS_DEGREE_BOUND;
    }

    function getMmInteractionElements() internal pure override returns (uint256) {
        return MM_INTERACTION_ELEMENTS;
    }

    function getMmOodsValues() internal pure override returns (uint256) {
        return MM_OODS_VALUES;
    }

    function getNInteractionElements() internal pure override returns (uint256) {
        return N_INTERACTION_ELEMENTS;
    }

    function getNCoefficients() internal pure override returns (uint256) {
        return N_COEFFICIENTS;
    }

    function getNOodsValues() internal pure override returns (uint256) {
        return N_OODS_VALUES;
    }

    function getNOodsCoefficients() internal pure override returns (uint256) {
        return N_OODS_COEFFICIENTS;
    }

    function getPublicMemoryOffset() internal pure override returns (uint256) {
        return OFFSET_PUBLIC_MEMORY;
    }

    function airSpecificInit(uint256[] memory publicInput)
        internal
        view
        override
        returns (uint256[] memory ctx, uint256 logTraceLength)
    {
        require(publicInput.length >= OFFSET_PUBLIC_MEMORY, "publicInput is too short.");
        ctx = new uint256[](MM_CONTEXT_SIZE);

        // Context for generated code.
        ctx[MM_OFFSET_SIZE] = 2**16;
        ctx[MM_HALF_OFFSET_SIZE] = 2**15;

        // Number of steps.
        uint256 logNSteps = publicInput[OFFSET_LOG_N_STEPS];
        require(logNSteps < 50, "Number of steps is too large.");
        ctx[MM_LOG_N_STEPS] = logNSteps;
        logTraceLength = logNSteps + LOG_CPU_COMPONENT_HEIGHT;

        // Range check limits.
        ctx[MM_RC_MIN] = publicInput[OFFSET_RC_MIN];
        ctx[MM_RC_MAX] = publicInput[OFFSET_RC_MAX];
        require(ctx[MM_RC_MIN] <= ctx[MM_RC_MAX], "rc_min must be <= rc_max");
        require(ctx[MM_RC_MAX] < ctx[MM_OFFSET_SIZE], "rc_max out of range");

        // Layout.
        require(publicInput[OFFSET_LAYOUT_CODE] == LAYOUT_CODE, "Layout code mismatch.");

        // Initial and final pc ("program" memory segment).
        ctx[MM_INITIAL_PC] = publicInput[OFFSET_PROGRAM_BEGIN_ADDR];
        ctx[MM_FINAL_PC] = publicInput[OFFSET_PROGRAM_STOP_PTR];
        // Invalid final pc may indicate that the program end was moved, or the program didn't
        // complete.
        require(ctx[MM_INITIAL_PC] == INITIAL_PC, "Invalid initial pc");
        require(ctx[MM_FINAL_PC] == FINAL_PC, "Invalid final pc");

        // Initial and final ap ("execution" memory segment).
        ctx[MM_INITIAL_AP] = publicInput[OFFSET_EXECUTION_BEGIN_ADDR];
        ctx[MM_FINAL_AP] = publicInput[OFFSET_EXECUTION_STOP_PTR];

        // Public memory.
        require(
            publicInput[OFFSET_N_PUBLIC_MEMORY_PAGES] >= 1 &&
                publicInput[OFFSET_N_PUBLIC_MEMORY_PAGES] < 100000,
            "Invalid number of memory pages."
        );
        ctx[MM_N_PUBLIC_MEM_PAGES] = publicInput[OFFSET_N_PUBLIC_MEMORY_PAGES];

        {
            // Compute the total number of public memory entries.
            uint256 n_public_memory_entries = 0;
            for (uint256 page = 0; page < ctx[MM_N_PUBLIC_MEM_PAGES]; page++) {
                uint256 n_page_entries = publicInput[getOffsetPageSize(page)];
                require(n_page_entries < 2**30, "Too many public memory entries in one page.");
                n_public_memory_entries += n_page_entries;
            }
            ctx[MM_N_PUBLIC_MEM_ENTRIES] = n_public_memory_entries;
        }

        uint256 expectedPublicInputLength = getPublicInputLength(ctx[MM_N_PUBLIC_MEM_PAGES]);
        require(expectedPublicInputLength == publicInput.length, "Public input length mismatch.");

        uint256 lmmPublicInputPtr = MM_PUBLIC_INPUT_PTR;
        assembly {
            // Set public input pointer to point at the first word of the public input
            // (skipping length word).
            mstore(add(ctx, mul(add(lmmPublicInputPtr, 1), 0x20)), add(publicInput, 0x20))
        }

        layoutSpecificInit(ctx, publicInput);
    }

    function getPublicInputHash(uint256[] memory publicInput)
        internal
        pure
        override
        returns (bytes32 publicInputHash)
    {
        // The initial seed consists of the first part of publicInput. Specifically, it does not
        // include the page products (which are only known later in the process, as they depend on
        // the values of z and alpha).
        uint256 nPages = publicInput[OFFSET_N_PUBLIC_MEMORY_PAGES];
        uint256 publicInputSizeForHash = 0x20 * getOffsetPageProd(0, nPages);

        assembly {
            publicInputHash := keccak256(add(publicInput, 0x20), publicInputSizeForHash)
        }
    }

    /*
      Computes the value of the public memory quotient:
        numerator / (denominator * padding)
      where:
        numerator = (z - (0 + alpha * 0))^S,
        denominator = \prod_i( z - (addr_i + alpha * value_i) ),
        padding = (z - (padding_addr + alpha * padding_value))^(S - N),
        N is the actual number of public memory cells,
        and S is the number of cells allocated for the public memory (which includes the padding).
    */
    function computePublicMemoryQuotient(uint256[] memory ctx) private view returns (uint256) {
        uint256 nValues = ctx[MM_N_PUBLIC_MEM_ENTRIES];
        uint256 z = ctx[MM_MEMORY__MULTI_COLUMN_PERM__PERM__INTERACTION_ELM];
        uint256 alpha = ctx[MM_MEMORY__MULTI_COLUMN_PERM__HASH_INTERACTION_ELM0];
        // The size that is allocated to the public memory.
        uint256 publicMemorySize = safeDiv(ctx[MM_TRACE_LENGTH], PUBLIC_MEMORY_STEP);

        // Ensure 'nValues' is bounded as a sanity check
        // (the bound is somewhat arbitrary).
        require(nValues < 0x1000000, "Overflow protection failed.");
        require(nValues <= publicMemorySize, "Number of values of public memory is too large.");

        uint256 nPublicMemoryPages = ctx[MM_N_PUBLIC_MEM_PAGES];
        uint256 cumulativeProdsPtr = ctx[MM_PUBLIC_INPUT_PTR] +
            getOffsetPageProd(0, nPublicMemoryPages) *
            0x20;
        uint256 denominator = computePublicMemoryProd(
            cumulativeProdsPtr,
            nPublicMemoryPages,
            K_MODULUS
        );

        // Compute address + alpha * value for the first address-value pair for padding.
        uint256 publicInputPtr = ctx[MM_PUBLIC_INPUT_PTR];
        uint256 paddingAddr;
        uint256 paddingValue;
        assembly {
            let paddingAddrPtr := add(publicInputPtr, mul(0x20, OFFSET_PUBLIC_MEMORY_PADDING_ADDR))
            paddingAddr := mload(paddingAddrPtr)
            paddingValue := mload(add(paddingAddrPtr, 0x20))
        }
        uint256 hash_first_address_value = fadd(paddingAddr, fmul(paddingValue, alpha));

        // Pad the denominator with the shifted value of hash_first_address_value.
        uint256 denom_pad = fpow(fsub(z, hash_first_address_value), publicMemorySize - nValues);
        denominator = fmul(denominator, denom_pad);

        // Calculate the numerator.
        uint256 numerator = fpow(z, publicMemorySize);

        // Compute the final result: numerator * denominator^(-1).
        return fmul(numerator, inverse(denominator));
    }

    /*
      Computes the cumulative product of the public memory cells:
        \prod_i( z - (addr_i + alpha * value_i) ).

      publicMemoryPtr is an array of nValues pairs (address, value).
      z and alpha are the perm and hash interaction elements required to calculate the product.
    */
    function computePublicMemoryProd(
        uint256 cumulativeProdsPtr,
        uint256 nPublicMemoryPages,
        uint256 prime
    ) private pure returns (uint256 res) {
        assembly {
            let lastPtr := add(cumulativeProdsPtr, mul(nPublicMemoryPages, 0x20))
            res := 1
            for {
                let ptr := cumulativeProdsPtr
            } lt(ptr, lastPtr) {
                ptr := add(ptr, 0x20)
            } {
                res := mulmod(res, mload(ptr), prime)
            }
        }
    }

    /*
      Verifies that all the information on each public memory page (size, hash, prod, and possibly
      address) is consistent with z and alpha, by checking that the corresponding facts were
      registered on memoryPageFactRegistry.
    */
    function verifyMemoryPageFacts(uint256[] memory ctx) private view {
        uint256 nPublicMemoryPages = ctx[MM_N_PUBLIC_MEM_PAGES];

        for (uint256 page = 0; page < nPublicMemoryPages; page++) {
            // Fetch page values from the public input (hash, product and size).
            uint256 memoryHashPtr = ctx[MM_PUBLIC_INPUT_PTR] + getOffsetPageHash(page) * 0x20;
            uint256 memoryHash;

            uint256 prodPtr = ctx[MM_PUBLIC_INPUT_PTR] +
                getOffsetPageProd(page, nPublicMemoryPages) *
                0x20;
            uint256 prod;

            uint256 pageSizePtr = ctx[MM_PUBLIC_INPUT_PTR] + getOffsetPageSize(page) * 0x20;
            uint256 pageSize;

            assembly {
                pageSize := mload(pageSizePtr)
                prod := mload(prodPtr)
                memoryHash := mload(memoryHashPtr)
            }

            uint256 pageAddr = 0;
            if (page > 0) {
                uint256 pageAddrPtr = ctx[MM_PUBLIC_INPUT_PTR] + getOffsetPageAddr(page) * 0x20;
                assembly {
                    pageAddr := mload(pageAddrPtr)
                }
            }

            // Verify that a corresponding fact is registered attesting to the consistency of the page
            // information with z and alpha.
            bytes32 factHash = keccak256(
                abi.encodePacked(
                    page == 0 ? REGULAR_PAGE : CONTINUOUS_PAGE,
                    K_MODULUS,
                    pageSize,
                    /*z=*/
                    ctx[MM_INTERACTION_ELEMENTS],
                    /*alpha=*/
                    ctx[MM_INTERACTION_ELEMENTS + 1],
                    prod,
                    memoryHash,
                    pageAddr
                )
            );

            require( // NOLINT: calls-loop.
                memoryPageFactRegistry.isValid(factHash),
                "Memory page fact was not registered."
            );
        }
    }

    /*
      Checks that the trace and the composition agree at oodsPoint, assuming the prover provided us
      with the proper evaluations.

      Later, we will use boundary constraints to check that those evaluations are actually
      consistent with the committed trace and composition polynomials.
    */
    function oodsConsistencyCheck(uint256[] memory ctx) internal view override {
        verifyMemoryPageFacts(ctx);
        ctx[MM_MEMORY__MULTI_COLUMN_PERM__PERM__INTERACTION_ELM] = ctx[MM_INTERACTION_ELEMENTS];
        ctx[MM_MEMORY__MULTI_COLUMN_PERM__HASH_INTERACTION_ELM0] = ctx[MM_INTERACTION_ELEMENTS + 1];
        ctx[MM_RC16__PERM__INTERACTION_ELM] = ctx[MM_INTERACTION_ELEMENTS + 2];
        {
            uint256 public_memory_prod = computePublicMemoryQuotient(ctx);
            ctx[MM_MEMORY__MULTI_COLUMN_PERM__PERM__PUBLIC_MEMORY_PROD] = public_memory_prod;
        }
        prepareForOodsCheck(ctx);

        uint256 compositionFromTraceValue;
        address lconstraintPoly = address(constraintPoly);
        uint256 offset = 0x20 * (1 + MM_CONSTRAINT_POLY_ARGS_START);
        uint256 size = 0x20 * (MM_CONSTRAINT_POLY_ARGS_END - MM_CONSTRAINT_POLY_ARGS_START);
        assembly {
            // Call CpuConstraintPoly contract.
            let p := mload(0x40)
            if iszero(staticcall(not(0), lconstraintPoly, add(ctx, offset), size, p, 0x20)) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
            compositionFromTraceValue := mload(p)
        }

        uint256 claimedComposition = fadd(
            ctx[MM_COMPOSITION_OODS_VALUES],
            fmul(ctx[MM_OODS_POINT], ctx[MM_COMPOSITION_OODS_VALUES + 1])
        );

        require(
            compositionFromTraceValue == claimedComposition,
            "claimedComposition does not match trace"
        );
    }
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "IQueryableFactRegistry.sol";

contract FactRegistry is IQueryableFactRegistry {
    // Mapping: fact hash -> true.
    mapping(bytes32 => bool) private verifiedFact;

    // Indicates whether the Fact Registry has at least one fact registered.
    bool anyFactRegistered = false;

    /*
      Checks if a fact has been verified.
    */
    function isValid(bytes32 fact) external view override returns (bool) {
        return _factCheck(fact);
    }

    /*
      This is an internal method to check if the fact is already registered.
      In current implementation of FactRegistry it's identical to isValid().
      But the check is against the local fact registry,
      So for a derived referral fact registry, it's not the same.
    */
    function _factCheck(bytes32 fact) internal view returns (bool) {
        return verifiedFact[fact];
    }

    function registerFact(bytes32 factHash) internal {
        // This function stores the fact hash in the mapping.
        verifiedFact[factHash] = true;

        // Mark first time off.
        if (!anyFactRegistered) {
            anyFactRegistered = true;
        }
    }

    /*
      Indicates whether at least one fact was registered.
    */
    function hasRegisteredFact() external view override returns (bool) {
        return anyFactRegistered;
    }
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "MemoryMap.sol";
import "MemoryAccessUtils.sol";
import "FriLayer.sol";
import "HornerEvaluator.sol";

/*
  This contract computes and verifies all the FRI layer, one by one. The final layer is verified
  by evaluating the fully committed polynomial, and requires specific handling.
*/
contract Fri is MemoryMap, MemoryAccessUtils, HornerEvaluator, FriLayer {
    function verifyLastLayer(uint256[] memory ctx, uint256 nPoints) private view {
        uint256 friLastLayerDegBound = ctx[MM_FRI_LAST_LAYER_DEG_BOUND];
        uint256 groupOrderMinusOne = friLastLayerDegBound * ctx[MM_BLOW_UP_FACTOR] - 1;
        uint256 coefsStart = ctx[MM_FRI_LAST_LAYER_PTR];

        for (uint256 i = 0; i < nPoints; i++) {
            uint256 point = ctx[MM_FRI_QUEUE + FRI_QUEUE_SLOT_SIZE * i + 2];
            // Invert point using inverse(point) == fpow(point, ord(point) - 1).

            point = fpow(point, groupOrderMinusOne);
            require(
                hornerEval(coefsStart, point, friLastLayerDegBound) ==
                    ctx[MM_FRI_QUEUE + FRI_QUEUE_SLOT_SIZE * i + 1],
                "Bad Last layer value."
            );
        }
    }

    /*
      Verifies FRI layers.

      See FriLayer for the descriptions of the FRI context and FRI queue.
    */
    function friVerifyLayers(uint256[] memory ctx) internal view virtual {
        uint256 friCtx = getPtr(ctx, MM_FRI_CTX);
        require(
            MAX_SUPPORTED_FRI_STEP_SIZE == FRI_MAX_STEP_SIZE,
            "MAX_STEP_SIZE is inconsistent in MemoryMap.sol and FriLayer.sol"
        );
        initFriGroups(friCtx);
        uint256 channelPtr = getChannelPtr(ctx);
        uint256 merkleQueuePtr = getMerkleQueuePtr(ctx);

        uint256 friStep = 1;
        uint256 nLiveQueries = ctx[MM_N_UNIQUE_QUERIES];

        // Add 0 at the end of the queries array to avoid empty array check in readNextElment.
        ctx[MM_FRI_QUERIES_DELIMITER] = 0;

        // Rather than converting all the values from Montgomery to standard form,
        // we can just pretend that the values are in standard form but all
        // the committed polynomials are multiplied by MontgomeryR.
        //
        // The values in the proof are already multiplied by MontgomeryR,
        // but the inputs from the OODS oracle need to be fixed.
        for (uint256 i = 0; i < nLiveQueries; i++) {
            ctx[MM_FRI_QUEUE + FRI_QUEUE_SLOT_SIZE * i + 1] = fmul(
                ctx[MM_FRI_QUEUE + FRI_QUEUE_SLOT_SIZE * i + 1],
                K_MONTGOMERY_R
            );
        }

        uint256 friQueue = getPtr(ctx, MM_FRI_QUEUE);

        uint256[] memory friStepSizes = getFriStepSizes(ctx);
        uint256 nFriSteps = friStepSizes.length;
        while (friStep < nFriSteps) {
            uint256 friCosetSize = 2**friStepSizes[friStep];

            nLiveQueries = computeNextLayer(
                channelPtr,
                friQueue,
                merkleQueuePtr,
                nLiveQueries,
                friCtx,
                ctx[MM_FRI_EVAL_POINTS + friStep],
                friCosetSize
            );

            // Layer is done, verify the current layer and move to next layer.
            // ctx[mmMerkleQueue: merkleQueueIdx) holds the indices
            // and values of the merkle leaves that need verification.
            verifyMerkle(
                channelPtr,
                merkleQueuePtr,
                bytes32(ctx[MM_FRI_COMMITMENTS + friStep - 1]),
                nLiveQueries
            );

            friStep++;
        }

        verifyLastLayer(ctx, nLiveQueries);
    }
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "MerkleVerifier.sol";
import "FriTransform.sol";

/*
  The main component of FRI is the FRI step which takes
  the i-th layer evaluations on a coset c*<g> and produces a single evaluation in layer i+1.

  To this end we have a friCtx that holds the following data:
  evaluations:    holds the evaluations on the coset we are currently working on.
  group:          holds the group <g> in bit reversed order.
  halfInvGroup:   holds the group <g^-1>/<-1> in bit reversed order.
                  (We only need half of the inverse group)

  Note that due to the bit reversed order, a prefix of size 2^k of either group
  or halfInvGroup has the same structure (but for a smaller group).
*/
contract FriLayer is MerkleVerifier, FriTransform {
    event LogGas(string name, uint256 val);

    uint256 internal constant MAX_COSET_SIZE = 2**FRI_MAX_STEP_SIZE;
    // Generator of the group of size MAX_COSET_SIZE: GENERATOR_VAL**((K_MODULUS - 1)/MAX_COSET_SIZE).
    uint256 internal constant FRI_GROUP_GEN =
        0x5ec467b88826aba4537602d514425f3b0bdf467bbf302458337c45f6021e539;

    uint256 internal constant FRI_GROUP_SIZE = 0x20 * MAX_COSET_SIZE;
    uint256 internal constant FRI_CTX_TO_COSET_EVALUATIONS_OFFSET = 0;
    uint256 internal constant FRI_CTX_TO_FRI_GROUP_OFFSET = FRI_GROUP_SIZE;
    uint256 internal constant FRI_CTX_TO_FRI_HALF_INV_GROUP_OFFSET =
        FRI_CTX_TO_FRI_GROUP_OFFSET + FRI_GROUP_SIZE;

    uint256 internal constant FRI_CTX_SIZE =
        FRI_CTX_TO_FRI_HALF_INV_GROUP_OFFSET + (FRI_GROUP_SIZE / 2);

    /*
      The FRI queue is an array of triplets (query index, FRI value, FRI inversed point).
         'query index' is an adjust query index,
            see adjustQueryIndicesAndPrepareEvalPoints for detail.
         'FRI value' is the expected committed value at query index.
         'FRI inversed point' is evaluation point corresponding to query index i.e.
            inverse(
               fpow(layerGenerator, bitReverse(query index - (1 << logLayerSize), logLayerSize)).
    */
    uint256 internal constant FRI_QUEUE_SLOT_SIZE = 3;
    // FRI_QUEUE_SLOT_SIZE_IN_BYTES cannot reference FRI_QUEUE_SLOT_SIZE as only direct constants
    // are supported in assembly.
    uint256 internal constant FRI_QUEUE_SLOT_SIZE_IN_BYTES = 3 * 0x20;

    /*
      Gathers the "cosetSize" elements that belong the coset of the first element in the FRI queue.
      The elements are written to 'evaluationsOnCosetPtr'.

      The coset elements are read either from the FriQueue or from the verifier channel
      depending on whether the required element are in queue or not.

      Returns
        newFriQueueHead - The update FRI queue head i.e.
          friQueueHead + FRI_QUEUE_SLOT_SIZE_IN_BYTES * (# elements that were taken from the queue).
        cosetIdx - the start index of the coset that was gathered.
        cosetOffset - the xInv field element that corresponds to cosetIdx.
    */
    function gatherCosetInputs(
        uint256 channelPtr,
        uint256 friGroupPtr,
        uint256 evaluationsOnCosetPtr,
        uint256 friQueueHead,
        uint256 cosetSize
    )
        internal
        pure
        returns (
            uint256 newFriQueueHead,
            uint256 cosetIdx,
            uint256 cosetOffset
        )
    {
        assembly {
            let queueItemIdx := mload(friQueueHead)
            // The coset index is represented by the most significant bits of the queue item index.
            cosetIdx := and(queueItemIdx, not(sub(cosetSize, 1)))
            let nextCosetIdx := add(cosetIdx, cosetSize)

            // Get the algebraic coset offset:
            // I.e. given c*g^(-k) compute c, where
            //      g is the generator of the coset group.
            //      k is bitReverse(offsetWithinCoset, log2(cosetSize)).
            //
            // To do this we multiply the algebraic coset offset at the top of the queue (c*g^(-k))
            // by the group element that corresponds to the index inside the coset (g^k).
            cosetOffset := mulmod(
                // (c*g^(-k))=
                mload(add(friQueueHead, 0x40)),
                // (g^k)=
                mload(
                    add(
                        friGroupPtr,
                        mul(
                            // offsetWithinCoset=
                            sub(queueItemIdx, cosetIdx),
                            0x20
                        )
                    )
                ),
                K_MODULUS
            )

            let proofPtr := mload(channelPtr)

            for {
                let index := cosetIdx
            } lt(index, nextCosetIdx) {
                index := add(index, 1)
            } {
                // Inline channel operation:
                // Assume we are going to read the next element from the proof.
                // If this is not the case add(proofPtr, 0x20) will be reverted.
                let fieldElementPtr := proofPtr
                proofPtr := add(proofPtr, 0x20)

                // Load the next index from the queue and check if it is our sibling.
                if eq(index, queueItemIdx) {
                    // Take element from the queue rather than from the proof
                    // and convert it back to Montgomery form for Merkle verification.
                    fieldElementPtr := add(friQueueHead, 0x20)

                    // Revert the read from proof.
                    proofPtr := sub(proofPtr, 0x20)

                    // Reading the next index here is safe due to the
                    // delimiter after the queries.
                    friQueueHead := add(friQueueHead, FRI_QUEUE_SLOT_SIZE_IN_BYTES)
                    queueItemIdx := mload(friQueueHead)
                }

                // Note that we apply the modulo operation to convert the field elements we read
                // from the proof to canonical representation (in the range [0, K_MODULUS - 1]).
                mstore(evaluationsOnCosetPtr, mod(mload(fieldElementPtr), K_MODULUS))
                evaluationsOnCosetPtr := add(evaluationsOnCosetPtr, 0x20)
            }

            mstore(channelPtr, proofPtr)
        }
        newFriQueueHead = friQueueHead;
    }

    /*
      Returns the bit reversal of num assuming it has the given number of bits.
      For example, if we have numberOfBits = 6 and num = (0b)1101 == (0b)001101,
      the function will return (0b)101100.
    */
    function bitReverse(uint256 num, uint256 numberOfBits)
        internal
        pure
        returns (uint256 numReversed)
    {
        assert((numberOfBits == 256) || (num < 2**numberOfBits));
        uint256 n = num;
        uint256 r = 0;
        for (uint256 k = 0; k < numberOfBits; k++) {
            r = (r * 2) | (n % 2);
            n = n / 2;
        }
        return r;
    }

    /*
      Initializes the FRI group and half inv group in the FRI context.
    */
    function initFriGroups(uint256 friCtx) internal view {
        uint256 friGroupPtr = friCtx + FRI_CTX_TO_FRI_GROUP_OFFSET;
        uint256 friHalfInvGroupPtr = friCtx + FRI_CTX_TO_FRI_HALF_INV_GROUP_OFFSET;

        // FRI_GROUP_GEN is the coset generator.
        // Raising it to the (MAX_COSET_SIZE - 1) power gives us the inverse.
        uint256 genFriGroup = FRI_GROUP_GEN;

        uint256 genFriGroupInv = fpow(genFriGroup, (MAX_COSET_SIZE - 1));

        uint256 lastVal = ONE_VAL;
        uint256 lastValInv = ONE_VAL;
        assembly {
            // ctx[mmHalfFriInvGroup + 0] = ONE_VAL;
            mstore(friHalfInvGroupPtr, lastValInv)
            // ctx[mmFriGroup + 0] = ONE_VAL;
            mstore(friGroupPtr, lastVal)
            // ctx[mmFriGroup + 1] = fsub(0, ONE_VAL);
            mstore(add(friGroupPtr, 0x20), sub(K_MODULUS, lastVal))
        }

        // To compute [1, -1 (== g^n/2), g^n/4, -g^n/4, ...]
        // we compute half the elements and derive the rest using negation.
        uint256 halfCosetSize = MAX_COSET_SIZE / 2;
        for (uint256 i = 1; i < halfCosetSize; i++) {
            lastVal = fmul(lastVal, genFriGroup);
            lastValInv = fmul(lastValInv, genFriGroupInv);
            uint256 idx = bitReverse(i, FRI_MAX_STEP_SIZE - 1);

            assembly {
                // ctx[mmHalfFriInvGroup + idx] = lastValInv;
                mstore(add(friHalfInvGroupPtr, mul(idx, 0x20)), lastValInv)
                // ctx[mmFriGroup + 2*idx] = lastVal;
                mstore(add(friGroupPtr, mul(idx, 0x40)), lastVal)
                // ctx[mmFriGroup + 2*idx + 1] = fsub(0, lastVal);
                mstore(add(friGroupPtr, add(mul(idx, 0x40), 0x20)), sub(K_MODULUS, lastVal))
            }
        }
    }

    /*
      Computes the FRI step with eta = log2(friCosetSize) for all the live queries.

      The inputs for the current layer are read from the FRI queue and the inputs
      for the next layer are written to the same queue (overwriting the input).
      See friVerifyLayers for the description for the FRI queue.

      The function returns the number of live queries remaining after computing the FRI step.

      The number of live queries decreases whenever multiple query points in the same
      coset are reduced to a single query in the next FRI layer.

      As the function computes the next layer it also collects that data from
      the previous layer for Merkle verification.
    */
    function computeNextLayer(
        uint256 channelPtr,
        uint256 friQueuePtr,
        uint256 merkleQueuePtr,
        uint256 nQueries,
        uint256 friCtx,
        uint256 friEvalPoint,
        uint256 friCosetSize
    ) internal pure returns (uint256 nLiveQueries) {
        uint256 evaluationsOnCosetPtr = friCtx + FRI_CTX_TO_COSET_EVALUATIONS_OFFSET;

        // The inputs are read from the Fri queue and the result is written same queue.
        // The inputs are never overwritten since gatherCosetInputs reads at least one element and
        // transformCoset writes exactly one element.
        uint256 inputPtr = friQueuePtr;
        uint256 inputEnd = inputPtr + (FRI_QUEUE_SLOT_SIZE_IN_BYTES * nQueries);
        uint256 ouputPtr = friQueuePtr;

        do {
            uint256 cosetOffset;
            uint256 index;
            (inputPtr, index, cosetOffset) = gatherCosetInputs(
                channelPtr,
                friCtx + FRI_CTX_TO_FRI_GROUP_OFFSET,
                evaluationsOnCosetPtr,
                inputPtr,
                friCosetSize
            );

            // Compute the index of the coset evaluations in the Merkle queue.
            index /= friCosetSize;

            // Add (index, keccak256(evaluationsOnCoset)) to the Merkle queue.
            assembly {
                mstore(merkleQueuePtr, index)
                mstore(
                    add(merkleQueuePtr, 0x20),
                    and(COMMITMENT_MASK, keccak256(evaluationsOnCosetPtr, mul(0x20, friCosetSize)))
                )
            }
            merkleQueuePtr += MERKLE_SLOT_SIZE_IN_BYTES;

            (uint256 friValue, uint256 FriInversedPoint) = transformCoset(
                friCtx + FRI_CTX_TO_FRI_HALF_INV_GROUP_OFFSET,
                evaluationsOnCosetPtr,
                cosetOffset,
                friEvalPoint,
                friCosetSize
            );

            // Add (index, friValue, FriInversedPoint) to the FRI queue.
            // Note that the index in the Merkle queue is also the index in the next FRI layer.
            assembly {
                mstore(ouputPtr, index)
                mstore(add(ouputPtr, 0x20), friValue)
                mstore(add(ouputPtr, 0x40), FriInversedPoint)
            }
            ouputPtr += FRI_QUEUE_SLOT_SIZE_IN_BYTES;
        } while (inputPtr < inputEnd);

        // Return the current number of live queries.
        return (ouputPtr - friQueuePtr) / FRI_QUEUE_SLOT_SIZE_IN_BYTES;
    }
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "FactRegistry.sol";
import "FriLayer.sol";

contract FriStatementContract is FriLayer, FactRegistry {
    /*
      Compute a single FRI layer of size friStepSize at evaluationPoint starting from input
      friQueue, and the extra witnesses in the "proof" channel. Also check that the input and
      witnesses belong to a Merkle tree with root expectedRoot, again using witnesses from "proof".
      After verification, register the FRI fact hash, which is:
      keccak256(
          evaluationPoint,
          friStepSize,
          keccak256(friQueue_input),
          keccak256(friQueue_output),  // The FRI queue after proccessing the FRI layer
          expectedRoot
      )

      Note that this function is used as external, but declared public to avoid copying the arrays.
    */
    function verifyFRI(
        uint256[] memory proof,
        uint256[] memory friQueue,
        uint256 evaluationPoint,
        uint256 friStepSize,
        uint256 expectedRoot
    ) public {
        require(friStepSize <= FRI_MAX_STEP_SIZE, "FRI step size too large");

        // Verify evaluation point within valid range.
        require(evaluationPoint < K_MODULUS, "INVALID_EVAL_POINT");

        // Validate the FRI queue.
        validateFriQueue(friQueue);

        uint256 mmFriCtxSize = FRI_CTX_SIZE;
        uint256 nQueries = friQueue.length / 3; // NOLINT: divide-before-multiply.
        uint256 merkleQueuePtr;
        uint256 friQueuePtr;
        uint256 channelPtr;
        uint256 friCtx;
        uint256 dataToHash;

        // Allocate memory queues: channelPtr, merkleQueue, friCtx, dataToHash.
        assembly {
            friQueuePtr := add(friQueue, 0x20)
            channelPtr := mload(0x40) // Free pointer location.
            mstore(channelPtr, add(proof, 0x20))
            merkleQueuePtr := add(channelPtr, 0x20)
            friCtx := add(merkleQueuePtr, mul(0x40, nQueries))
            dataToHash := add(friCtx, mmFriCtxSize)
            mstore(0x40, add(dataToHash, 0xa0)) // Advance free pointer.

            mstore(dataToHash, evaluationPoint)
            mstore(add(dataToHash, 0x20), friStepSize)
            mstore(add(dataToHash, 0x80), expectedRoot)

            // Hash FRI inputs and add to dataToHash.
            mstore(add(dataToHash, 0x40), keccak256(friQueuePtr, mul(0x60, nQueries)))
        }

        initFriGroups(friCtx);

        nQueries = computeNextLayer(
            channelPtr,
            friQueuePtr,
            merkleQueuePtr,
            nQueries,
            friCtx,
            evaluationPoint,
            2**friStepSize /* friCosetSize = 2**friStepSize */
        );

        verifyMerkle(channelPtr, merkleQueuePtr, bytes32(expectedRoot), nQueries);

        bytes32 factHash;
        assembly {
            // Hash FRI outputs and add to dataToHash.
            mstore(add(dataToHash, 0x60), keccak256(friQueuePtr, mul(0x60, nQueries)))
            factHash := keccak256(dataToHash, 0xa0)
        }

        registerFact(factHash);
    }

    /*
      Validates the entries of the FRI queue.

      The friQueue should have of 3*nQueries + 1 elements, beginning with nQueries triplets
      of the form (query_index, FRI_value, FRI_inverse_point), and ending with a single buffer
      cell set to 0, which is accessed and read during the computation of the FRI layer.  

      Queries need to be in the range [2**height .. 2**(height+1)-1] and strictly incrementing.
      The FRI values and inverses need to be smaller than K_MODULUS.
    */
    function validateFriQueue(uint256[] memory friQueue) private pure {
        require(
            friQueue.length % 3 == 1,
            "FRI Queue must be composed of triplets plus one delimiter cell"
        );
        require(friQueue.length >= 4, "No query to process");

        // Force delimiter cell to 0, this is cheaper then asserting it.
        friQueue[friQueue.length - 1] = 0;

        // We need to check that Qi+1 > Qi for each i,
        // Given that the queries are sorted the height range requirement can be validated by
        // checking that (Q1 ^ Qn) < Q1.
        // This check affirms that all queries are within the same logarithmic step.
        uint256 nQueries = friQueue.length / 3; // NOLINT: divide-before-multiply.
        uint256 prevQuery = 0;
        for (uint256 i = 0; i < nQueries; i++) {
            // Verify that queries are strictly incrementing.
            require(friQueue[3 * i] > prevQuery, "INVALID_QUERY_VALUE");
            // Verify FRI value and inverse are within valid range.
            require(friQueue[3 * i + 1] < K_MODULUS, "INVALID_FRI_VALUE");
            require(friQueue[3 * i + 2] < K_MODULUS, "INVALID_FRI_INVERSE_POINT");
            prevQuery = friQueue[3 * i];
        }

        // Verify all queries are on the same logarithmic step.
        // NOLINTNEXTLINE: divide-before-multiply.
        require((friQueue[0] ^ friQueue[3 * nQueries - 3]) < friQueue[0], "INVALID_QUERIES_RANGE");
    }
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "MemoryMap.sol";
import "MemoryAccessUtils.sol";
import "FriStatementContract.sol";
import "HornerEvaluator.sol";
import "VerifierChannel.sol";

/*
  This contract verifies all the FRI layer, one by one, using the FriStatementContract.
  The first layer is computed from decommitments, the last layer is computed by evaluating the
  fully committed polynomial, and the mid-layers are provided in the proof only as hashed data.
*/
abstract contract FriStatementVerifier is
    MemoryMap,
    MemoryAccessUtils,
    VerifierChannel,
    HornerEvaluator
{
    FriStatementContract friStatementContract;

    constructor(address friStatementContractAddress) internal {
        friStatementContract = FriStatementContract(friStatementContractAddress);
    }

    /*
      Fast-forwards the queries and invPoints of the friQueue from before the first layer to after
      the last layer, computes the last FRI layer using horner evaluations, then returns the hash
      of the final FriQueue.
    */
    function computeLastLayerHash(
        uint256[] memory ctx,
        uint256 nPoints,
        uint256 sumOfStepSizes
    ) private view returns (bytes32 lastLayerHash) {
        uint256 friLastLayerDegBound = ctx[MM_FRI_LAST_LAYER_DEG_BOUND];
        uint256 groupOrderMinusOne = friLastLayerDegBound * ctx[MM_BLOW_UP_FACTOR] - 1;
        uint256 exponent = 1 << sumOfStepSizes;
        uint256 curPointIndex = 0;
        uint256 prevQuery = 0;
        uint256 coefsStart = ctx[MM_FRI_LAST_LAYER_PTR];

        for (uint256 i = 0; i < nPoints; i++) {
            uint256 query = ctx[MM_FRI_QUEUE + 3 * i] >> sumOfStepSizes;
            if (query == prevQuery) {
                continue;
            }
            ctx[MM_FRI_QUEUE + 3 * curPointIndex] = query;
            prevQuery = query;

            uint256 point = fpow(ctx[MM_FRI_QUEUE + 3 * i + 2], exponent);
            ctx[MM_FRI_QUEUE + 3 * curPointIndex + 2] = point;
            // Invert point using inverse(point) == fpow(point, ord(point) - 1).

            point = fpow(point, groupOrderMinusOne);
            ctx[MM_FRI_QUEUE + 3 * curPointIndex + 1] = hornerEval(
                coefsStart,
                point,
                friLastLayerDegBound
            );

            curPointIndex++;
        }

        uint256 friQueue = getPtr(ctx, MM_FRI_QUEUE);
        assembly {
            lastLayerHash := keccak256(friQueue, mul(curPointIndex, 0x60))
        }
    }

    /*
      Verifies that FRI layers consistent with the computed first and last FRI layers
      have been registered in the FriStatementContract.
    */
    function friVerifyLayers(uint256[] memory ctx) internal view virtual {
        uint256 channelPtr = getChannelPtr(ctx);
        uint256 nQueries = ctx[MM_N_UNIQUE_QUERIES];

        // Rather than converting all the values from Montgomery to standard form,
        // we can just pretend that the values are in standard form but all
        // the committed polynomials are multiplied by MontgomeryR.
        //
        // The values in the proof are already multiplied by MontgomeryR,
        // but the inputs from the OODS oracle need to be fixed.
        for (uint256 i = 0; i < nQueries; i++) {
            ctx[MM_FRI_QUEUE + 3 * i + 1] = fmul(ctx[MM_FRI_QUEUE + 3 * i + 1], K_MONTGOMERY_R);
        }

        uint256 friQueue = getPtr(ctx, MM_FRI_QUEUE);
        uint256 inputLayerHash;
        assembly {
            inputLayerHash := keccak256(friQueue, mul(nQueries, 0x60))
        }

        uint256[] memory friStepSizes = getFriStepSizes(ctx);
        uint256 nFriInnerLayers = friStepSizes.length - 1;
        uint256 friStep = 1;
        uint256 sumOfStepSizes = friStepSizes[1];
        uint256[5] memory dataToHash;
        while (friStep < nFriInnerLayers) {
            uint256 outputLayerHash = uint256(readBytes(channelPtr, true));
            dataToHash[0] = ctx[MM_FRI_EVAL_POINTS + friStep];
            dataToHash[1] = friStepSizes[friStep];
            dataToHash[2] = inputLayerHash;
            dataToHash[3] = outputLayerHash;
            dataToHash[4] = ctx[MM_FRI_COMMITMENTS + friStep - 1];

            // Verify statement is registered.
            require( // NOLINT: calls-loop.
                friStatementContract.isValid(keccak256(abi.encodePacked(dataToHash))),
                "INVALIDATED_FRI_STATEMENT"
            );

            inputLayerHash = outputLayerHash;

            friStep++;
            sumOfStepSizes += friStepSizes[friStep];
        }

        dataToHash[0] = ctx[MM_FRI_EVAL_POINTS + friStep];
        dataToHash[1] = friStepSizes[friStep];
        dataToHash[2] = inputLayerHash;
        dataToHash[3] = uint256(computeLastLayerHash(ctx, nQueries, sumOfStepSizes));
        dataToHash[4] = ctx[MM_FRI_COMMITMENTS + friStep - 1];

        require(
            friStatementContract.isValid(keccak256(abi.encodePacked(dataToHash))),
            "INVALIDATED_FRI_STATEMENT"
        );
    }
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "PrimeFieldElement0.sol";

/*
  The FRI transform for a coset of size 2 (x, -x) takes the inputs
  x, f(x), f(-x) and evalPoint
  and returns
  (f(x) + f(-x) + evalPoint*(f(x) - f(-x))/x) / 2.

  The implementation here modifies this transformation slightly:
  1. Since dividing by 2 does not affect the degree, it is omitted here (and in the prover).
  2. The division by x is replaced by multiplication by x^-1, x^-1 is passed as input to the
     transform and (x^-1)^2 is returned as it will be needed in the next layer.

  To apply the transformation on a larger coset the transformation above is used multiple times
  with the evaluation points: evalPoint, evalPoint^2, evalPoint^4, ...
*/
contract FriTransform is PrimeFieldElement0 {
    // The supported step sizes are 2, 3 and 4.
    uint256 internal constant FRI_MIN_STEP_SIZE = 2;
    uint256 internal constant FRI_MAX_STEP_SIZE = 4;

    // The largest power of 2 multiple of K_MODULUS that fits in a uint256.
    // The value is given as a constant because "Only direct number constants and references to such
    // constants are supported by inline assembly."
    // This constant is used in places where we delay the module operation to reduce gas usage.
    uint256 internal constant K_MODULUS_TIMES_16 = (
        0x8000000000000110000000000000000000000000000000000000000000000010
    );

    /*
      Performs a FRI transform for the coset of size friFoldedCosetSize that begins at index.

      Assumes the evaluations on the coset are stored at 'evaluationsOnCosetPtr'.
      See gatherCosetInputs for more detail.
    */
    function transformCoset(
        uint256 friHalfInvGroupPtr,
        uint256 evaluationsOnCosetPtr,
        uint256 cosetOffset,
        uint256 friEvalPoint,
        uint256 friCosetSize
    ) internal pure returns (uint256 nextLayerValue, uint256 nextXInv) {
        // Compare to expected FRI step sizes in order of likelihood, step size 3 being most common.
        if (friCosetSize == 8) {
            return
                transformCosetOfSize8(
                    friHalfInvGroupPtr,
                    evaluationsOnCosetPtr,
                    cosetOffset,
                    friEvalPoint
                );
        } else if (friCosetSize == 4) {
            return
                transformCosetOfSize4(
                    friHalfInvGroupPtr,
                    evaluationsOnCosetPtr,
                    cosetOffset,
                    friEvalPoint
                );
        } else if (friCosetSize == 16) {
            return
                transformCosetOfSize16(
                    friHalfInvGroupPtr,
                    evaluationsOnCosetPtr,
                    cosetOffset,
                    friEvalPoint
                );
        } else {
            require(false, "Only step sizes of 2, 3 or 4 are supported.");
        }
    }

    /*
      Applies 2 + 1 FRI transformations to a coset of size 2^2.

      evaluations on coset:                    f0 f1  f2 f3
      ----------------------------------------  \ / -- \ / -----------
                                                 f0    f2
      ------------------------------------------- \ -- / -------------
      nextLayerValue:                               f0

      For more detail, see description of the FRI transformations at the top of this file.
    */
    function transformCosetOfSize4(
        uint256 friHalfInvGroupPtr,
        uint256 evaluationsOnCosetPtr,
        uint256 cosetOffset_,
        uint256 friEvalPoint
    ) private pure returns (uint256 nextLayerValue, uint256 nextXInv) {
        assembly {
            let friEvalPointDivByX := mulmod(friEvalPoint, cosetOffset_, K_MODULUS)

            let f0 := mload(evaluationsOnCosetPtr)
            {
                let f1 := mload(add(evaluationsOnCosetPtr, 0x20))

                // f0 < 3P ( = 1 + 1 + 1).
                f0 := add(
                    add(f0, f1),
                    mulmod(
                        friEvalPointDivByX,
                        add(
                            f0,
                            // -fMinusX
                            sub(K_MODULUS, f1)
                        ),
                        K_MODULUS
                    )
                )
            }

            let f2 := mload(add(evaluationsOnCosetPtr, 0x40))
            {
                let f3 := mload(add(evaluationsOnCosetPtr, 0x60))
                f2 := addmod(
                    add(f2, f3),
                    mulmod(
                        add(
                            f2,
                            // -fMinusX
                            sub(K_MODULUS, f3)
                        ),
                        mulmod(mload(add(friHalfInvGroupPtr, 0x20)), friEvalPointDivByX, K_MODULUS),
                        K_MODULUS
                    ),
                    K_MODULUS
                )
            }

            {
                let newXInv := mulmod(cosetOffset_, cosetOffset_, K_MODULUS)
                nextXInv := mulmod(newXInv, newXInv, K_MODULUS)
            }

            // f0 + f2 < 4P ( = 3 + 1).
            nextLayerValue := addmod(
                add(f0, f2),
                mulmod(
                    mulmod(friEvalPointDivByX, friEvalPointDivByX, K_MODULUS),
                    add(
                        f0,
                        // -fMinusX
                        sub(K_MODULUS, f2)
                    ),
                    K_MODULUS
                ),
                K_MODULUS
            )
        }
    }

    /*
      Applies 4 + 2 + 1 FRI transformations to a coset of size 2^3.

      For more detail, see description of the FRI transformations at the top of this file.
    */
    function transformCosetOfSize8(
        uint256 friHalfInvGroupPtr,
        uint256 evaluationsOnCosetPtr,
        uint256 cosetOffset_,
        uint256 friEvalPoint
    ) private pure returns (uint256 nextLayerValue, uint256 nextXInv) {
        assembly {
            let f0 := mload(evaluationsOnCosetPtr)

            let friEvalPointDivByX := mulmod(friEvalPoint, cosetOffset_, K_MODULUS)
            let friEvalPointDivByXSquared := mulmod(
                friEvalPointDivByX,
                friEvalPointDivByX,
                K_MODULUS
            )
            let imaginaryUnit := mload(add(friHalfInvGroupPtr, 0x20))

            {
                let f1 := mload(add(evaluationsOnCosetPtr, 0x20))

                // f0 < 3P ( = 1 + 1 + 1).
                f0 := add(
                    add(f0, f1),
                    mulmod(
                        friEvalPointDivByX,
                        add(
                            f0,
                            // -fMinusX
                            sub(K_MODULUS, f1)
                        ),
                        K_MODULUS
                    )
                )
            }
            {
                let f2 := mload(add(evaluationsOnCosetPtr, 0x40))
                {
                    let f3 := mload(add(evaluationsOnCosetPtr, 0x60))

                    // f2 < 3P ( = 1 + 1 + 1).
                    f2 := add(
                        add(f2, f3),
                        mulmod(
                            add(
                                f2,
                                // -fMinusX
                                sub(K_MODULUS, f3)
                            ),
                            mulmod(friEvalPointDivByX, imaginaryUnit, K_MODULUS),
                            K_MODULUS
                        )
                    )
                }

                // f0 < 7P ( = 3 + 3 + 1).
                f0 := add(
                    add(f0, f2),
                    mulmod(
                        friEvalPointDivByXSquared,
                        add(
                            f0,
                            // -fMinusX
                            sub(K_MODULUS_TIMES_16, f2)
                        ),
                        K_MODULUS
                    )
                )
            }
            {
                let f4 := mload(add(evaluationsOnCosetPtr, 0x80))
                {
                    let friEvalPointDivByX2 := mulmod(
                        friEvalPointDivByX,
                        mload(add(friHalfInvGroupPtr, 0x40)),
                        K_MODULUS
                    )
                    {
                        let f5 := mload(add(evaluationsOnCosetPtr, 0xa0))

                        // f4 < 3P ( = 1 + 1 + 1).
                        f4 := add(
                            add(f4, f5),
                            mulmod(
                                friEvalPointDivByX2,
                                add(
                                    f4,
                                    // -fMinusX
                                    sub(K_MODULUS, f5)
                                ),
                                K_MODULUS
                            )
                        )
                    }

                    let f6 := mload(add(evaluationsOnCosetPtr, 0xc0))
                    {
                        let f7 := mload(add(evaluationsOnCosetPtr, 0xe0))

                        // f6 < 3P ( = 1 + 1 + 1).
                        f6 := add(
                            add(f6, f7),
                            mulmod(
                                add(
                                    f6,
                                    // -fMinusX
                                    sub(K_MODULUS, f7)
                                ),
                                // friEvalPointDivByX2 * imaginaryUnit ==
                                // friEvalPointDivByX * mload(add(friHalfInvGroupPtr, 0x60)).
                                mulmod(friEvalPointDivByX2, imaginaryUnit, K_MODULUS),
                                K_MODULUS
                            )
                        )
                    }

                    // f4 < 7P ( = 3 + 3 + 1).
                    f4 := add(
                        add(f4, f6),
                        mulmod(
                            mulmod(friEvalPointDivByX2, friEvalPointDivByX2, K_MODULUS),
                            add(
                                f4,
                                // -fMinusX
                                sub(K_MODULUS_TIMES_16, f6)
                            ),
                            K_MODULUS
                        )
                    )
                }

                // f0, f4 < 7P -> f0 + f4 < 14P && 9P < f0 + (K_MODULUS_TIMES_16 - f4) < 23P.
                nextLayerValue := addmod(
                    add(f0, f4),
                    mulmod(
                        mulmod(friEvalPointDivByXSquared, friEvalPointDivByXSquared, K_MODULUS),
                        add(
                            f0,
                            // -fMinusX
                            sub(K_MODULUS_TIMES_16, f4)
                        ),
                        K_MODULUS
                    ),
                    K_MODULUS
                )
            }

            {
                let xInv2 := mulmod(cosetOffset_, cosetOffset_, K_MODULUS)
                let xInv4 := mulmod(xInv2, xInv2, K_MODULUS)
                nextXInv := mulmod(xInv4, xInv4, K_MODULUS)
            }
        }
    }

    /*
      Applies 8 + 4 + 2 + 1 FRI transformations to a coset of size 2^4.
      to obtain a single element.

      For more detail, see description of the FRI transformations at the top of this file.
    */
    function transformCosetOfSize16(
        uint256 friHalfInvGroupPtr,
        uint256 evaluationsOnCosetPtr,
        uint256 cosetOffset_,
        uint256 friEvalPoint
    ) private pure returns (uint256 nextLayerValue, uint256 nextXInv) {
        assembly {
            let friEvalPointDivByXTessed
            let f0 := mload(evaluationsOnCosetPtr)

            let friEvalPointDivByX := mulmod(friEvalPoint, cosetOffset_, K_MODULUS)
            let imaginaryUnit := mload(add(friHalfInvGroupPtr, 0x20))

            {
                let f1 := mload(add(evaluationsOnCosetPtr, 0x20))

                // f0 < 3P ( = 1 + 1 + 1).
                f0 := add(
                    add(f0, f1),
                    mulmod(
                        friEvalPointDivByX,
                        add(
                            f0,
                            // -fMinusX
                            sub(K_MODULUS, f1)
                        ),
                        K_MODULUS
                    )
                )
            }
            {
                let f2 := mload(add(evaluationsOnCosetPtr, 0x40))
                {
                    let f3 := mload(add(evaluationsOnCosetPtr, 0x60))

                    // f2 < 3P ( = 1 + 1 + 1).
                    f2 := add(
                        add(f2, f3),
                        mulmod(
                            add(
                                f2,
                                // -fMinusX
                                sub(K_MODULUS, f3)
                            ),
                            mulmod(friEvalPointDivByX, imaginaryUnit, K_MODULUS),
                            K_MODULUS
                        )
                    )
                }
                {
                    let friEvalPointDivByXSquared := mulmod(
                        friEvalPointDivByX,
                        friEvalPointDivByX,
                        K_MODULUS
                    )
                    friEvalPointDivByXTessed := mulmod(
                        friEvalPointDivByXSquared,
                        friEvalPointDivByXSquared,
                        K_MODULUS
                    )

                    // f0 < 7P ( = 3 + 3 + 1).
                    f0 := add(
                        add(f0, f2),
                        mulmod(
                            friEvalPointDivByXSquared,
                            add(
                                f0,
                                // -fMinusX
                                sub(K_MODULUS_TIMES_16, f2)
                            ),
                            K_MODULUS
                        )
                    )
                }
            }
            {
                let f4 := mload(add(evaluationsOnCosetPtr, 0x80))
                {
                    let friEvalPointDivByX2 := mulmod(
                        friEvalPointDivByX,
                        mload(add(friHalfInvGroupPtr, 0x40)),
                        K_MODULUS
                    )
                    {
                        let f5 := mload(add(evaluationsOnCosetPtr, 0xa0))

                        // f4 < 3P ( = 1 + 1 + 1).
                        f4 := add(
                            add(f4, f5),
                            mulmod(
                                friEvalPointDivByX2,
                                add(
                                    f4,
                                    // -fMinusX
                                    sub(K_MODULUS, f5)
                                ),
                                K_MODULUS
                            )
                        )
                    }

                    let f6 := mload(add(evaluationsOnCosetPtr, 0xc0))
                    {
                        let f7 := mload(add(evaluationsOnCosetPtr, 0xe0))

                        // f6 < 3P ( = 1 + 1 + 1).
                        f6 := add(
                            add(f6, f7),
                            mulmod(
                                add(
                                    f6,
                                    // -fMinusX
                                    sub(K_MODULUS, f7)
                                ),
                                // friEvalPointDivByX2 * imaginaryUnit ==
                                // friEvalPointDivByX * mload(add(friHalfInvGroupPtr, 0x60)).
                                mulmod(friEvalPointDivByX2, imaginaryUnit, K_MODULUS),
                                K_MODULUS
                            )
                        )
                    }

                    // f4 < 7P ( = 3 + 3 + 1).
                    f4 := add(
                        add(f4, f6),
                        mulmod(
                            mulmod(friEvalPointDivByX2, friEvalPointDivByX2, K_MODULUS),
                            add(
                                f4,
                                // -fMinusX
                                sub(K_MODULUS_TIMES_16, f6)
                            ),
                            K_MODULUS
                        )
                    )
                }

                // f0 < 15P ( = 7 + 7 + 1).
                f0 := add(
                    add(f0, f4),
                    mulmod(
                        friEvalPointDivByXTessed,
                        add(
                            f0,
                            // -fMinusX
                            sub(K_MODULUS_TIMES_16, f4)
                        ),
                        K_MODULUS
                    )
                )
            }
            {
                let f8 := mload(add(evaluationsOnCosetPtr, 0x100))
                {
                    let friEvalPointDivByX4 := mulmod(
                        friEvalPointDivByX,
                        mload(add(friHalfInvGroupPtr, 0x80)),
                        K_MODULUS
                    )
                    {
                        let f9 := mload(add(evaluationsOnCosetPtr, 0x120))

                        // f8 < 3P ( = 1 + 1 + 1).
                        f8 := add(
                            add(f8, f9),
                            mulmod(
                                friEvalPointDivByX4,
                                add(
                                    f8,
                                    // -fMinusX
                                    sub(K_MODULUS, f9)
                                ),
                                K_MODULUS
                            )
                        )
                    }

                    let f10 := mload(add(evaluationsOnCosetPtr, 0x140))
                    {
                        let f11 := mload(add(evaluationsOnCosetPtr, 0x160))
                        // f10 < 3P ( = 1 + 1 + 1).
                        f10 := add(
                            add(f10, f11),
                            mulmod(
                                add(
                                    f10,
                                    // -fMinusX
                                    sub(K_MODULUS, f11)
                                ),
                                // friEvalPointDivByX4 * imaginaryUnit ==
                                // friEvalPointDivByX * mload(add(friHalfInvGroupPtr, 0xa0)).
                                mulmod(friEvalPointDivByX4, imaginaryUnit, K_MODULUS),
                                K_MODULUS
                            )
                        )
                    }

                    // f8 < 7P ( = 3 + 3 + 1).
                    f8 := add(
                        add(f8, f10),
                        mulmod(
                            mulmod(friEvalPointDivByX4, friEvalPointDivByX4, K_MODULUS),
                            add(
                                f8,
                                // -fMinusX
                                sub(K_MODULUS_TIMES_16, f10)
                            ),
                            K_MODULUS
                        )
                    )
                }
                {
                    let f12 := mload(add(evaluationsOnCosetPtr, 0x180))
                    {
                        let friEvalPointDivByX6 := mulmod(
                            friEvalPointDivByX,
                            mload(add(friHalfInvGroupPtr, 0xc0)),
                            K_MODULUS
                        )
                        {
                            let f13 := mload(add(evaluationsOnCosetPtr, 0x1a0))

                            // f12 < 3P ( = 1 + 1 + 1).
                            f12 := add(
                                add(f12, f13),
                                mulmod(
                                    friEvalPointDivByX6,
                                    add(
                                        f12,
                                        // -fMinusX
                                        sub(K_MODULUS, f13)
                                    ),
                                    K_MODULUS
                                )
                            )
                        }

                        let f14 := mload(add(evaluationsOnCosetPtr, 0x1c0))
                        {
                            let f15 := mload(add(evaluationsOnCosetPtr, 0x1e0))

                            // f14 < 3P ( = 1 + 1 + 1).
                            f14 := add(
                                add(f14, f15),
                                mulmod(
                                    add(
                                        f14,
                                        // -fMinusX
                                        sub(K_MODULUS, f15)
                                    ),
                                    // friEvalPointDivByX6 * imaginaryUnit ==
                                    // friEvalPointDivByX * mload(add(friHalfInvGroupPtr, 0xe0)).
                                    mulmod(friEvalPointDivByX6, imaginaryUnit, K_MODULUS),
                                    K_MODULUS
                                )
                            )
                        }

                        // f12 < 7P ( = 3 + 3 + 1).
                        f12 := add(
                            add(f12, f14),
                            mulmod(
                                mulmod(friEvalPointDivByX6, friEvalPointDivByX6, K_MODULUS),
                                add(
                                    f12,
                                    // -fMinusX
                                    sub(K_MODULUS_TIMES_16, f14)
                                ),
                                K_MODULUS
                            )
                        )
                    }

                    // f8 < 15P ( = 7 + 7 + 1).
                    f8 := add(
                        add(f8, f12),
                        mulmod(
                            mulmod(friEvalPointDivByXTessed, imaginaryUnit, K_MODULUS),
                            add(
                                f8,
                                // -fMinusX
                                sub(K_MODULUS_TIMES_16, f12)
                            ),
                            K_MODULUS
                        )
                    )
                }

                // f0, f8 < 15P -> f0 + f8 < 30P && 16P < f0 + (K_MODULUS_TIMES_16 - f8) < 31P.
                nextLayerValue := addmod(
                    add(f0, f8),
                    mulmod(
                        mulmod(friEvalPointDivByXTessed, friEvalPointDivByXTessed, K_MODULUS),
                        add(
                            f0,
                            // -fMinusX
                            sub(K_MODULUS_TIMES_16, f8)
                        ),
                        K_MODULUS
                    ),
                    K_MODULUS
                )
            }

            {
                let xInv2 := mulmod(cosetOffset_, cosetOffset_, K_MODULUS)
                let xInv4 := mulmod(xInv2, xInv2, K_MODULUS)
                let xInv8 := mulmod(xInv4, xInv4, K_MODULUS)
                nextXInv := mulmod(xInv8, xInv8, K_MODULUS)
            }
        }
    }
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "PrimeFieldElement0.sol";

contract HornerEvaluator is PrimeFieldElement0 {
    /*
      Computes the evaluation of a polynomial f(x) = sum(a_i * x^i) on the given point.
      The coefficients of the polynomial are given in
        a_0 = coefsStart[0], ..., a_{n-1} = coefsStart[n - 1]
      where n = nCoefs = friLastLayerDegBound. Note that coefsStart is not actually an array but
      a direct pointer.
      The function requires that n is divisible by 8.
    */
    function hornerEval(
        uint256 coefsStart,
        uint256 point,
        uint256 nCoefs
    ) internal pure returns (uint256) {
        uint256 result = 0;
        uint256 prime = PrimeFieldElement0.K_MODULUS;

        require(nCoefs % 8 == 0, "Number of polynomial coefficients must be divisible by 8");
        // Ensure 'nCoefs' is bounded as a sanity check (the bound is somewhat arbitrary).
        require(nCoefs < 4096, "No more than 4096 coefficients are supported");

        assembly {
            let coefsPtr := add(coefsStart, mul(nCoefs, 0x20))
            for {

            } gt(coefsPtr, coefsStart) {

            } {
                // Reduce coefsPtr by 8 field elements.
                coefsPtr := sub(coefsPtr, 0x100)

                // Apply 4 Horner steps (result := result * point + coef).
                result := add(
                    mload(add(coefsPtr, 0x80)),
                    mulmod(
                        add(
                            mload(add(coefsPtr, 0xa0)),
                            mulmod(
                                add(
                                    mload(add(coefsPtr, 0xc0)),
                                    mulmod(
                                        add(
                                            mload(add(coefsPtr, 0xe0)),
                                            mulmod(result, point, prime)
                                        ),
                                        point,
                                        prime
                                    )
                                ),
                                point,
                                prime
                            )
                        ),
                        point,
                        prime
                    )
                )

                // Apply 4 additional Horner steps.
                result := add(
                    mload(coefsPtr),
                    mulmod(
                        add(
                            mload(add(coefsPtr, 0x20)),
                            mulmod(
                                add(
                                    mload(add(coefsPtr, 0x40)),
                                    mulmod(
                                        add(
                                            mload(add(coefsPtr, 0x60)),
                                            mulmod(result, point, prime)
                                        ),
                                        point,
                                        prime
                                    )
                                ),
                                point,
                                prime
                            )
                        ),
                        point,
                        prime
                    )
                )
            }
        }

        // Since the last operation was "add" (instead of "addmod"), we need to take result % prime.
        return result % prime;
    }
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

/*
  The Fact Registry design pattern is a way to separate cryptographic verification from the
  business logic of the contract flow.

  A fact registry holds a hash table of verified "facts" which are represented by a hash of claims
  that the registry hash check and found valid. This table may be queried by accessing the
  isValid() function of the registry with a given hash.

  In addition, each fact registry exposes a registry specific function for submitting new claims
  together with their proofs. The information submitted varies from one registry to the other
  depending of the type of fact requiring verification.

  For further reading on the Fact Registry design pattern see this
  `StarkWare blog post <https://medium.com/starkware/the-fact-registry-a64aafb598b6>`_.
*/
interface IFactRegistry {
    /*
      Returns true if the given fact was previously registered in the contract.
    */
    function isValid(bytes32 fact) external view returns (bool);
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

abstract contract IMerkleVerifier {
    uint256 internal constant MAX_N_MERKLE_VERIFIER_QUERIES = 128;

    // The size of a SLOT in the verifyMerkle queue.
    // Every slot holds a (index, hash) pair.
    uint256 internal constant MERKLE_SLOT_SIZE_IN_BYTES = 0x40;

    function verifyMerkle(
        uint256 channelPtr,
        uint256 queuePtr,
        bytes32 root,
        uint256 n
    ) internal view virtual returns (bytes32 hash);
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

interface IPeriodicColumn {
    function compute(uint256 x) external pure returns (uint256 result);
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "IFactRegistry.sol";

/*
  Extends the IFactRegistry interface with a query method that indicates
  whether the fact registry has successfully registered any fact or is still empty of such facts.
*/
interface IQueryableFactRegistry is IFactRegistry {
    /*
      Returns true if at least one fact has been registered.
    */
    function hasRegisteredFact() external view returns (bool);
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

abstract contract IStarkVerifier {
    function verifyProof(
        uint256[] memory proofParams,
        uint256[] memory proof,
        uint256[] memory publicInput
    ) internal view virtual;
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// ---------- The following code was auto-generated. PLEASE DO NOT EDIT. ----------
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "IPeriodicColumn.sol";
import "MemoryMap.sol";
import "StarkParameters.sol";
import "CpuPublicInputOffsets.sol";
import "CairoVerifierContract.sol";

abstract contract LayoutSpecific is MemoryMap, StarkParameters, CpuPublicInputOffsets, CairoVerifierContract {
    IPeriodicColumn pedersenPointsX;
    IPeriodicColumn pedersenPointsY;
    IPeriodicColumn ecdsaGeneratorPointsX;
    IPeriodicColumn ecdsaGeneratorPointsY;
    IPeriodicColumn poseidonPoseidonFullRoundKey0;
    IPeriodicColumn poseidonPoseidonFullRoundKey1;
    IPeriodicColumn poseidonPoseidonFullRoundKey2;
    IPeriodicColumn poseidonPoseidonPartialRoundKey0;
    IPeriodicColumn poseidonPoseidonPartialRoundKey1;

    function initPeriodicColumns(address[] memory auxPolynomials) internal {
        pedersenPointsX = IPeriodicColumn(auxPolynomials[1]);
        pedersenPointsY = IPeriodicColumn(auxPolynomials[2]);
        ecdsaGeneratorPointsX = IPeriodicColumn(auxPolynomials[3]);
        ecdsaGeneratorPointsY = IPeriodicColumn(auxPolynomials[4]);
        poseidonPoseidonFullRoundKey0 = IPeriodicColumn(auxPolynomials[5]);
        poseidonPoseidonFullRoundKey1 = IPeriodicColumn(auxPolynomials[6]);
        poseidonPoseidonFullRoundKey2 = IPeriodicColumn(auxPolynomials[7]);
        poseidonPoseidonPartialRoundKey0 = IPeriodicColumn(auxPolynomials[8]);
        poseidonPoseidonPartialRoundKey1 = IPeriodicColumn(auxPolynomials[9]);
    }

    function getLayoutInfo()
        external pure override returns (uint256 publicMemoryOffset, uint256 selectedBuiltins) {
        publicMemoryOffset = OFFSET_N_PUBLIC_MEMORY_PAGES;
        selectedBuiltins =
            (1 << OUTPUT_BUILTIN_BIT) |
            (1 << PEDERSEN_BUILTIN_BIT) |
            (1 << RANGE_CHECK_BUILTIN_BIT) |
            (1 << ECDSA_BUILTIN_BIT) |
            (1 << BITWISE_BUILTIN_BIT) |
            (1 << EC_OP_BUILTIN_BIT) |
            (1 << POSEIDON_BUILTIN_BIT);
    }

    function safeDiv(uint256 numerator, uint256 denominator) internal pure returns (uint256) {
        require(denominator > 0, "The denominator must not be zero");
        require(numerator % denominator == 0, "The numerator is not divisible by the denominator.");
        return numerator / denominator;
    }

    function validateBuiltinPointers(
        uint256 initialAddress, uint256 stopAddress, uint256 builtinRatio, uint256 cellsPerInstance,
        uint256 nSteps, string memory builtinName)
        internal pure {
        require(
            initialAddress < 2**64,
            string(abi.encodePacked("Out of range ", builtinName, " begin_addr.")));
        uint256 maxStopPtr = initialAddress + cellsPerInstance * safeDiv(nSteps, builtinRatio);
        require(
            initialAddress <= stopAddress && stopAddress <= maxStopPtr,
            string(abi.encodePacked("Invalid ", builtinName, " stop_ptr.")));
    }

    function layoutSpecificInit(uint256[] memory ctx, uint256[] memory publicInput)
        internal pure {
        // "output" memory segment.
        uint256 outputBeginAddr = publicInput[OFFSET_OUTPUT_BEGIN_ADDR];
        uint256 outputStopPtr = publicInput[OFFSET_OUTPUT_STOP_PTR];
        require(outputBeginAddr <= outputStopPtr, "output begin_addr must be <= stop_ptr");
        require(outputStopPtr < 2**64, "Out of range output stop_ptr.");

        uint256 nSteps = 2 ** ctx[MM_LOG_N_STEPS];

        // "pedersen" memory segment.
        ctx[MM_INITIAL_PEDERSEN_ADDR] = publicInput[OFFSET_PEDERSEN_BEGIN_ADDR];
        validateBuiltinPointers(
            ctx[MM_INITIAL_PEDERSEN_ADDR], publicInput[OFFSET_PEDERSEN_STOP_PTR],
            PEDERSEN_BUILTIN_RATIO, 3, nSteps, 'pedersen');

        // Pedersen's shiftPoint values.
        ctx[MM_PEDERSEN__SHIFT_POINT_X] =
            0x49ee3eba8c1600700ee1b87eb599f16716b0b1022947733551fde4050ca6804;
        ctx[MM_PEDERSEN__SHIFT_POINT_Y] =
            0x3ca0cfe4b3bc6ddf346d49d06ea0ed34e621062c0e056c1d0405d266e10268a;

        // "range_check" memory segment.
        ctx[MM_INITIAL_RC_ADDR] = publicInput[OFFSET_RANGE_CHECK_BEGIN_ADDR];
        validateBuiltinPointers(
            ctx[MM_INITIAL_RC_ADDR], publicInput[OFFSET_RANGE_CHECK_STOP_PTR],
            RC_BUILTIN_RATIO, 1, nSteps, 'range_check');
        ctx[MM_RC16__PERM__PUBLIC_MEMORY_PROD] = 1;

        // "ecdsa" memory segment.
        ctx[MM_INITIAL_ECDSA_ADDR] = publicInput[OFFSET_ECDSA_BEGIN_ADDR];
        validateBuiltinPointers(
            ctx[MM_INITIAL_ECDSA_ADDR], publicInput[OFFSET_ECDSA_STOP_PTR],
            ECDSA_BUILTIN_RATIO, 2, nSteps, 'ecdsa');

        ctx[MM_ECDSA__SIG_CONFIG_ALPHA] = 1;
        ctx[MM_ECDSA__SIG_CONFIG_BETA] =
            0x6f21413efbe40de150e596d72f7a8c5609ad26c15c915c1f4cdfcb99cee9e89;
        ctx[MM_ECDSA__SIG_CONFIG_SHIFT_POINT_X] =
            0x49ee3eba8c1600700ee1b87eb599f16716b0b1022947733551fde4050ca6804;
        ctx[MM_ECDSA__SIG_CONFIG_SHIFT_POINT_Y] =
            0x3ca0cfe4b3bc6ddf346d49d06ea0ed34e621062c0e056c1d0405d266e10268a;

        // "bitwise" memory segment.
        ctx[MM_INITIAL_BITWISE_ADDR] = publicInput[OFFSET_BITWISE_BEGIN_ADDR];
        validateBuiltinPointers(
            ctx[MM_INITIAL_BITWISE_ADDR], publicInput[OFFSET_BITWISE_STOP_ADDR],
            BITWISE__RATIO, 5, nSteps, 'bitwise');

        ctx[MM_DILUTED_CHECK__PERMUTATION__PUBLIC_MEMORY_PROD] = 1;
        ctx[MM_DILUTED_CHECK__FIRST_ELM] = 0;

        // "ec_op" memory segment.
        ctx[MM_INITIAL_EC_OP_ADDR] = publicInput[OFFSET_EC_OP_BEGIN_ADDR];
        validateBuiltinPointers(
            ctx[MM_INITIAL_EC_OP_ADDR], publicInput[OFFSET_EC_OP_STOP_ADDR],
            EC_OP_BUILTIN_RATIO, 7, nSteps, 'ec_op');

        ctx[MM_EC_OP__CURVE_CONFIG_ALPHA] = 1;

        // "poseidon" memory segment.
        ctx[MM_INITIAL_POSEIDON_ADDR] = publicInput[OFFSET_POSEIDON_BEGIN_ADDR];
        validateBuiltinPointers(
            ctx[MM_INITIAL_POSEIDON_ADDR], publicInput[OFFSET_POSEIDON_STOP_PTR],
            POSEIDON__RATIO, 6, nSteps, 'poseidon');
    }

    function prepareForOodsCheck(uint256[] memory ctx) internal view {
        uint256 oodsPoint = ctx[MM_OODS_POINT];
        uint256 nSteps = 2 ** ctx[MM_LOG_N_STEPS];

        // The number of copies in the pedersen hash periodic columns is
        // nSteps / PEDERSEN_BUILTIN_RATIO / PEDERSEN_BUILTIN_REPETITIONS.
        uint256 nPedersenHashCopies = safeDiv(
            nSteps,
            PEDERSEN_BUILTIN_RATIO * PEDERSEN_BUILTIN_REPETITIONS);
        uint256 zPointPowPedersen = fpow(oodsPoint, nPedersenHashCopies);
        ctx[MM_PERIODIC_COLUMN__PEDERSEN__POINTS__X] = pedersenPointsX.compute(zPointPowPedersen);
        ctx[MM_PERIODIC_COLUMN__PEDERSEN__POINTS__Y] = pedersenPointsY.compute(zPointPowPedersen);

        // The number of copies in the ECDSA signature periodic columns is
        // nSteps / ECDSA_BUILTIN_RATIO / ECDSA_BUILTIN_REPETITIONS.
        uint256 nEcdsaSignatureCopies = safeDiv(
            2 ** ctx[MM_LOG_N_STEPS],
            ECDSA_BUILTIN_RATIO * ECDSA_BUILTIN_REPETITIONS);
        uint256 zPointPowEcdsa = fpow(oodsPoint, nEcdsaSignatureCopies);

        ctx[MM_PERIODIC_COLUMN__ECDSA__GENERATOR_POINTS__X] = ecdsaGeneratorPointsX.compute(zPointPowEcdsa);
        ctx[MM_PERIODIC_COLUMN__ECDSA__GENERATOR_POINTS__Y] = ecdsaGeneratorPointsY.compute(zPointPowEcdsa);

        ctx[MM_DILUTED_CHECK__PERMUTATION__INTERACTION_ELM] = ctx[MM_INTERACTION_ELEMENTS +
            3];
        ctx[MM_DILUTED_CHECK__INTERACTION_Z] = ctx[MM_INTERACTION_ELEMENTS + 4];
        ctx[MM_DILUTED_CHECK__INTERACTION_ALPHA] = ctx[MM_INTERACTION_ELEMENTS +
            5];

        ctx[MM_DILUTED_CHECK__FINAL_CUM_VAL] = computeDilutedCumulativeValue(ctx);

        // The number of copies in the Poseidon hash periodic columns is
        // nSteps / POSEIDON__RATIO.
        uint256 nPoseidonHashCopies = safeDiv(
            2 ** ctx[MM_LOG_N_STEPS],
            POSEIDON__RATIO);
        uint256 zPointPowPoseidon = fpow(oodsPoint, nPoseidonHashCopies);

        ctx[MM_PERIODIC_COLUMN__POSEIDON__POSEIDON__FULL_ROUND_KEY0] = poseidonPoseidonFullRoundKey0.compute(zPointPowPoseidon);
        ctx[MM_PERIODIC_COLUMN__POSEIDON__POSEIDON__FULL_ROUND_KEY1] = poseidonPoseidonFullRoundKey1.compute(zPointPowPoseidon);
        ctx[MM_PERIODIC_COLUMN__POSEIDON__POSEIDON__FULL_ROUND_KEY2] = poseidonPoseidonFullRoundKey2.compute(zPointPowPoseidon);
        ctx[MM_PERIODIC_COLUMN__POSEIDON__POSEIDON__PARTIAL_ROUND_KEY0] = poseidonPoseidonPartialRoundKey0.compute(zPointPowPoseidon);
        ctx[MM_PERIODIC_COLUMN__POSEIDON__POSEIDON__PARTIAL_ROUND_KEY1] = poseidonPoseidonPartialRoundKey1.compute(zPointPowPoseidon);

    }

    /*
      Computes the final cumulative value of the diluted pool.
    */
    function computeDilutedCumulativeValue(uint256[] memory ctx)
        internal
        pure
        returns (uint256 res)
    {
        // The cumulative value is defined using the following recursive formula:
        //   r_1 = 1, r_{j+1} = r_j * (1 + z * u_j) + alpha * u_j^2 (for j >= 1)
        // where u_j = Dilute(j, spacing, n_bits) - Dilute(j-1, spacing, n_bits)
        // and we want to compute the final value r_{2^n_bits}.
        // Note that u_j depends only on the number of trailing zeros in the binary representation
        // of j. Specifically,
        //   u_{(1 + 2k) * 2^i} = u_{2^i} =
        //   u_{2^{i - 1}} + 2^{i * spacing} - 2^{(i - 1) * spacing + 1}.
        //
        // The recursive formula can be reduced to a nonrecursive form:
        //   r_j = prod_{n=1..j-1}(1 + z*u_n) +
        //     alpha * sum_{n=1..j-1}(u_n^2 * prod_{m=n + 1..j - 1}(1 + z * u_m))
        //
        // We rewrite this equation to generate a recursive formula that converges in log(j) steps:
        // Denote:
        //   p_i = prod_{n=1..2^i - 1}(1 + z * u_n)
        //   q_i = sum_{n=1..2^i - 1}(u_n^2 * prod_{m=n + 1..2^i-1}(1 + z * u_m))
        //   x_i = u_{2^i}.
        //
        // Clearly
        //   r_{2^i} = p_i + alpha * q_i.
        // Moreover, due to the symmetry of the sequence u_j,
        //   p_i = p_{i - 1} * (1 + z * x_{i - 1}) * p_{i - 1}
        //   q_i = q_{i - 1} * (1 + z * x_{i - 1}) * p_{i - 1} + x_{i - 1}^2 * p_{i - 1} + q_{i - 1}
        //
        // Now we can compute p_{n_bits} and q_{n_bits} in 'n_bits' steps and we are done.
        uint256 z = ctx[MM_DILUTED_CHECK__INTERACTION_Z];
        uint256 alpha = ctx[MM_DILUTED_CHECK__INTERACTION_ALPHA];
        uint256 diffMultiplier = 1 << DILUTED_SPACING;
        uint256 diffX = diffMultiplier - 2;
        // Initialize p, q and x to p_1, q_1 and x_0 respectively.
        uint256 p = 1 + z;
        uint256 q = 1;
        uint256 x = 1;
        assembly {
            for {
                let i := 1
            } lt(i, DILUTED_N_BITS) {
                i := add(i, 1)
            } {
                x := addmod(x, diffX, K_MODULUS)
                diffX := mulmod(diffX, diffMultiplier, K_MODULUS)
                // To save multiplications, store intermediate values.
                let x_p := mulmod(x, p, K_MODULUS)
                let y := add(p, mulmod(z, x_p, K_MODULUS))
                q := addmod(
                add(mulmod(q, y, K_MODULUS), mulmod(x, x_p, K_MODULUS)),
                    q,
                    K_MODULUS
                )
                p := mulmod(p, y, K_MODULUS)
            }
            res := addmod(p, mulmod(q, alpha, K_MODULUS), K_MODULUS)
        }
    }
}
// ---------- End of auto-generated code. ----------

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "MemoryMap.sol";

contract MemoryAccessUtils is MemoryMap {
    function getPtr(uint256[] memory ctx, uint256 offset) internal pure returns (uint256) {
        uint256 ctxPtr;
        require(offset < MM_CONTEXT_SIZE, "Overflow protection failed");
        assembly {
            ctxPtr := add(ctx, 0x20)
        }
        return ctxPtr + offset * 0x20;
    }

    function getProofPtr(uint256[] memory proof) internal pure returns (uint256) {
        uint256 proofPtr;
        assembly {
            proofPtr := proof
        }
        return proofPtr;
    }

    function getChannelPtr(uint256[] memory ctx) internal pure returns (uint256) {
        uint256 ctxPtr;
        assembly {
            ctxPtr := add(ctx, 0x20)
        }
        return ctxPtr + MM_CHANNEL * 0x20;
    }

    function getQueries(uint256[] memory ctx) internal pure returns (uint256[] memory) {
        uint256[] memory queries;
        // Dynamic array holds length followed by values.
        uint256 offset = 0x20 + 0x20 * MM_N_UNIQUE_QUERIES;
        assembly {
            queries := add(ctx, offset)
        }
        return queries;
    }

    function getMerkleQueuePtr(uint256[] memory ctx) internal pure returns (uint256) {
        return getPtr(ctx, MM_MERKLE_QUEUE);
    }

    function getFriStepSizes(uint256[] memory ctx)
        internal
        pure
        returns (uint256[] memory friStepSizes)
    {
        uint256 friStepSizesPtr = getPtr(ctx, MM_FRI_STEP_SIZES_PTR);
        assembly {
            friStepSizes := mload(friStepSizesPtr)
        }
    }
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// ---------- The following code was auto-generated. PLEASE DO NOT EDIT. ----------
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

contract MemoryMap {
    /*
      We store the state of the verifier in a contiguous chunk of memory.
      The offsets of the different fields are listed below.
      E.g. The offset of the i'th hash is [mm_hashes + i].
    */
    uint256 constant internal MAX_N_QUERIES = 48;
    uint256 constant internal FRI_QUEUE_SIZE = MAX_N_QUERIES;

    uint256 constant internal MAX_FRI_STEPS = 10;
    uint256 constant internal MAX_SUPPORTED_FRI_STEP_SIZE = 4;

    uint256 constant internal MM_EVAL_DOMAIN_SIZE =                          0x0;
    uint256 constant internal MM_BLOW_UP_FACTOR =                            0x1;
    uint256 constant internal MM_LOG_EVAL_DOMAIN_SIZE =                      0x2;
    uint256 constant internal MM_PROOF_OF_WORK_BITS =                        0x3;
    uint256 constant internal MM_EVAL_DOMAIN_GENERATOR =                     0x4;
    uint256 constant internal MM_PUBLIC_INPUT_PTR =                          0x5;
    uint256 constant internal MM_TRACE_COMMITMENT =                          0x6; // uint256[2]
    uint256 constant internal MM_OODS_COMMITMENT =                           0x8;
    uint256 constant internal MM_N_UNIQUE_QUERIES =                          0x9;
    uint256 constant internal MM_CHANNEL =                                   0xa; // uint256[3]
    uint256 constant internal MM_MERKLE_QUEUE =                              0xd; // uint256[96]
    uint256 constant internal MM_FRI_QUEUE =                                0x6d; // uint256[144]
    uint256 constant internal MM_FRI_QUERIES_DELIMITER =                    0xfd;
    uint256 constant internal MM_FRI_CTX =                                  0xfe; // uint256[40]
    uint256 constant internal MM_FRI_STEP_SIZES_PTR =                      0x126;
    uint256 constant internal MM_FRI_EVAL_POINTS =                         0x127; // uint256[10]
    uint256 constant internal MM_FRI_COMMITMENTS =                         0x131; // uint256[10]
    uint256 constant internal MM_FRI_LAST_LAYER_DEG_BOUND =                0x13b;
    uint256 constant internal MM_FRI_LAST_LAYER_PTR =                      0x13c;
    uint256 constant internal MM_CONSTRAINT_POLY_ARGS_START =              0x13d;
    uint256 constant internal MM_PERIODIC_COLUMN__PEDERSEN__POINTS__X =    0x13d;
    uint256 constant internal MM_PERIODIC_COLUMN__PEDERSEN__POINTS__Y =    0x13e;
    uint256 constant internal MM_PERIODIC_COLUMN__ECDSA__GENERATOR_POINTS__X = 0x13f;
    uint256 constant internal MM_PERIODIC_COLUMN__ECDSA__GENERATOR_POINTS__Y = 0x140;
    uint256 constant internal MM_PERIODIC_COLUMN__POSEIDON__POSEIDON__FULL_ROUND_KEY0 = 0x141;
    uint256 constant internal MM_PERIODIC_COLUMN__POSEIDON__POSEIDON__FULL_ROUND_KEY1 = 0x142;
    uint256 constant internal MM_PERIODIC_COLUMN__POSEIDON__POSEIDON__FULL_ROUND_KEY2 = 0x143;
    uint256 constant internal MM_PERIODIC_COLUMN__POSEIDON__POSEIDON__PARTIAL_ROUND_KEY0 = 0x144;
    uint256 constant internal MM_PERIODIC_COLUMN__POSEIDON__POSEIDON__PARTIAL_ROUND_KEY1 = 0x145;
    uint256 constant internal MM_TRACE_LENGTH =                            0x146;
    uint256 constant internal MM_OFFSET_SIZE =                             0x147;
    uint256 constant internal MM_HALF_OFFSET_SIZE =                        0x148;
    uint256 constant internal MM_INITIAL_AP =                              0x149;
    uint256 constant internal MM_INITIAL_PC =                              0x14a;
    uint256 constant internal MM_FINAL_AP =                                0x14b;
    uint256 constant internal MM_FINAL_PC =                                0x14c;
    uint256 constant internal MM_MEMORY__MULTI_COLUMN_PERM__PERM__INTERACTION_ELM = 0x14d;
    uint256 constant internal MM_MEMORY__MULTI_COLUMN_PERM__HASH_INTERACTION_ELM0 = 0x14e;
    uint256 constant internal MM_MEMORY__MULTI_COLUMN_PERM__PERM__PUBLIC_MEMORY_PROD = 0x14f;
    uint256 constant internal MM_RC16__PERM__INTERACTION_ELM =             0x150;
    uint256 constant internal MM_RC16__PERM__PUBLIC_MEMORY_PROD =          0x151;
    uint256 constant internal MM_RC_MIN =                                  0x152;
    uint256 constant internal MM_RC_MAX =                                  0x153;
    uint256 constant internal MM_DILUTED_CHECK__PERMUTATION__INTERACTION_ELM = 0x154;
    uint256 constant internal MM_DILUTED_CHECK__PERMUTATION__PUBLIC_MEMORY_PROD = 0x155;
    uint256 constant internal MM_DILUTED_CHECK__FIRST_ELM =                0x156;
    uint256 constant internal MM_DILUTED_CHECK__INTERACTION_Z =            0x157;
    uint256 constant internal MM_DILUTED_CHECK__INTERACTION_ALPHA =        0x158;
    uint256 constant internal MM_DILUTED_CHECK__FINAL_CUM_VAL =            0x159;
    uint256 constant internal MM_PEDERSEN__SHIFT_POINT_X =                 0x15a;
    uint256 constant internal MM_PEDERSEN__SHIFT_POINT_Y =                 0x15b;
    uint256 constant internal MM_INITIAL_PEDERSEN_ADDR =                   0x15c;
    uint256 constant internal MM_INITIAL_RC_ADDR =                         0x15d;
    uint256 constant internal MM_ECDSA__SIG_CONFIG_ALPHA =                 0x15e;
    uint256 constant internal MM_ECDSA__SIG_CONFIG_SHIFT_POINT_X =         0x15f;
    uint256 constant internal MM_ECDSA__SIG_CONFIG_SHIFT_POINT_Y =         0x160;
    uint256 constant internal MM_ECDSA__SIG_CONFIG_BETA =                  0x161;
    uint256 constant internal MM_INITIAL_ECDSA_ADDR =                      0x162;
    uint256 constant internal MM_INITIAL_BITWISE_ADDR =                    0x163;
    uint256 constant internal MM_INITIAL_EC_OP_ADDR =                      0x164;
    uint256 constant internal MM_EC_OP__CURVE_CONFIG_ALPHA =               0x165;
    uint256 constant internal MM_INITIAL_POSEIDON_ADDR =                   0x166;
    uint256 constant internal MM_TRACE_GENERATOR =                         0x167;
    uint256 constant internal MM_OODS_POINT =                              0x168;
    uint256 constant internal MM_INTERACTION_ELEMENTS =                    0x169; // uint256[6]
    uint256 constant internal MM_COMPOSITION_ALPHA =                       0x16f;
    uint256 constant internal MM_OODS_VALUES =                             0x170; // uint256[269]
    uint256 constant internal MM_CONSTRAINT_POLY_ARGS_END =                0x27d;
    uint256 constant internal MM_COMPOSITION_OODS_VALUES =                 0x27d; // uint256[2]
    uint256 constant internal MM_OODS_EVAL_POINTS =                        0x27f; // uint256[48]
    uint256 constant internal MM_OODS_ALPHA =                              0x2af;
    uint256 constant internal MM_TRACE_QUERY_RESPONSES =                   0x2b0; // uint256[480]
    uint256 constant internal MM_COMPOSITION_QUERY_RESPONSES =             0x490; // uint256[96]
    uint256 constant internal MM_LOG_N_STEPS =                             0x4f0;
    uint256 constant internal MM_N_PUBLIC_MEM_ENTRIES =                    0x4f1;
    uint256 constant internal MM_N_PUBLIC_MEM_PAGES =                      0x4f2;
    uint256 constant internal MM_CONTEXT_SIZE =                            0x4f3;
}
// ---------- End of auto-generated code. ----------

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "FactRegistry.sol";

contract MemoryPageFactRegistryConstants {
    // A page based on a list of pairs (address, value).
    // In this case, memoryHash = hash(address, value, address, value, address, value, ...).
    uint256 internal constant REGULAR_PAGE = 0;
    // A page based on adjacent memory cells, starting from a given address.
    // In this case, memoryHash = hash(value, value, value, ...).
    uint256 internal constant CONTINUOUS_PAGE = 1;
}

/*
  A fact registry for the claim:
    I know n pairs (addr, value) for which the hash of the pairs is memoryHash, and the cumulative
    product: \prod_i( z - (addr_i + alpha * value_i) ) is prod.
  The exact format of the hash depends on the type of the page
  (see MemoryPageFactRegistryConstants).
  The fact consists of (pageType, prime, n, z, alpha, prod, memoryHash, address).
  Note that address is only available for CONTINUOUS_PAGE, and otherwise it is 0.
*/
contract MemoryPageFactRegistry is FactRegistry, MemoryPageFactRegistryConstants {
    event LogMemoryPageFactRegular(bytes32 factHash, uint256 memoryHash, uint256 prod);
    event LogMemoryPageFactContinuous(bytes32 factHash, uint256 memoryHash, uint256 prod);

    /*
      Registers a fact based of the given memory (address, value) pairs (REGULAR_PAGE).
    */
    function registerRegularMemoryPage(
        uint256[] calldata memoryPairs,
        uint256 z,
        uint256 alpha,
        uint256 prime
    )
        external
        returns (
            bytes32 factHash,
            uint256 memoryHash,
            uint256 prod
        )
    {
        // Ensure 'memoryPairs.length' is bounded as a sanity check (the bound is somewhat arbitrary).
        require(memoryPairs.length < 2**20, "Too many memory values.");
        require(memoryPairs.length % 2 == 0, "Size of memoryPairs must be even.");
        require(z < prime, "Invalid value of z.");
        require(alpha < prime, "Invalid value of alpha.");
        (factHash, memoryHash, prod) = computeFactHash(memoryPairs, z, alpha, prime);
        emit LogMemoryPageFactRegular(factHash, memoryHash, prod);

        registerFact(factHash);
    }

    function computeFactHash(
        uint256[] memory memoryPairs,
        uint256 z,
        uint256 alpha,
        uint256 prime
    )
        private
        pure
        returns (
            bytes32 factHash,
            uint256 memoryHash,
            uint256 prod
        )
    {
        uint256 memorySize = memoryPairs.length / 2; // NOLINT: divide-before-multiply.

        prod = 1;

        assembly {
            let memoryPtr := add(memoryPairs, 0x20)

            // Each value of memoryPairs is a pair: (address, value).
            let lastPtr := add(memoryPtr, mul(memorySize, 0x40))
            for {
                let ptr := memoryPtr
            } lt(ptr, lastPtr) {
                ptr := add(ptr, 0x40)
            } {
                // Compute address + alpha * value.
                let address_value_lin_comb := addmod(
                    // address=
                    mload(ptr),
                    mulmod(
                        // value=
                        mload(add(ptr, 0x20)),
                        alpha,
                        prime
                    ),
                    prime
                )
                prod := mulmod(prod, add(z, sub(prime, address_value_lin_comb)), prime)
            }

            memoryHash := keccak256(
                memoryPtr,
                mul(
                    // 0x20 * 2.
                    0x40,
                    memorySize
                )
            )
        }

        factHash = keccak256(
            abi.encodePacked(
                REGULAR_PAGE,
                prime,
                memorySize,
                z,
                alpha,
                prod,
                memoryHash,
                uint256(0)
            )
        );
    }

    /*
      Registers a fact based on the given values, assuming continuous addresses.
      values should be [value at startAddr, value at (startAddr + 1), ...].
    */
    function registerContinuousMemoryPage(
        // NOLINT: external-function.
        uint256 startAddr,
        uint256[] memory values,
        uint256 z,
        uint256 alpha,
        uint256 prime
    )
        public
        returns (
            bytes32 factHash,
            uint256 memoryHash,
            uint256 prod
        )
    {
        require(values.length < 2**20, "Too many memory values.");
        require(prime < 2**254, "prime is too big for the optimizations in this function.");
        require(z < prime, "Invalid value of z.");
        require(alpha < prime, "Invalid value of alpha.");
        // Ensure 'startAddr' less then prime and bounded as a sanity check (the bound is somewhat arbitrary).
        require((startAddr < prime) && (startAddr < 2**64), "Invalid value of startAddr.");

        uint256 nValues = values.length;

        assembly {
            // Initialize prod to 1.
            prod := 1
            // Initialize valuesPtr to point to the first value in the array.
            let valuesPtr := add(values, 0x20)

            let minus_z := mod(sub(prime, z), prime)

            // Start by processing full batches of 8 cells, addr represents the last address in each
            // batch.
            let addr := add(startAddr, 7)
            let lastAddr := add(startAddr, nValues)
            for {

            } lt(addr, lastAddr) {
                addr := add(addr, 8)
            } {
                // Compute the product of (lin_comb - z) instead of (z - lin_comb), since we're
                // doing an even number of iterations, the result is the same.
                prod := mulmod(
                    prod,
                    mulmod(
                        add(add(sub(addr, 7), mulmod(mload(valuesPtr), alpha, prime)), minus_z),
                        add(
                            add(sub(addr, 6), mulmod(mload(add(valuesPtr, 0x20)), alpha, prime)),
                            minus_z
                        ),
                        prime
                    ),
                    prime
                )

                prod := mulmod(
                    prod,
                    mulmod(
                        add(
                            add(sub(addr, 5), mulmod(mload(add(valuesPtr, 0x40)), alpha, prime)),
                            minus_z
                        ),
                        add(
                            add(sub(addr, 4), mulmod(mload(add(valuesPtr, 0x60)), alpha, prime)),
                            minus_z
                        ),
                        prime
                    ),
                    prime
                )

                prod := mulmod(
                    prod,
                    mulmod(
                        add(
                            add(sub(addr, 3), mulmod(mload(add(valuesPtr, 0x80)), alpha, prime)),
                            minus_z
                        ),
                        add(
                            add(sub(addr, 2), mulmod(mload(add(valuesPtr, 0xa0)), alpha, prime)),
                            minus_z
                        ),
                        prime
                    ),
                    prime
                )

                prod := mulmod(
                    prod,
                    mulmod(
                        add(
                            add(sub(addr, 1), mulmod(mload(add(valuesPtr, 0xc0)), alpha, prime)),
                            minus_z
                        ),
                        add(add(addr, mulmod(mload(add(valuesPtr, 0xe0)), alpha, prime)), minus_z),
                        prime
                    ),
                    prime
                )

                valuesPtr := add(valuesPtr, 0x100)
            }

            // Handle leftover.
            // Translate addr to the beginning of the last incomplete batch.
            addr := sub(addr, 7)
            for {

            } lt(addr, lastAddr) {
                addr := add(addr, 1)
            } {
                let address_value_lin_comb := addmod(
                    addr,
                    mulmod(mload(valuesPtr), alpha, prime),
                    prime
                )
                prod := mulmod(prod, add(z, sub(prime, address_value_lin_comb)), prime)
                valuesPtr := add(valuesPtr, 0x20)
            }

            memoryHash := keccak256(add(values, 0x20), mul(0x20, nValues))
        }

        factHash = keccak256(
            abi.encodePacked(CONTINUOUS_PAGE, prime, nValues, z, alpha, prod, memoryHash, startAddr)
        );

        emit LogMemoryPageFactContinuous(factHash, memoryHash, prod);

        registerFact(factHash);
    }
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "FactRegistry.sol";
import "MerkleVerifier.sol";

contract MerkleStatementContract is MerkleVerifier, FactRegistry {
    /*
      This function receives an initial Merkle queue (consists of indices of leaves in the Merkle
      in addition to their values) and a Merkle view (contains the values of all the nodes
      required to be able to validate the queue). In case of success it registers the Merkle fact,
      which is the hash of the queue together with the resulting root.
    */
    // NOLINTNEXTLINE: external-function.
    function verifyMerkle(
        uint256[] memory merkleView,
        uint256[] memory initialMerkleQueue,
        uint256 height,
        uint256 expectedRoot
    ) public {
        // Ensure 'height' is bounded as a sanity check (the bound is somewhat arbitrary).
        require(height < 200, "Height must be < 200.");
        require(
            initialMerkleQueue.length <= MAX_N_MERKLE_VERIFIER_QUERIES * 2,
            "TOO_MANY_MERKLE_QUERIES"
        );
        require(initialMerkleQueue.length % 2 == 0, "ODD_MERKLE_QUEUE_SIZE");

        uint256 merkleQueuePtr;
        uint256 channelPtr;
        uint256 nQueries;
        uint256 dataToHashPtr;
        uint256 badInput = 0;

        assembly {
            // Skip 0x20 bytes length at the beginning of the merkleView.
            let merkleViewPtr := add(merkleView, 0x20)
            // Let channelPtr point to a free space.
            channelPtr := mload(0x40) // freePtr.
            // channelPtr will point to the merkleViewPtr since the 'verify' function expects
            // a pointer to the proofPtr.
            mstore(channelPtr, merkleViewPtr)
            // Skip 0x20 bytes length at the beginning of the initialMerkleQueue.
            merkleQueuePtr := add(initialMerkleQueue, 0x20)
            // Get number of queries.
            nQueries := div(mload(initialMerkleQueue), 0x2) //NOLINT: divide-before-multiply.
            // Get a pointer to the end of initialMerkleQueue.
            let initialMerkleQueueEndPtr := add(
                merkleQueuePtr,
                mul(nQueries, MERKLE_SLOT_SIZE_IN_BYTES)
            )
            // Let dataToHashPtr point to a free memory.
            dataToHashPtr := add(channelPtr, 0x20) // Next freePtr.

            // Copy initialMerkleQueue to dataToHashPtr and validaite the indices.
            // The indices need to be in the range [2**height..2*(height+1)-1] and
            // strictly incrementing.

            // First index needs to be >= 2**height.
            let idxLowerLimit := shl(height, 1)
            for {

            } lt(merkleQueuePtr, initialMerkleQueueEndPtr) {

            } {
                let curIdx := mload(merkleQueuePtr)
                // badInput |= curIdx < IdxLowerLimit.
                badInput := or(badInput, lt(curIdx, idxLowerLimit))

                // The next idx must be at least curIdx + 1.
                idxLowerLimit := add(curIdx, 1)

                // Copy the pair (idx, hash) to the dataToHash array.
                mstore(dataToHashPtr, curIdx)
                mstore(add(dataToHashPtr, 0x20), mload(add(merkleQueuePtr, 0x20)))

                dataToHashPtr := add(dataToHashPtr, 0x40)
                merkleQueuePtr := add(merkleQueuePtr, MERKLE_SLOT_SIZE_IN_BYTES)
            }

            // We need to enforce that lastIdx < 2**(height+1)
            // => fail if lastIdx >= 2**(height+1)
            // => fail if (lastIdx + 1) > 2**(height+1)
            // => fail if idxLowerLimit > 2**(height+1).
            badInput := or(badInput, gt(idxLowerLimit, shl(height, 2)))

            // Reset merkleQueuePtr.
            merkleQueuePtr := add(initialMerkleQueue, 0x20)
            // Let freePtr point to a free memory (one word after the copied queries - reserved
            // for the root).
            mstore(0x40, add(dataToHashPtr, 0x20))
        }
        require(badInput == 0, "INVALID_MERKLE_INDICES");
        bytes32 resRoot = verifyMerkle(channelPtr, merkleQueuePtr, bytes32(expectedRoot), nQueries);
        bytes32 factHash;
        assembly {
            // Append the resulted root (should be the return value of verify) to dataToHashPtr.
            mstore(dataToHashPtr, resRoot)
            // Reset dataToHashPtr.
            dataToHashPtr := add(channelPtr, 0x20)
            factHash := keccak256(dataToHashPtr, add(mul(nQueries, 0x40), 0x20))
        }

        registerFact(factHash);
    }
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "MerkleStatementContract.sol";

abstract contract MerkleStatementVerifier is IMerkleVerifier {
    MerkleStatementContract merkleStatementContract;

    constructor(address merkleStatementContractAddress) public {
        merkleStatementContract = MerkleStatementContract(merkleStatementContractAddress);
    }

    // Computes the hash of the Merkle statement, and verifies that it is registered in the
    // Merkle Fact Registry. Receives as input the queuePtr (as address), its length
    // the numbers of queries n, and the root. The channelPtr is is ignored.
    function verifyMerkle(
        uint256, /*channelPtr*/
        uint256 queuePtr,
        bytes32 root,
        uint256 n
    ) internal view virtual override returns (bytes32) {
        bytes32 statement;
        require(n <= MAX_N_MERKLE_VERIFIER_QUERIES, "TOO_MANY_MERKLE_QUERIES");

        assembly {
            let dataToHashPtrStart := mload(0x40) // freePtr.
            let dataToHashPtrCur := dataToHashPtrStart

            let queEndPtr := add(queuePtr, mul(n, 0x40))

            for {

            } lt(queuePtr, queEndPtr) {

            } {
                mstore(dataToHashPtrCur, mload(queuePtr))
                dataToHashPtrCur := add(dataToHashPtrCur, 0x20)
                queuePtr := add(queuePtr, 0x20)
            }

            mstore(dataToHashPtrCur, root)
            dataToHashPtrCur := add(dataToHashPtrCur, 0x20)
            mstore(0x40, dataToHashPtrCur)

            statement := keccak256(dataToHashPtrStart, sub(dataToHashPtrCur, dataToHashPtrStart))
        }
        require(merkleStatementContract.isValid(statement), "INVALIDATED_MERKLE_STATEMENT");
        return root;
    }
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "IMerkleVerifier.sol";

contract MerkleVerifier is IMerkleVerifier {
    // Commitments are masked to 160bit using the following mask to save gas costs.
    uint256 internal constant COMMITMENT_MASK = (
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000
    );

    // The size of a commitment. We use 32 bytes (rather than 20 bytes) per commitment as it
    // simplifies the code.
    uint256 internal constant COMMITMENT_SIZE_IN_BYTES = 0x20;

    // The size of two commitments.
    uint256 internal constant TWO_COMMITMENTS_SIZE_IN_BYTES = 0x40;

    // The size of and index in the verifyMerkle queue.
    uint256 internal constant INDEX_SIZE_IN_BYTES = 0x20;

    /*
      Verifies a Merkle tree decommitment for n leaves in a Merkle tree with N leaves.

      The inputs data sits in the queue at queuePtr.
      Each slot in the queue contains a 32 bytes leaf index and a 32 byte leaf value.
      The indices need to be in the range [N..2*N-1] and strictly incrementing.
      Decommitments are read from the channel in the ctx.

      The input data is destroyed during verification.
    */
    function verifyMerkle(
        uint256 channelPtr,
        uint256 queuePtr,
        bytes32 root,
        uint256 n
    ) internal view virtual override returns (bytes32 hash) {
        require(n <= MAX_N_MERKLE_VERIFIER_QUERIES, "TOO_MANY_MERKLE_QUERIES");

        assembly {
            // queuePtr + i * MERKLE_SLOT_SIZE_IN_BYTES gives the i'th index in the queue.
            // hashesPtr + i * MERKLE_SLOT_SIZE_IN_BYTES gives the i'th hash in the queue.
            let hashesPtr := add(queuePtr, INDEX_SIZE_IN_BYTES)
            let queueSize := mul(n, MERKLE_SLOT_SIZE_IN_BYTES)

            // The items are in slots [0, n-1].
            let rdIdx := 0
            let wrIdx := 0 // = n % n.

            // Iterate the queue until we hit the root.
            let index := mload(add(rdIdx, queuePtr))
            let proofPtr := mload(channelPtr)

            // while(index > 1).
            for {

            } gt(index, 1) {

            } {
                let siblingIndex := xor(index, 1)
                // sibblingOffset := COMMITMENT_SIZE_IN_BYTES * lsb(siblingIndex).
                let sibblingOffset := mulmod(
                    siblingIndex,
                    COMMITMENT_SIZE_IN_BYTES,
                    TWO_COMMITMENTS_SIZE_IN_BYTES
                )

                // Store the hash corresponding to index in the correct slot.
                // 0 if index is even and 0x20 if index is odd.
                // The hash of the sibling will be written to the other slot.
                mstore(xor(0x20, sibblingOffset), mload(add(rdIdx, hashesPtr)))
                rdIdx := addmod(rdIdx, MERKLE_SLOT_SIZE_IN_BYTES, queueSize)

                // Inline channel operation:
                // Assume we are going to read a new hash from the proof.
                // If this is not the case add(proofPtr, COMMITMENT_SIZE_IN_BYTES) will be reverted.
                let newHashPtr := proofPtr
                proofPtr := add(proofPtr, COMMITMENT_SIZE_IN_BYTES)

                // Push index/2 into the queue, before reading the next index.
                // The order is important, as otherwise we may try to read from an empty queue (in
                // the case where we are working on one item).
                // wrIdx will be updated after writing the relevant hash to the queue.
                mstore(add(wrIdx, queuePtr), div(index, 2))

                // Load the next index from the queue and check if it is our sibling.
                index := mload(add(rdIdx, queuePtr))
                if eq(index, siblingIndex) {
                    // Take sibling from queue rather than from proof.
                    newHashPtr := add(rdIdx, hashesPtr)
                    // Revert reading from proof.
                    proofPtr := sub(proofPtr, COMMITMENT_SIZE_IN_BYTES)
                    rdIdx := addmod(rdIdx, MERKLE_SLOT_SIZE_IN_BYTES, queueSize)

                    // Index was consumed, read the next one.
                    // Note that the queue can't be empty at this point.
                    // The index of the parent of the current node was already pushed into the
                    // queue, and the parent is never the sibling.
                    index := mload(add(rdIdx, queuePtr))
                }

                mstore(sibblingOffset, mload(newHashPtr))

                // Push the new hash to the end of the queue.
                mstore(
                    add(wrIdx, hashesPtr),
                    and(COMMITMENT_MASK, keccak256(0x00, TWO_COMMITMENTS_SIZE_IN_BYTES))
                )
                wrIdx := addmod(wrIdx, MERKLE_SLOT_SIZE_IN_BYTES, queueSize)
            }
            hash := mload(add(rdIdx, hashesPtr))

            // Update the proof pointer in the context.
            mstore(channelPtr, proofPtr)
        }
        require(hash == root, "INVALID_MERKLE_PROOF");
    }
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

contract PageInfo {
    uint256 public constant PAGE_INFO_SIZE = 3;
    // PAGE_INFO_SIZE_IN_BYTES cannot reference PAGE_INFO_SIZE as only direct constants are
    // supported in assembly.
    uint256 public constant PAGE_INFO_SIZE_IN_BYTES = 3 * 32;

    uint256 public constant PAGE_INFO_ADDRESS_OFFSET = 0;
    uint256 public constant PAGE_INFO_SIZE_OFFSET = 1;
    uint256 public constant PAGE_INFO_HASH_OFFSET = 2;

    // A regular page entry is a (address, value) pair stored as 2 uint256 words.
    uint256 internal constant MEMORY_PAIR_SIZE = 2;
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

contract PrimeFieldElement0 {
    uint256 internal constant K_MODULUS =
        0x800000000000011000000000000000000000000000000000000000000000001;
    uint256 internal constant K_MONTGOMERY_R =
        0x7fffffffffffdf0ffffffffffffffffffffffffffffffffffffffffffffffe1;
    uint256 internal constant K_MONTGOMERY_R_INV =
        0x40000000000001100000000000012100000000000000000000000000000000;
    uint256 internal constant GENERATOR_VAL = 3;
    uint256 internal constant ONE_VAL = 1;

    function fromMontgomery(uint256 val) internal pure returns (uint256 res) {
        // uint256 res = fmul(val, kMontgomeryRInv);
        assembly {
            res := mulmod(val, K_MONTGOMERY_R_INV, K_MODULUS)
        }
        return res;
    }

    function fromMontgomeryBytes(bytes32 bs) internal pure returns (uint256) {
        // Assuming bs is a 256bit bytes object, in Montgomery form, it is read into a field
        // element.
        uint256 res = uint256(bs);
        return fromMontgomery(res);
    }

    function toMontgomeryInt(uint256 val) internal pure returns (uint256 res) {
        //uint256 res = fmul(val, kMontgomeryR);
        assembly {
            res := mulmod(val, K_MONTGOMERY_R, K_MODULUS)
        }
        return res;
    }

    function fmul(uint256 a, uint256 b) internal pure returns (uint256 res) {
        //uint256 res = mulmod(a, b, kModulus);
        assembly {
            res := mulmod(a, b, K_MODULUS)
        }
        return res;
    }

    function fadd(uint256 a, uint256 b) internal pure returns (uint256 res) {
        // uint256 res = addmod(a, b, kModulus);
        assembly {
            res := addmod(a, b, K_MODULUS)
        }
        return res;
    }

    function fsub(uint256 a, uint256 b) internal pure returns (uint256 res) {
        // uint256 res = addmod(a, kModulus - b, kModulus);
        assembly {
            res := addmod(a, sub(K_MODULUS, b), K_MODULUS)
        }
        return res;
    }

    function fpow(uint256 val, uint256 exp) internal view returns (uint256) {
        return expmod(val, exp, K_MODULUS);
    }

    function expmod(
        uint256 base,
        uint256 exponent,
        uint256 modulus
    ) private view returns (uint256 res) {
        assembly {
            let p := mload(0x40)
            mstore(p, 0x20) // Length of Base.
            mstore(add(p, 0x20), 0x20) // Length of Exponent.
            mstore(add(p, 0x40), 0x20) // Length of Modulus.
            mstore(add(p, 0x60), base) // Base.
            mstore(add(p, 0x80), exponent) // Exponent.
            mstore(add(p, 0xa0), modulus) // Modulus.
            // Call modexp precompile.
            if iszero(staticcall(gas(), 0x05, p, 0xc0, p, 0x20)) {
                revert(0, 0)
            }
            res := mload(p)
        }
    }

    function inverse(uint256 val) internal view returns (uint256) {
        return expmod(val, K_MODULUS - 2, K_MODULUS);
    }
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "PrimeFieldElement0.sol";

contract Prng is PrimeFieldElement0 {
    function storePrng(
        uint256 prngPtr,
        bytes32 digest,
        uint256 counter
    ) internal pure {
        assembly {
            mstore(prngPtr, digest)
            mstore(add(prngPtr, 0x20), counter)
        }
    }

    function loadPrng(uint256 prngPtr) internal pure returns (bytes32, uint256) {
        bytes32 digest;
        uint256 counter;

        assembly {
            digest := mload(prngPtr)
            counter := mload(add(prngPtr, 0x20))
        }

        return (digest, counter);
    }

    function initPrng(uint256 prngPtr, bytes32 publicInputHash) internal pure {
        storePrng(
            prngPtr,
            // keccak256(publicInput)
            publicInputHash,
            0
        );
    }

    /*
      Auxiliary function for getRandomBytes.
    */
    function getRandomBytesInner(bytes32 digest, uint256 counter)
        private
        pure
        returns (
            bytes32,
            uint256,
            bytes32
        )
    {
        // returns 32 bytes (for random field elements or four queries at a time).
        bytes32 randomBytes = keccak256(abi.encodePacked(digest, counter));

        return (digest, counter + 1, randomBytes);
    }

    /*
      Returns 32 bytes. Used for a random field element, or for 4 query indices.
    */
    function getRandomBytes(uint256 prngPtr) internal pure returns (bytes32 randomBytes) {
        bytes32 digest;
        uint256 counter;
        (digest, counter) = loadPrng(prngPtr);

        // returns 32 bytes (for random field elements or four queries at a time).
        (digest, counter, randomBytes) = getRandomBytesInner(digest, counter);

        storePrng(prngPtr, digest, counter);
        return randomBytes;
    }
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "PageInfo.sol";

abstract contract PublicMemoryOffsets is PageInfo {
    /*
      Returns the offset in the public input where the public memory related information starts.
      The offset is layout specific and each layout needs to override this function.
    */
    function getPublicMemoryOffset() internal pure virtual returns (uint256);

    // The format of the public input, starting at getPublicMemoryOffset() is as follows:
    //   * For each page:
    //     * First address in the page (this field is not included for the first page).
    //     * Page size.
    //     * Page hash.
    //   # All data above this line, appears in the initial seed of the proof.
    //   * For each page:
    //     * Cumulative product.
    function getOffsetPageSize(uint256 pageId) internal pure returns (uint256) {
        return getPublicMemoryOffset() + PAGE_INFO_SIZE * pageId - 1 + PAGE_INFO_SIZE_OFFSET;
    }

    function getOffsetPageHash(uint256 pageId) internal pure returns (uint256) {
        return getPublicMemoryOffset() + PAGE_INFO_SIZE * pageId - 1 + PAGE_INFO_HASH_OFFSET;
    }

    function getOffsetPageAddr(uint256 pageId) internal pure returns (uint256) {
        require(pageId >= 1, "Address of page 0 is not part of the public input.");
        return getPublicMemoryOffset() + PAGE_INFO_SIZE * pageId - 1 + PAGE_INFO_ADDRESS_OFFSET;
    }

    function getOffsetPageProd(uint256 pageId, uint256 nPages) internal pure returns (uint256) {
        return getPublicMemoryOffset() + PAGE_INFO_SIZE * nPages - 1 + pageId;
    }

    function getPublicInputLength(uint256 nPages) internal pure returns (uint256) {
        return getPublicMemoryOffset() + (PAGE_INFO_SIZE + 1) * nPages - 1;
    }
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// ---------- The following code was auto-generated. PLEASE DO NOT EDIT. ----------
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "PrimeFieldElement0.sol";

contract StarkParameters is PrimeFieldElement0 {
    uint256 constant internal N_COEFFICIENTS = 195;
    uint256 constant internal N_INTERACTION_ELEMENTS = 6;
    uint256 constant internal MASK_SIZE = 269;
    uint256 constant internal N_ROWS_IN_MASK = 191;
    uint256 constant internal N_COLUMNS_IN_MASK = 10;
    uint256 constant internal N_COLUMNS_IN_TRACE0 = 9;
    uint256 constant internal N_COLUMNS_IN_TRACE1 = 1;
    uint256 constant internal CONSTRAINTS_DEGREE_BOUND = 2;
    uint256 constant internal N_OODS_VALUES = MASK_SIZE + CONSTRAINTS_DEGREE_BOUND;
    uint256 constant internal N_OODS_COEFFICIENTS = N_OODS_VALUES;

    // ---------- // Air specific constants. ----------
    uint256 constant internal PUBLIC_MEMORY_STEP = 8;
    uint256 constant internal DILUTED_SPACING = 4;
    uint256 constant internal DILUTED_N_BITS = 16;
    uint256 constant internal PEDERSEN_BUILTIN_RATIO = 32;
    uint256 constant internal PEDERSEN_BUILTIN_REPETITIONS = 1;
    uint256 constant internal RC_BUILTIN_RATIO = 16;
    uint256 constant internal RC_N_PARTS = 8;
    uint256 constant internal ECDSA_BUILTIN_RATIO = 2048;
    uint256 constant internal ECDSA_BUILTIN_REPETITIONS = 1;
    uint256 constant internal BITWISE__RATIO = 64;
    uint256 constant internal EC_OP_BUILTIN_RATIO = 1024;
    uint256 constant internal EC_OP_SCALAR_HEIGHT = 256;
    uint256 constant internal EC_OP_N_BITS = 252;
    uint256 constant internal POSEIDON__RATIO = 32;
    uint256 constant internal POSEIDON__M = 3;
    uint256 constant internal POSEIDON__ROUNDS_FULL = 8;
    uint256 constant internal POSEIDON__ROUNDS_PARTIAL = 83;
    uint256 constant internal LAYOUT_CODE = 8319381555716711796;
    uint256 constant internal LOG_CPU_COMPONENT_HEIGHT = 4;
}
// ---------- End of auto-generated code. ----------

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "Fri.sol";
import "MemoryMap.sol";
import "MemoryAccessUtils.sol";
import "IStarkVerifier.sol";
import "VerifierChannel.sol";

abstract contract StarkVerifier is
    MemoryMap,
    MemoryAccessUtils,
    VerifierChannel,
    IStarkVerifier,
    Fri
{
    /*
      The work required to generate an invalid proof is 2^numSecurityBits.
      Typical values: 80-128.
    */
    uint256 immutable numSecurityBits;

    /*
      The secuirty of a proof is a composition of bits obtained by PoW and bits obtained by FRI
      queries. The verifier requires at least minProofOfWorkBits to be obtained by PoW.
      Typical values: 20-30.
    */
    uint256 immutable minProofOfWorkBits;
    address oodsContractAddress;

    constructor(
        uint256 numSecurityBits_,
        uint256 minProofOfWorkBits_,
        address oodsContractAddress_
    ) public {
        numSecurityBits = numSecurityBits_;
        minProofOfWorkBits = minProofOfWorkBits_;
        oodsContractAddress = oodsContractAddress_;
    }

    /*
      To print LogDebug messages from assembly use code like the following:

      assembly {
            let val := 0x1234
            mstore(0, val) // uint256 val
            // log to the LogDebug(uint256) topic
            log1(0, 0x20, 0x2feb477e5c8c82cfb95c787ed434e820b1a28fa84d68bbf5aba5367382f5581c)
      }

      Note that you can't use log in a contract that was called with staticcall
      (ContraintPoly, Oods,...)

      If logging is needed replace the staticcall to call and add a third argument of 0.
    */
    event LogBool(bool val);
    event LogDebug(uint256 val);

    function airSpecificInit(uint256[] memory publicInput)
        internal
        view
        virtual
        returns (uint256[] memory ctx, uint256 logTraceLength);

    uint256 internal constant PROOF_PARAMS_N_QUERIES_OFFSET = 0;
    uint256 internal constant PROOF_PARAMS_LOG_BLOWUP_FACTOR_OFFSET = 1;
    uint256 internal constant PROOF_PARAMS_PROOF_OF_WORK_BITS_OFFSET = 2;
    uint256 internal constant PROOF_PARAMS_FRI_LAST_LAYER_LOG_DEG_BOUND_OFFSET = 3;
    uint256 internal constant PROOF_PARAMS_N_FRI_STEPS_OFFSET = 4;
    uint256 internal constant PROOF_PARAMS_FRI_STEPS_OFFSET = 5;

    function validateFriParams(
        uint256[] memory friStepSizes,
        uint256 logTraceLength,
        uint256 logFriLastLayerDegBound
    ) internal pure {
        require(friStepSizes[0] == 0, "Only eta0 == 0 is currently supported");

        uint256 expectedLogDegBound = logFriLastLayerDegBound;
        uint256 nFriSteps = friStepSizes.length;
        for (uint256 i = 1; i < nFriSteps; i++) {
            uint256 friStepSize = friStepSizes[i];
            require(friStepSize >= FRI_MIN_STEP_SIZE, "Min supported fri step size is 2.");
            require(friStepSize <= FRI_MAX_STEP_SIZE, "Max supported fri step size is 4.");
            expectedLogDegBound += friStepSize;
        }

        // FRI starts with a polynomial of degree 'traceLength'.
        // After applying all the FRI steps we expect to get a polynomial of degree less
        // than friLastLayerDegBound.
        require(expectedLogDegBound == logTraceLength, "Fri params do not match trace length");
    }

    function initVerifierParams(uint256[] memory publicInput, uint256[] memory proofParams)
        internal
        view
        returns (uint256[] memory ctx)
    {
        require(proofParams.length > PROOF_PARAMS_FRI_STEPS_OFFSET, "Invalid proofParams.");
        require(
            proofParams.length ==
                (PROOF_PARAMS_FRI_STEPS_OFFSET + proofParams[PROOF_PARAMS_N_FRI_STEPS_OFFSET]),
            "Invalid proofParams."
        );
        uint256 logBlowupFactor = proofParams[PROOF_PARAMS_LOG_BLOWUP_FACTOR_OFFSET];
        // Ensure 'logBlowupFactor' is bounded as a sanity check (the bound is somewhat arbitrary).
        require(logBlowupFactor <= 16, "logBlowupFactor must be at most 16");
        require(logBlowupFactor >= 1, "logBlowupFactor must be at least 1");

        uint256 proofOfWorkBits = proofParams[PROOF_PARAMS_PROOF_OF_WORK_BITS_OFFSET];
        // Ensure 'proofOfWorkBits' is bounded as a sanity check (the bound is somewhat arbitrary).
        require(proofOfWorkBits <= 50, "proofOfWorkBits must be at most 50");
        require(proofOfWorkBits >= minProofOfWorkBits, "minimum proofOfWorkBits not satisfied");
        require(proofOfWorkBits < numSecurityBits, "Proofs may not be purely based on PoW.");

        uint256 logFriLastLayerDegBound = (
            proofParams[PROOF_PARAMS_FRI_LAST_LAYER_LOG_DEG_BOUND_OFFSET]
        );
        require(logFriLastLayerDegBound <= 10, "logFriLastLayerDegBound must be at most 10.");

        uint256 nFriSteps = proofParams[PROOF_PARAMS_N_FRI_STEPS_OFFSET];
        require(nFriSteps <= MAX_FRI_STEPS, "Too many fri steps.");
        require(nFriSteps > 1, "Not enough fri steps.");

        uint256[] memory friStepSizes = new uint256[](nFriSteps);
        for (uint256 i = 0; i < nFriSteps; i++) {
            friStepSizes[i] = proofParams[PROOF_PARAMS_FRI_STEPS_OFFSET + i];
        }

        uint256 logTraceLength;
        (ctx, logTraceLength) = airSpecificInit(publicInput);

        validateFriParams(friStepSizes, logTraceLength, logFriLastLayerDegBound);

        uint256 friStepSizesPtr = getPtr(ctx, MM_FRI_STEP_SIZES_PTR);
        assembly {
            mstore(friStepSizesPtr, friStepSizes)
        }
        ctx[MM_FRI_LAST_LAYER_DEG_BOUND] = 2**logFriLastLayerDegBound;
        ctx[MM_TRACE_LENGTH] = 2**logTraceLength;

        ctx[MM_BLOW_UP_FACTOR] = 2**logBlowupFactor;
        ctx[MM_PROOF_OF_WORK_BITS] = proofOfWorkBits;

        uint256 nQueries = proofParams[PROOF_PARAMS_N_QUERIES_OFFSET];
        require(nQueries > 0, "Number of queries must be at least one");
        require(nQueries <= MAX_N_QUERIES, "Too many queries.");
        require(
            nQueries * logBlowupFactor + proofOfWorkBits >= numSecurityBits,
            "Proof params do not satisfy security requirements."
        );

        ctx[MM_N_UNIQUE_QUERIES] = nQueries;

        // We start with logEvalDomainSize = logTraceSize and update it here.
        ctx[MM_LOG_EVAL_DOMAIN_SIZE] = logTraceLength + logBlowupFactor;
        ctx[MM_EVAL_DOMAIN_SIZE] = 2**ctx[MM_LOG_EVAL_DOMAIN_SIZE];

        // Compute the generators for the evaluation and trace domains.
        uint256 genEvalDomain = fpow(GENERATOR_VAL, (K_MODULUS - 1) / ctx[MM_EVAL_DOMAIN_SIZE]);
        ctx[MM_EVAL_DOMAIN_GENERATOR] = genEvalDomain;
        ctx[MM_TRACE_GENERATOR] = fpow(genEvalDomain, ctx[MM_BLOW_UP_FACTOR]);
    }

    function getPublicInputHash(uint256[] memory publicInput)
        internal
        pure
        virtual
        returns (bytes32);

    function oodsConsistencyCheck(uint256[] memory ctx) internal view virtual;

    function getNColumnsInTrace() internal pure virtual returns (uint256);

    function getNColumnsInComposition() internal pure virtual returns (uint256);

    function getMmOodsValues() internal pure virtual returns (uint256);

    function getNCoefficients() internal pure virtual returns (uint256);

    function getNOodsValues() internal pure virtual returns (uint256);

    function getNOodsCoefficients() internal pure virtual returns (uint256);

    // Interaction functions.
    // If the AIR uses interaction, the following functions should be overridden.
    function getNColumnsInTrace0() internal pure virtual returns (uint256) {
        return getNColumnsInTrace();
    }

    function getNColumnsInTrace1() internal pure virtual returns (uint256) {
        return 0;
    }

    function getMmInteractionElements() internal pure virtual returns (uint256) {
        revert("AIR does not support interaction.");
    }

    function getNInteractionElements() internal pure virtual returns (uint256) {
        revert("AIR does not support interaction.");
    }

    function hasInteraction() internal pure returns (bool) {
        return getNColumnsInTrace1() > 0;
    }

    /*
      Adjusts the query indices and generates evaluation points for each query index.
      The operations above are independent but we can save gas by combining them as both
      operations require us to iterate the queries array.

      Indices adjustment:
          The query indices adjustment is needed because both the Merkle verification and FRI
          expect queries "full binary tree in array" indices.
          The adjustment is simply adding evalDomainSize to each query.
          Note that evalDomainSize == 2^(#FRI layers) == 2^(Merkle tree hight).

      evalPoints generation:
          for each query index "idx" we compute the corresponding evaluation point:
              g^(bitReverse(idx, log_evalDomainSize).
    */
    function adjustQueryIndicesAndPrepareEvalPoints(uint256[] memory ctx) internal view {
        uint256 nUniqueQueries = ctx[MM_N_UNIQUE_QUERIES];
        uint256 friQueue = getPtr(ctx, MM_FRI_QUEUE);
        uint256 friQueueEnd = friQueue + nUniqueQueries * FRI_QUEUE_SLOT_SIZE_IN_BYTES;
        uint256 evalPointsPtr = getPtr(ctx, MM_OODS_EVAL_POINTS);
        uint256 log_evalDomainSize = ctx[MM_LOG_EVAL_DOMAIN_SIZE];
        uint256 evalDomainSize = ctx[MM_EVAL_DOMAIN_SIZE];
        uint256 evalDomainGenerator = ctx[MM_EVAL_DOMAIN_GENERATOR];

        assembly {
            /*
              Returns the bit reversal of value assuming it has the given number of bits.
              numberOfBits must be <= 64.
            */
            function bitReverse(value, numberOfBits) -> res {
                // Bit reverse value by swapping 1 bit chunks then 2 bit chunks and so forth.
                // A swap can be done by masking the relevant chunks and shifting them to the
                // correct location.
                // However, to save some shift operations we shift only one of the chunks by twice
                // the chunk size, and perform a single right shift at the end.
                res := value
                // Swap 1 bit chunks.
                res := or(shl(2, and(res, 0x5555555555555555)), and(res, 0xaaaaaaaaaaaaaaaa))
                // Swap 2 bit chunks.
                res := or(shl(4, and(res, 0x6666666666666666)), and(res, 0x19999999999999998))
                // Swap 4 bit chunks.
                res := or(shl(8, and(res, 0x7878787878787878)), and(res, 0x78787878787878780))
                // Swap 8 bit chunks.
                res := or(shl(16, and(res, 0x7f807f807f807f80)), and(res, 0x7f807f807f807f8000))
                // Swap 16 bit chunks.
                res := or(shl(32, and(res, 0x7fff80007fff8000)), and(res, 0x7fff80007fff80000000))
                // Swap 32 bit chunks.
                res := or(
                    shl(64, and(res, 0x7fffffff80000000)),
                    and(res, 0x7fffffff8000000000000000)
                )
                // Shift right the result.
                // Note that we combine two right shifts here:
                // 1. On each swap above we skip a right shift and get a left shifted result.
                //    Consequently, we need to right shift the final result by
                //    1 + 2 + 4 + 8 + 16 + 32 = 63.
                // 2. The step above computes the bit-reverse of a 64-bit input. If the goal is to
                //    bit-reverse only numberOfBits then the result needs to be right shifted by
                //    64 - numberOfBits.
                res := shr(sub(127, numberOfBits), res)
            }

            function expmod(base, exponent, modulus) -> res {
                let p := mload(0x40)
                mstore(p, 0x20) // Length of Base.
                mstore(add(p, 0x20), 0x20) // Length of Exponent.
                mstore(add(p, 0x40), 0x20) // Length of Modulus.
                mstore(add(p, 0x60), base) // Base.
                mstore(add(p, 0x80), exponent) // Exponent.
                mstore(add(p, 0xa0), modulus) // Modulus.
                // Call modexp precompile.
                if iszero(staticcall(gas(), 0x05, p, 0xc0, p, 0x20)) {
                    revert(0, 0)
                }
                res := mload(p)
            }

            for {

            } lt(friQueue, friQueueEnd) {
                friQueue := add(friQueue, FRI_QUEUE_SLOT_SIZE_IN_BYTES)
            } {
                let queryIdx := mload(friQueue)
                // Adjust queryIdx, see comment in function description.
                let adjustedQueryIdx := add(queryIdx, evalDomainSize)
                mstore(friQueue, adjustedQueryIdx)

                // Compute the evaluation point corresponding to the current queryIdx.
                mstore(
                    evalPointsPtr,
                    expmod(evalDomainGenerator, bitReverse(queryIdx, log_evalDomainSize), K_MODULUS)
                )
                evalPointsPtr := add(evalPointsPtr, 0x20)
            }
        }
    }

    /*
      Reads query responses for nColumns from the channel with the corresponding authentication
      paths. Verifies the consistency of the authentication paths with respect to the given
      merkleRoot, and stores the query values in proofDataPtr.

      nTotalColumns is the total number of columns represented in proofDataPtr (which should be
      an array of nUniqueQueries rows of size nTotalColumns). nColumns is the number of columns
      for which data will be read by this function.
      The change to the proofDataPtr array will be as follows:
      * The first nColumns cells will be set,
      * The next nTotalColumns - nColumns will be skipped,
      * The next nColumns cells will be set,
      * The next nTotalColumns - nColumns will be skipped,
      * ...

      To set the last columns for each query simply add an offset to proofDataPtr before calling the
      function.
    */
    function readQueryResponsesAndDecommit(
        uint256[] memory ctx,
        uint256 nTotalColumns,
        uint256 nColumns,
        uint256 proofDataPtr,
        bytes32 merkleRoot
    ) internal view {
        require(nColumns <= getNColumnsInTrace() + getNColumnsInComposition(), "Too many columns.");

        uint256 nUniqueQueries = ctx[MM_N_UNIQUE_QUERIES];
        uint256 channelPtr = getPtr(ctx, MM_CHANNEL);
        uint256 friQueue = getPtr(ctx, MM_FRI_QUEUE);
        uint256 friQueueEnd = friQueue + nUniqueQueries * FRI_QUEUE_SLOT_SIZE_IN_BYTES;
        uint256 merkleQueuePtr = getPtr(ctx, MM_MERKLE_QUEUE);
        uint256 rowSize = 0x20 * nColumns;
        uint256 proofDataSkipBytes = 0x20 * (nTotalColumns - nColumns);

        assembly {
            let proofPtr := mload(channelPtr)
            let merklePtr := merkleQueuePtr

            for {

            } lt(friQueue, friQueueEnd) {
                friQueue := add(friQueue, FRI_QUEUE_SLOT_SIZE_IN_BYTES)
            } {
                let merkleLeaf := and(keccak256(proofPtr, rowSize), COMMITMENT_MASK)
                if eq(rowSize, 0x20) {
                    // If a leaf contains only 1 field element we don't hash it.
                    merkleLeaf := mload(proofPtr)
                }

                // push(queryIdx, hash(row)) to merkleQueue.
                mstore(merklePtr, mload(friQueue))
                mstore(add(merklePtr, 0x20), merkleLeaf)
                merklePtr := add(merklePtr, 0x40)

                // Copy query responses to proofData array.
                // This array will be sent to the OODS contract.
                for {
                    let proofDataChunk_end := add(proofPtr, rowSize)
                } lt(proofPtr, proofDataChunk_end) {
                    proofPtr := add(proofPtr, 0x20)
                } {
                    mstore(proofDataPtr, mload(proofPtr))
                    proofDataPtr := add(proofDataPtr, 0x20)
                }
                proofDataPtr := add(proofDataPtr, proofDataSkipBytes)
            }

            mstore(channelPtr, proofPtr)
        }

        verifyMerkle(channelPtr, merkleQueuePtr, merkleRoot, nUniqueQueries);
    }

    /*
      Computes the first FRI layer by reading the query responses and calling
      the OODS contract.

      The OODS contract will build and sum boundary constraints that check that
      the prover provided the proper evaluations for the Out of Domain Sampling.

      I.e. if the prover said that f(z) = c, the first FRI layer will include
      the term (f(x) - c)/(x-z).
    */
    function computeFirstFriLayer(uint256[] memory ctx) internal view {
        adjustQueryIndicesAndPrepareEvalPoints(ctx);
        readQueryResponsesAndDecommit(
            ctx,
            getNColumnsInTrace(),
            getNColumnsInTrace0(),
            getPtr(ctx, MM_TRACE_QUERY_RESPONSES),
            bytes32(ctx[MM_TRACE_COMMITMENT])
        );
        if (hasInteraction()) {
            readQueryResponsesAndDecommit(
                ctx,
                getNColumnsInTrace(),
                getNColumnsInTrace1(),
                getPtr(ctx, MM_TRACE_QUERY_RESPONSES + getNColumnsInTrace0()),
                bytes32(ctx[MM_TRACE_COMMITMENT + 1])
            );
        }

        readQueryResponsesAndDecommit(
            ctx,
            getNColumnsInComposition(),
            getNColumnsInComposition(),
            getPtr(ctx, MM_COMPOSITION_QUERY_RESPONSES),
            bytes32(ctx[MM_OODS_COMMITMENT])
        );

        address oodsAddress = oodsContractAddress;
        uint256 friQueue = getPtr(ctx, MM_FRI_QUEUE);
        uint256 returnDataSize = MAX_N_QUERIES * FRI_QUEUE_SLOT_SIZE_IN_BYTES;
        assembly {
            // Call the OODS contract.
            if iszero(
                staticcall(
                    not(0),
                    oodsAddress,
                    ctx,
                    mul(add(mload(ctx), 1), 0x20), /*sizeof(ctx)*/
                    friQueue,
                    returnDataSize
                )
            ) {
                returndatacopy(0, 0, returndatasize())
                revert(0, returndatasize())
            }
        }
    }

    /*
      Reads the last FRI layer (i.e. the polynomial's coefficients) from the channel.
      This differs from standard reading of channel field elements in several ways:
      -- The digest is updated by hashing it once with all coefficients simultaneously, rather than
         iteratively one by one.
      -- The coefficients are kept in Montgomery form, as is the case throughout the FRI
         computation.
      -- The coefficients are not actually read and copied elsewhere, but rather only a pointer to
         their location in the channel is stored.
    */
    function readLastFriLayer(uint256[] memory ctx) internal pure {
        uint256 lmmChannel = MM_CHANNEL;
        uint256 friLastLayerDegBound = ctx[MM_FRI_LAST_LAYER_DEG_BOUND];
        uint256 lastLayerPtr;
        uint256 badInput = 0;

        assembly {
            let primeMinusOne := 0x800000000000011000000000000000000000000000000000000000000000000
            let channelPtr := add(add(ctx, 0x20), mul(lmmChannel, 0x20))
            lastLayerPtr := mload(channelPtr)

            // Make sure all the values are valid field elements.
            let length := mul(friLastLayerDegBound, 0x20)
            let lastLayerEnd := add(lastLayerPtr, length)
            for {
                let coefsPtr := lastLayerPtr
            } lt(coefsPtr, lastLayerEnd) {
                coefsPtr := add(coefsPtr, 0x20)
            } {
                badInput := or(badInput, gt(mload(coefsPtr), primeMinusOne))
            }

            // Update prng.digest with the hash of digest + 1 and the last layer coefficient.
            // (digest + 1) is written to the proof area because keccak256 needs all data to be
            // consecutive.
            let newDigestPtr := sub(lastLayerPtr, 0x20)
            let digestPtr := add(channelPtr, 0x20)
            // Overwriting the proof to minimize copying of data.
            mstore(newDigestPtr, add(mload(digestPtr), 1))

            // prng.digest := keccak256((digest+1)||lastLayerCoefs).
            mstore(digestPtr, keccak256(newDigestPtr, add(length, 0x20)))
            // prng.counter := 0.
            mstore(add(channelPtr, 0x40), 0)

            // Note: proof pointer is not incremented until this point.
            mstore(channelPtr, lastLayerEnd)
        }

        require(badInput == 0, "Invalid field element.");
        ctx[MM_FRI_LAST_LAYER_PTR] = lastLayerPtr;
    }

    function verifyProof(
        uint256[] memory proofParams,
        uint256[] memory proof,
        uint256[] memory publicInput
    ) internal view override {
        uint256[] memory ctx = initVerifierParams(publicInput, proofParams);
        uint256 channelPtr = getChannelPtr(ctx);

        initChannel(channelPtr, getProofPtr(proof), getPublicInputHash(publicInput));
        // Read trace commitment.
        ctx[MM_TRACE_COMMITMENT] = uint256(readHash(channelPtr, true));

        if (hasInteraction()) {
            // Send interaction elements.
            VerifierChannel.sendFieldElements(
                channelPtr,
                getNInteractionElements(),
                getPtr(ctx, getMmInteractionElements())
            );

            // Read second trace commitment.
            ctx[MM_TRACE_COMMITMENT + 1] = uint256(readHash(channelPtr, true));
        }

        // Send constraint polynomial random element.
        VerifierChannel.sendFieldElements(channelPtr, 1, getPtr(ctx, MM_COMPOSITION_ALPHA));
        ctx[MM_OODS_COMMITMENT] = uint256(readHash(channelPtr, true));

        // Send Out of Domain Sampling point.
        VerifierChannel.sendFieldElements(channelPtr, 1, getPtr(ctx, MM_OODS_POINT));

        // Read the answers to the Out of Domain Sampling.
        uint256 lmmOodsValues = getMmOodsValues();
        for (uint256 i = lmmOodsValues; i < lmmOodsValues + getNOodsValues(); i++) {
            ctx[i] = VerifierChannel.readFieldElement(channelPtr, true);
        }
        oodsConsistencyCheck(ctx);
        VerifierChannel.sendFieldElements(channelPtr, 1, getPtr(ctx, MM_OODS_ALPHA));
        ctx[MM_FRI_COMMITMENTS] = uint256(VerifierChannel.readHash(channelPtr, true));

        uint256 nFriSteps = getFriStepSizes(ctx).length;
        uint256 fri_evalPointPtr = getPtr(ctx, MM_FRI_EVAL_POINTS);
        for (uint256 i = 1; i < nFriSteps - 1; i++) {
            VerifierChannel.sendFieldElements(channelPtr, 1, fri_evalPointPtr + i * 0x20);
            ctx[MM_FRI_COMMITMENTS + i] = uint256(VerifierChannel.readHash(channelPtr, true));
        }

        // Send last random FRI evaluation point.
        VerifierChannel.sendFieldElements(
            channelPtr,
            1,
            getPtr(ctx, MM_FRI_EVAL_POINTS + nFriSteps - 1)
        );

        // Read FRI last layer commitment.
        readLastFriLayer(ctx);

        // Generate queries.
        // emit LogGas("Read FRI commitments", gasleft());
        VerifierChannel.verifyProofOfWork(channelPtr, ctx[MM_PROOF_OF_WORK_BITS]);
        ctx[MM_N_UNIQUE_QUERIES] = VerifierChannel.sendRandomQueries(
            channelPtr,
            ctx[MM_N_UNIQUE_QUERIES],
            ctx[MM_EVAL_DOMAIN_SIZE] - 1,
            getPtr(ctx, MM_FRI_QUEUE),
            FRI_QUEUE_SLOT_SIZE_IN_BYTES
        );
        computeFirstFriLayer(ctx);

        friVerifyLayers(ctx);
    }
}

/*
  Copyright 2019-2022 StarkWare Industries Ltd.

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

  https://www.starkware.co/open-source-license/

  Unless required by applicable law or agreed to in writing,
  software distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions
  and limitations under the License.
*/
// SPDX-License-Identifier: Apache-2.0.
pragma solidity ^0.6.12;

import "Prng.sol";

/*
  Implements the communication channel from the verifier to the prover in the non-interactive case
  (See the BCS16 paper for more details).

  The state of the channel is stored in a uint256[3] as follows:
    [0] proof pointer.
    [1] prng digest.
    [2] prng counter.
*/
contract VerifierChannel is Prng {
    event LogValue(bytes32 val);

    event SendRandomnessEvent(uint256 val);

    event ReadFieldElementEvent(uint256 val);

    event ReadHashEvent(bytes32 val);

    function getPrngPtr(uint256 channelPtr) internal pure returns (uint256) {
        return channelPtr + 0x20;
    }

    function initChannel(
        uint256 channelPtr,
        uint256 proofPtr,
        bytes32 publicInputHash
    ) internal pure {
        assembly {
            // Skip 0x20 bytes length at the beginning of the proof.
            mstore(channelPtr, add(proofPtr, 0x20))
        }

        initPrng(getPrngPtr(channelPtr), publicInputHash);
    }

    /*
      Sends a field element through the verifier channel.

      Note that the logic of this function is inlined in many places throughout the code to reduce
      gas costs.
    */
    function sendFieldElements(
        uint256 channelPtr,
        uint256 nElements,
        uint256 targetPtr
    ) internal pure {
        require(nElements < 0x1000000, "Overflow protection failed.");
        assembly {
            // 31 * PRIME.
            let BOUND := 0xf80000000000020f00000000000000000000000000000000000000000000001f
            let digestPtr := add(channelPtr, 0x20)
            let counterPtr := add(channelPtr, 0x40)

            let endPtr := add(targetPtr, mul(nElements, 0x20))
            for {

            } lt(targetPtr, endPtr) {
                targetPtr := add(targetPtr, 0x20)
            } {
                // *targetPtr = getRandomFieldElement(getPrngPtr(channelPtr));

                let fieldElement := BOUND
                // while (fieldElement >= 31 * K_MODULUS).
                for {

                } iszero(lt(fieldElement, BOUND)) {

                } {
                    // keccak256(abi.encodePacked(digest, counter));
                    fieldElement := keccak256(digestPtr, 0x40)
                    // *counterPtr += 1;
                    mstore(counterPtr, add(mload(counterPtr), 1))
                }
                // *targetPtr = fromMontgomery(fieldElement);
                mstore(targetPtr, mulmod(fieldElement, K_MONTGOMERY_R_INV, K_MODULUS))
            }
        }
    }

    /*
      Sends random queries and returns an array of queries sorted in ascending order.
      Generates count queries in the range [0, mask] and returns the number of unique queries.
      Note that mask is of the form 2^k-1 (for some k <= 64).

      Note that queriesOutPtr may be (and is) interleaved with other arrays. The stride parameter
      is passed to indicate the distance between every two entries in the queries array, i.e.
      stride = 0x20*(number of interleaved arrays).
    */
    function sendRandomQueries(
        uint256 channelPtr,
        uint256 count,
        uint256 mask,
        uint256 queriesOutPtr,
        uint256 stride
    ) internal pure returns (uint256) {
        require(mask < 2**64, "mask must be < 2**64.");

        uint256 val;
        uint256 shift = 0;
        uint256 endPtr = queriesOutPtr;
        for (uint256 i = 0; i < count; i++) {
            if (shift == 0) {
                val = uint256(getRandomBytes(getPrngPtr(channelPtr)));
                shift = 0x100;
            }
            shift -= 0x40;
            uint256 queryIdx = (val >> shift) & mask;
            uint256 ptr = endPtr;

            // Initialize 'curr' to -1 to make sure the condition 'queryIdx != curr' is satisfied
            // on the first iteration.
            uint256 curr = uint256(-1);

            // Insert new queryIdx in the correct place like insertion sort.
            while (ptr > queriesOutPtr) {
                assembly {
                    curr := mload(sub(ptr, stride))
                }

                if (queryIdx >= curr) {
                    break;
                }

                assembly {
                    mstore(ptr, curr)
                }
                ptr -= stride;
            }

            if (queryIdx != curr) {
                assembly {
                    mstore(ptr, queryIdx)
                }
                endPtr += stride;
            } else {
                // Revert right shuffling.
                while (ptr < endPtr) {
                    assembly {
                        mstore(ptr, mload(add(ptr, stride)))
                        ptr := add(ptr, stride)
                    }
                }
            }
        }

        return (endPtr - queriesOutPtr) / stride;
    }

    function readBytes(uint256 channelPtr, bool mix) internal pure returns (bytes32) {
        uint256 proofPtr;
        bytes32 val;

        assembly {
            proofPtr := mload(channelPtr)
            val := mload(proofPtr)
            mstore(channelPtr, add(proofPtr, 0x20))
        }
        if (mix) {
            // Mix the bytes that were read into the state of the channel.
            assembly {
                let digestPtr := add(channelPtr, 0x20)
                let counterPtr := add(digestPtr, 0x20)

                // digest += 1.
                mstore(digestPtr, add(mload(digestPtr), 1))
                mstore(counterPtr, val)
                // prng.digest := keccak256(digest + 1||val), nonce was written earlier.
                mstore(digestPtr, keccak256(digestPtr, 0x40))
                // prng.counter := 0.
                mstore(counterPtr, 0)
            }
        }

        return val;
    }

    function readHash(uint256 channelPtr, bool mix) internal pure returns (bytes32) {
        bytes32 val = readBytes(channelPtr, mix);
        return val;
    }

    /*
      Reads a field element from the verifier channel (that is, the proof in the non-interactive
      case).
      The field elements on the channel are in Montgomery form and this function converts
      them to the standard representation.

      Note that the logic of this function is inlined in many places throughout the code to reduce
      gas costs.
    */
    function readFieldElement(uint256 channelPtr, bool mix) internal pure returns (uint256) {
        uint256 val = fromMontgomery(uint256(readBytes(channelPtr, mix)));

        return val;
    }

    function verifyProofOfWork(uint256 channelPtr, uint256 proofOfWorkBits) internal pure {
        if (proofOfWorkBits == 0) {
            return;
        }

        uint256 proofOfWorkDigest;
        assembly {
            // [0:0x29) := 0123456789abcded || digest     || workBits.
            //             8 bytes          || 0x20 bytes || 1 byte.
            mstore(0, 0x0123456789abcded000000000000000000000000000000000000000000000000)
            let digest := mload(add(channelPtr, 0x20))
            mstore(0x8, digest)
            mstore8(0x28, proofOfWorkBits)
            mstore(0, keccak256(0, 0x29))

            let proofPtr := mload(channelPtr)
            mstore(0x20, mload(proofPtr))
            // proofOfWorkDigest:= keccak256(keccak256(0123456789abcded || digest || workBits) || nonce).
            proofOfWorkDigest := keccak256(0, 0x28)

            mstore(0, add(digest, 1))
            // prng.digest := keccak256(digest + 1||nonce), nonce was written earlier.
            mstore(add(channelPtr, 0x20), keccak256(0, 0x28))
            // prng.counter := 0.
            mstore(add(channelPtr, 0x40), 0)

            mstore(channelPtr, add(proofPtr, 0x8))
        }

        uint256 proofOfWorkThreshold = uint256(1) << (256 - proofOfWorkBits);
        require(proofOfWorkDigest < proofOfWorkThreshold, "Proof of work check failed.");
    }
}