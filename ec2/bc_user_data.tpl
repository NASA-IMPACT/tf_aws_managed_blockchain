Content-Type: multipart/mixed; boundary="//"
MIME-Version: 1.0

--//
Content-Type: text/cloud-config; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="cloud-config.txt"

#cloud-config
cloud_final_modules:
- [scripts-user, always]

--//
Content-Type: text/x-shellscript; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="userdata.txt"

#!/usr/bin/env bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
yum update -y
yum install jq libtool libtool-ltdl-devel wget python3-pip git -y
curl -L https://github.com/docker/compose/releases/download/1.20.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod a+x /usr/local/bin/docker-compose
VpcEndpointServiceName=$(aws managedblockchain get-network --region ${REGION} --network-id ${NETWORKID}  --query 'Network.VpcEndpointServiceName' --output text)
OrderingServiceEndpoint=$(aws managedblockchain get-network --region ${REGION}  --network-id ${NETWORKID}  --query 'Network.FrameworkAttributes.Fabric.OrderingServiceEndpoint' --output text)
CaEndpoint=$(aws managedblockchain get-member --region ${REGION}  --network-id ${NETWORKID}  --member-id ${MEMBERID}  --query 'Member.FrameworkAttributes.Fabric.CaEndpoint' --output text)
nodeID=${MEMEBERNODEID}
peerEndpoint=$(aws managedblockchain get-node --region ${REGION}  --network-id ${NETWORKID}  --member-id ${MEMBERID}  --node-id $nodeID --query 'Node.FrameworkAttributes.Fabric.PeerEndpoint' --output text)
peerEventEndpoint=$(aws managedblockchain get-node --region ${REGION}  --network-id ${NETWORKID}  --member-id ${MEMBERID}  --node-id $nodeID --query 'Node.FrameworkAttributes.Fabric.PeerEventEndpoint' --output text)
# Exports to be exported before executing any Fabric 'peer' commands via the CLI
cat << EXPORT_ENVS > /tmp/peer-exports.sh
NETWORKNAME=${NETWORKNAME}
MEMBERNAME=${MEMBERNAME}
NETWORKVERSION=${NETWORKVERSION}
ADMINUSER=${ADMINUSER}
ADMINPWD=${ADMINPWD}
NETWORKID=${NETWORKID}
MEMBERID=${MEMBERID}
ORDERINGSERVICEENDPOINT=$OrderingServiceEndpoint
ORDERINGSERVICEENDPOINTNOPORT=$(echo $OrderingServiceEndpoint| cut -d ':'  -f 1-1 )
VPCENDPOINTSERVICENAME=$VpcEndpointServiceName
CASERVICEENDPOINT=$CaEndpoint
PEERNODEID=$nodeID
PEERSERVICEENDPOINT=$peerEndpoint
PEERSERVICEENDPOINTNOPORT=$(echo $peerEndpoint| cut -d ':'  -f 1-1 )
PEEREVENTENDPOINT=$peerEventEndpoint
MSP_PATH=/opt/home/admin-msp
MSP=${MEMBERID}
ORDERER=$OrderingServiceEndpoint
PEER=$peerEndpoint
CHANNEL=${CHANNELID}
CAFILE=/opt/home/managedblockchain-tls-chain.pem
CHAINCODENAME=${CHANNELCODENAME}
CHAINCODEVERSION=v0
CHAINCODEDIR=github.com/chaincode_example02/go
BUCKETNAME=${STORAGE_BUCKET}
EXPORT_ENVS
source /tmp/peer-exports.sh
cat << EOFDOCKER > /tmp/docker-compose-cli.yaml
version: '2'
services:
  cli:
    container_name: cli
    image: hyperledger/fabric-tools:2.2.3
    tty: true
    environment:
      - GOPATH=/opt/gopath
      - CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock
      - FABRIC_LOGGING_SPEC=info # Set logging level to debug for more verbose logging
      - CORE_PEER_ID=cli
      - CORE_CHAINCODE_KEEPALIVE=10
      - CORE_PEER_TLS_ENABLED=true
      - CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/managedblockchain-tls-chain.pem
      - CORE_PEER_LOCALMSPID=${MEMBERID}
      - CORE_PEER_MSPCONFIGPATH=/opt/home/admin-msp
      - CORE_PEER_ADDRESS=$PEERSERVICEENDPOINT
    working_dir: /opt/home
    command: /bin/bash
    volumes:
        - /var/run/:/host/var/run/
        - /home/ec2-user/fabric-samples/chaincode:/opt/gopath/src/github.com/
        - /home/ec2-user/:/opt/home

EOFDOCKER



