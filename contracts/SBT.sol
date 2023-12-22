// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract AliceRingToken is ERC721, ERC721URIStorage {
    uint256 private _nextTokenId;
    address public owner;
    //mapping of the smart contrat allowed to mint SBT
    //the mint will happen on fallback functions of other smart contracts
    mapping (address => bool) public allowedMinters;
    enum Status {
        UNKNOWN, // the proof has not been verified on-chain, no proof has been minted
        MINTED // the proof has already been minted
    }

    error AlreadyMinted(string proofId);
    error InvalidSignature();
    error InvalidTokenAmounts();
    error OnlyOwnerCanBurn(uint256 tokenId);
    error UnexpectedRequestID(bytes32 requestId);

    mapping(string => Status) public mintStatus; // signatureHash => Status (computed off-chain)

    constructor(
        address router 
    ) ERC721("AliceRingToken", "ART")   {
        owner = msg.sender;
     }

    // The following functions are overrides required by Solidity.
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @notice safeTransferFrom is disabled because the nft is a sbt
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public pure override(ERC721, IERC721) {
        revert("SBT: SafeTransfer not allowed");
    }

    /**
     * @notice transferFrom is disabled because the nft is a sbt
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public pure override(ERC721, IERC721) {
        revert("SBT: Transfer not allowed");
    }

    /**
     * @notice approve is disabled because the nft is a sbt and cannot be transferred
     */
    function approve(
        address to,
        uint256 tokenId
    ) public pure override(ERC721, IERC721) {
        revert("SBT: Approve not allowed");
    }

    /**
     * @notice getApproved is disabled because the nft is a sbt and cannot be transferred
     */
    function getApproved(
        uint256 tokenId
    ) public pure override(ERC721, IERC721) returns (address operator) {
        revert("SBT: getApproved not allowed");
    }

    /**
     * @notice setApprovalForAll is disabled because the nft is a sbt and cannot be transferred
     */
    function setApprovalForAll(
        address operator,
        bool _approved
    ) public pure override(ERC721, IERC721) {
        revert("SBT: setApprovalForAll not allowed");
    }

    /**
     * @notice isApprovedForAll is disabled because the nft is a sbt and cannot be transferred -> the output will always be false
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) public pure override(ERC721, IERC721) returns (bool) {
        return false;
    }


    /**
     * @notice mint a SBT
     *
     * Only the allowedMinters can mint a SBT
     *
     * @param to is the address of the receiver
     * @param uri is the uri of the NFT
     */
    function mint( // TODO: comment on verifie que le message est bien valide -> le former dans le contrat
      address to, 
      string memory uri
    ) external {
        require(allowedMinters[msg.sender], "SBT: Only allowed minter");
        _safeMint(to, _nextTokenId);
        _setTokenURI(_nextTokenId, uri);
        _nextTokenId++;

    }

    /**
     * @notice delete all the caracteristics of tokenId (burn)
     *
     * Only the owner of an sbt can burn it
     *
     * @param tokenId is the id of the sbt to burn
     */
    function burn(uint256 tokenId) external {
        if (ownerOf(tokenId) != msg.sender) {
            revert OnlyOwnerCanBurn(tokenId);
        }
        _burn(tokenId);
    }

   
    // Override the _burn function from ERC721
    function _burn(uint256 tokenId) internal override(ERC721) {
        super._burn(tokenId);
    }

    /**
     * @notice set the allowedMinters
     *
     * @param minter is the address of the minter
     * @param allowed is the boolean value to set
     */
    function setAllowedMinter(address minter, bool allowed) external  {
        require(msg.sender == owner, "SBT: Only owner");
        allowedMinters[minter] = allowed;
    }


     function changeOwner(address newOwner) external {
        require(msg.sender == owner, "SBT: Only owner");
        owner = newOwner;
    }
}