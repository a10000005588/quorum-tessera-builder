echo "[*] Initialising Tessera configuration"

currentDir=$(pwd)
currentTesseraDir="${currentDir}/tessera"
    DDIR="${currentTesseraDir}/tdata"
    mkdir -p ${DDIR}
    mkdir -p ${DDIR}/logs
    mkdir -p ${DDIR}/keys
    echo "[*] Generating your Tessera Public Key and Private Key"

    java -jar ${currentTesseraDir}/app/tessera-app-0.9-SNAPSHOT-app.jar -keygen -filename tm
   
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
        "port": $node_tessera_port,
        "hostName": "http://$node_IP_address",  
        "bindingAddress": "http://0.0.0.0:$node_tessera_port",
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
    "peer": [
        {
            "url": "http://$node_IP_address:$node_tessera_port"
        }
    ],
    "keys": {
        "passwords": [],
        "keyData": [
            {   
                "privateKeyPath": "${DDIR}/keys/tm.key",
                "publicKeyPath": "${DDIR}/keys/tm.pub"
            }
        ]
    },
    "alwaysSendTo": [],
    "unixSocketFile": "${DDIR}/tm.ipc"
}
EOF
