// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Mintable.sol";


contract AnimalToken is ERC721, ERC721Full, ERC721Mintable {
    constructor() ERC721Full("Animal", "ANI") public{}
//    // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
//    // which can be also obtained as `IERC721Receiver(0).onERC721Received.selector`
//    bytes4 private constant _ERC721_RECEIVED = 0x150b7a02;
//
//    // Mapping from token ID to owner
//    mapping (uint256 => address) private _tokenOwner;
//
//    // Mapping from token ID to approved address
//    mapping (uint256 => address) private _tokenApprovals;
//
//    // Mapping from owner to number of owned token
//    mapping (address => Counters.Counter) private _ownedTokensCount;
//
//    // Mapping from owner to operator approvals
//    mapping (address => mapping (address => bool)) private _operatorApprovals;

    struct myEvent{
        string description;
        uint timestamp;
    }

    struct Animal {
        uint caravana;
        string breed;
        uint weight;
        uint dateOfBirth;
        bool male;
        bool exists;
        mapping (uint => myEvent) events;
        uint eventCount;
        uint tokenID;
    }
    // Asociamos la caravana al animal que la tiene, como la caravana se reusa después de la faena,
    // el animal asociado se reescribirá.
    mapping(uint => Animal) animalsCaravana;

    //Cada animal nuevo se pushea al array, para así obtener un id único para cada animal con el length del array.
    Animal[] animals;


    function mint(uint caravana, string memory breed, uint weight, uint dateOfBirth, bool male) public {
        require(!animalsCaravana[caravana].exists, "Another animal with that caravana still exists.");
        Animal memory animal;
        //Animal memory animal= Animal(caravana, breed, weight, dateOfBirth, male,true,new mapping (uint => myEvent) events, animals.length+1 );
        //Token id = length de animals al momento de generar un nuevo animal.


        animal.caravana=caravana;
        animal.breed=breed;
        animal.weight=weight;
        animal.dateOfBirth=dateOfBirth;
        animal.male=male;
        animal.exists= true;
        animal.eventCount=0;
        uint _id = animals.push(animal);
        animal.tokenID= _id;
        animalsCaravana[caravana]= animal;

        _mint (msg.sender, _id);
    }

    function updateAnimalWeight (uint caravana, uint newWeight) public payable{
        require(animalsCaravana[caravana].exists, "That animal does not exist.");
        address owner = ownerOf(animalsCaravana[caravana].tokenID);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved."
        );

        string memory str1= uint2str(animalsCaravana[caravana].tokenID);
        string memory str2= concat(str1,"weight changed from");
        string memory str3= concat(str2,uint2str(animalsCaravana[caravana].weight));
        string memory str4= concat(str3, "kg to");
        string memory str5= concat(str4, uint2str(newWeight));
        string memory text= concat(str5, "kg.");

        animalsCaravana[caravana].events[animalsCaravana[caravana].eventCount]= myEvent(text, now);
        animalsCaravana[caravana].eventCount+=1;
        animalsCaravana[caravana].weight=newWeight;
    }

    function slaughter(uint caravana) public payable{
        require(animalsCaravana[caravana].exists, "That animal does not exist.");
        address owner = ownerOf(animalsCaravana[caravana].tokenID);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved."
        );
        string memory str1= uint2str(animalsCaravana[caravana].tokenID);
        string memory str2= concat( "Animal", str1);
        string memory text= concat(str2, "has been slaughtered or has died.");
        animalsCaravana[caravana].events[animalsCaravana[caravana].eventCount]= myEvent(text, now);
        animalsCaravana[caravana].eventCount+=1;
        animalsCaravana[caravana].exists=false;
    }

    function transferFrom(address from, address to, uint caravana) public {
        require(animalsCaravana[caravana].exists, "That animal does not exist.");
        uint256 tokenId= animalsCaravana[caravana].tokenID;
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        string memory str1= uint2str(animalsCaravana[caravana].tokenID);
        string memory str2= concat(str1, "has been transferred from: ");
        string memory str3= concat(str2, toAsciiString(from));
        string memory str4= concat(str3, " to");
        string memory text= concat(str4, toAsciiString(to));
        animalsCaravana[caravana].events[animalsCaravana[caravana].eventCount]= myEvent(text, now);
        animalsCaravana[caravana].eventCount+=1;

        _transferFrom(from, to, tokenId);
    }

//    function ownerOf(uint256 tokenId) public view returns (address) {
//        address owner = _tokenOwner[tokenId];
//        require(owner != address(0), "ERC721: owner query for nonexistent token");
//
//        return owner;
//    }

    function uint2str(uint i) internal pure returns (string memory) {
        if (i == 0) return "0";
        uint j = i;
        uint length;
        while (j != 0) {
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0) {
            bstr[k--] = byte(uint8(48 + i % 10));
            i /= 10;
        }
        return string(bstr);
    }

    function concat(string memory a, string memory b) internal pure returns (string memory ) {

        return string(abi.encodePacked(a, b));

    }

    function toAsciiString(address x) internal pure returns (string memory) {
        bytes memory s = new bytes(40);
        for (uint i = 0; i < 20; i++) {
            byte b = byte(uint8(uint(x) / (2**(8*(19 - i)))));
            byte hi = byte(uint8(b) / 16);
            byte lo = byte(uint8(b) - 16 * uint8(hi));
            s[2*i] = char(hi);
            s[2*i+1] = char(lo);
        }
        return string(s);
    }

    function char(byte b) internal pure returns (byte c) {
        if (uint8(b) < 10) return byte(uint8(b) + 0x30);
        else return byte(uint8(b) + 0x57);
    }
}



// el unico momento en el que se puede actualizar un struct es cuando se hace una transaccion?
//Podes tener en un contrato definidos mas de un tipo de struct?
//Como sincronizamos con metamask las addresses?
//podria tener mas de un struct adentro de otro

//Esta bien que cada struct se mapee de acuerdo a un int y no un address, por ERC721
//Deberiamos tener dentro de cada vaca o crop un array de struct "evento", donde se vayan
    //guardando todas los eventos que le van pasando a la vaca.
    //Supongo que en cada evento podrias modificar cualquiera de los atributos, peso, granja, etc.
    //No estoy seguro desde donde se llaman las funciones
    //metamask no creo que nos de el tiempo de meternos a hacer eso, es mas para frontend