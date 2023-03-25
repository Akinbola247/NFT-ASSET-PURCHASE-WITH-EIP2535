// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "forge-std/Script.sol";
import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/Diamond.sol";
import "../contracts/KZN.sol";
import "../contracts/facets/Market.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../contracts/upgradeInitializers/DiamondInit.sol";
contract MarketScript is Script, IDiamondCut {
    // Diamond diamond;
    // DiamondCutFacet dCutFacet;
    // DiamondLoupeFacet dLoupe;
    // OwnershipFacet ownerF;
    // Market marketF;
    // NFT kzn;
    // DiamondInit init;

       address dCutFacet = 0xb36d8D7293FC6677c6e2bd0B1be3aD8B32C48CF9;
       address kzn = 0x2C29556D276963C0edB28dFdCED0cE846F00eb53;
       address diamond = 0x1Ad703e4605984A20171A4dB0a4231E4BA3458f1;
       address dLoupe = 0x5EA90F87dD15dfE255119AA2Aca1574f41BD207E;
       address ownerF = 0x989479FF00c1635843380c4a9317681de826A77E;
       address marketF = 0x8b88fFDCcCc066F5CEbfcA705929eD4926368Aa7;
        address init = 0x3593dfd4Ea11d0b10ec7C823beAf76A3937CD756;

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        // dCutFacet = new DiamondCutFacet();
        // kzn = new NFT();
        // diamond = new Diamond(address(0x9B69F998b2a2b20FF54a575Bd5fB90A5D71656C1), address(dCutFacet), IERC721(kzn));
        // dLoupe = new DiamondLoupeFacet();
        // ownerF = new OwnershipFacet();
        // marketF = new Market();
        // init = new DiamondInit();
       
        
        FacetCut[] memory cut = new FacetCut[](3);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            FacetCut({
                facetAddress: address(marketF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("Market")
            })
        );

        // upgrade diamond
        bytes memory _calldata = abi.encodeWithSignature("init()");
        IDiamondCut(address(diamond)).diamondCut(cut, address(init), _calldata);

        // call a function
        IDiamondLoupe(address(diamond)).facetAddresses();
        DiamondLoupeFacet(address(diamond)).facetAddresses();
        
        
        vm.stopBroadcast();
//         // vm.broadcast();
    }
function generateSelectors (string memory _facetName)
        internal
        returns (bytes4[] memory selectors)
    {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }
 function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}