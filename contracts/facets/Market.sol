// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "../../lib/chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "../../lib/openzeppelin-contracts/contracts/utils/math/SafeCast.sol";
import "../../contracts/libraries/AppStorage.sol";
contract Market {
     using SafeCast for int256;
    AppStorage internal s;

constructor(){}
function listItem(uint _tokenitemID) public {
    ItemDetails storage _a = s.itemInfo[_tokenitemID];
    _a.tokenID = _tokenitemID;
    _a.seller = msg.sender;
    _a.status = true;
}
function purchaseItem(uint _tokenID, Option _token) public payable{
    if(_token == Option.dai){
    uint balance = (s.DaiContract).balanceOf(msg.sender);
    address _seller = s.itemInfo[_tokenID].seller;
    require(s.itemInfo[_tokenID].status == true, "not for sale");
    require(balance >= 3.5 ether);
    uint ethusdCurrentPrice = getETHUSDPrice();
    uint daiusdCurrentPrice = getDAIUSDPrice();
    uint _amountindai = (3.5 ether * ethusdCurrentPrice)/daiusdCurrentPrice;
    s.DaiContract.transferFrom(msg.sender, _seller, _amountindai);
    s.nftAddress.transferFrom(s.owner, msg.sender, _tokenID);
    }else if(_token == Option.usdc){
    uint balance = (s.USDCContract).balanceOf(msg.sender);
    address _seller = s.itemInfo[_tokenID].seller;
    require(s.itemInfo[_tokenID].status == true, "not for sale");
    require(balance >= (3.5 ether/1e6), "not enough balance");
    uint ethusdCurrentPrice = getETHUSDPrice();
    uint usdcusdCurrentPrice = getUSDCUSDPrice();
    uint _amountinusdc = ((3.5 ether * ethusdCurrentPrice)/usdcusdCurrentPrice);
    s.USDCContract.transferFrom(msg.sender, _seller, _amountinusdc);
    s.nftAddress.transferFrom(s.owner, msg.sender, _tokenID);
    }
 }


function getDAIUSDPrice() public view returns (uint) {
        ( , int price, , , ) = s.DAIusdpriceFeed.latestRoundData();
        return price.toUint256();
    }
function getETHUSDPrice() public view returns (uint) {
        ( , int price, , , ) = s.ETHusdpriceFeed.latestRoundData();
        return price.toUint256();
    }
function getUSDCUSDPrice() public view returns (uint) {
        ( , int price, , , ) = s.USDCusdpriceFeed.latestRoundData();

        return (price*1e18).toUint256();
    }

}


