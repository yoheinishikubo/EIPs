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