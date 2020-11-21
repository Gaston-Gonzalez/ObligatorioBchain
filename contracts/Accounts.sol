// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0 <0.8.0;

contract Accounts{

    struct FarmAccount {
        bool farm;
        bool exists;
        string description;
        bool admin;
        mapping (address => FarmLocation) farmLocations;
        uint farmlength;
        
    }
    mapping(address => FarmAccount) public farms;

    function isLocation(address sender, address from) public returns(bool){
        return farms[sender].farmLocations[from].exists;
    }
    function isAdmin(address sender) public returns(bool){
        return farms[sender].admin;
    }

    constructor () public {
        farms[msg.sender].admin = true;
    }

    struct FarmLocation{
        bool exists;
        string description;
        address farm;
    }

    function createFarm(string memory description, address _adresss) public{
        require(farms[msg.sender].admin, "Only admin can create Farms");
        farms[_adresss].description= description;
        farms[_adresss].exists= true;
        farms[_adresss].farm= true;
        farms[_adresss].farmlength=0;
    }

    function createFarmLocation(string memory description, address _address, address farmAddress) public{
        require(isFarm(farmAddress) && (msg.sender==farmAddress || farms[msg.sender].admin), "That address does not correspond to a farm");
        FarmAccount storage farm = farms[farmAddress];

        farm.farmLocations[_address].exists=true;
        farm.farmLocations[_address].description=description;
        farm.farmLocations[_address].farm=farmAddress;
        farm.farmlength+=1;

    }


    function isFarm (address myAccount) public view returns(bool){
        bool ok = false;
        if (farms [myAccount].exists){
            ok = true;
        } 
        return ok;
    }
}