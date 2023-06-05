let AWS = require('aws-sdk');

let BUCKETNAME = process.env.BUCKETNAME;
const connection = require("./connection.js");

const MCP_ROLE = "arn:aws:iam::114506680961:role/veda-data-store-read-staging";


class Datastore {
  constructor() {
  }

  async setupAWSCreds() {
    let roleCreds = await connection.crossAccountCredentials();
    let mcpRoleCreds = await connection.crossAccountCredentials(roleCreds, MCP_ROLE);
    this.s3Conn = new AWS.S3({
      apiVersion: '2016-04-18',
      region: "us-west-2",
      accessKeyId: mcpRoleCreds.accessKeyId,
      secretAccessKey: mcpRoleCreds.secretAccessKey,
      sessionToken: mcpRoleCreds.sessionToken,
    });
  }

  async upload(key, dataBuffer) {
    let params = {
      Body: dataBuffer,
      Key: key,
      Bucket: BUCKETNAME
    };
    const s3Response = await this.s3Conn.putObject(params).promise();
    let response = {
      statusCode: 200,
      key: key,
      hash: s3Response.ETag.replace(/\"/g, ""),
      bucket: BUCKETNAME
    };
    return response;
  }

  async delete(key) {
    await this.s3Conn.deleteObject({ Bucket: BUCKETNAME, Key: key }).promise();
  }

  async download(key) {
    console.log(`Fetching ${key} from ${BUCKETNAME}.`);
    let data = await this.s3Conn.getObject({ Key: key, Bucket: BUCKETNAME }).promise();
    return data;
  }

  async getHead(key, bucketname) {
    const s3Response = await this.s3Conn.headObject({ Key: key, Bucket: bucketname }).promise();
    let response = {
      statusCode: 200,
      key: key,
      hash: s3Response.ETag.replace(/\"/g, ""),
      bucket: bucketname
    };
    return response;
  }
}

module.exports = Datastore;
