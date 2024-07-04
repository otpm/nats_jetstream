#!/bin/sh

# Wait until the NATS server is healthy
while true; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:$MONITORING_PORT/healthz)
  if [ "$STATUS" -eq 200 ]; then
    echo "NATS server is healthy"
    break
  else
    echo $STATUS
    echo $(curl http://localhost:$MONITORING_PORT/healtz)
    echo "Waiting for NATS server to be healthy"
    sleep 1
  fi
done
