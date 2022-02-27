// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Token721 is ERC721Enumerable ,Ownable {
  using Strings for uint256;

  string public baseURI;
  string public baseExtension = ".json";
  string public notRevealedUri;
  uint256 public cost = 0.1 ether;
  uint256 public maxAmountOfNfts = 1000;
  uint256 public maxAmountOfNftsByUser = 10;
  bool public paused = true;
  bool public revealed;
  mapping(address => bool) userInWhiteList;
  mapping(address => uint256) public addressMintedBalance;
  mapping(uint => address) public ownerByToken;
  mapping(string => bool) public existingRole;
  mapping(string => mapping(address => bool)) userHasRole;
  

  constructor(address[] initialUsersInWhiteList) ERC721("Warrior Clan NFT", "WCN") {
    setBaseURI("https://ipfs.io/ipfs/QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT");
    setNotRevealedURI("https://ipfs.io/ipfs/QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/unrevealed.json");
    createRole("ADMIN");
    createRole("MINTER");
    addInitialUsersToWhiteList(initialUsersInWhiteList);
  }


    /// @notice Create a role
    /// @param _role role that will be added to the contract
    /// @dev  add seting _role to the mapping existingRole
    function createRole(string memory _role) private {
     existingRole[_role] = true;
  }

    /// @notice Add user to role
    /// @param _role string that shows the Role where _account will be added
    /// @param _account address that shows the user that will be added to the Role
    /// @dev  add string _role and address _account to nested mapping userHasRole
  function addUserToRole(string memory _role, address _account) public onlyOwner {
    require(existingRole[_role] == true, "This role does not exist");
     userHasRole[_role][_account] = true;
  }

    /// @notice Remove user from token
    /// @param _role string that shows the Role from where _account will be removed
    /// @param _account address that shows the user that will be removed from the Role
    /// @dev  get URI QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/{id}.json  
  function removeUserFromRole(string  memory _role, address  _account) public onlyOwner {
    require(existingRole[_role] == true, "This role does not exist");
     userHasRole[_role][_account] = false;
  }

    /// @notice Get the base URI of the tokens
    /// @dev get the base URI https://QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT
    /// @return base URI  
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

    /// @notice Mint the amount of tokens that the user wants
    /// @param _mintAmount amount of tokens that will be minted
    /// @dev  mint tokens to msg.sender, sum 1 to mapping addressMintedBalance[msg.sender] and set the ownerShip of tokens 
    /// @return url of the token    
  function mint(uint256 _mintAmount) public payable {
    require(!paused || userInWhiteList[msg.sender] || userHasRole["ADMIN"][msg.sender] || owner() == msg.sender, "the contract is paused");
    uint256 supply = totalSupply();
    require(userHasRole["ADMIN"][msg.sender] || userInWhiteList[msg.sender] || userHasRole["MINTER"][msg.sender] || owner() == msg.sender, "You are not allowed to mint");
    require(_mintAmount > 0, "need to mint at least 1 NFT");
    require(supply + _mintAmount <= maxAmountOfNfts, "You can exceed the max amount of nfts");
    require(_mintAmount + addressMintedBalance[msg.sender] <= maxAmountOfNftsByUser, "Each user has a max amount of nfts");
    require(msg.value == _mintAmount * cost, "You have to pay the right price");

    for (uint256 i = 1; i <= _mintAmount; i++) {
      addressMintedBalance[msg.sender]++;
      _safeMint(msg.sender, supply + i);
      ownerByToken[supply + i] = msg.sender;
    }
  }

    /// @notice Get the data of the token
    /// @param tokenId id of the token from where we want to check the data
    /// @dev  get uri QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/{id}.json
    /// @return uri of the token  
  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );
    
    if(revealed == false) {
        return notRevealedUri;
    } else {

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, "/",(tokenId % 11).toString(), baseExtension))
        : "";
    }    
  }

    /// @notice Get the data of the token
    /// @param tokenId id of the token from where we want to check the data
    /// @dev  get uri QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/{id}.json
    /// @return url of the token  
  function addUserToWhiteList(address _user) public {
      require(owner() == msg.sender || userHasRole["ADMIN"][msg.sender], "You are not allowed to do this action"); 
      userInWhiteList[_user] = true;
  }

    /// @notice Get the data of the token
    /// @param tokenId id of the token from where we want to check the data
    /// @dev  get uri QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/{id}.json
    /// @return url of the token  
  function removeUserFromWhiteList(address _user) public {
    require(owner() == msg.sender || userHasRole["ADMIN"][msg.sender], "You are not allowed to do this action");
    userInWhiteList[_user] = false;
  }

    /// @notice Get the data of the token
    /// @param tokenId id of the token from where we want to check the data
    /// @dev  get uri QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/{id}.json
    /// @return url of the token  
  function reveal() public {
      require(owner() == msg.sender || userHasRole["ADMIN"][msg.sender], "You are not allowed to do this action");
      revealed = true;
  }

    /// @notice Get the data of the token
    /// @param tokenId id of the token from where we want to check the data
    /// @dev  get uri QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/{id}.json
    /// @return url of the token    
  function setNftPerAddressLimit(uint256 _limit) public {
        require(owner() == msg.sender || userHasRole["ADMIN"][msg.sender], "You are not allowed to do this action");
        maxAmountOfNftsByUser = _limit;
  }

    /// @notice Get the data of the token
    /// @param tokenId id of the token from where we want to check the data
    /// @dev  get uri QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/{id}.json
    /// @return url of the token    
  function setCost(uint256 _newCost) public {
        require(owner() == msg.sender || userHasRole["ADMIN"][msg.sender], "You are not allowed to do this action");
        cost = _newCost;
  }

    /// @notice Get the data of the token
    /// @param tokenId id of the token from where we want to check the data
    /// @dev  get uri QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/{id}.json
    /// @return url of the token  
  function setMaxMintAmount(uint256 _newmaxMintAmount) public {
    require(owner() == msg.sender || userHasRole["ADMIN"][msg.sender], "You are not allowed to do this action");
    maxAmountOfNfts = _newmaxMintAmount;
  }

    /// @notice Get the data of the token
    /// @param tokenId id of the token from where we want to check the data
    /// @dev  get uri QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/{id}.json
    /// @return url of the token  
  function setBaseURI(string memory _newBaseURI) private {
    baseURI = _newBaseURI;
  }

     /// @notice Get the data of the token
    /// @param tokenId id of the token from where we want to check the data
    /// @dev  get uri QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/{id}.json
    /// @return url of the token   
  function setNotRevealedURI(string memory _notRevealedURI) private {
    notRevealedUri = _notRevealedURI;
  }

    /// @notice Get the data of the token
    /// @param tokenId id of the token from where we want to check the data
    /// @dev  get uri QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/{id}.json
    /// @return url of the token  
  function pause(bool _state) public {
    require(owner() == msg.sender || userHasRole["ADMIN"][msg.sender], "You are not allowed to do this action");
    paused = _state;
  }

    /// @notice Get the data of the token
    /// @param tokenId id of the token from where we want to check the data
    /// @dev  get uri QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/{id}.json
    /// @return url of the token    
  function addInitialUsersToWhiteList(address[] memory _users) private {
    uint numberOfUsers = _users.length;
    for(uint i = 0; i < numberOfUsers; i++){
      userInWhiteList[_users[i]] = true;
      userHasRole["MINTER"][_users[i]] = true;
    }
  }

    /// @notice Get the data of the token
    /// @param tokenId id of the token from where we want to check the data
    /// @dev  get uri QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/{id}.json
    /// @return url of the token  
    function burn(uint256 tokenId) public virtual {
        require(ownerByToken[tokenId] == msg.sender, "You are not the owner of this token");
        _burn(tokenId);
        ownerByToken[tokenId] = address(0);
        addressMintedBalance[msg.sender] = addressMintedBalance[msg.sender] - 1;
    }

    /// @notice Get the data of the token
    /// @param tokenId id of the token from where we want to check the data
    /// @dev  get uri QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/{id}.json
    /// @return url of the token   
    function withdraw()  public onlyOwner payable {
      payable(msg.sender).transfer(address(this).balance);
    }

    /// @notice Get the data of the token
    /// @param tokenId id of the token from where we want to check the data
    /// @dev  get uri QmUuNFzKA2ya3mU8ac2vUJf3ThoqwYB5i24z7t6QNXpveT/{id}.json
    /// @return url of the token  
    function contractBalance() public view onlyOwner returns(uint) {
      return address(this).balance;
}   

}