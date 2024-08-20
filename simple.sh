#!/bin/bash

# linera-link simple deploy script
# Usage: ./scripts/simple.sh <wallet_directory>

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <wallet_directory>"
    exit 1
fi

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd ) && cd $SCRIPT_DIR/..
WALLET_DIR="$1"

cargo build --release

LINK_BYTE_ID=`linera publish-bytecode ./target/wasm32-unknown-unknown/release/linera-link_{contract,service}.wasm`
LINK_APP_ID=`linera create-application $LINK_BYTE_ID`

echo -e "\nLinera-Link successfully deployed!"
echo -e "Bytecode ID: $LINK_BYTE_ID"
echo -e "Application ID: $LINK_APP_ID\n"

WALLET=$WALLET_DIR/wallet_2.json
STORAGE=rocksdb:$WALLET_DIR/linera2.db

echo -e "\nInitialization and opening chain for wallet...\n"
linera --wallet $WALLET --storage $STORAGE wallet init --genesis $WALLET_DIR/genesis.json

echo -e "\nCreating an unassigned keypair for wallet...\n"
PUB_KEY=`linera --wallet $WALLET --storage $STORAGE keygen`

echo -e "\nOpening chain for wallet...\n"
CHAIN=$(linera open-chain --to-public-key $PUB_KEY 2>/dev/null)
MES_ID=$(echo "$CHAIN" | sed -n '1 p')
linera --wallet $WALLET --storage $STORAGE assign --key $PUB_KEY --message-id $MES_ID
linera --wallet $WALLET --storage $STORAGE wallet show

linera wallet show

echo -n "Enter the first wallet: "
read ACCOUNT1
echo -n "Enter the second wallet: "
read ACCOUNT2
FUNGIBLE_BYTE_ID=$(linera publish-bytecode ./target/wasm32-unknown-unknown/release/fungible_{contract,service}.wasm)
JSON_ARGUMENT="{\"accounts\": {
    \"User:$ACCOUNT1\": \"1000.\",
    \"User:$ACCOUNT2\": \"2000.\"
}}"
FUNGIBLE_APP_ID=$(linera create-application $FUNGIBLE_BYTE_ID --json-argument "$JSON_ARGUMENT")

echo -e "\nLinera-Fungible successfully deployed!"
echo -e "Bytecode ID: $FUNGIBLE_BYTE_ID"
echo -e "Application ID: $FUNGIBLE_APP_ID\n"

bash frontend.sh e476187f6ddfeb9d588c7b45d3df334d5501d6499b3f9ad5595cae86cce16a65 $LINK_APP_ID $FUNGIBLE_APP_ID 8080

echo -e "\nRunning service for wallet on port :8081...\n"
linera --wallet $WALLET --storage $STORAGE service --port $2 &
linera service &
