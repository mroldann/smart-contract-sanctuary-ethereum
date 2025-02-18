// Black & White
// Twitter: https://twitter.com/blackwhite_nft
// Opensea: https://opensea.io/collection/black-white

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./ERC721A.sol";
import "./Ownable.sol";

contract BlackAndWhite is ERC721A, Ownable {
    using Strings for uint256;
    uint256 public maxSupply = 10000;
    uint256 public price = 0;
    uint256 public maxPerTx = 4;
    uint256 public maxPerWallet = 20;
    uint256 public maxFreePerWallet = 4;
    uint256 public maxFreeAmount = 2000;
    string public baseURI;

    constructor() ERC721A("Black and White", "Black & White") {}

    function publicMint(uint256 quantity) external payable {
        require(totalSupply() + quantity < maxSupply + 1, "No more");
        uint256 cost = getPrice();
        uint256 _maxPerWallet = maxPerWallet;
        if (cost == 0) {
            _maxPerWallet = 4;
        }
        require(
            _numberMinted(msg.sender) + quantity <= _maxPerWallet,
            "Max per wallet"
        );
        require(msg.value >= quantity * cost, "Please send the exact amount.");
        _safeMint(msg.sender, quantity);
    }

    // set a variable price throughout mint
    // tokens 0 - 2000 ~~~~~~~~~~~~~ free
    // tokens 2001 - 4000 ~~~~~~~~~~ .001 eth
    // tokens 4001 - 6000 ~~~~~~~~~~ .002 eth
    // tokens 6001 -8000 ~~~~~~~~~~~ .003 eth
    // tokens 8001 - 9999 ~~~~~~~~~~ .004 eth

    function getPrice() public view returns (uint256) {
        uint256 minted = totalSupply();
        uint256 cost = 0;
        if (minted < maxFreeAmount) {
            cost = 0;
        } else if (minted < 4000) {
            cost = 0.001 ether;
        } else if (minted < 6000) {
            cost = 0.002 ether;
        } else if (minted < 8000) {
            cost = 0.003 ether;
        } else {
            cost = 0.004 ether;
        }
        return cost;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );
        return string(abi.encodePacked(baseURI, tokenId.toString(), ".json"));
    }

    function setBaseURI(string memory uri) public onlyOwner {
        baseURI = uri;
    }

    function setMaxFreeAmount(uint256 _amount) external onlyOwner {
        maxFreeAmount = _amount;
    }

    function setMaxFreePerWallet(uint256 _amount) external onlyOwner {
        maxFreePerWallet = _amount;
    }

    function withdraw() external onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success, "Transfer failed.");
    }
}