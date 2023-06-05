#!/bin/sh
rsync -zxvh fabric:~/rest-api/* ./rest-api --exclude-from='./rest-api/.gitignore'
rsync -zxvh ./rest-api/* fabric3:~/rest-api/ --exclude-from='./rest-api/.gitignore'
rsync -zxvh ./rest-api/* fabricmicrosoft:~/rest-api/ --exclude-from='./rest-api/.gitignore'
