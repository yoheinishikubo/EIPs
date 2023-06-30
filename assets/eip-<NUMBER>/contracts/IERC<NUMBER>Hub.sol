// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.4;

interface IERC<NUMBER>Hub {
    /**
     * @notice `AddedByNFT` MUST emit when the Spoke NFT contract is deployed.
     * @dev Emitted when an NFT (Non-Fungible Token) contract is deployed.
     * @param contractAddress The address of the deployed NFT contract.
     * @param contractURI The URI (Uniform Resource Identifier) of the deployed NFT contract.
     */
    event AddedByNFT(address indexed contractAddress, string contractURI);

    /**
     * @notice `NFTBalanceChanged` MUST emit when the Spoke NFT is changed.
     * @dev Emitted when the balance of an NFT changes.
     * @param contractAddress The address of the NFT contract.
     * @param owner The owner of the NFT.
     * @param tokenId The ID of the NFT.
     * @param value The change in the NFT balance.
     */
    event NFTBalanceChanged(
        address indexed contractAddress,
        address indexed owner,
        uint256 indexed tokenId,
        int256 value
    );

    /**
     * @notice `NFTAccepted` MUST emit when the Spoke NFT is accepted as a event emitter.
     * @dev Emitted when an NFT is accepted.
     * @param contractAddress The address of the contract that accepted the NFT.
     */
    event NFTAccepted(address indexed contractAddress);

    /**
     * @notice `supportsInterface` MUST be implemented as per ERC-165.
     * @param interfaceId The interface identifier, as specified in ERC-165
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    /**
     * @notice `addedByNFT` MUST be called when the NFT added this contract.
     */
    function addedByNFT() external;

    /**
     * @notice `accept` MUST be called when the Spoke NFT contract is accepted as a event emitter.
     * @param spoke_ @dev The address of the Spoke NFT contract.
     */
    function accept(address spoke_) external;

    /**
     * @notice `afterTokenTransfer` MUST be called when the Spoke NFT contract is transferred.
     * @param from The address of the sender.
     * @param to The address of the recipient.
     * @param ids The IDs of the NFTs being transferred.
     * @param amounts The amounts of the NFTs being transferred.
     */
    function afterTokenTransfer(
        address from,
        address to,
        uint256[] calldata ids,
        uint256[] calldata amounts
    ) external;
}