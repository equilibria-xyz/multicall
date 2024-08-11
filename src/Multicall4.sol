// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import { Multicall3 } from "./Multicall3.sol";

/// @title Multicall4
/// @notice Extension of Multicall3 with additional hooks to drain non-deterministally obtained tokens during execution
contract Multicall4 is Multicall3 {
    /// @notice Send the full ether balance to the sender
    /// @dev Used to sweep any non-deterministically obtained ether during the course of aggregate execution
    function drain() external payable {
        payable(msg.sender).transfer(address(this).balance);
    }

    /// @notice Send the full balance of `token` to the sender
    /// @dev Used to sweep any non-deterministically obtained tokens during the course of aggregate execution
    function drain(IERC20 token) external payable {
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
}
