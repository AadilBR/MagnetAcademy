//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./SchoolMagnet.sol";

contract MagnetAcademy is AccessControl{
    using Counters for Counters.Counter;

    bytes32 public constant RECTOR = keccak256("RECTOR");
    bytes32 public constant ADMIN = keccak256("ADMIN");
    Counters.Counter private _nbSchools;
    address private _rector;
    mapping(address => address) private _schoolDirectors; // director to school
    mapping(address => address) private _schools; // school to director

    event SchoolCreated(address indexed schoolAddress, address indexed directorAddress, string name);
    event SchoolDeleted(address indexed schoolAddress, address indexed directorAddress);
    event DirectorSet(address indexed directorAddress, address indexed schoolAddress);


    modifier OnlySchoolDirector(address account) {
        require(_schoolDirectors[account] != address(0), "MagnetAcademy: Not a school director");
        _;
    }

    modifier OnlyNotSchoolDirector(address account) {
        require(_schoolDirectors[account] == address(0), "MagnetAcademy: Already a school director");
        _;
    }

    modifier OnlySchoolAddress(address addr) {
        require(_schools[addr] != address(0), "MagnetAcademy: Only for created schools");
        _;
    }

    constructor(address rector_) {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);

        _setRoleAdmin(ADMIN, RECTOR);
        
        _rector = rector_;
        _setupRole(RECTOR, rector_);
    }

    function changeSchoolDirector(address oldDirector, address newDirector)
        public
        onlyRole(ADMIN)
        OnlySchoolDirector(oldDirector)
        OnlyNotSchoolDirector(newDirector)
        returns (bool)
    {
        address schoolAddress = _schoolDirectors[oldDirector];
        _schoolDirectors[oldDirector] = address(0);
        _schoolDirectors[newDirector] = schoolAddress;
        _schools[schoolAddress] = newDirector;
        emit DirectorSet(newDirector, schoolAddress);
        return true;
    }

    function createSchool(string memory name, address directorAddress)
        public
        onlyRole(ADMIN)
        OnlyNotSchoolDirector(directorAddress)
        returns (bool)
    {
        SchoolMagnet school = new SchoolMagnet(directorAddress, name);
        _schoolDirectors[directorAddress] = address(school);
        _schools[address(school)] = directorAddress;
        emit DirectorSet(directorAddress, address(school));
        _nbSchools.increment();
        emit SchoolCreated(address(school), directorAddress, name);
        return true;
    }

    function deleteSchool(address schoolAddress) public onlyRole(ADMIN) OnlySchoolAddress(schoolAddress) returns (bool) {
        address directorAddress = _schools[schoolAddress];
        _schools[schoolAddress] = address(0);
        _schoolDirectors[directorAddress] = address(0);
        _nbSchools.decrement();
        emit SchoolDeleted(schoolAddress, directorAddress);
        return true;
    }

    function nbSchools() public view returns (uint256) {
        return _nbSchools.current();
    }

    function schoolOf(address account) public view returns (address) {
        return _schoolDirectors[account];
    }

    function directorOf(address school) public view returns (address) {
        return _schools[school];
    }

    function rector() public view returns (address) {
        return _rector;
    }

    function isAdmin(address account) public view returns (bool) {
        return hasRole(ADMIN, account);
    }

    function isDirector(address account) public view returns (bool) {
        return _schoolDirectors[account] != address(0);
    }

    function isSchool(address addr) public view returns (bool) {
        return _schools[addr] != address(0);
    }
}
