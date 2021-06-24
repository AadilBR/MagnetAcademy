//SPDX-License-Identifier: Unlicense
/*
NOT FINISHED YET
*/

pragma solidity ^0.8.0;

contract SchoolMagnet {
    address private _director;
    string private _name;

    constructor(address director_, string memory name_) {
        _director = director_;
        _name = name_;
    }

    function director() public view returns (address) {
        return _director;
    }

    function name() public view returns (string memory) {
        return _name;
    }
}
