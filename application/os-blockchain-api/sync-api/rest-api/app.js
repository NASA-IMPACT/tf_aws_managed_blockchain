"use strict";

const {
  multer,
  bodyParser,
  cors,
  express,
  hfc,
  http,
  WebSocketServer
} = require("./imports.js")


const Metadata = require("./metadata.js");
const { User } = require("./user.js");
const utils = require("./utils.js");
const swaggerUi = require("swagger-ui-express");
const swaggerDocument = require("./swagger.json");

const connection = require("./connection.js");

const awaitHandler = utils.awaitHandler;

const storage = multer.memoryStorage();
const upload = multer({ storage: storage });

hfc.addConfigFile("config.json");


let port = 3000;

let app = express();
app.options("*", cors());
app.use(express.json({ limit: "50mb" }));
app.use(bodyParser.urlencoded({ limit: "50mb", extended: false }));
app.use(cors());
app.use(bodyParser.json());
app.use(
  bodyParser.urlencoded({
    extended: false,
  })
  );
app.use(function (req, res, next) {
  return next();
});

let server = http.createServer(app).listen(port, function () {});
server.timeout = 240000;

/**
 *  Websocker server
 */
const wss = new WebSocketServer.Server({ server });
wss.on("connection", function connection(ws) {
  ws.on("message", function incoming(message) {
    console.log("##### Websocket Server received message: %s", message);
  });

  ws.send("something");
});


/**
 * Rest APIs
 */

const authenticateUser = async (req, res, next) => {
  const { username, password, orgName, authorization } = req.headers;
  const token = authorization && authorization?.split(' ')[0] === 'Bearer' && authorization?.split(' ')[1];
  if((!username || !password) && !token) {
    next(new Error(401))
  }
  else {
    try {
      let userResponse = await connection.getRegisteredUser(
        username,
        orgName,
        password,
        token,
        true
        );
      if(userResponse.success) {
        res.locals = {};
        res.locals.user = userResponse;
        next();
      }
      else {
        next(new Error(401))
      }
    }
    catch(err) {
      console.log('Error:', err)
      next(new Error(500));
    }
  }
}

app.use(
  '/docs',
  swaggerUi.serve,
  swaggerUi.setup(swaggerDocument)
  );

// Root
app.get(
  "/",
  awaitHandler(async (req, res) => {
    res.send("Hello");
    // res.sendStatus(200);
  })
  );

// Health check - can be called by load balancer to check health of REST API
app.get(
  "/health",
  awaitHandler(async (req, res) => {
    res.sendStatus(200);
  })
  );


// Register and enroll user. A user must be registered and enrolled before any queries
// or transactions can be invoked

// User endpoints
const user = new User(wss);

app.post("/enroll", authenticateUser, awaitHandler(user.enroll));
app.post("/users", authenticateUser, awaitHandler(user.create));
app.get("/users/:username", authenticateUser, awaitHandler(user.getuser));

// Metadata endpoints
const metadata = new Metadata(user);

app.get("/access/:metadataId&:username", authenticateUser, awaitHandler(metadata.access));

app.get("/metadata/:metadataId", authenticateUser, awaitHandler(metadata.getmetadata));
app.patch("/metadata/:metadataId", authenticateUser, (upload.single("file"), awaitHandler(metadata.update)));
app.post("/metadata", authenticateUser, upload.single("file"), awaitHandler(metadata.upload));
app.post("/metadata/s3", authenticateUser, awaitHandler(metadata.uploadFromS3));

app.get("/history/:metadataId", authenticateUser, awaitHandler(metadata.gethistory));

app.get("/listmetadata", authenticateUser, awaitHandler(metadata.listallmetadata));

app.get("/makeCopy", authenticateUser, awaitHandler(metadata.makecopy));

app.post("/verify", authenticateUser, upload.single("file"), awaitHandler(metadata.verify));
app.post("/verify/s3", authenticateUser, awaitHandler(metadata.verifyFromS3));

/************************************************************************************
 * Error handler
 ************************************************************************************/

app.use(function (error, req, res, next) {
  res.status(500).json({ error: error.toString() });
});
