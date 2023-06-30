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