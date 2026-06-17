# mock-sftp-server

A disposable SFTP partner that shows up when the real one won't — the file-drop
stand-in for your integration landscape.

## Why this exists

Every integration lives in a *landscape*: a cast of systems strung together,
with middleware (SAP Integration Suite / CPI) as the stage manager wiring them
up. A source over here, a target over there, a third party or two waiting in the
wings, and the middleware running the whole show.

The catch is that the cast is almost never all on stage at once. The customer's
landscape is half-built. The third-party endpoint isn't open yet. Sandbox access
is "a couple of weeks away." The partner's test system is only up on Tuesdays.
You've got a four-tier landscape and exactly two of the systems actually exist.

You can't put the build on hold until everyone shows up — so this is the
**stand-in**: a believable double for the missing system that speaks the right
protocol, answers the way the real one would, and lets the middleware run the
scene end to end. Prove the concept, demo the flow, test the unhappy paths today,
with the systems you *don't* have. When the real one finally walks on set, you
swap it in and the iFlow never notices the difference.

## What it stands in for

The **file-based partner**: the bank's SFTP drop, the 3PL's outbound folder, the
supplier that "only does SFTP." It's a throwaway SSH/SFTP host in Docker with
`inbox` / `outbox` / `upload` / `archive` folders, exposed to CPI through SAP
Cloud Connector exactly like an on-premise server. Your SFTP Sender polls it,
your SFTP Receiver writes to it, and you watch the files land on your own disk.

## Quick start

```bash
bash scripts/setup.sh     # users.conf, data folders, persistent SSH host keys
npm run lab:sftp          # start the SFTP host on localhost:2222
npm run lab:sftp:test     # verify connectivity
```

Then expose it to CPI — see **[CLOUD-CONNECTOR.md](CLOUD-CONNECTOR.md)**. Generate
the host-key trust entry for CPI with `bash scripts/known-hosts.sh`.

## The rest of the cast

- **mock-sftp-server** — the file-drop partner *(you are here)*
- [catchall-server](https://github.com/samwatso/catchall-server) — the universal receiver; catches whatever an iFlow sends and keeps the evidence
- [mock-erp-server](https://github.com/samwatso/mock-erp-server) — a stand-in SAP ECC / S/4HANA (IDoc, SOAP, OData, XI)
- [mock-mq-broker](https://github.com/samwatso/mock-mq-broker) — JMS / AMQP / MQTT brokers (Artemis + Mosquitto)
- [mock-event-broker](https://github.com/samwatso/mock-event-broker) — HTTP topics & queues with ack/nack
- [mock-ibmmq](https://github.com/samwatso/mock-ibmmq) — a stand-in on-premise IBM MQ queue manager

## House rules

For SAP BTP trial / dev only. No real data, no production systems, and nothing
committed you wouldn't want on a public stage — credentials stay in gitignored
`.env` / `users.conf`, host keys in a gitignored `ssh/`.
