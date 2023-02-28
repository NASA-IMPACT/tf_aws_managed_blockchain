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
pip install --upgrade awscli
VpcEndpointServiceName=$(aws managedblockchain get-network --region ${REGION} --network-id ${NETWORKID}  --query 'Network.VpcEndpointServiceName' --output text)
OrderingServiceEndpoint=$(aws managedblockchain get-network --region ${REGION}  --network-id ${NETWORKID}  --query 'Network.FrameworkAttributes.Fabric.OrderingServiceEndpoint' --output text)
CaEndpoint=$(aws managedblockchain get-member --region ${REGION}  --network-id ${NETWORKID}  --member-id ${MEMBERID}  --query 'Member.FrameworkAttributes.Fabric.CaEndpoint' --output text)
nodeID=${MEMEBERNODEID}
peerEndpoint=$(aws managedblockchain get-node --region ${REGION}  --network-id ${NETWORKID}  --member-id ${MEMBERID}  --node-id $nodeID --query 'Node.FrameworkAttributes.Fabric.PeerEndpoint' --output text)
peerEventEndpoint=$(aws managedblockchain get-node --region ${REGION}  --network-id ${NETWORKID}  --member-id ${MEMBERID}  --node-id $nodeID --query 'Node.FrameworkAttributes.Fabric.PeerEventEndpoint' --output text)

sudo -u ec2-user -i <<EOF1
PATH=$PATH:/usr/local/bin
source /home/ec2-user/.bash_profile
# Exports to be exported before executing any Fabric 'peer' commands via the CLI
cat << EOF2 > ~/peer-exports.sh
export NETWORKNAME=${NETWORKNAME}
export MEMBERNAME=${MEMBERNAME}
export NETWORKVERSION=${NETWORKVERSION}
export ADMINUSER=${ADMINUSER}
export ADMINPWD=${ADMINPWD}
export NETWORKID=${NETWORKID}
export MEMBERID=${MEMBERID}
export ORDERINGSERVICEENDPOINT=$OrderingServiceEndpoint
export ORDERINGSERVICEENDPOINTNOPORT=$(echo $OrderingServiceEndpoint| cut -d ':'  -f 1-1 )
export VPCENDPOINTSERVICENAME=$VpcEndpointServiceName
export CASERVICEENDPOINT=$CaEndpoint
export PEERNODEID=$nodeID
export PEERSERVICEENDPOINT=$peerEndpoint
export PEERSERVICEENDPOINTNOPORT=$(echo $peerEndpoint| cut -d ':'  -f 1-1 )
export PEEREVENTENDPOINT=$peerEventEndpoint
export MSP_PATH=/opt/home/admin-msp
export MSP=${MEMBERID}
export ORDERER=$OrderingServiceEndpoint
export PEER=$peerEndpoint
export CHANNEL=${CHANNELID}
export CAFILE=/opt/home/managedblockchain-tls-chain.pem
export CHAINCODENAME=${CHANNELCODENAME}
export CHAINCODEVERSION=v0
export CHAINCODEDIR=github.com/chaincode_example02/go
EOF2
aws s3 cp s3://us-east-1.managedblockchain/etc/managedblockchain-tls-chain.pem  /home/ec2-user/managedblockchain-tls-chain.pem
source /home/ec2-user/peer-exports.sh
fabric-ca-client enroll -u https://${ADMINUSER}:${ADMINPWD}@\$CASERVICEENDPOINT --tls.certfiles /home/ec2-user/managedblockchain-tls-chain.pem -M /home/ec2-user/admin-msp
echo https://${ADMINUSER}:${ADMINPWD}@\$CASERVICEENDPOINT  >> /tmp/api_url.txt
mkdir -p /home/ec2-user/admin-msp/admincerts
cp /home/ec2-user/admin-msp/signcerts/* /home/ec2-user/admin-msp/admincerts/
EOF1

sudo -u ec2-user -i <<EOF1
cat << EOF2 > ~/configtx.yaml
Organizations:
    - &Org1
        Name: ${MEMBERID}

        # ID to load the MSP definition as
        ID: ${MEMBERID}

        MSPDir: /opt/home/admin-msp

        AnchorPeers:
            # AnchorPeers defines the location of peers which can be used
            # for cross org gossip communication.  Note, this value is only
            # encoded in the genesis block in the Application section context
            - Host:
              Port:

################################################################################
#
#   SECTION: Application
#
#   - This section defines the values to encode into a config transaction or
#   genesis block for application related parameters
#
################################################################################
Application: &ApplicationDefaults

    # Organizations is the list of orgs which are defined as participants on
    # the application side of the network
    Organizations:

################################################################################
#
#   Profile
#
#   - Different configuration profiles may be encoded here to be specified
#   as parameters to the configtxgen tool
#
################################################################################
Profiles:

    OneOrgChannel:
        Consortium: AWSSystemConsortium
        Application:
            <<: *ApplicationDefaults
            Organizations:
                - *Org1

EOF2
EOF1





source /home/ec2-user/peer-exports.sh

# Update the configtx channel configuration
docker exec cli configtxgen -outputCreateChannelTx /opt/home/$CHANNEL.pb -profile OneOrgChannel -channelID $CHANNEL --configPath /opt/home/
sleep 30
# Create a Fabric channel
docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/managedblockchain-tls-chain.pem" \
    -e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \
    cli peer channel create -c $CHANNEL -f /opt/home/$CHANNEL.pb -o $ORDERER --cafile $CAFILE --tls --timeout 900s >> /tmp/this_what_happened.txt


# Get the block from the channel itself
docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/managedblockchain-tls-chain.pem"  \
    -e "CORE_PEER_ADDRESS=$PEER"  -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \
    cli peer channel fetch oldest /opt/home/fabric-samples/chaincode/hyperledger/fabric/peer/$CHANNELID.block \
    -c $CHANNEL -o $ORDERER --cafile /opt/home/managedblockchain-tls-chain.pem --tls

# Join your peer node to the channel
docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/managedblockchain-tls-chain.pem" \
    -e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \
    cli peer channel join -b $CHANNEL.block  -o $ORDERER --cafile $CAFILE --tls

# Install chaincode on your peer node
docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/managedblockchain-tls-chain.pem" \
    -e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \
    cli peer chaincode install -n $CHAINCODENAME -v $CHAINCODEVERSION -p $CHAINCODEDIR

# Instantiate the chaincode on the channel
docker exec -e "CORE_PEER_TLS_ENABLED=true" -e "CORE_PEER_TLS_ROOTCERT_FILE=/opt/home/managedblockchain-tls-chain.pem" \
    -e "CORE_PEER_ADDRESS=$PEER" -e "CORE_PEER_LOCALMSPID=$MSP" -e "CORE_PEER_MSPCONFIGPATH=$MSP_PATH" \
    cli peer chaincode instantiate -o $ORDERER -C $CHANNEL -n $CHAINCODENAME -v $CHAINCODEVERSION \
    -c '{"Args":["init","a","100","b","200"]}' --cafile $CAFILE --tls

