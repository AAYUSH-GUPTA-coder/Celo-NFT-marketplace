// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

error MRKT__NotTheOwner();
error MRKT__NftAlreadyListed();
error MRKT__NftNotListed();
error MRKT__NftPriceCantBeZero();
error MRKT__IncorrectEthSupplied();
error MRKT__FailedToSendEth();
error MRKT__NoApprovalForNFT();


contract NFTMarketplace {
    struct Listing {
        uint256 price;
        address seller;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;

    modifier isNFTOwner(address nftAddress, uint256 tokenId) {
        if(IERC721(nftAddress).ownerOf(tokenId) != msg.sender){
            revert MRKT__NotTheOwner();
        }
        _;
    }

    modifier isNotListed(address nftAddress, uint256 tokenId) {
        if(listings[nftAddress][tokenId].price != 0){
            revert MRKT__NftAlreadyListed();
        }
        _;
    }

    modifier isListed(address nftAddress, uint256 tokenId) {
        if(listings[nftAddress][tokenId].price == 0){
            revert MRKT__NftNotListed();
        }
        _;
    }

    modifier isPriceAboveZero(uint price) {
        if(price == 0){
            revert MRKT__NftPriceCantBeZero();
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
        isPriceAboveZero(price)
    {
        IERC721 nftContract = IERC721(nftAddress);
        
        if(!nftContract.isApprovedForAll(msg.sender, address(this)) ||
                nftContract.getApproved(tokenId) != address(this))
                {
                    revert MRKT__NoApprovalForNFT();
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
    ) external isListed(nftAddress, tokenId) isNFTOwner(nftAddress, tokenId) isPriceAboveZero(newPrice){
        listings[nftAddress][tokenId].price = newPrice;
        emit ListingUpdated(nftAddress, tokenId, newPrice, msg.sender);
    }

    function purchaseListing(address nftAddress, uint256 tokenId)
        external
        payable
        isListed(nftAddress, tokenId)
    {
        Listing memory listing = listings[nftAddress][tokenId];
        if(msg.value != listing.price){
            revert MRKT__IncorrectEthSupplied();
        }

		delete listings[nftAddress][tokenId];

        IERC721(nftAddress).safeTransferFrom(
            listing.seller,
            msg.sender,
            tokenId
        );
        (bool sent, ) = payable(listing.seller).call{value: msg.value}("");
        if(!sent){
            revert MRKT__FailedToSendEth();
        }

        emit ListingPurchased(nftAddress, tokenId, listing.seller, msg.sender);
    }
}