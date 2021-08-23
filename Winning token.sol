// SPDX-License-Identifier: MIT
pragma solidity ^0.6.12;

import "./BEP20.sol";

// Winning token with Governance.
contract WinningToken is BEP20("Winning Token", "Win") {
    // Burn address
    address public constant BURN_ADDRESS = 0xE01c772831016Fc7bA5e196C6ECff7E3360b8429;
    /// @notice transfers `_amount` token to `_to`. Must only be called by the owner (The judges).
    function Distribute(address owner, address _to, uint256 _amount) public onlyOwner {
        super._transfer(owner, _to, _amount);
    }
    /// @dev overrides transfer function to meet tokenomics of Winning token
    // super raises the input to the bep20.sol contract's _transfer
    // Dont want to burn tokens being moved to the burn address or sent via the judges
    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        if (recipient == BURN_ADDRESS) {
            super._transfer(sender, recipient, amount); 
        } else {
            //0.01% of every transfer burnt
            uint256 burnAmount = amount.div(10000);
            // 99.99% of transfer sent to recipient
            uint256 sendAmount = amount.sub(burnAmount);
            // makes sure no maths errors have been committed
            require(amount == sendAmount + burnAmount, "Winning::transfer: Burn value invalid");
            super._transfer(sender, BURN_ADDRESS, burnAmount);
            super._transfer(sender, recipient, sendAmount);
            // The final amount given to the recipient address 
            amount = sendAmount;
        }
    }
}
