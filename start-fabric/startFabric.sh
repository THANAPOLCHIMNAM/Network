#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error
set -e

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1
starttime=$(date +%s)
CC_SRC_LANGUAGE=${1:-"go"}
CC_SRC_LANGUAGE=`echo "$CC_SRC_LANGUAGE" | tr [:upper:] [:lower:]`
if [ "$CC_SRC_LANGUAGE" = "go" -o "$CC_SRC_LANGUAGE" = "golang"  ]; then
	CC_RUNTIME_LANGUAGE=golang
	CC_SRC_PATH=github.com/mychaincode/go

elif [ "$CC_SRC_LANGUAGE" = "javascript" ]; then
	CC_RUNTIME_LANGUAGE=node # chaincode runtime language is node.js
	CC_SRC_PATH=/opt/gopath/src/github.com/mychaincode/javascript
elif [ "$CC_SRC_LANGUAGE" = "typescript" ]; then
	CC_RUNTIME_LANGUAGE=node # chaincode runtime language is node.js
	CC_SRC_PATH=/opt/gopath/src/github.com/mychaincode/typescript
	echo Compiling TypeScript code into JavaScript ...
	pushd ../chaincode/mychaincode/typescript
	npm install
	npm run build
	popd
	echo Finished compiling TypeScript code into JavaScript
else
	echo The chaincode language ${CC_SRC_LANGUAGE} is not supported by this script
	echo Supported chaincode languages are: go, javascript, and typescript
	exit 1
fi


# clean the keystore
rm -rf ./hfc-key-store
rm -rf ./user1/wallet
rm -rf ./user2/wallet
rm -rf ./user3/wallet




# # launch network; create channel and join peer to channel
cd ../basic-network
./start.sh

# # Now launch the CLI container in order to install, instantiate chaincode
# # and prime the ledger with our 10 cars
# docker-compose -f docker-compose.yml up -d 
# docker ps -a

cat <<EOF
###########################################################SUCCEED#############################################################################
EOF

CONFIG_ROOT=/opt/gopath/src/github.com/hyperledger/fabric/peer
ORG1_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp
PEER0ORG1_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/org1.example.com/peers/peer0.org1.example.com/tls/ca.crt
PEER1ORG1_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/org1.example.com/peers/peer1.org1.example.com/tls/ca.crt

ORG2_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/org2.example.com/users/Admin@org2.example.com/msp
PEER0ORG2_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/org2.example.com/peers/peer0.org2.example.com/tls/ca.crt
PEER1ORG2_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/org2.example.com/peers/peer1.org2.example.com/tls/ca.crt

ORG3_MSPCONFIGPATH=${CONFIG_ROOT}/crypto/peerOrganizations/org3.example.com/users/Admin@org3.example.com/msp
PEER0ORG3_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/org3.example.com/peers/peer0.org3.example.com/tls/ca.crt
PEER1ORG3_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/peerOrganizations/org3.example.com/peers/peer1.org3.example.com/tls/ca.crt

ORDERER_TLS_ROOTCERT_FILE=${CONFIG_ROOT}/crypto/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem
set -x

echo "Installing smart contract on peer0.org1.example.com"
docker exec \
-e CORE_PEER_LOCALMSPID=Org1MSP \
-e CORE_PEER_ADDRESS=peer0.org1.example.com:7051 \
-e CORE_PEER_MSPCONFIGPATH=${ORG1_MSPCONFIGPATH} \
-e CORE_PEER_TLS_ROOTCERT_FILE=${PEER0ORG1_TLS_ROOTCERT_FILE} \
cli \
peer chaincode install \
-n mychaincode \
-v 1.0 \
-p "$CC_SRC_PATH" \
-l "$CC_RUNTIME_LANGUAGE"

echo "Installing smart contract on peer1.org1.example.com"
docker exec \
-e CORE_PEER_LOCALMSPID=Org1MSP \
-e CORE_PEER_ADDRESS=peer1.org1.example.com:7051 \
-e CORE_PEER_MSPCONFIGPATH=${ORG1_MSPCONFIGPATH} \
-e CORE_PEER_TLS_ROOTCERT_FILE=${PEER1ORG1_TLS_ROOTCERT_FILE} \
cli \
peer chaincode install \
-n mychaincode \
-v 1.0 \
-p "$CC_SRC_PATH" \
-l "$CC_RUNTIME_LANGUAGE"

echo "Installing smart contract on peer0.org2.example.com"
docker exec \
-e CORE_PEER_LOCALMSPID=Org2MSP \
-e CORE_PEER_ADDRESS=peer0.org2.example.com:7051 \
-e CORE_PEER_MSPCONFIGPATH=${ORG2_MSPCONFIGPATH} \
-e CORE_PEER_TLS_ROOTCERT_FILE=${PEER0ORG2_TLS_ROOTCERT_FILE} \
cli \
peer chaincode install \
-n mychaincode \
-v 1.0 \
-p "$CC_SRC_PATH" \
-l "$CC_RUNTIME_LANGUAGE"

