pragma solidity ^0.8.20;

import { FunctionsClient } from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/FunctionsClient.sol";
import { FunctionsRequest } from "@chainlink/contracts/src/v0.8/functions/dev/v1_0_0/libraries/FunctionsRequest.sol";
import './RingSigVerifier.sol';

contract NonEVMMinter is FunctionsClient {


    using FunctionsRequest for FunctionsRequest.Request;


    mapping  (bytes32 => address) public senderOfRequest;
    mapping (bytes32=> string) public uriOfRequest;
    mapping (string => string) public source_functions;

    bytes32 public s_lastRequestId;
    bytes public s_lastResponse;
    bytes public s_lastError;
    address public SBTContract;
    address public owner;

    uint32 public gasLimit = 250000;  // fallback function gas limit
    bytes32 public donId = 0x66756e2d657468657265756d2d7365706f6c69612d3100000000000000000000;


    event Response(bytes32 indexed requestId, bytes response, bytes err);
    event BalanceMissmatch(bytes32 indexed requestId, bytes reponse, string uri, address sender);
    constructor(address router, address SBTAddress) FunctionsClient(router) {
         owner = msg.sender;
    SBTContract = SBTAddress;
    }   

    modifier OnlyOwner() {
        require(msg.sender == owner, "OnlyOwner");
        _;
    }

     /**
     * Function to add a source function to the contract
     * @param name of the source function
     * @param source code of the source function, should be a javascript function stringified
     */
    function addSourceFunction(string memory name, string memory source) external OnlyOwner {
        source_functions[name] = source;
    }

    /**
     * Function to remove a source function from the contract
     * @param name of the source function
     */
    function removeSourceFunction(string memory name) external OnlyOwner {
        delete source_functions[name];
    }

    /**
     * Chnage the gas limit of the fallback function
     * @param newGasLimit the new gas limit for the fallback function
     */
    function modifyGasLimit(uint32 newGasLimit) external OnlyOwner {
        require(newGasLimit>100000 && newGasLimit<300000, "Invalid gas limit");
        gasLimit=newGasLimit;
    }

     enum Location {
    Inline, // Provided within the Request
    Remote, // Hosted through remote location that can be accessed through a provided URL
    DONHosted // Hosted on the DON's storage
  }

    /**
     * function to verify a proof and mint a SBT
     * it verify the ring siganture and then if the ring hold the right amount of tokens
     * mint a SBT on the fallback function
     * 
     * @param source the source code of the function to be executed
     * @param secretsLocation the location of the secrets
     * @param args the arguments of the source code
     * @param uri the uri of the NFT
     * @param message the signed message
     * @param ring the ring of public keys
     * @param responses the responses of the ring
     * @param c the signature seed
     */
    function sendRequest(
        string calldata source,
        FunctionsRequest.Location secretsLocation,
        string[] calldata args,
        string calldata uri,
        uint256 message, 
        uint256[] memory ring, 
        uint256[] memory responses,
        uint256 c 
    ) external returns (bytes32) {

        require(RingSigVerifier.verifyRingSignature(message, ring, responses, c)==true, "Invalid signature");
        FunctionsRequest.Request memory req;
        req.initializeRequest(FunctionsRequest.Location.Inline,FunctionsRequest.CodeLanguage.JavaScript, source);
        if (args.length > 0) {
            req.setArgs(args);
        }
        s_lastRequestId = _sendRequest(req.encodeCBOR(), 1809, gasLimit, donId);
        senderOfRequest[s_lastRequestId]=msg.sender;
        uriOfRequest[s_lastRequestId] = uri;
        return s_lastRequestId;
    }



    /**
     * fallback function called by the chainlink node
     * @param requestId the id of the request
     * @param response the response of the chainlink node
     * @param err the error message if any
     */
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
         require(s_lastRequestId == requestId, "Wrong request ID");
        s_lastResponse = response;
        s_lastError = err;
        emit Response(requestId, s_lastResponse, s_lastError);
        address sender = senderOfRequest[requestId];
        string memory uri = uriOfRequest[requestId];
        require(keccak256(response) == keccak256(bytes("true")), "balances missmatch"); // true in hex
        (bool success, ) = SBTContract.call(
            abi.encodeWithSignature("mint(address,string)", sender, uri));
        require(success, "error while minting the NFT");
    }

    function changeOwner(address newOwner) external OnlyOwner {
        owner = newOwner;
    }

    
}
