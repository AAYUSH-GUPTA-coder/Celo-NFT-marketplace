// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

error NOT_THE_OWNER_OF_NFT(address);
error ITEM_IS_ALREADY_LISTED();
error ITEM_IS_NOT_LISTED();
error PRICE_MUST_BE_GREATER_THAN_ZERO();
error MARKETPLACE_HAS_NO_APPROVAL();
error INCORRECT_ETH_SUPPLIED();

contract NFTMarketplace {
    struct Listing {
        uint256 price;
        address seller;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;

    modifier isNFTOwner(address nftAddress, uint256 tokenId) {
        // require(
        //     IERC721(nftAddress).ownerOf(tokenId) == msg.sender,
        //     "MRKT: Not the owner"
        // );

        if (IERC721(nftAddress).ownerOf(tokenId) != msg.sender) {
            revert NOT_THE_OWNER_OF_NFT(nftAddress);
        }
        _;
    }

    modifier isNotListed(address nftAddress, uint256 tokenId) {
        // require(
        //     listings[nftAddress][tokenId].price == 0,
        //     "MRKT: Already listed"
        // );
        if (listings[nftAddress][tokenId].price != 0) {
            revert ITEM_IS_ALREADY_LISTED();
        }
        _;
    }

    modifier isListed(address nftAddress, uint256 tokenId) {
        // require(listings[nftAddress][tokenId].price > 0, "MRKT: Not listed");
        if (listings[nftAddress][tokenId].price == 0) {
            revert ITEM_IS_NOT_LISTED();
        }
        _;
    }

    event ListingCreated(
        address nftAddress,
        uint256 tokenId,
        uint256 price,
        address seller
    );

    event ListingCanceled(address nftAddress, uint256 tokenId, address seller);

    event ListingUpdated(
        address nftAddress,
        uint256 tokenId,
        uint256 newPrice,
        address seller
    );

    event ListingPurchased(
        address nftAddress,
        uint256 tokenId,
        address seller,
        address buyer
    );

    function createListing(
        address nftAddress,
        uint256 tokenId,
        uint256 price
    )
        external
        isNotListed(nftAddress, tokenId)
        isNFTOwner(nftAddress, tokenId)
    {
        // require(price > 0, "MRKT: Price must be > 0");
        if (price == 0) {
            revert PRICE_MUST_BE_GREATER_THAN_ZERO();
        }
        IERC721 nftContract = IERC721(nftAddress);
        // require(
        //     nftContract.isApprovedForAll(msg.sender, address(this)) ||
        //         nftContract.getApproved(tokenId) == address(this),
        //     "MRKT: No approval for NFT"
        // );
        if (
            !nftContract.isApprovedForAll(msg.sender, address(this)) ||
            nftContract.getApproved(tokenId) != address(this)
        ) {
            revert MARKETPLACE_HAS_NO_APPROVAL();
        }
        listings[nftAddress][tokenId] = Listing({
            price: price,
            seller: msg.sender
        });

        emit ListingCreated(nftAddress, tokenId, price, msg.sender);
    }

    function cancelListing(address nftAddress, uint256 tokenId)
        external
        isListed(nftAddress, tokenId)
        isNFTOwner(nftAddress, tokenId)
    {
        delete listings[nftAddress][tokenId];
        emit ListingCanceled(nftAddress, tokenId, msg.sender);
    }

    function updateListing(
        address nftAddress,
        uint256 tokenId,
        uint256 newPrice
    ) external isListed(nftAddress, tokenId) isNFTOwner(nftAddress, tokenId) {
        // require(newPrice > 0, "MRKT: Price must be > 0");
        if(newPrice == 0){
            revert PRICE_MUST_BE_GREATER_THAN_ZERO();
        }
        listings[nftAddress][tokenId].price = newPrice;
        emit ListingUpdated(nftAddress, tokenId, newPrice, msg.sender);
    }

    function purchaseListing(address nftAddress, uint256 tokenId)
        external
        payable
        isListed(nftAddress, tokenId)
    {
        Listing memory listing = listings[nftAddress][tokenId];
        // require(msg.value == listing.price, "MRKT: Incorrect ETH supplied");
        if(msg.value != listing.price){
            revert INCORRECT_ETH_SUPPLIED();
        }
        delete listings[nftAddress][tokenId];

        IERC721(nftAddress).safeTransferFrom(
            listing.seller,
            msg.sender,
            tokenId
        );
        payable(listing.seller).transfer(msg.value);

        emit ListingPurchased(nftAddress, tokenId, listing.seller, msg.sender);
    }
}
