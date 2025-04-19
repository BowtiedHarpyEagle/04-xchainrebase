# Cross-Chain Rebase Token

1. A protocol that allows users to deposit into a vault, and in return, they recieve rebase tokens that represent their underlying balance. 

2. Rebase token -> balanceOf function is dynamic, reflecting changing amount of tokens over time.
    - Balance increases linearly over time (gaining interest)
    - mint tokens to our users every time they perform an action (minting, burning, transferring or ...bridging)
3. Interest rate 
    - Individually set an interest rate for each user based on some global interest rate of the protocol at the time the user deposits into the vault. 
    - This global interest rate can only decrease to incentivise-reward the early adopters. 
    - Increase token adoption 