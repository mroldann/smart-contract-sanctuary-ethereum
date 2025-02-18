// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.11;

contract BaseV2GaugeFactoryInterface {
    bool public isBoostPaused;

    function childInterfaceAddress()
        external
        view
        returns (address _childInterface)
    {}

    function childSubImplementationAddress()
        external
        view
        returns (address _childSubImplementation)
    {}

    function createGauge(
        address _pool,
        address _bribe,
        address _ve
    ) external returns (address lastGauge) {}

    function governanceAddress()
        external
        view
        returns (address _governanceAddress)
    {}

    function interfaceSourceAddress() external view returns (address) {}

    function setBoostPaused(bool _state) external {}

    function updateChildInterfaceAddress(address _childInterfaceAddress)
        external
    {}

    function updateChildSubImplementationAddress(
        address _childSubImplementationAddress
    ) external {}
}