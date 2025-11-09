// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title SimpleNFT - Minimal ERC-721-like NFT contract (hand-written)
/// @notice Minimal implementation: minting, ownerOf, balanceOf, tokenURI, approve, getApproved, transferFrom
contract SimpleNFT {
    string public name = "SimpleNFT";
    string public symbol = "SNFT";

    uint256 private _currentTokenId;
    uint256 private _totalSupply;

    // tokenId => owner
    mapping(uint256 => address) private _owners;
    // owner => balance
    mapping(address => uint256) private _balances;
    // tokenId => approved address
    mapping(uint256 => address) private _tokenApprovals;
    // tokenId => tokenURI
    mapping(uint256 => string) private _tokenURIs;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /// @notice Mint a new token with a tokenURI. Caller becomes owner.
    /// @param _tokenURI A string (will pass a data: URL from the frontend)
    /// @return tokenId of the newly minted token
    function mint(string memory _tokenURI) public returns (uint256) {
        _currentTokenId += 1;
        uint256 newId = _currentTokenId;

        _owners[newId] = msg.sender;
        _balances[msg.sender] += 1;
        _tokenURIs[newId] = _tokenURI;
        _totalSupply += 1;

        emit Transfer(address(0), msg.sender, newId);
        return newId;
    }

    /// @notice Returns owner of a given tokenId
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];
        require(owner != address(0), "owner query for nonexistent token");
        return owner;
    }

    /// @notice Returns balance (number of tokens) owned by address
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "balance query for zero address");
        return _balances[owner];
    }

    /// @notice Returns tokenURI for a token id
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_owners[tokenId] != address(0), "URI query for nonexistent token");
        return _tokenURIs[tokenId];
    }

    /// @notice Approve another address to transfer a specific token
    function approve(address to, uint256 tokenId) public {
        address owner = _owners[tokenId];
        require(owner != address(0), "approve for nonexistent token");
        require(msg.sender == owner, "approve caller is not owner");

        _tokenApprovals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }

    /// @notice Get approved address for a token
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_owners[tokenId] != address(0), "approved query for nonexistent token");
        return _tokenApprovals[tokenId];
    }

    /// @notice Transfer token from `from` to `to`. Caller must be owner or approved.
    function transferFrom(address from, address to, uint256 tokenId) public {
        address owner = _owners[tokenId];
        require(owner != address(0), "transfer of nonexistent token");
        require(owner == from, "from is not owner");
        require(to != address(0), "transfer to zero address");

        bool isApprovedOrOwner = (msg.sender == owner) || (msg.sender == _tokenApprovals[tokenId]);
        require(isApprovedOrOwner, "caller is not owner nor approved");

        // clear approval
        _tokenApprovals[tokenId] = address(0);

        // update balances and ownership
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    /// @notice Total supply (number of minted tokens)
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
}
