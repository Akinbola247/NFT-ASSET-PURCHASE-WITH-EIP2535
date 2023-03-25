// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../../lib/forge-std/src/Test.sol";
import "../contracts/Diamond.sol";
import "../contracts/KZN.sol";
import "../contracts/facets/Market.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/interfaces/IMarket.sol";

contract DiamondDeployer is Test, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    Market marketF;
    NFT kzn;
    IERC20 daiContract;
    IERC20 usdcContract;


    function testDeployDiamond() public {
        vm.startPrank(0xBB9F947cB5b21292DE59EFB0b1e158e90859dddb);
        uint mainnet = vm.createFork("https://eth-mainnet.g.alchemy.com/v2/xypdsCZYrlk6oNi93UmpUzKE9kmxHy2n", 16903702);
        vm.selectFork(mainnet);
        //deploy facets
        dCutFacet = new DiamondCutFacet();
        kzn = new NFT();
        diamond = new Diamond(address(0xBB9F947cB5b21292DE59EFB0b1e158e90859dddb), address(dCutFacet), IERC721(kzn));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        marketF = new Market();
        daiContract = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        usdcContract = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);


        //upgrade diamond with facets

        //build cut struct
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

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        //call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();
        vm.stopPrank();
    }

    
    function testMint() public {
    testDeployDiamond();
    vm.startPrank(0xBB9F947cB5b21292DE59EFB0b1e158e90859dddb);
    kzn.safeMint("https://ipfs.filebase.io/ipfs/QmYqEcCNJiP7pP2nzSsvyv7Ji1tNpv6omWMJ4Nph22dmfn", address(diamond));
    IMarket(address(diamond)).listItem(0);
    vm.stopPrank();
}
function testPurchaseItemWithDai() public {
    testMint(); 
    vm.startPrank(0x748dE14197922c4Ae258c7939C7739f3ff1db573);
    daiContract.approve(address(diamond), 35000000000000000000000000000000000000000000000000000);
    IMarket(address(diamond)).purchaseItem(0, IMarket.Option(0));
    uint balance = daiContract.balanceOf(address(0xBB9F947cB5b21292DE59EFB0b1e158e90859dddb));
    console.log(balance);
    vm.stopPrank();
}
function testPurchaseItemWithUSDC() public {
    testMint(); 
    vm.startPrank(0x99Dcb7939231f4Ad9aB89f6330a3176bE981dD29);
    usdcContract.approve(address(diamond), 35000000000000000000000000000000000000000000000000000);
    IMarket(address(diamond)).purchaseItem(0, IMarket.Option(1));
    uint balance = usdcContract.balanceOf(address(0xBB9F947cB5b21292DE59EFB0b1e158e90859dddb));
    console.log(balance);
    vm.stopPrank();
}
    function generateSelectors(string memory _facetName)
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
