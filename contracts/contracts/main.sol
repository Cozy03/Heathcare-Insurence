// SPDX-License-Identifier: MIT


pragma solidity ^0.8.0;

//Contract of ERC20

contract ERC20{
    string token_name;
    string token_symbol;
    uint8 token_decimals;
    uint256 token_totalsupply;
    
    mapping(address => uint256) ownerBalance;
    mapping(address => mapping (address => uint256)) allowedToSend;


    constructor(){
        token_name= "Hel Coin";
        token_symbol="Hcoin";
        token_decimals=0;
        token_totalsupply=21000000;
        ownerBalance[msg.sender]=token_totalsupply;
    }
    
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);



    function name() public view returns (string memory){
        return token_name;
    }

    function symbol() public view returns (string memory){
        return token_symbol;
    }

    function decimals() public view returns (uint8){
       return token_decimals;
    }
 
    function totalSupply() public view returns (uint256){
     return token_totalsupply;
    }
    

    function transfer(address _to, uint256 _value) public payable returns (bool success){
        if(ownerBalance[msg.sender]>=_value){
        ownerBalance[msg.sender]=ownerBalance[msg.sender]-_value;
        ownerBalance[_to]=ownerBalance[_to]+_value;
        emit Transfer(msg.sender,_to,_value); //Using Task 10
        return true;
        }
        else {
            return false;
        }
    }

     function balanceOf(address _owner) public view returns (uint256 balance){
         return ownerBalance[_owner];
     }

    function approve(address _spender, uint256 _value) public returns (bool success){
        allowedToSend[msg.sender][_spender]=_value;
        emit Approval(msg.sender,_spender,_value); //Using Task 11
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining){
    return allowedToSend[_owner][_spender];
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){
        require(_value<=ownerBalance[_from]);
        require(_value<=allowedToSend[_from][msg.sender]);
        ownerBalance[_from]=ownerBalance[_from]-_value;
        allowedToSend[_from][msg.sender]=allowedToSend[_from][msg.sender]-_value;
        ownerBalance[_to]=ownerBalance[_to]+_value; //Using Task 10
        emit Transfer(msg.sender,_to,_value);
        return true;
    }

}

//Contract for insurence

 contract Insurence is ERC20{
    address owner;
    address hospital_admin;
    address payable insurence_admin;
     constructor(address h_a){
       owner=msg.sender;
       hospital_admin=h_a;
    // insurence_admin=i_a;
     }

     // 1. User Functions

     //Defining the user variables
     struct User{
         uint user_id;
         string user_name;
         bool reg;
     }

     mapping(address => User) U;

     uint id=1;

     //Function to register a user

     function regUser(string memory _name) public {
        require(U[msg.sender].reg==false,"Already Registered");
        U[msg.sender].user_id=id;
        U[msg.sender].user_name=_name;
        U[msg.sender].reg=true;
        id++;
     }

     //View a User(Only by the user)

     function viewUserId(address _add) public view returns (User memory){
         require(msg.sender==_add,"Only the user can see its own details");
         return U[_add];
     }

     //functiin to claim a insurence cost

        function claim_insurence_cost(uint _i,uint _j,string memory _des,uint _cost) public {
            require(msg.sender==O[_j][msg.sender].user_add);
            Oparation memory op=Oparation(_i,_j,_des,_cost,msg.sender,false);
            leftClaims.push(op);
        }

    //  function check_insurence_claim_a(uint _i,uint _j,string memory _des,uint _cost) public view returns(bool){
    //      require(msg.sender==O[_j][msg.sender].user_add,"Only the claimers adress can call this function!");
    //       require(_i==O[_j][msg.sender].user_id,"Id of the adresses does not match.");
    //       require(keccak256(abi.encodePacked(_des))==keccak256(abi.encodePacked(O[_j][msg.sender].description)),"Description of Operation does not match.");
    //       require(_cost==O[_j][msg.sender].cost_for_claim,"Cost of claim is not correct");
    //       return true;
    //  }

    //See an oparation details

    function oparation_details(address a,uint b) public view returns(Oparation memory){
        require(msg.sender==a,"Only the oparation owner can see this message");
        return O[b][a];
    }


     
     //2. Hospital Record

     //Changing the hospital admin
     function change_hospital_admin(address _add) public{
         require(msg.sender==hospital_admin);
         hospital_admin=_add;
     }
    
    //Struct to hold user oparation
     struct Oparation{
       uint user_id;
       uint operation_id;
       string description;
       uint cost_for_claim;
       address user_add;
       bool claimed;
     }

     mapping (uint=>mapping (address=>Oparation)) O;
     uint j=1;

     //Setting an oparation
     function recording_oparation(address _add,string memory des,uint cost) public returns(uint){
        require(msg.sender==hospital_admin,"Only Hospital Admin can call this function");
        O[j][_add].user_id= U[_add].user_id;
        O[j][_add].operation_id=j;
        O[j][_add].description=des;
        O[j][_add].cost_for_claim=cost;
        O[j][_add].user_add=_add;
        O[j][_add].claimed=false;
        uint k=j;
        j++;
        return k;
     }    

    //3. Insurence company paying 

    //Claim Pool to use for traking unsetteled payments
    Oparation[] private leftClaims;

    //Checking the validity of a claim
    function check_insurence_claim(address a,uint _i,uint _j,string memory _des,uint _cost) public view returns(bool){
        require(a==O[_j][a].user_add,"Only the claimers adress can call this function!");
        require(_i==O[_j][a].user_id,"Id of the adresses does not match.");
        require(keccak256(abi.encodePacked(_des))==keccak256(abi.encodePacked(O[_j][a].description)),"Description of Operation does not match.");
        require(_cost==O[_j][a].cost_for_claim,"Cost of claim is not correct");
        return true;
     }

     function approve_claim(uint claim_no) public returns(bool){
       require(msg.sender==owner,"Only Insurence Admin can call this function!");
       Oparation memory x=leftClaims[claim_no];
       address a=x.user_add;
       uint _i=x.user_id;
       uint _j=x.operation_id;
       string memory _des=x.description;
       uint _cost=x.cost_for_claim;
       require(check_insurence_claim(a,_i, _j, _des, _cost)==true,"The Claim Presented in `i` not true");
    //    uint amt=_cost*1 wei;
    //    payee.transfer(amt);
       transfer(a, _cost);
       remove_i_claim(claim_no);
       O[j][O[_j][a].user_add].claimed=true;
       return true;
     }

     function claim_pool_size() public view returns(uint){
        return leftClaims.length;
     }

     function remove_i_claim(uint i) public {
         uint k=0;
         uint p=claim_pool_size();
         for(k=i+1;k<p;k++){
            leftClaims[k-1]=leftClaims[k];
         }
         leftClaims.pop();
     }
 }