// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {TokenPool} from "@chainlink/ccip/pools/TokenPool.sol";
import {Pool} from "@chainlink/ccip/libraries/Pool.sol";
import {IERC20} from "@chainlink/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {IRebaseToken} from "./interfaces/IRebaseToken.sol";

contract RebaseTokenPool is TokenPool {
    constructor(IERC20 _token, address[] memory _allowlist, address _rmnProxy, address _router) TokenPool(_token, 18, _allowlist, _rmnProxy, _router) {}

    function lockOrBurn(
    Pool.LockOrBurnInV1 calldata lockOrBurnIn
  ) external returns (Pool.LockOrBurnOutV1 memory lockOrBurnOut) 
  {
    _validateLockOrBurn(lockOrBurnIn);
    address receiver = abi.decode(lockOrBurnIn.receiver, (address));
    uint256 userInterestRate = IRebaseToken(address(i_token)).getUserInterestRate(receiver);
    IRebaseToken(address(i_token)).burn(address(this), lockOrBurnIn.amount);
    lockOrBurnOut = Pool.LockOrBurnOutV1({
      destTokenAddress: 
    });
  }

  function releaseOrMint(
    Pool.ReleaseOrMintInV1 calldata releaseOrMintIn
  ) external returns (Pool.ReleaseOrMintOutV1 memory) 
  {}

}