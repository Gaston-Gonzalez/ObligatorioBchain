// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Mintable.sol";


contract animalToken is ERC721, ERC721Full, ERC721Mintable {
    constructor() ERC721Full("Animal", "ANI") public{}
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
        myEvent[] events;
        uint tokenID;
    }
    // Asociamos la caravana al animal que la tiene, como la caravana se reusa después de la faena,
    // el animal asociado se reescribirá.
    mapping(uint => Animal) animalsCaravana;

    //Cada animal nuevo se pushea al array, para así obtener un id único para cada animal con el length del array.
    Animal[] animals;


   /* struct crop{
        uint256 id;
        string name;

    }*/

  //  mapping(uint256 => crop) crops;

    function mint(uint caravana, string memory breed, uint weight, uint dateOfBirth, bool male) internal{
        require(!animalsCaravana[caravana].exists, "Another animal with that caravana still exists.");

        myEvent[] memory events;
        Animal memory _animal = Animal(caravana, breed, weight, dateOfBirth, male, true, events, animals.length+1);
        animalsCaravana[caravana]= _animal;

        //Token id = length de animals al momento de generar un nuevo animal.
        uint _id= animals.push(_animal);
        _mint (msg.sender, _id);
    }

    function updateAnimalWeight (uint caravana, uint newWeight) public payable{
        require(animalsCaravana[caravana].exists, "That animal does not exist.");
        address owner = ownerOf(animalsCaravana[caravana].tokenID);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved."
        );

        string memory str1= uint2str(caravana);
        string memory str2= concat(str1,"weight changed from");
        string memory str3= concat(str2,uint2str(animalsCaravana[caravana].weight));
        string memory str4= concat(str3, "kg to");
        string memory str5= concat(str4, uint2str(newWeight));
        string memory text= concat(str5, "kg.");

        animalsCaravana[caravana].events.push(myEvent(text, now));
        animalsCaravana[caravana].weight=newWeight;
    }

    function slaughter(uint caravana) public payable{
        require(animalsCaravana[caravana].exists, "That animal does not exist.");
        address owner = ownerOf(animalsCaravana[caravana].tokenID);
        require(msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved."
        );
        string memory str1= uint2str(caravana);
        string memory str2= concat( "Animal", str1);
        string memory text= concat(str2, "has been slaughtered or has died.");
        animalsCaravana[caravana].events.push(myEvent(text, now));
        animalsCaravana[caravana].exists=false;
    }


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