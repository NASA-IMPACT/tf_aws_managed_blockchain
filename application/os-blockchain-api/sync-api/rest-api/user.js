const jwt = require("jsonwebtoken");

const Chaincode = require("./chaincode.js");
const { hfc } = require("./imports.js");
const connection = require("./connection.js");

let blockListener = require('./blocklistener.js');

let channelName = hfc.getConfigSetting('channelName');
let chaincodeName = hfc.getConfigSetting('chaincodeName');
let peers = hfc.getConfigSetting('peers');

const chaincode = new Chaincode();


class User {
  constructor(wss) {

    this.username = "";
    this.orgName = "VEDA";
    this.wss = wss;
    this.enroll = this.enroll.bind(this);
    this.getuser = this.getuser.bind(this);
    this.create = this.create.bind(this);
    this.getOrgAndUsername = this.getOrgAndUsername.bind(this);

  }

  async enroll(req, res, next) {
    this.username = req.headers.username;
      this.orgName = req.headers.orgname; //req.headers.orgName || this.orgName;
      let userResponse = await connection.getRegisteredUser(
        this.username,
        this.orgName,
        req.headers.password,
        true
        );
      if (userResponse["success"]) {
        // Now that we have a username & org, we can start the block listener
        await blockListener.startBlockListener(
          channelName,
          this.username,
          this.orgName,
          this.wss
          );
        res.json(userResponse);
      } else {
        res.json({ success: false, message: userResponse });
      }
    }

    async getuser(req, res, next) {
      let args = req.params;
      let fcn = "queryUser";
      let message = await chaincode.query(peers, channelName, chaincodeName, args, fcn, this.username, this.orgName);
      res.send(message);
    }

    async create(req, res, next) {
      let args = req.headers;
      let fcn = "createUser";

      let message = await chaincode.invoke(
        peers,
        channelName,
        chaincodeName,
        args,
        fcn,
        req.headers.username,
        this.orgName
        );
      res.send(message);
    }


    getOrgAndUsername(){
      return { orgName:this.orgName, username: this.username };
    }
  }

  module.exports = {User, channelName, chaincodeName, peers};
