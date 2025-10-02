#!/bin/bash


set -e


#function deploy_local () {
# 
#  export AUTHPROXY_ADDRESS=0x0000000000000000000000000000000000000000
#
#  _run_deployment forge script script/Deploy.s.sol:DeployEPC \
#    --fork-url http://localhost:8545 \
#    --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
#    --broadcast --ffi -vvvv --color always \
#    $@
#}



function deploy_sepolia () {
  export AUTHPROXY_ADDRESS=0x0000000000000000000000000000000000000000
  _run_deployment forge script script/Deploy.s.sol:DeployEPC \
    --chain sepolia --rpc-url $SEPOLIA_RPC_URL \
    --broadcast --ffi -vvvv --color always \
    $PROD_SIGNER \
    $@
}

function _run_deployment () {
  $@ |& tee log.txt

  # Remove colors from log
  #sed -ie 's/\x1b\[[0-9;]*m//g' log.txt
}


##
## This is called from solidity test code using forge test --ffi
function facetMethodIds () {

  mapfile -t lines < <(jq -r .methodIdentifiers[] out/*.sol/$1.json)

  # Count the number of lines
  line_count=${#lines[@]}

  # Convert the line count to hexadecimal
  hex_count=$(printf '%x' "$line_count")

  # Pad the hexadecimal number with zeros to the left to make it up to 64 bytes
  padded_hex=$(printf '%064s' "$hex_count" | tr ' ' '0')

  # Output the padded hexadecimal number
  echo -n 0000000000000000000000000000000000000000000000000000000000000020
  echo -n "$padded_hex"

  # Output each line padded to the left in the same way
  for line in "${lines[@]}"; do
    printf '%-64s' "$line" | tr ' ' '0'
  done
}



if [ -z "$1" ]; then                                     
  echo "Commands:"                                       
  echo                                                   
  cat $0 | sed -rne 's/^function ([^_][^ \(]+).*/  \1/p'     
  echo                                                   
else                                                     
                                                         
  set -a # auto export variables                         
  . .env
  . .env.local
  set +a # end auto export                               

  cmd=$1           # Get the function name from argv     
  shift            # Remove function name                
  eval $cmd $@     # Call function and parse arguments   
fi                                                       

