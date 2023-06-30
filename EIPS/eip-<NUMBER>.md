---
eip: <NUMBER>
title: Base Protocol for Applications for NFTs widely distributed.
description: Hub and spoke contracts enabling to collect and filter NFTs deployed and minted.
author: Yohei Nishikubo (@yoheinishikubo)
discussions-to: <URL>
status: Draft
type: Standards Track
category: ERC
created: 2023-05-01
requires: 165, 721, 1155
---

## Abstract

The proposed EIP outlines a hub and spoke model that can be integrated into an Ethereum-based network. The hub, which is a smart contract, will be called by deployed, minted, and transferred NFTs within the network and emit events for those triggers.
Any NFT contracts can call a method to emit deployed events. However, accepted events will be emitted only when the NFT contract is allowed in the hub.
The spokes, which also are smart contracts extends ERC-721 or ERC-1155, will call the methods of the hubs when deployed, minted, and transferred.

## Motivation

As of the moment this proposal issued, no standard application to enjoy NFTs published by multi parties is available.
For this purpose, people should pick or remove NFTs on common wallets or use dedicated applications for NFTs published by limited parties.

## Specification

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in RFC 2119 and RFC 8174.

### Hub

```solidity
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

```

### Spoke

```solidity
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
```

## Rationale

Developing an application which shows a curated list of NFTs is not so easy.
In common cases at this moment, the list of NFT addresses are managed by off-chain systems. The list is updated off chain by the way like filtering event logs on the chain. All contracts or a predefined set of contracts can be targets.
There seems to be no standard to implement systems like above.
With this proposal, the application can be implemented only to watch the events of the hub contract.
In addition, the events are formatted in a way that the application can easily understand the balances of the NFTs owned by an user.
A spoke contract should be accepted to trigger events by the hub contract. The acceptance can be managed by the common role-based enumerable access control system. This design realizes the flexibility including external mechanism like DAO to manage the acceptance.

## Backwards Compatibility

No backward compatibility issues found.

## Reference Implementation

The followings are abstract contracts for the hub and spoke contracts.

### Hub

```solidity
// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable/access/AccessControlEnumerableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/interfaces/IERC165Upgradeable.sol";

import "./IERC<NUMBER>Spoke.sol";
import "./IERC<NUMBER>Hub.sol";

contract ERC<NUMBER>HubUpgradeable is
    Initializable,
    AccessControlEnumerableUpgradeable,
    UUPSUpgradeable,
    IERC<NUMBER>Hub
{
    using AddressUpgradeable for address;

    // Roles for the contract
    bytes32 public constant DEPLOYER_ROLE = keccak256("DEPLOYER_ROLE");
    bytes32 public constant ACCEPTED_ROLE = keccak256("ACCEPTED_ROLE");

    mapping(address => bool) private _requested;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /**
     * @dev Function to initialize the contract.
     */
    function initialize() public initializer {
        __AccessControlEnumerable_init();
        __UUPSUpgradeable_init();

        // Grant admin and deployer roles to the contract deployer.
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(DEPLOYER_ROLE, msg.sender);
    }

    /**
     * @dev Function to authorize an upgrade to the contract.
     * @param newImplementation The address of the new implementation.
     */
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEPLOYER_ROLE) {}

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(AccessControlEnumerableUpgradeable, IERC<NUMBER>Hub)
        returns (bool)
    {
        return
            interfaceId == type(IERC<NUMBER>Hub).interfaceId ||
            AccessControlUpgradeable.supportsInterface(interfaceId);
    }

    /**
     * @dev Function to mark the deployment of an NFT contract
     * Any contract can call this function to mark its deployment.
     */
    function AddedByNFT() public {
        require(
            msg.sender.isContract(),
            "ERC<NUMBER>Hub: only contracts can call this function"
        );

        require(!_requested[msg.sender], "ERC<NUMBER>Hub: already requested");
        _requested[msg.sender] = true;

        require(
            IERC<NUMBER>Spoke(msg.sender).supportsInterface(
                type(IERC<NUMBER>Spoke).interfaceId
            ),
            "ERC<NUMBER>Hub: does not support IERC<NUMBER>Spoke"
        );

        string memory contractURI = IERC<NUMBER>Spoke(msg.sender).contractURI();
        require(
            bytes(contractURI).length > 0,
            "ERC<NUMBER>Hub: contract URI is empty"
        );
        emit AddedByNFT(msg.sender, contractURI);
    }

    /**
     * Accepts a contract as an accepted spoke.
     *
     * @param spoke_ The address of the contract to be accepted.
     *
     * Requirements:
     * Only users with the DEPLOYER_ROLE are allowed to call this function.
     * The `spoke_` must be a contract.
     *
     * Emits a {NFTAccepted} event indicating a spoke has been accepted.
     */

    function accept(address spoke_) external onlyRole(DEPLOYER_ROLE) {
        require(address(spoke_).isContract(), "ERC<NUMBER>Hub: not a contract");
        _grantRole(ACCEPTED_ROLE, spoke_);
        emit NFTAccepted(spoke_);
    }

    /**
     * @dev Hook that is called after a transfer of NFT tokens.
     * @param from address sending the tokens.
     * @param to address receiving the tokens.
     * @param ids array of NFT token IDs.
     * @param amounts array of amounts corresponding to NFT token IDs.
     * @notice This function is only callable by an address with the REQUESTER_ROLE.
     * @notice This function emits events for the affected NFT token balances after the transfer.
     */
    function afterTokenTransfer(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts
    ) external onlyRole(ACCEPTED_ROLE) {
        unchecked {
            for (uint256 i = 0; i < ids.length; ) {
                emit NFTBalanceChanged(
                    msg.sender,
                    from,
                    ids[i],
                    int256(amounts[i]) * -1
                );
                emit NFTBalanceChanged(
                    msg.sender,
                    to,
                    ids[i],
                    int256(amounts[i])
                );
                ++i;
            }
        }
    }
}
```

