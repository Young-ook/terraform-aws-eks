#!/bin/bash -e

aws ecr get-login-password --region ${region} | docker login --username AWS --password-stdin ${ecr_uri}
docker build -t app .
docker tag apps:latest ${ecr_uri}
docker push ${ecr_uri}
