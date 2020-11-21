// SPDX-License-Identifier: MIT
pragma experimental ABIEncoderV2;
pragma solidity >=0.4.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Mintable.sol";
import "./Accounts.sol";


contract AnimalToken is ERC721, ERC721Full {
    constructor(address _accountsContract) ERC721Full("Animal", "ANI") public{
        accountsContract = _accountsContract;
    }

    address accountsContract;

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
    mapping(uint => uint) animalsCaravana;

    //Cada animal nuevo se pushea al array, para así obtener un id único para cada animal con el length del array.
    Animal[] animals;


    function mint(uint caravana, string memory breed, uint weight, uint dateOfBirth, bool male) public {
        require(Accounts(accountsContract).isFarm(msg.sender), "only farms can execute this method");
        if (animals.length!=0){
            if (int(caravana)==int (animals[animalsCaravana[caravana]].caravana)){
                require(!animals[getTokenId(caravana)].exists, "Another animal with that caravana still exists.");
            }
        }
        Animal memory animal;


        animal.caravana=caravana;
        animal.breed=breed;
        animal.weight=weight;
        animal.dateOfBirth=dateOfBirth;
        animal.male=male;
        animal.exists= true;
        animal.eventCount=0;
        animal.tokenID= animals.length;

        //Token id = length de animals al momento de generar un nuevo animal.
        animals.push(animal);
        uint _id = animals.length-1;
        animals[_id].tokenID= _id;
        animalsCaravana[caravana]= _id;

        _mint (msg.sender, _id);
    }

    function updateAnimalWeight (uint caravana, uint newWeight) public  {
        require(Accounts(accountsContract).isFarm(msg.sender), "only farms can execute this method");
        require(animals[animalsCaravana[caravana]].exists && int(caravana)==int(animals[animalsCaravana[caravana]].caravana), "That animal does not exist.");
        address owner = ownerOf(animalsCaravana[caravana]);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved."
        );

        string memory str1= uint2str(animalsCaravana[caravana]);
        string memory str2= concat(str1,"'s weight changed from ");
        string memory str3= concat(str2,uint2str(animals[animalsCaravana[caravana]].weight));
        string memory str4= concat(str3, "kg to ");
        string memory str5= concat(str4, uint2str(newWeight));
        string memory text= concat(str5, "kg.");

        animals[animalsCaravana[caravana]].events[animals[animalsCaravana[caravana]].eventCount]= myEvent(text, now);
        animals[animalsCaravana[caravana]].eventCount+=1;
        animals[animalsCaravana[caravana]].weight=newWeight;
    }

    function slaughter(uint caravana) public {
        require(Accounts(accountsContract).isFarm(msg.sender), "only farms can execute this method");
        require((animals[animalsCaravana[caravana]].exists) && int(caravana)==int(animals[animalsCaravana[caravana]].caravana), "That animal does not exist.");
        address owner = ownerOf(animalsCaravana[caravana]);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: method caller is not owner nor approved."
        );
        string memory str1= uint2str((animalsCaravana[caravana]));
        string memory str2= concat( "Animal ", str1);
        string memory str3= concat(str2, " has been slaughtered or has died while being owned by: ");
        string memory text= concat(str3, toAsciiString(ownerOf(animalsCaravana[caravana])));


        animals[animalsCaravana[caravana]].events[animals[animalsCaravana[caravana]].eventCount]= myEvent(text, now);
        animals[animalsCaravana[caravana]].eventCount+=1;
        animals[animalsCaravana[caravana]].exists=false;
    }

    function changeFarmLocation(address from, address to, uint caravana) public {
        require(Accounts(accountsContract).isFarm(msg.sender),"Only Farms can move cattle");
        require(Accounts(accountsContract).isLocation(msg.sender,from) || Accounts(accountsContract).isLocation(msg.sender,to), "Location does not belong to farm");
        uint256 tokenId= getTokenId(caravana);

        string memory str1= uint2str(tokenId);
        string memory str2= concat(str1, " has been moved within a farm from: ");
        string memory str3= concat(str2, toAsciiString(from));
        string memory str4= concat(str3, " to: ");
        string memory text= concat(str4, toAsciiString(to));
        animals[tokenId].events[animals[tokenId].eventCount]= myEvent(text, now);
        animals[tokenId].eventCount+=1;
        _transferFrom(from, to, tokenId);
    }

    function myApprove(address farm, uint caravana) public{
        require(Accounts(accountsContract).isLocation(farm,msg.sender), 'Invalid entry');
        uint tokenId= getTokenId(caravana);
        approve(farm,tokenId);
    }

    function transferFrom(address from, address to, uint caravana) public {
        require(Accounts(accountsContract).isFarm(from) || Accounts(accountsContract).isFarm(to), "Only farms can transfer animals to another farm");
        require(Accounts(accountsContract).isFarm(msg.sender) || Accounts(accountsContract).isAdmin(msg.sender), "Only admins or farms can use this method");
        require(animals[animalsCaravana[caravana]].exists && int(caravana)==int(animals[animalsCaravana[caravana]].caravana), "That animal does not exist.");
        uint256 tokenId= animalsCaravana[caravana];
        require(_isApprovedOrOwner(msg.sender, tokenId), "ERC721: transfer caller is not owner nor approved");

        string memory str1= uint2str(tokenId);
        string memory str2= concat(str1, " has been transferred from: ");
        string memory str3= concat(str2, toAsciiString(from));
        string memory str4= concat(str3, " to: ");
        string memory text= concat(str4, toAsciiString(to));
        animals[tokenId].events[animals[tokenId].eventCount]= myEvent(text, now);
        animals[tokenId].eventCount+=1;

        _transferFrom(from, to, tokenId);
    }

    function getAnimalFromId(uint id) public view returns(uint, string memory, uint, uint, bool, bool, uint){
        return(animals[id].caravana, animals[id].breed, animals[id].weight, animals[id].dateOfBirth, animals[id].male, animals[id].exists, animals[id].tokenID);
    }
    function getAnimalFromCaravana(uint caravana) public view returns(uint, string memory, uint, uint, bool, bool, uint){
        uint tokenId= animalsCaravana[caravana];
        if (int(animals[tokenId].caravana)==int(caravana)){
            return(animals[tokenId].caravana, animals[tokenId].breed, animals[tokenId].weight, animals[tokenId].dateOfBirth, animals[tokenId].male, animals[tokenId].exists, tokenId);
        } else {
            require(false,  "That caravana does not exist");
        }
        return(0,"",0,0,true,true,0);
    }

    function getTokenId(uint caravana) public view returns(uint){
        require (int(animals[animalsCaravana[caravana]].caravana)==int(caravana),  "That caravana does not exist");
        return animalsCaravana[caravana];
    }

    function getEverythingAnimalFromId(uint id) public view returns(uint, string memory, uint, uint, bool, bool, uint, myEvent[] memory){
        Animal storage animal = animals[id];
        myEvent[] memory events= new myEvent[](animal.eventCount);
        for (uint i =0; i < animal.eventCount; i++){
            events[i]=animal.events[i];
        }
        return(animal.caravana, animal.breed, animal.weight, animal.dateOfBirth, animal.male, animal.exists, animal.tokenID,events);
    }
    function getEverythingAnimalFromCaravana(uint caravana) public view returns(uint, string memory, uint, uint, bool, bool, uint, myEvent[] memory){
        uint tokenId= animalsCaravana[caravana];
        myEvent[] memory events;
        if (int(animals[tokenId].caravana)==int(caravana)){
            Animal storage animal = animals[tokenId];
            events= new myEvent[](animal.eventCount);
            for (uint i =0; i < animal.eventCount; i++){
                events[i]=animal.events[i];
            }
            return(animals[tokenId].caravana, animals[tokenId].breed, animals[tokenId].weight, animals[tokenId].dateOfBirth, animals[tokenId].male, animals[tokenId].exists, tokenId, events);
        } else {
            require(false,  "That caravana does not exist");
        }
        return(0,"",0,0,true,true,0,events);
    }

    function getEventsFromId(uint id) public view returns (myEvent[] memory){
        Animal storage animal = animals[id];
        myEvent[] memory events= new myEvent[](animal.eventCount);
        for (uint i =0; i < animal.eventCount; i++){
            events[i]=animal.events[i];
        }
        return events;
    }

    //Funciones Auxiliares
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