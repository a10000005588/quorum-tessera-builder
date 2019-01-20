
dockerImage="a10000005588/quorum-tessera-builder"

echo "[*] Preparing 'quorum-tessera-builder'.........."

docker run -it -d -p 22000-22010:22000-22010 $dockerImage 

echo "[*] If create container successfully, please use 'docker exec -it <container-id> bash'"
echo "[*] And execute the ./menu.sh to run installing the Quorum and Tessera"
