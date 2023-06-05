/*
# Copyright 2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
# 
# Licensed under the Apache License, Version 2.0 (the "License").
# You may not use this file except in compliance with the License.
# A copy of the License is located at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# or in the "license" file accompanying this file. This file is distributed 
# on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either 
# express or implied. See the License for the specific language governing 
# permissions and limitations under the License.
#
*/

'use strict';
let util = require('util');
let helper = require('./connection.js');


async function sendProposal(request, channel) {
  let results = await channel.sendTransactionProposal(request);
    // the returned object has both the endorsement results
    // and the actual proposal, the proposal will be needed
    // later when we send a transaction to the ordering service
  let proposalResponses = results[0];
  let proposal = results[1];

    // lets have a look at the responses to see if they are
    // all good, if good they will also include signatures
    // required to be committed
  let successfulResponses = true;
  for (let i in proposalResponses) {
    let oneSuccessfulResponse = false;
    if (proposalResponses && proposalResponses[i].response &&
      proposalResponses[i].response.status === 200) {
      oneSuccessfulResponse = true;
  } else {
  }
  successfulResponses = successfulResponses & oneSuccessfulResponse;
}
return [proposal,proposalResponses,successfulResponses];
}

class Chaincode{

  async invoke(peerNames, channelName, chaincodeName, args, fcn, username, orgName) {
    let error_message = null;
    let txIdAsString = null;
    try {
                // first setup the client for this org
      let client = await helper.getClientForOrg(orgName, username);
      let channel = client.getChannel(channelName);
      if(!channel) {
        let message = util.format('##### invokeChaincode - Channel %s was not defined in the connection profile', channelName);
        throw new Error(message);
      }
      let txId = client.newTransactionID();
      txIdAsString = txId.getTransactionID();
            // send proposal to endorsing peers
      let request = {
        targets: peerNames,
        chaincodeId: chaincodeName,
        fcn: fcn,
        args: [JSON.stringify(args)],
        channelNames: [channelName],
        txId: txId
      };

      let [proposal,proposalResponses,successfulResponses] = await sendProposal(request, channel);
      if (successfulResponses) {
                // wait for the channel-based event hub to tell us
                // that the commit was good or bad on each peer in our organization
        let promises = [];
        let event_hubs = channel.getChannelEventHubsForOrg();
        event_hubs.forEach((eh) => {
          let invokeEventPromise = new Promise((resolve, reject) => {
            let event_timeout = setTimeout(() => {
              eh.disconnect();
            }, 10000);
            eh.registerTxEvent(txIdAsString, (tx, code, block_num) => {
              clearTimeout(event_timeout);

              if (code !== 'VALID') {
                let message = util.format('##### invokeChaincode - The invoke chaincode transaction was invalid, code:%s',code);
                reject(new Error(message));
              } else {
                let message = '##### invokeChaincode - The invoke chaincode transaction was valid.';
                resolve(message);
              }
            }, (err) => {
              clearTimeout(event_timeout);
              reject(err);
            },
                            // the default for 'unregister' is true for transaction listeners
                            // so no real need to set here, however for 'disconnect'
                            // the default is false as most event hubs are long running
                            // in this use case we are using it only once
            {unregister: true, disconnect: true}
            );
            eh.connect();
          });
          promises.push(invokeEventPromise);
        });

        let orderer_request = {
          txId: txId,
          proposalResponses: proposalResponses,
          proposal: proposal
        };
        let sendPromise = channel.sendTransaction(orderer_request);
                // put the send to the ordering service last so that the events get registered and
                // are ready for the orderering and committing
        promises.push(sendPromise);
        let results = await Promise.all(promises);
                let response = results.pop(); //  ordering service results are last in the results
                if (response.status === 'SUCCESS') {
                } else {
                  error_message = util.format('##### invokeChaincode - Failed to order the transaction. Error code: %s',response.status);
                }

                // now see what each of the event hubs reported
                for(let i in results) {
                  let event_hub_result = results[i];
                  if(typeof event_hub_result === 'string') {
                  }
                  else {
                    if (!error_message) error_message = event_hub_result.toString();
                  }
                }
              }
              else {
                error_message = util.format('##### invokeChaincode - Failed to send Proposal and receive all good ProposalResponse. Status code: ' + 
                  proposalResponses[0].status + ', ' +
                  proposalResponses[0].message + '\n' +
                  proposalResponses[0].stack);
              }
            }
            catch (error) {
              error_message = error.toString();
            }

            if (!error_message) {
              let response = {};
              response.transactionId = txIdAsString;
              return response;
            }
            else {
              let message = util.format('##### invokeChaincode - Failed to invoke chaincode. cause:%s', error_message);
              throw new Error(message);
            }
          };


          async query(peers, channelName, chaincodeName, args, fcn, username, orgName) {
            try {
              let client = await helper.getClientForOrg(orgName, username);
              let channel = client.getChannel(channelName);
              if(!channel) {
                let message = util.format('##### queryChaincode - Channel %s was not defined in the connection profile', channelName);
                throw new Error(message);
              }

      // send query
              let request = {
                targets : peers,
                chaincodeId: chaincodeName,
                fcn: fcn,
                args: [JSON.stringify(args)]
              };

              let responses = await channel.queryByChaincode(request);
              let ret = [];
              if (responses) {
        // you may receive multiple responses if you passed in multiple peers. For example,
        // if the targets : peers in the request above contained 2 peers, you should get 2 responses
                for (let i = 0; i < responses.length; i++) {
                }
        // check for error
                let response = responses[0].toString('utf8');
                if (responses[0].toString('utf8').indexOf("Error: transaction returned with failure") != -1) {
                  let message = util.format('##### queryChaincode - error in query result: %s', responses[0].toString('utf8'));
                  throw new Error(message);
                }
        // we will only use the first response. We strip out the Fabric key and just return the payload
                let json = JSON.parse(responses[0].toString('utf8'));
                if (Array.isArray(json)) {
                  for (let key in json) {
                    if (json[key]['Record']) {
                      ret.push(json[key]['Record']);
                    }
                    else {
                      ret.push(json[key]);
                    }
                  }
                }
                else {
                  ret.push(json);
                }
                return ret;
              }
              else {
                return 'responses is null';
              }
            }
            catch(error) {
              return error.toString();
            }
          };
        }

        module.exports = Chaincode;
