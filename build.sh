#!/bin/sh

flutter build web && docker build -f Dockerfile.web -t claimix-web:v1 .

