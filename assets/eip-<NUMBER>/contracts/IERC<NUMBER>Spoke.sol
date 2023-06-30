// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.4;

interface IERC<NUMBER>Spoke {
    /**
     * @notice `CallFailed` MAY be emitted when a hub call fails.
     * @dev Emitted when a hub call fails.
     * @param hub The address of the hub to be added.
     */
    event CallFailed(address hub);

    /**
     * @notice `supportsInterface` MUST be implemented as per ERC-165.
     * @dev See https://eips.ethereum.org/EIPS/eip-165
     * @param interfaceId The interface identifier, as specified in ERC-165
     * @return `true` if the contract implements `interfaceId`
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    /**
     * @notice `contractURI` MUST return the URI (Uniform Resource Identifier) of the Spoke NFT contract itself.
     * @return The URI of the Spoke NFT contract.
     */
    function contractURI() external view returns (string memory);

    /**
     * @notice `hubAtIndex` MUST return the address of the hub at the given index.
     * @param index The index of the hub.
     * @return The address of the hub.
     */
    function hubAtIndex(uint256 index) external view returns (address);

    /**
     * @notice `hubCount` MUST return the number of hubs.
     * @return The number of hubs.
     */
    function hubCount() external view returns (uint256);

    /**
     * @notice `_addHub` MUST be implemented to add a hub.
     * @param hub_ The address of the hub to be added.
     */
    function _addHub(address hub_) external;

    /**
     * @notice `_removeHub` MUST be implemented to remove a hub.
     * @param hub_ The address of the hub to be removed.
     */
    function _removeHub(address hub_) external;

    /**
     * @notice `_callAfterTokenTransfer` MUST be implemented to call `afterTokenTransfer` on all hubs.
     * @param from The address of the sender.
     * @param to The address of the recipient.
     * @param ids The IDs of the NFTs being transferred.
     * @param amounts The amounts of the NFTs being transferred.
     */
    function _callAfterTokenTransfer(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external;
}