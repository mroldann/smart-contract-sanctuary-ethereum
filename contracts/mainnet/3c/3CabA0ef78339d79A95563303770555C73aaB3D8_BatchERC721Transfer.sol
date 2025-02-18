// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

interface ERC721Partial {
  function transferFrom(address from, address to, uint256 tokenId) external;
}

contract BatchERC721Transfer {
  error RecipientsAndTokenIdsAreNotSameLength();
  
  /// @notice Tokens on the given ERC-721 contract are transferred from you to a recipient.
  ///         Don't forget to execute setApprovalForAll first to authorize this contract.
  /// @param  tokenContract An ERC-721 contract
  /// @param  recipients    Who gets the tokens?
  /// @param  tokenIds      Which token IDs are transferred?
  function batchTransfer(ERC721Partial tokenContract, address[] calldata recipients, uint256[] calldata tokenIds) external {
    if (recipients.length != tokenIds.length) revert RecipientsAndTokenIdsAreNotSameLength();
  
    for (uint256 index; index < tokenIds.length; index++) {
      tokenContract.transferFrom(msg.sender, recipients[index], tokenIds[index]);
    }
  }
}