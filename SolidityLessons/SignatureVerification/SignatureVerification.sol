// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/* Signature Verification

How to Sign and Verify Messages 

# Signing
1. Create message to sign
2. Hash the message
3. Sign the hash (off chain, keep your private key secret)

# Verify
1. Recreate hash from the original message
2. Recover signer from signature and hash
3. Compare recovered signer to claimed signer

*/

contract VerifySignature {
    function getMessageHash(address _to, uint _amount, string memory _message, uint _nonce) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_to, _amount, _message, _nonce));
    }

    function getEthSignedMessageHash(bytes32 _messageHash) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(
            "\x19Ethereum Signed Message:\n32", 
            _messageHash
        ));
    }

    function verify(
        address _signer,
        address _to,
        uint _amount,
        string memory _message,
        uint _nonce,
        bytes memory _signature) public pure returns (bool) {
            bytes32 messageHash = getMessageHash(_to, _amount, _message, _nonce);
            bytes32 ethSignedMEssageHash = getEthSignedMessageHash(messageHash);

            return recoverSigner(ethSignedMEssageHash, _signature) == _signer;
    }

    function recoverSigner(
        bytes32 _ethSignedMessageHash, bytes memory _signature
    )
        public pure returns (address) 
    {
        (bytes32 r, bytes32 s, uint8 v) = splitSignature(_signature);

        return ecrecover(_ethSignedMessageHash, v, r, s);
    }

    function splitSignature(bytes memory _sig) public pure returns (bytes32 r, bytes32 s, uint8 v) {
        require(_sig.length == 65, "invalid signature length"); 

        assembly {
            r := mload(add(_sig, 32))
            // add(x, y) --> x + y
            // add(_sig, 32) --> skips first 32 bytes
            // mload(p) loads next 32 bytes starting at the memory address p
            s := mload(add(_sig, 64))
            v := byte(0, mload(add(_sig, 96)))
        }
    }
    
        
    /* 

    Signature is produced by signing a keccak256 with the following format:
    "\x19Ethereum Signed Message\n" + len(msg) + msg
     \x19Ethereum Signed Message\n32...message hash goes here...
     keccak256(
         \x19Ethereum Signed Message\n32...message hash goes here...
     )

    */

}