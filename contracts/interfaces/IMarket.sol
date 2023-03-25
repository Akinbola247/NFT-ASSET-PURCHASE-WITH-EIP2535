// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IMarket {
enum Option {dai, usdc}
function listItem(uint _tokenitemID ) external;
function purchaseItem(uint _tokenID, Option _token) external payable;
}