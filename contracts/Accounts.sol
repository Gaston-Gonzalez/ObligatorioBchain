// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0 <0.8.0;

contract Accounts{

    struct FarmAccount {
        bool exists;
        string description;
        bool admin;
        mapping (uint => FarmLocation) farmLocations;
        
    }
    mapping(address => FarmAccount) farms;

    constructor () public {
        farms[msg.sender].admin = true;
    }

    struct FarmLocation{
        bool exists;
        string description;
        address farm;
    
    }


  

    function AccountType (address myAccount) public view returns 

        }

        //

       
    }
}