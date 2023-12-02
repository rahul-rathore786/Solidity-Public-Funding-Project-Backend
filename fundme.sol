
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./priceConverter.sol";


contract FundMe{
    using PriceConverter for uint256;
    uint256 public constant minVal = 50* 1e18;
    address[] public funders;
    mapping (address => uint256) public addressToAmountFunded;

    address public immutable owner;

    constructor(){
        owner = msg.sender; // store address of the contracts owner
    }
// function to recieve fund 
    function fund() public payable {

        require(msg.value.getConversionRate() >= minVal, "Send minimum amount 50 USD");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

// function to withdraw fund ( only owner can withdraw 
    function withdraw() public onlyOwner {

    for(uint256 funderInd = 0; funderInd < funders.length; funderInd++){
       address funder =  funders[funderInd];
       addressToAmountFunded[funder] =0;
    }
    
    funders = new address[](0);
    // method 1) transfer
    // payable (msg.sender).transfer(address(this).balance);

    // method 2) send 
     // bool status = payable (msg.sender).send(address(this).balance);

    // method 3) call
    (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    modifier onlyOwner {
        require(msg.sender == owner, "Sender is not a owner");
        _;
    }

    receive() external payable { 
       fund();
    }
    fallback() external payable { 
        fund();
    }

}
