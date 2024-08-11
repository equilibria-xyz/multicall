// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import { Test } from "forge-std/Test.sol";
import { Multicall4, IERC20 } from "../Multicall4.sol";
import "forge-std/console.sol";

contract Multicall4Test is Test {
  IERC20 mockToken = IERC20(makeAddr("mockToken"));
  Multicall4 multicall;

  /// @notice Setups up the testing suite
  function setUp() public {
    multicall = new Multicall4();
  }

  /// >>>>>>>>>>>>>>>>>>>>>  DRAIN TESTS  <<<<<<<<<<<<<<<<<<<<< ///

  function testDrain() public {
    vm.deal(address(this), 1 ether);

    Multicall4.Call[] memory noop;
    multicall.aggregate{value: 1 ether}(noop);
    assertEq(address(multicall).balance, 1 ether);

    multicall.drain();

    assertEq(address(multicall).balance, 0);
    assertEq(address(this).balance, 1 ether);
  }

  function testDrainToken() public {
    vm.mockCall(
        address(mockToken),
        abi.encodeWithSelector(IERC20.balanceOf.selector, address(multicall)),
        abi.encode(1 ether)
    );
    vm.mockCall(
        address(mockToken),
        abi.encodeWithSelector(IERC20.transfer.selector, address(this), 1 ether),
        abi.encode(true)
    );

    vm.expectCall(
      address(mockToken), 0, abi.encodeWithSelector(IERC20.balanceOf.selector, address(multicall))
    );
    vm.expectCall(
      address(mockToken), 0, abi.encodeWithSelector(IERC20.transfer.selector, address(this), 1 ether)
    );

    multicall.drain(mockToken);
  }

  receive() external payable { }
}
