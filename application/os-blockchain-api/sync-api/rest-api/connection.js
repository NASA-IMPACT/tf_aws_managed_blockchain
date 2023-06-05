'use strict';
const {
  CognitoIdentityProviderClient,
  AdminInitiateAuthCommand,
} = require("@aws-sdk/client-cognito-identity-provider");
// skip jwt for now
// const bcrypt = require ('bcrypt');

// Load the AWS SDK for Node.js
const AWS = require('aws-sdk');
// Set the region
AWS.config.update({region: 'us-east-1'});

const APP_CLIENT_ID = process.env.APP_CLIENT_ID;
const ROLE_ARN = 'arn:aws:iam::853558080719:role/veda-blockchain-access';
const ROLE_TO_ASSUME = {
  RoleArn: ROLE_ARN,
  RoleSessionName: 'veda-auth',
  DurationSeconds: 900,
};
const USER_POOL_ID = process.env.USER_POOL_ID

let util = require('util');
let hfc = require('fabric-client');

let authorize = require('./authorizer.js');

hfc.addConfigFile('config.json');


const getClientForOrg = async (userorg, username) => {
  let config = './connection_profile/connection-profile.yaml';
  let orgLower = (userorg || "VEDA").toLowerCase();
  let clientConfig = './connection_profile/' + orgLower + '/client-' + orgLower + '.yaml';
    // Load the connection profiles. First load the network settings, then load the client specific settings
  let client = hfc.loadFromConfig(config);

  client.loadFromConfig(clientConfig);
  // Create the state store and the crypto store
  await client.initCredentialStores();
  // Try and obtain the user from persistence if the user has previously been
  // registered and enrolled
  if(username) {
    let user = await client.getUserContext(username, true);
    if(!user) {
      throw new Error(util.format('##### getClient - User was not found :', username));
    }
  }
  return client;
}


const jwtAuth = async (req) => {
  const user = users.find((c) => c.user == req.body.name)
    //check to see if the user exists in the list of registered users
  if (user == null) res.status(404).send("User does not exist!")
      //if user does not exist, send a 400 response
    if (await bcrypt.compare(req.body.password, user.password)) {
      const accessToken = generateAccessToken ({user: req.body.name})
      const refreshToken = generateRefreshToken ({user: req.body.name})
      res.json ({accessToken: accessToken, refreshToken: refreshToken})
    }
    else {
      res.status(401).send("Password Incorrect!")
    }
  }


  const crossAccountCredentials = async (roleCreds, roleName) => {
    let roleToAssume = ROLE_TO_ASSUME;
    roleToAssume['RoleArn'] = roleName || ROLE_ARN;
    roleToAssume['RoleSessionName'] = roleName ? "mcp_role_session" : roleToAssume['RoleSessionName'];
    let sts = new AWS.STS({apiVersion: '2011-06-15', ...roleCreds});
    return new Promise((resolve, reject) => {
      sts.assumeRole(roleToAssume, function(err, data) {
        if (err) reject(err);
        else{
          resolve({
            accessKeyId: data.Credentials.AccessKeyId,
            secretAccessKey: data.Credentials.SecretAccessKey,
            sessionToken: data.Credentials.SessionToken
          });
        }
      });
    });
  };

const cognitoUserAuthentication = async (roleCreds, username, password, token) => {
  if (token) {
    return new Promise((resolve, reject) => {
      authorize(token, USER_POOL_ID)
        .then(response =>
          resolve({ success: true, response: response }))
        .catch(err => 
          reject({ success: false, error: err })
        )
      }
    );
  }
  const params = {
      "UserPoolId": USER_POOL_ID,
      "ClientId": APP_CLIENT_ID,
      "AuthFlow": "ADMIN_USER_PASSWORD_AUTH",
      "AuthParameters": {
        "USERNAME": username,
        "PASSWORD": password,
      },
    };
    const client = new AWS.CognitoIdentityServiceProvider({
      apiVersion: '2016-04-18',
      region: "us-west-2",
      accessKeyId: roleCreds.accessKeyId,
      secretAccessKey: roleCreds.secretAccessKey,
      sessionToken: roleCreds.sessionToken,
    });
    return new Promise((resolve, reject) => {
      client.adminInitiateAuth(params, (err, response) => {
        if(err) reject({ success: false, error: err });
        else
          resolve({ success: true, response: response });
      });
    });
  };

  const enrollNewUser = async (client, username) => {
  // user was not enrolled, so we will need an admin user object to register
    let admins = hfc.getConfigSetting('admins');
    let adminUserObj = await client.setUserContext({
      username: admins[0].username,
      password: admins[0].secret
    });
    let caClient = client.getCertificateAuthority();
    let secret = await caClient.register(
      { enrollmentID: username },
      adminUserObj
      );
    let enrolledUser = await client.setUserContext({username:username, password:secret}, true);
    return enrolledUser;
  }

  const retrieveEnrolledUser = async (username, organization, isJson) => {
    let client = await getClientForOrg(organization);
    let user = await client.getUserContext(username, true);
    try {
    // Handle case when user is already enrolled.
      if (user && user.isEnrolled){}
        else {
          user = await enrollNewUser(client, username);
        }

        if (user && user.isEnrolled) {
          if (isJson && isJson === true) {
            let response = {
              success: true,
              secret: user._enrollmentSecret,
              message: username + ' enrolled Successfully',
            };
            return response;
          }
          else {
            throw new Error('##### User was not enrolled');
          }
        }
      }
      catch(error) {
        return { success: false, message: `failed ${error.toString()}` };
      }
    }

const getRegisteredUser = async (username, organization, password, token, isJson) => {
  let roleCreds = await crossAccountCredentials();

  let cognitoResponse = await cognitoUserAuthentication(roleCreds, username, password, token);
  if(cognitoResponse['success']) {
    let enrolledUser = await retrieveEnrolledUser(cognitoResponse.response?.username || username, organization, isJson);
    return enrolledUser;
  }
  else {
    return { success: false, error: new Error(401), message: "User not authorized." }
  }

    };

exports.getClientForOrg = getClientForOrg;
exports.getRegisteredUser = getRegisteredUser;
exports.crossAccountCredentials = crossAccountCredentials;
