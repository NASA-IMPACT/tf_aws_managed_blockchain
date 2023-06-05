FROM --platform=linux/amd64 node:16.15.0-alpine
RUN apk add --no-cache python3 py3-pip g++ make
WORKDIR /app
RUN pip install awscli
RUN aws s3 cp s3://us-east-1.managedblockchain/etc/managedblockchain-tls-chain.pem /opt/home/managedblockchain-tls-chain.pem --no-sign-request
COPY ./sync-api/rest-api/package.json ./package.json
RUN npm install

COPY ./sync-api/rest-api/ .

COPY entrypoint.sh entrypoint.sh
ENTRYPOINT ["/bin/sh", "entrypoint.sh"]
#TODO
