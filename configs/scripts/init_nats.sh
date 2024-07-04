#!/bin/sh

# Function to check if a stream exists
stream_exists() {
  nats --server="nats://$SERVICE_TOKEN@localhost:$COMMUNICATION_PORT" stream info "$1" > /dev/null 2>&1
}

# Function to check if a consumer exists
consumer_exists() {
  nats --server="nats://$SERVICE_TOKEN@localhost:$COMMUNICATION_PORT" consumer info "$1" "$2" > /dev/null 2>&1
}

# Add streams if they don't exist
for file in /etc/nats/configs/streams/*.json; do
  STREAM_NAME=$(basename $file .json)
  if ! stream_exists "$STREAM_NAME"; then
    nats --server="nats://$SERVICE_TOKEN@localhost:$COMMUNICATION_PORT" stream add $STREAM_NAME --config $file
  fi
done

# Add consumers if they don't exist
for file in /etc/nats/configs/consumers/*.json; do
  STREAM_NAME=$(basename $file .json | cut -d '.' -f 1)
  CONSUMER_NAME=$(basename $file .json | cut -d '.' -f 2)
  if ! consumer_exists "$STREAM_NAME" "$CONSUMER_NAME"; then
    nats --server="nats://$SERVICE_TOKEN@localhost:$COMMUNICATION_PORT" consumer add $STREAM_NAME $CONSUMER_NAME --config $file
  fi
done
