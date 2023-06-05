'use strict';
let util = require('util');
let helper = require('./connection.js');

let startBlockListener = async function(channelName, username, orgName, websocketServer) {
  console.log(util.format('\n============ START startBlockListener on channel %s ============\n', channelName));
  try {
    // first setup the client for this org
    let client = await helper.getClientForOrg(orgName, username);
    console.log('##### startBlockListener - Successfully got the fabric client for the organization "%s"', orgName);
    let channel = client.getChannel(channelName);
    if(!channel) {
      let message = util.format('##### startBlockListener - Channel %s was not defined in the connection profile', channelName);
      console.log('error', message);
      throw new Error(message);
    }

    // Register a block listener.
    //
    // This will return a list of channel event hubs when using a connection profile,
    // based on the current organization defined in the currently active client section
    // of the connection profile. Peers defined in the organization that have the eventSource
    // set to true will be added to the list.
    let eventHubs = channel.getChannelEventHubsForOrg();

    eventHubs.forEach((eh) => {
      eh.registerBlockEvent((block) => {
        let blockMsg = {
          blockNumber: block.header.number,
          txCount: block.data.data.length,
          txInBlock: []
        }
        let txCount = 0;
        block.data.data.forEach((tx) => {
          blockMsg['txInBlock'][txCount] = tx.payload.header.channel_header.tx_id;
          txCount++;
        })
        // Broadcast the new block to all websocket listeners
        websocketServer.broadcast = async function broadcast(msg) {
          websocketServer.clients.forEach(function each(client) {
            if (client.readyState === 1) {
              client.send(JSON.stringify(msg));
            }
          });
        };
        websocketServer.broadcast(blockMsg);
      }, (error)=> {
      });
      eh.connect(true);
    })

  } catch (error) {
    let error_message = error.toString();
  }
}

exports.startBlockListener = startBlockListener;
