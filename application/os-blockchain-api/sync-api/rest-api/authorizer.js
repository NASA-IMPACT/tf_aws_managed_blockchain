let jwt = require('jsonwebtoken');
let jwkToPem = require('jwk-to-pem');
const requestify = require('requestify');

const USERPOOL_REGION = "us-west-2";

/**
 * Get cognito's secret key
 * @returns {Promise}
 */
async function authorize(token, userPoolId) {
  const iss = `https://cognito-idp.${USERPOOL_REGION}.amazonaws.com/${userPoolId}`;
  const jwkUrl = iss + "/.well-known/jwks.json";
  const pems = {};

  const res = await requestify.request(jwkUrl, { method: 'get', dataType: 'json'})
  const keys = res.getBody()['keys'];
  for(let i = 0; i < keys.length; i++) {
      //Convert each key to PEM
      let key_id = keys[i].kid;
      let modulus = keys[i].n;
      let exponent = keys[i].e;
      let key_type = keys[i].kty;
      let jwk = { kty: key_type, n: modulus, e: exponent};
      let pem = jwkToPem(jwk);
      pems[key_id] = pem;
  }
  let decodedJwt = jwt.decode(token, {complete: true});
  if (!decodedJwt) {
      console.log("Not a valid JWT token");
      throw Error("Unauthorized");
  }

  //Fail if token is not from your UserPool
  if (decodedJwt.payload.iss != iss) {
      console.log("invalid issuer");
      throw Error("Unauthorized");
  }

  //Reject the jwt if it's not an 'Access Token'
  if (decodedJwt.payload.token_use != 'access') {
      console.log("Not an access token");
      throw Error("Unauthorized");
  }

  //Get the kid from the token and retrieve corresponding PEM
  let kid = decodedJwt.header.kid;
  let pem = pems[kid];
  if (!pem) {
      console.log('Invalid access token');
      throw Error("Unauthorized");
  }

  //Verify the signature of the JWT token to ensure it's really coming from your User Pool
  return await jwt.verify(token, pem, { issuer: iss })
}

module.exports = authorize;
