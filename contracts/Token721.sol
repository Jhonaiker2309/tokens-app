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
  

  constructor(address[] memory initialUsersInWhiteList) ERC721("Warrior Clan NFT", "WCN") {
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

    /// @notice Add user to white list
    /// @param _user address that will be added to white list
    /// @dev  add address _user to the mapping userInWhiteList
  function addUserToWhiteList(address _user) public {
      require(owner() == msg.sender || userHasRole["ADMIN"][msg.sender], "You are not allowed to do this action"); 
      userInWhiteList[_user] = true;
  }

    /// @notice Remove user from white list
    /// @param _user address that will be removed from white list
    /// @dev  from address _user from the mapping userInWhiteList
  function removeUserFromWhiteList(address _user) public {
    require(owner() == msg.sender || userHasRole["ADMIN"][msg.sender], "You are not allowed to do this action");
    userInWhiteList[_user] = false;
  }

    /// @notice Show the data of Nfts
    /// @dev  set revealed to true
  function reveal() public {
      require(owner() == msg.sender || userHasRole["ADMIN"][msg.sender], "You are not allowed to do this action");
      revealed = true;
  }

    /// @notice Change the number of Nfts that each user can have
    /// @param _limit amount of nfts that each user could have
    /// @dev  change maxAmountOfNftsByUser to _limit
  function setNftPerAddressLimit(uint256 _limit) public {
        require(owner() == msg.sender || userHasRole["ADMIN"][msg.sender], "You are not allowed to do this action");
        maxAmountOfNftsByUser = _limit;
  }

    /// @notice Change cost of nfts
    /// @param _newCost new price of the nfts
    /// @dev  change cost to _newCosts
  function setCost(uint256 _newCost) public {
        require(owner() == msg.sender || userHasRole["ADMIN"][msg.sender], "You are not allowed to do this action");
        cost = _newCost;
  }

    /// @notice Set max amount of nfts
    /// @param _newMaxMintAmount New max amount of nfts
    /// @dev  change maxAmountOfNfts to _newMaxMintAmount
  function setMaxMintAmount(uint256 _newMaxMintAmount) public {
    require(owner() == msg.sender || userHasRole["ADMIN"][msg.sender], "You are not allowed to do this action");
    maxAmountOfNfts = _newMaxMintAmount;
  }

    /// @notice Set baseURI for the nfts
    /// @param _newBaseURI new base uri of the contract
    /// @dev  change baseURI to _newBaseURI
  function setBaseURI(string memory _newBaseURI) private {
    baseURI = _newBaseURI;
  }

    /// @notice Set base uri for the nfts
    /// @param _notRevealedURI new not revealed uri of the contract
    /// @dev  change notRevealedUri to _notRevealedURI
  function setNotRevealedURI(string memory _notRevealedURI) private {
    notRevealedUri = _notRevealedURI;
  }

    /// @notice Control if MINTERS can mint or nor
    /// @param _state controls if users can mint or nor
    /// @dev  sets the variable paused to _state
  function pause(bool _state) public {
    require(owner() == msg.sender || userHasRole["ADMIN"][msg.sender], "You are not allowed to do this action");
    paused = _state;
  }

    /// @notice Add an initial list of users to the whitelist and gives them the role MINTER
    /// @param _users array of addresses that will be added to the whitelist
    /// @dev  add addresses in address[] users to the whitelist and adds them to the nestedMapping userHasRole["MINTER"][_users[i]] 
  function addInitialUsersToWhiteList(address[] memory _users) private {
    uint numberOfUsers = _users.length;
    for(uint i = 0; i < numberOfUsers; i++){
      userInWhiteList[_users[i]] = true;
      userHasRole["MINTER"][_users[i]] = true;
    }
  }

    /// @notice burn token
    /// @param tokenId id of the token that will be burned
    /// @dev  call function _burn with the parameter tokenId 
    function burn(uint256 tokenId) public virtual {
        require(ownerByToken[tokenId] == msg.sender, "You are not the owner of this token");
        _burn(tokenId);
        ownerByToken[tokenId] = address(0);
        addressMintedBalance[msg.sender] = addressMintedBalance[msg.sender] - 1;
    }

    /// @notice The owner withdraws the ether in the contract
    /// @dev  get send the ether in address(this) to msg.sender
    function withdraw()  public onlyOwner payable {
      payable(msg.sender).transfer(address(this).balance);
    }

    /// @notice Check amount of ether in smart contract
    /// @dev  get address(this).balance 
    /// @return balance of ether of the contract
    function contractBalance() public view onlyOwner returns(uint) {
      return address(this).balance;
}   

}