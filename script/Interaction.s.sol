// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "../lib/forge-std/src/Script.sol";
import {DevOpsTools} from "../lib/forge-std/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";


contract FundFundMe is Script {

    function fundFundMe(addres mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe( payable(mostRecentDeployed) ).fund{value: 5e18}();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployement("FundMe", block.chainid);
        FundFundMe(mostRecentDeployed);
    }
}

contract WithdrawFundMe is Script {

    function withdrawFundMe(addres mostRecentDeployed) public {
        vm.startBroadcast();
        FundMe( payable(mostRecentDeployed) ).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentDeployed = DevOpsTools.get_most_recent_deployement("FundMe", block.chainid);
        WithdrawFundMe(mostRecentDeployed);
    }
}