sudo -u ec2-user -i <<EOF1
cd /home/ec2-user/
cp /tmp/peer-exports.sh /home/ec2-user/peer-exports.sh
pip install --upgrade awscli
rm -rf fabric-samples
git clone --branch v2.2.3 https://github.com/hyperledger/fabric-samples.git
aws s3 cp s3://us-east-1.managedblockchain/etc/managedblockchain-tls-chain.pem  /home/ec2-user/managedblockchain-tls-chain.pem
source /home/ec2-user/peer-exports.sh
curl https://\$CASERVICEENDPOINT/cainfo -k
mkdir -p /home/ec2-user/go/src/github.com/hyperledger/fabric-ca
cd /home/ec2-user/go/src/github.com/hyperledger/fabric-ca
wget https://github.com/hyperledger/fabric-ca/releases/download/v1.4.7/hyperledger-fabric-ca-linux-amd64-1.4.7.tar.gz
tar -xzf hyperledger-fabric-ca-linux-amd64-1.4.7.tar.gz
cd /home/ec2-user/
cp /tmp/docker-compose-cli.yaml /home/ec2-user/docker-compose-cli.yaml
docker-compose -f docker-compose-cli.yaml up -d
/home/ec2-user/go/src/github.com/hyperledger/fabric-ca/bin/fabric-ca-client enroll -u "https://${ADMINUSER}:${ADMINPWD}@\$CASERVICEENDPOINT" --tls.certfiles /home/ec2-user/managedblockchain-tls-chain.pem -M /home/ec2-user/admin-msp
cp -r /home/ec2-user/admin-msp/signcerts admin-msp/admincerts
cat << EOFCONFIG > /home/ec2-user/configtx.yaml
Organizations:
    - &Org1
        Name: ${MEMBERID}
        ID: ${MEMBERID}
        SkipAsForeign: false
        Policies: &Org1Policies
            Readers:
                Type: Signature
                Rule: "OR('Org1.member')"
            Writers:
                Type: Signature
                Rule: "OR('Org1.member')"
            Admins:
                Type: Signature
                Rule: "OR('Org1.admin')"
        MSPDir: /opt/home/admin-msp
        AnchorPeers:
            - Host: 127.0.0.1
              Port: 7051
Capabilities:
    Channel: &ChannelCapabilities
        V2_0: true
    Orderer: &OrdererCapabilities
        V2_0: true
    Application: &ApplicationCapabilities
        V2_0: true
Channel: &ChannelDefaults
    Policies:
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"
    Capabilities:
        <<: *ChannelCapabilities
Application: &ApplicationDefaults
    Organizations:
    Policies: &ApplicationDefaultPolicies
        LifecycleEndorsement:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Endorsement:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Readers:
            Type: ImplicitMeta
            Rule: "ANY Readers"
        Writers:
            Type: ImplicitMeta
            Rule: "ANY Writers"
        Admins:
            Type: ImplicitMeta
            Rule: "MAJORITY Admins"

    Capabilities:
        <<: *ApplicationCapabilities
Profiles:
    OneOrgChannel:
        <<: *ChannelDefaults
        Consortium: AWSSystemConsortium
        Application:
            <<: *ApplicationDefaults
            Organizations:
                - <<: *Org1

EOFCONFIG
docker exec cli configtxgen -outputCreateChannelTx /opt/home/${CHANNELID}.pb -profile OneOrgChannel -channelID ${CHANNELID} --configPath /opt/home/
aws s3 cp ${S3URIBCCODE} .
EOF1
echo "Allowing blockchain to be established"
sleep 300
source /home/ec2-user/peer-exports.sh
echo "Now Creating the channel"
docker exec cli peer channel create -c ${CHANNELID} -f /opt/home/${CHANNELID}.pb -o $ORDERER --cafile /opt/home/managedblockchain-tls-chain.pem --tls
docker exec cli peer channel join -b ${CHANNELID}.block -o $ORDERER --cafile /opt/home/managedblockchain-tls-chain.pem --tls

# INSTALL Chain Code
echo "Installing chain-code"
sleep 100
docker exec cli peer lifecycle chaincode install final.tar.gz
PACKAGE_QUERY=$(docker exec cli peer lifecycle chaincode queryinstalled)
export CC_PACKAGE_ID=$(echo $PACKAGE_QUERY | grep -o '\w\+:[a-f0-9]\{64\}')
echo "PACKAGE_ID: $CC_PACKAGE_ID"
docker exec cli peer lifecycle chaincode approveformyorg --orderer $ORDERER --tls --cafile /opt/home/managedblockchain-tls-chain.pem --channelID $CHANNEL --name $CHAINCODENAME --version v0 --sequence 1 --package-id $CC_PACKAGE_ID
docker exec cli peer lifecycle chaincode checkcommitreadiness --orderer $ORDERER --tls --cafile /opt/home/managedblockchain-tls-chain.pem --channelID $CHANNEL --name $CHAINCODENAME --version v0 --sequence 1
docker exec cli peer lifecycle chaincode commit --orderer $ORDERER --tls --cafile /opt/home/managedblockchain-tls-chain.pem --channelID $CHANNEL --name $CHAINCODENAME --version v0 --sequence 1
docker exec cli peer lifecycle chaincode querycommitted --channelID $CHANNEL
docker exec cli peer chaincode invoke --tls --cafile /opt/home/managedblockchain-tls-chain.pem --channelID $CHANNEL --name $CHAINCODENAME -c '{"Args":["createUser","{\"username\": \"edge\", \"email\": \"edge@def.com\", \"registeredDate\": \"2018-10-22T11:52:20.182Z\"}"]}'


# Test Query
#docker exec cli peer chaincode invoke --tls --cafile /opt/home/managedblockchain-tls-chain.pem --channelID $CHANNEL --name $CHAINCODENAME -c '{"Args":["queryUser","{\"username\": \"edge\"}"]}'

#### Deploy ChainCode restapi

docker login -u AWS -p $(aws ecr get-login-password --region ${AWS_REGION}) ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
docker pull ${REST_API_DOCKER_IMAGE_URL}
mkdir -p home/ec2-user/os-blockchain-api/sync-api/rest-api/credential-store
docker run --rm --env-file /home/ec2-user/peer-exports.sh -p 80:3000 -v /home/ec2-user/os-blockchain-api/sync-api/rest-api/credential-store:/app/credential-store  -v /tmp/data:/tmp/data ${REST_API_DOCKER_IMAGE_URL}




