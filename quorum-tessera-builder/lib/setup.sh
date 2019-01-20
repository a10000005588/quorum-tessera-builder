echo "####################################"
echo "#  Start Setting Your Quorum Node  #"
echo "####################################"

pkill java
pkill geth
rm genesis.json

node_name="node"
rm -rf $node_name
rm nohup.out

currentDir=$(pwd)
currentTesseraDir="${currentDir}/tessera"

export currentTesseraDir

echo "[*] Please enter the IP address of this node:"
read node_IP_address

echo "#################################################################"
echo "#   Suggestion: Setting Your Port Number between 22000-22010    #"
echo "#################################################################"

echo "[*] Please enter RPC port [default:22000]:"
read node_rpc_port

if ["${node_rpc_port}" == ""]; then
    node_rpc_port=22000
fi

echo "[*] Please enter Network Listening port [default:22001]:"
read node_network_port

if ["${node_network_port}" == ""]; then
    node_network_port=22001
fi

echo "[*] Please enter Tessera port [default:22002]:"
read node_tessera_port

if ["${node_tessera_port}" == ""]; then
    node_tessera_port=22002
fi

echo "[*] Please enter Raft port [default:22003 ]: "
read node_raft_port 

if ["${node_raft_port}" == ""]; then
    node_raft_port=22003
fi

echo "[*] Please enter Node Manager Port [default:22004]: "
read node_manager_port

if ["${node_manager_port}" == ""]; then
    node_manager_port=22004
fi

echo "[*] Please enter WS Port [default:22005]: "
read node_ws_port

if ["${node_ws_port}" == ""]; then
    node_ws_port=22005
fi

export node_tessera_port
export node_IP_address

echo "#############################################"
echo "#        Create Tessera Key Pair            #"
echo "#############################################"

cp $currentDir/lib/tessera/tessera-init-sample.sh $currentDir/tessera
. $currentDir/tessera/tessera-init-sample.sh

echo "#########################################"
echo "#          Create Geth Account          #"
echo "#########################################"

rm -rf $currentDir/$node_name

cp $currentDir/lib/quorum/genesis_sample.json $currentDir
mv $currentDir/genesis_sample.json $currentDir/genesis.json

mkdir $currentDir/$node_name

# Generate your geth account and private key.

echo "[*] Generate your geth account and private key"

geth --datadir $currentDir/$node_name account new

cd $currentDir/$node_name
bootnode --genkey=nodekey

# Generate the nodekey and enode...
node_enode=$(bootnode --nodekey=nodekey --writeaddress)

    cat <<EOF > $currentDir/$node_name/static-nodes.json
["enode://$node_enode@$node_IP_address:$node_ws_port?discport=0&raftport=$node_raft_port"]
EOF

# cp $currentDir/lib/static-nodes_sample.json $currentDir/$node_name/static-nodes.json

# Initialize the geth data
cd $currentDir
geth --datadir $node_name init $currentDir/genesis.json

sleep 2

echo "[*] Start tessera services... "
nohup java -jar $currentTesseraDir/app/tessera-app-0.9-SNAPSHOT-app.jar -configfile $currentTesseraDir/tdata/tessera-config.json >> $currentTesseraDir/tdata/logs/tessera.log 2>&1 &

sleep 15

echo "[*] Start quorum network... "

mkdir $currentDir/$node_name/logs

PRIVATE_CONFIG=$currentTesseraDir/tdata/tm.ipc nohup geth --datadir $node_name --nodiscover --verbosity 5 --networkid 31337 --raft --raftport $node_raft_port --rpc --rpcaddr 0.0.0.0 --rpcport $node_rpc_port --rpcapi admin,db,eth,debug,miner,net,shh,txpool,personal,web3,quorum,raft --emitcheckpoints --port $node_manager_port 2>>$currentDir/$node_name/logs/node.log &

sleep 5

echo "*******************************************************************"
echo "Your Quorum Node has successfully running    "
echo "You can send transactions to :$node_raft_port"
echo "For private transactions, use tessera public key(in /tessera/tdata/keys/tm.pub)"
echo "For accessing Quorum UI, please open the following from a web browser http://localhost:$node_manager_port/"
echo "To join this node from a different host, choose option 'Join Network'"
echo "When asked, enter for Existing Node IP and $node_manager_port for Node Manager Port"
echo "*******************************************************************"
