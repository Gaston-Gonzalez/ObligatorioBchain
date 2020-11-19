// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0 <0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721Full.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Burnable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Mintable.sol";


contract animalToken is ERC721, ERC721Full, ERC721Burnable, ERC721Mintable {
  struct animal {
        uint256 id;
        string name;
        uint64 weight;
        bool male;
        bool exists;
    }

    mapping(uint256 => animal) animals;

    struct myEvent{
        uint256 id;
        //timestamp

    }

    constructor() ERC721Full("Animal", "ANI") public{

    }
   /* struct crop{
        uint256 id;
        string name;

    }*/

  //  mapping(uint256 => crop) crops;
/*
    function mint() public{
        _mint (msg.sender, _id);
    }
*/
    function updateAnimalWeight (uint256 id, uint64 newWeight) public payable{
        animals[id].weight=newWeight;
        //this.weight = newWeight;

        //crear animal en el id 1000
        animals[1000].id = 1000;
        animals[1000].name = 'pepito';
        animals[1000].weight = 500;
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