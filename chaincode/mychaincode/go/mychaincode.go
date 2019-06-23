package main

import (
	"encoding/json"
	"fmt"
	"strings"
	"strconv"

	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"

	// "fmt"
	// "strconv"

	// "github.com/hyperledger/fabric/core/chaincode/shim/ext/cid"
	// "github.com/hyperledger/fabric/core/chaincode/shim"
	// pb "github.com/hyperledger/fabric/protos/peer"
)
type SimpleChaincode struct {

}

type User struct {
	Name string `json:"name"`
	StdID string `json:"stdID"`
	Tel string `json:"tel"`
	Status bool `json:"status"`
} 

type Wallet struct {
	Walletname string
	Money int
	Owner string	
}

func (t *SimpleChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	return shim.Success(nil)
}
func (t *SimpleChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {


	fmt.Println("abac Invoke")
	function, args := stub.GetFunctionAndParameters()
	if function == "createUser" {
		// Make payment of X units from A to B
		return t.createUser(stub, args)
	} else  if function == "createwallet" {
		// Deletes an entity from its state
		return t.createwallet(stub, args)
	} else  if function == "query" {
		// the old "Query" is now implemtned in invoke
		return t.query(stub, args)
	} else if function == "AA" {
		return t.AA(stub, args)
	} 

	return shim.Error("Invalid invoke function name. Expecting  \"query\"")
}

func (t *SimpleChaincode) createUser(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	jsutString := strings.Join(args,"")
	args = strings.Split(jsutString,"|")
	//var err error

	//   0       1       2     
	// "name"	ID		tel
	if len(args) != 3 {
		return shim.Error("Incorrect number of arguments. Expecting 3")
	}
	// fmt.Println("start init model")
	// if len(args[0]) <+ 0{
	// 	return shim.Error("1st") 
	// }
	// if len(args[1]) <+ 0{
	// 	return shim.Error("2nd") 
	// }
	// if len(args[2]) <+ 0{
	// 	return shim.Error("3rd") 
	// }
	name := strings.ToLower(args[0])
	stdID := args[1]
	tel := args[2]
	userkey := "stdID|" + stdID
	// // keybytes, err := stub.GetState(userkey)
	// // if keybytes == nil {
	// // 	return shim.Error(err.Error())
	// // }
	// if err != nil {
	// 	return shim.Error(err.Error())
	// }

	user := &User{
		StdID : stdID,
		Name : name,
		Tel : tel,
		Status : true,
	}
	userjsonbytes,err := json.Marshal(user)
	if err != nil {
		return shim.Error(err.Error())
	}
	err = stub.PutState(userkey,userjsonbytes)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Success(nil)
}

func (t *SimpleChaincode) createwallet(stub shim.ChaincodeStubInterface, args []string) pb.Response {

	jsutString := strings.Join(args,"")
	args = strings.Split(jsutString,"|")

	// 	0			1			2
	// 	walletname	money		owner
	if len(args) != 3 {
		return shim.Error("Incorrect number of arguments. Expecting 3")
	}
	walletname := strings.ToLower(args[0])
	// money := args[1]
	owner := args[2]
	walletkey := "wallet|" + walletname
	//check
	keybytes,err := stub.GetState(walletkey)
	if keybytes != nil {
		keybytes := "wallet walletkey already exists : "+walletkey
		return shim.Error(keybytes)
	}
	if err != nil {
		return shim.Error("Invalid transaction amount, excpting a integer value")
	}
	Money,err := strconv.Atoi(args[1])
	if err != nil{
		return shim.Error("money isn't Int" + err.Error())
	}
	wallet := &Wallet {
		Walletname : walletname,
		Money : Money,
		Owner : owner,
	}
	walletjsonbytes,err := json.Marshal(wallet)
	if err != nil{
		return shim.Error("Marshal is Error" + err.Error())
	}
	err = stub.PutState(walletkey,walletjsonbytes)
	if err != nil{
		return shim.Error("Putstate is error " + err.Error())
	}
	return shim.Success(nil)
}


func (t *SimpleChaincode) query(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	// Entities
	var A string
	//ใช้ดึงข้อมูลและแสดงผลออกมาว่ามี id  ตามนั้นหรือไม่

	if len(args) != 1 {
		return shim.Error("Incorrect number of arguments. Expecting name of the person to query")
	}

	A = args[0]

	// Get the state from the ledger
	jsonbytes, err := stub.GetState(A)
	if err != nil {
		jsonResp := "{\"Error\":\"Failed to get state for " + A + "\"}"
		return shim.Error(jsonResp)
	}

	if jsonbytes == nil {
		jsonResp := "{\"Error\":\"Nil amount for " + A + "\"}"
		return shim.Error(jsonResp)
	}

	jsonResp := "{\"Name\":\"" + A + "\",\"Amount\":\"" + string(jsonbytes) + "\"}"
	fmt.Printf("Query Response:%s\n", jsonResp)
	return shim.Success(jsonbytes)
}
func (t *SimpleChaincode) AA(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//   0       1       2     
	// "name"	ID		tel
	if len(args) != 3 {
		return shim.Error("Incorrect number of arguments. Expecting 3")
	}
	name := strings.ToLower(args[0])
	stdID := args[1]
	tel := args[2]
	userkey := "stdID|" + stdID
	keybytes, err := stub.GetState(userkey)
	if keybytes == nil {
		return shim.Error(err.Error())
	}
	if err != nil {
		return shim.Error(err.Error())
	}

	user := &User{
		StdID : stdID,
		Name : name,
		Tel : tel,
		Status : true,
	}
	userjsonbytes,err := json.Marshal(user)
	if err != nil {
		return shim.Error(err.Error())
	}
	err = stub.PutState(userkey,userjsonbytes)
	if err != nil {
		return shim.Error(err.Error())
	}
	return shim.Error("Putstate is error"+err.Error())
}
func main() {
	err := shim.Start(new(SimpleChaincode))
	if err != nil {
		fmt.Printf("Error starting Simple chaincode: %s", err)
	}

}