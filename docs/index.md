# Preconfigured NATS JetStream

This repository is based on the `NATS JetStream` service and provides a customized version tailored for our live system configurations.\
The modified service is encapsulated within a tailored Docker container to meet our specific operational requirements.

The pre-configured service includes the following settings for `STREAM` and `CONSUMER`:
```bash
.
├── STREAMS/
│   ├── BANK_STATEMENTS
│   └── COMMISSIONS
└── CONSUMERS/
    ├── UTAH
    ├── UTAH_ALL
    ├── UTAH_INSTANT_TRANSFER_ERROR
    ├── DON_CARNAGE
    └── OMAHA
```

The service differs from the live NATS service in the following ways:
* Does not contain settings related to the `TLS` service
* Does not contain settings related to the `DNS` settings
* No persistence of data is possible, which means that data is lost when the container is restarted or recreated
* The data in the container is not encrypted, so the STREAM and CONSUMER information in the container, as well as the data of the message exchanges, can be freely read
* In the case of this service, the communication is enabled on the user's host machine, i.e. `localhost`.

## Service Configuration

1. Create a folder for the modified service and create the following files
    ```bash
    .
    └── nats/
        ├── .env
        └── compose.yaml
    ```
2. Set the following parameters in the `.env` file
    | Variable | Value | Required |
    | :-- | :-- | :--: |
    | `MONITORING_PORT` | `8222` or a `specific` monitoring port | `true` |
    | `COMMUNICATION_PORT` | `4222` or a `specific` communication port | `true` |
    | `SERVICE_TOKEN` | `ILOVEOTPM` or a `specific` token for **authentication**  | `true` |
    | `TZ` | `Europe/Budapest` or a `specific` timezone configuration | `false` |
    ```properties
    MONITORING_PORT=8222
    COMMUNICATION_PORT=4222
    SERVICE_TOKEN=ILOVEOTPM
    TZ=Europe/Budapest
    ```
3. Set the following parameters in the `compose.yaml` file
    | Variable | Value | Required |
    | :-- | :-- | :--: |
    | `<VERSION>` | Can be `latest` or a `specific` version | `true` |
    
    **For environment variables in the `.env` file specified (in the previous step) that are not mandatory, they do not need to be specified in the environment section of the `compose.yaml` file.**
    ```yaml
    services:
    nats:
        image: ghcr.io/otpm/nats_jetstream:<VERSION>
        restart: on-failure
        stop_signal: SIGUSR2
        stop_grace_period: 3m
        ports:
        - "${MONITORING_PORT}:${MONITORING_PORT}"
        - "${COMMUNICATION_PORT}:${COMMUNICATION_PORT}"
        environment:
            COMMUNICATION_PORT: ${COMMUNICATION_PORT}
            MONITORING_PORT: ${MONITORING_PORT}
            SERVICE_TOKEN: ${SERVICE_TOKEN}
            TZ: ${TZ}
    ```

## Application Configuration

Application configuration can be done in a number of ways
1. Database side configuration
2. Application Framework side configuration (i.e. `Spring Framework`)
3. ...

There are many ways to configure the application, so please configure the communication on the application as described in the documentation.
1. [DonCarnage Docs](https://github.com/otpm/overlord-doncarnage?tab=readme-ov-file#nats-jetstream-konfigur%C3%A1l%C3%A1sa)
2. [Microbi Docs](https://gitlab.intra.otpmobil.com/tools/mikrobi#queue-konfigur%C3%A1l%C3%A1sa) - Not described in documentation, but must be set in database
3. Omaha Docs - Not described in documentation, but must be set in database
4. [Utah Docs](https://gitlab.intra.otpmobil.com/overlord/utah/-/blob/develop/README.md) - It needs an database modification

### Important Note
* Do not use `TLS` for the `NATS URL`!
