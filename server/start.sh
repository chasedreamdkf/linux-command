#!/usr/bin/env bash
# Start the server application
echo "Starting the server application..."
# uvicorn main:app --reload --ssl-keyfile private.key --ssl-certfile certificate.crt
uvicorn main:app --reload --port 8080 --host 172.21.223.159