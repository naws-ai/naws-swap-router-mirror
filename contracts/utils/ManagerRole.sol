// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >= 0.7.6;

import {Roles} from "../libraries/Roles.sol";

contract ManagerRole {
    using Roles for Roles.Role;

    Roles.Role private managers;

    event ManagerAdded(address indexed account);
    event ManagerRemoved(address indexed account);

    modifier onlyManager() {
        require(managers.has(msg.sender), "ManagerRole: caller does not have the Manager role");
        _;
    }

    constructor() public {
        managers.add(msg.sender);
    }

    function addManager(address account) public onlyManager {
        managers.add(account);
        emit ManagerAdded(account);
    }

    function removeManager(address account) public onlyManager {
        managers.remove(account);
        emit ManagerRemoved(account);
    }

    function isManager(address account) public view returns (bool) {
        return managers.has(account);
    }
}
