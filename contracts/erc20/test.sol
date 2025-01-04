// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC20Training} from "./ERC20Training.sol";

contract test is ERC20Training {
    constructor() ERC20Training("aaa", "KDK"){}

}