### Spoke

#### ERC721SpokeUpgradeable

```solidity
// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.4;
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "./ERC<NUMBER>Spoke.sol";

abstract contract ERC721SpokeUpgradeable is
    Initializable,
    ERC721Upgradeable,
    ERC<NUMBER>Spoke
{
    using AddressUpgradeable for address;

    function __ERC721Spoke_init(
        string memory contractURI_,
        address[] memory hubs_
    ) internal onlyInitializing {
        __ERC<NUMBER>Spoke_init(contractURI_, hubs_);
    }

    function __ERC721Spoke_init_unchained() internal onlyInitializing {}

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC721Upgradeable, ERC<NUMBER>Spoke)
        returns (bool)
    {
        return
            ERC721Upgradeable.supportsInterface(interfaceId) ||
            ERC<NUMBER>Spoke.supportsInterface(interfaceId);
    }

    /**
     * @dev Hook that is called after any token transfer. This includes minting and burning. If {ERC721Consecutive} is
     * used, the hook may be called as part of a consecutive (batch) mint, as indicated by `batchSize` greater than 1.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s tokens were transferred to `to`.
     * - When `from` is zero, the tokens were minted for `to`.
     * - When `to` is zero, ``from``'s tokens were burned.
     * - `from` and `to` are never both zero.
     * - `batchSize` is non-zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 firstTokenId,
        uint256 batchSize
    ) internal virtual override {
        super._afterTokenTransfer(from, to, firstTokenId, batchSize);

        uint256[] memory ids = new uint256[](batchSize);
        uint256[] memory amounts = new uint256[](batchSize);
        unchecked {
            for (uint256 i = firstTokenId; i < firstTokenId + batchSize; ) {
                ids[i] = i;
                amounts[i] = 1;
                ++i;
            }
        }

        _callAfterTokenTransfer(from, to, ids, amounts);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
```

#### ERC1155SpokeUpgradeable

```solidity
// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.4;
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "./ERC<NUMBER>Spoke.sol";

abstract contract ERC1155SpokeUpgradeable is
    Initializable,
    ERC1155Upgradeable,
    ERC<NUMBER>Spoke
{
    using AddressUpgradeable for address;

    function __ERC1155Spoke_init(
        string memory contractAddress_,
        address[] memory hubs_
    ) internal onlyInitializing {
        __ERC<NUMBER>Spoke_init(contractAddress_, hubs_);
    }

    function __ERC1155Spoke_init_unchained() internal onlyInitializing {}

    function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        virtual
        override(ERC1155Upgradeable, ERC<NUMBER>Spoke)
        returns (bool)
    {
        return
            ERC1155Upgradeable.supportsInterface(interfaceId) ||
            ERC<NUMBER>Spoke.supportsInterface(interfaceId);
    }

    /**
     * @dev Hook that is called after any token transfer. This includes minting
     * and burning, as well as batched variants.
     *
     * The same hook is called on both single and batched variants. For single
     * transfers, the length of the `id` and `amount` arrays will be 1.
     *
     * Calling conditions (for each `id` and `amount` pair):
     *
     * - When `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * of token type `id` will be  transferred to `to`.
     * - When `from` is zero, `amount` tokens of token type `id` will be minted
     * for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens of token type `id`
     * will be burned.
     * - `from` and `to` are never both zero.
     * - `ids` and `amounts` have the same, non-zero length.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155Upgradeable) {
        super._afterTokenTransfer(operator, from, to, ids, amounts, data);
        _callAfterTokenTransfer(from, to, ids, amounts);
    }

    /**
     * @dev This empty reserved space is put in place to allow future versions to add new
     * variables without shifting down storage in the inheritance chain.
     * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
     */
    uint256[50] private __gap;
}
```

## Security Considerations

Needs discussion.

## Copyright

Copyright and related rights waived via [CC0](../LICENSE.md).
