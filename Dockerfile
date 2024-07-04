ARG MONITORING_PORT=8222
ARG COMMUNICATION_PORT=5222
ARG SERVICE_TOKEN=TEST

# Stage 1: Configuration
FROM nats:2.10.12-alpine AS configurator
ARG MONITORING_PORT
ARG COMMUNICATION_PORT
ARG SERVICE_TOKEN

# Install NATS CLI
COPY tools/nats /usr/local/bin/nats

# Copy configuration files
COPY nats-server.conf /etc/nats/nats-server.conf
COPY configs/ /etc/nats/configs/

# Install curl for the script
RUN apk add curl

# Start NATS server and run the initialization script
RUN ["sh", "-c", "nats-server -c /etc/nats/nats-server.conf -DVV & /etc/nats/configs/scripts/wait_for_nats.sh && /etc/nats/configs/scripts/init_nats.sh && sleep 10 && pkill -SIGUSR2 nats-server && sleep 5"]

# Stage 2: Final Image
FROM nats:2.10.12-alpine
ARG MONITORING_PORT
ARG COMMUNICATION_PORT
ARG SERVICE_TOKEN

# Copy data and configuration file from the configurator stage
COPY --from=configurator /data /data
COPY --from=configurator /etc/nats/nats-server.conf /etc/nats/nats-server.conf

# Set the entrypoint and command
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["nats-server", "--config", "/etc/nats/nats-server.conf", "-DVV"]
