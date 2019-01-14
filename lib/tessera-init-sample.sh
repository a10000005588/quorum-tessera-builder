echo "[*] Initialising Tessera configuration"

currentDir=$(pwd)
currentTesseraDir="${currentDir}/tessera"
    DDIR="${currentTesseraDir}/tdata"
    mkdir -p ${DDIR}
    mkdir -p ${DDIR}/logs
    mkdir -p ${DDIR}/keys
    echo "[*] Generating your Tessera Public Key and Private Key"

    java -jar ${currentTesseraDir}/app/tessera-app-0.8-SNAPSHOT-app.jar -keygen -filename tm
   
    mv -t ${DDIR}/keys tm.pub tm.key 
    
    echo "[*] The public key information:"
    cat ${DDIR}/keys/tm.pub
    echo "\n" 
    echo "[*] The private key information:"
    cat ${DDIR}/keys/tm.key
    echo "\n"
    echo "[*] Your key pairs are put in ${DDIR}/keys"
    # remvoe the processing daemon of the tessera server
    rm -f "${DDIR}/tm.ipc"

    #change tls to "strict" to enable it (don't forget to also change http -> https)
    cat <<EOF > ${DDIR}/tessera-config.json
{
    "useWhiteList": false,
    "jdbc": {
        "username": "sa",
        "password": "",
        "url": "jdbc:h2:${DDIR}/db$;MODE=Oracle;TRACE_LEVEL_SYSTEM_OUT=0"
    },
    "server": {
        "port": 9000,
        "hostName": "http://<node public ip>",   // add your node's public ip
        "bindingAddress": "http://0.0.0.0:9000",
        "sslConfig": {
            "tls": "OFF",
            "generateKeyStoreIfNotExisted": true,
            "serverKeyStore": "${DDIR}/server-keystore",
            "serverKeyStorePassword": "quorum",
            "serverTrustStore": "${DDIR}/server-truststore",
            "serverTrustStorePassword": "quorum",
            "serverTrustMode": "TOFU",
            "knownClientsFile": "${DDIR}/knownClients",
            "clientKeyStore": "${DDIR}/client-keystore",
            "clientKeyStorePassword": "quorum",
            "clientTrustStore": "${DDIR}/client-truststore",
            "clientTrustStorePassword": "quorum",
            "clientTrustMode": "TOFU",
            "knownServersFile": "${DDIR}/knownServers"
        }
    },
    "peer": [ // setting your peer's public ip 
        {
            "url": "http://<node1 public ip>:9000"
        },
        {
            "url": "http://<node2 public ip>:9000"
        },
        {
            "url": "http://<node3 public ip>:9000"
        }
    ],
    "keys": {
        "passwords": [],
        "keyData": [
            {   // if the node index is 1, modify <node-index> here with  node1  
                "privateKeyPath": "${DDIR}/tessera-key/<node-index>/tm.key",
                "publicKeyPath": "${DDIR}/tessera-key/<node-index>/tm.pub"
            }
        ]
    },
    "alwaysSendTo": [],
    "unixSocketFile": "${DDIR}/tm.ipc"
}
EOF
