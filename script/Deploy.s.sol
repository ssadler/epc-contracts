// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
 
import {Script, console} from "forge-std/Script.sol";
import {Vm, VmSafe} from "forge-std/Vm.sol";

import '@diamond-3-hardhat/interfaces/IDiamondCut.sol';
import '@solady/utils/LibString.sol';

import {AuthProxy} from "../src/AuthProxy.sol";
import {EPCMint} from "../src/Mint.sol";
import {EPCAdmin} from "../src/Admin.sol";
import {EPCRouter} from "../src/Router.sol";



contract DeployEPC is Script {
  EPCRouter public _router;
 
  function setUp() public {}
 
  function run() public {
    vm.startBroadcast();

    /*
     * Get proxy from env or deploy it
     */
    AuthProxy proxy = AuthProxy(vm.envAddress("AUTHPROXY_ADDRESS"));
    if (address(proxy) == address(0)) {
      proxy = new AuthProxy();
    }

    /*
     * Deploy Router
     */
    _router = new EPCRouter();

    /*
     * Deploy Admin facet
     */
    EPCAdmin admin = new EPCAdmin();
    addFacet("EPCAdmin", address(admin));

    /*
     * Deploy Mint facet
     */
    EPCMint mint = new EPCMint(proxy);
    addFacet("EPCMint", address(mint));

    /*
     * Test Mint
     */
    EPCMint(address(_router)).sanityTest();

    vm.stopBroadcast();
  }


  function addFacet(string memory contractName, address facet) internal {

    IDiamondCut.FacetCut[] memory cuts = new IDiamondCut.FacetCut[](1);
    createAddFacetsCut(vm, cuts[0], contractName, facet);

    _router.diamondCut(cuts, address(0), "");

  }
}

function createAddFacetsCut(Vm vm, IDiamondCut.FacetCut memory cut, string memory contractName, address facet) {
  string[] memory cmd = new string[](3);
  cmd[0] = "./manage.sh";
  cmd[1] = "facetMethodIds";
  cmd[2] = contractName;
  bytes memory selectorBytes = vm.ffi(cmd);

  cut.facetAddress = facet;
  cut.action = IDiamondCut.FacetCutAction.Add;
  cut.functionSelectors = abi.decode(selectorBytes, (bytes4[]));
}

function createRemoveFacetsCut(Vm vm, IDiamondCut.FacetCut memory cut, string memory facetsEnv) view {
  bytes memory selectorBytes = vm.envBytes(facetsEnv);

  cut.action = IDiamondCut.FacetCutAction.Remove;
  cut.functionSelectors = abi.decode(selectorBytes, (bytes4[]));
}
