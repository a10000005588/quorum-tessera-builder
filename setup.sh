echo "##############################"
echo "#          Tessera           #"
echo "##############################"

currentDir="$(pwd)"

cp $currentDir/lib/tessera-init-sample.sh $currentDir/tessera
sh $currentDir/tessera/tessera-init-sample.sh

echo "##############################"
echo "#           Geth             #"
echo "##############################"

rm -rf $currentDir/node

cp $currentDir/lib/genesis_sample.json $currentDir
mv $currentDir/genesis_sample.json $currentDir/genesis.json

mkdir $currentDir/node

# Generate your geth account and private key.

echo "[*] Generate your geth account and private key"

geth --datadir $currentDir/node account new

# Generate the nodekey

cd $currentDir/node
bootnode --genkey=nodekey

echo "[*] The enode information is:\n"
bootnode --nodekey=nodekey --writeaddress


cp $currentDir/lib/static-nodes_sample.json $currentDir/node/static-nodes.json

# Initialize the geth data

geth --datadir $currentDir/node init $currentDir/genesis.json