echo "Installing smart contract on peer1.org2.example.com"
docker exec \
-e CORE_PEER_LOCALMSPID=Org2MSP \
-e CORE_PEER_ADDRESS=peer1.org2.example.com:7051 \
-e CORE_PEER_MSPCONFIGPATH=${ORG2_MSPCONFIGPATH} \
-e CORE_PEER_TLS_ROOTCERT_FILE=${PEER1ORG2_TLS_ROOTCERT_FILE} \
cli \
peer chaincode install \
-n mychaincode \
-v 1.0 \
-p "$CC_SRC_PATH" \
-l "$CC_RUNTIME_LANGUAGE"

echo "Installing smart contract on peer0.org3.example.com"
docker exec \
-e CORE_PEER_LOCALMSPID=Org3MSP \
-e CORE_PEER_ADDRESS=peer0.org3.example.com:7051 \
-e CORE_PEER_MSPCONFIGPATH=${ORG3_MSPCONFIGPATH} \
-e CORE_PEER_TLS_ROOTCERT_FILE=${PEER0ORG3_TLS_ROOTCERT_FILE} \
cli \
peer chaincode install \
-n mychaincode \
-v 1.0 \
-p "$CC_SRC_PATH" \
-l "$CC_RUNTIME_LANGUAGE"

echo "Installing smart contract on peer1.org3.example.com"
docker exec \
-e CORE_PEER_LOCALMSPID=Org3MSP \
-e CORE_PEER_ADDRESS=peer1.org3.example.com:7051 \
-e CORE_PEER_MSPCONFIGPATH=${ORG3_MSPCONFIGPATH} \
-e CORE_PEER_TLS_ROOTCERT_FILE=${PEER1ORG3_TLS_ROOTCERT_FILE} \
cli \
peer chaincode install \
-n mychaincode \
-v 1.0 \
-p "$CC_SRC_PATH" \
-l "$CC_RUNTIME_LANGUAGE"


cat <<EOF
###########################################################OK#############################################################################
EOF

echo "Instantiating smart contract on mychannel"
docker exec \
-e CORE_PEER_LOCALMSPID=Org1MSP \
-e CORE_PEER_ADDRESS=peer0.org1.example.com:7051 \
-e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp \
-e CORE_PEER_TLS_ROOTCERT_FILE=${PEER0ORG1_TLS_ROOTCERT_FILE} \
peer0.org1.example.com \
peer chaincode instantiate \
-o orderer.example.com:7050 \
-C mychannel \
-n mychaincode \
-l "$CC_RUNTIME_LANGUAGE" \
-v 1.0 \
-c '{"Args":[""]}' \
-P "OR('Org1MSP.member','Org2MSP.member','Org3MSP.member')" \

cat <<EOF
###########################################################GOOD#############################################################################
EOF


# docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode install -n mychaincode -v 1.0 -p "$CC_SRC_PATH" -l "$CC_RUNTIME_LANGUAGE"
# docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode instantiate -o orderer.example.com:7050 -C mychannel -n mychaincode -l "$CC_RUNTIME_LANGUAGE" -v 1.0 -c '{"Args":[]}' -P "OR ('Org1MSP.member','Org2MSP.member')"
# sleep 10
# docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode invoke -o orderer.example.com:7050 -C mychannel -n mychaincode -c '{"function":"initLedger","Args":[]}'

# cat <<EOF

# Total setup execution time : $(($(date +%s) - starttime)) secs ...

# Next, use the mychaincode applications to interact with the deployed mychaincode contract.
# The mychaincode applications are available in multiple programming languages.
# Follow the instructions for the programming language of your choice:

# JavaScript:

#   Start by changing into the "javascript" directory:
#     cd javascript

#   Next, install all required packages:
#     npm install

#   Then run the following applications to enroll the admin user, and register a new user
#   called user1 which will be used by the other applications to interact with the deployed
#   mychaincode contract:
#     node enrollAdmin
#     node registerUser

#   You can run the invoke application as follows. By default, the invoke application will
#   create a new car, but you can update the application to submit other transactions:
#     node invoke

#   You can run the query application as follows. By default, the query application will
#   return all cars, but you can update the application to evaluate other transactions:
#     node query

# TypeScript:

#   Start by changing into the "typescript" directory:
#     cd typescript

#   Next, install all retquired packages:
#     npm install

#   Next, compile the TypeScript code into JavaScript:
#     npm run build

#   Then run the following applications to enroll the admin user, and register a new user
#   called user1 which will be used by the other applications to interact with the deployed
#   mychaincode contract:
#     node dist/enrollAdmin
#     node dist/registerUser

#   You can run the invoke application as follows. By default, the invoke application will
#   create a new car, but you can update the application to submit other transactions:
#     node dist/invoke

#   You can run the query application as follows. By default, the query application will
#   return all cars, but you can update the application to evaluate other transactions:
#     node dist/query

# EOF
