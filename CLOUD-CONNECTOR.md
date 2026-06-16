# Exposing mock-sftp-server via SAP Cloud Connector

The SAP Cloud Connector (SCC) creates a secure outbound tunnel from your local machine
to your BTP subaccount. CPI's SFTP adapter then addresses the virtual host that SCC maps
to your local Docker SFTP container.

## Prerequisites

- SCC installed on this Mac (or any always-on host on the same network).
  Download: https://tools.hana.ondemand.com/#cloud  → Cloud Connector
- Java 11+ runtime (bundled with newer SCC installers).
- Docker SFTP container running: `npm run lab:sftp`
- BTP trial subaccount: `your-subaccount`, region `your-region`

## 1. Install and start SCC (one-time)

```bash
# macOS: unzip the downloaded archive, then:
sudo /Applications/sapcc/go.sh start    # or the path where you extracted SCC
```

Admin UI: https://localhost:8443  
Default login: `Administrator` / `manage` (change on first login)

## 2. Connect SCC to your BTP subaccount (one-time)

1. Open https://localhost:8443
2. **Add Subaccount** → fill in:
   - Region host: `cf.your-region.hana.ondemand.com`
   - Subaccount ID: `your-subaccount` (find in BTP cockpit → subaccount overview)
   - Display name: `lab-trial`
   - Login name / Password: your SAP BTP user
3. Set **Location ID**: `lab-local`
   (This is the identifier you enter in every CPI adapter that goes through SCC.)

## 3. Add the SFTP system mapping

Under your connected subaccount → **Cloud To On-Premise** → **Access Control** → add:

| Field              | Value              |
|--------------------|--------------------|
| Back-end Type      | Non-SAP System     |
| Protocol           | TCP                |
| Internal Host      | `localhost`        |
| Internal Port      | `2222`             |
| Virtual Host       | `sftp-lab`         |
| Virtual Port       | `22`               |
| Principal Type     | None               |

Then add a resource under that system mapping:
| URL Path | Accessible |
|----------|------------|
| `.*`     | ✓          |

## 4. Configure the CPI SFTP adapter

In your iFlow's SFTP Sender or Receiver adapter:

| Setting           | Value         |
|-------------------|---------------|
| Host              | `sftp-lab`    |
| Port              | `22`          |
| Proxy Type        | On-Premise    |
| Location ID       | `lab-local`   |
| Authentication    | User Name/Password |
| Credential Name   | `LAB_SFTP_CREDS`  |
| Directory         | `/inbox` (or `/upload`, `/outbox`, `/archive`) |

### Security Material to create in CPI

1. **User Credentials** named `LAB_SFTP_CREDS` — User `labuser`, Password = the
   value you set in `users.conf`. (Monitor → Security Material → Create → User
   Credentials.) The adapter references it by **Credential Name**, not inline.

2. **Known Hosts (SSH)** named `LAB_SFTP_KNOWNHOSTS` — CPI refuses to connect
   unless the server's host key is trusted under the name it dials (`sftp-lab`).
   Generate the entry locally and upload it:

   ```bash
   bash scripts/known-hosts.sh sftp-lab     # writes known_hosts.lab
   ```

   Upload `known_hosts.lab` as Security Material type **Known Hosts (SSH)**. Host
   keys are persisted (mounted from `./ssh`), so this entry stays valid across
   container restarts — no need to regenerate unless you delete `./ssh`.

> Public-key auth instead of password: create an SSH key pair in CPI **Keystore**
> (alias e.g. `lab-sftp-key`), add its public key to the server's
> `authorized_keys`, and set adapter Authentication = Public Key.

## 5. Verify end-to-end

```bash
# 1. Start the container
npm run lab:sftp

# 2. Confirm local connectivity
npm run lab:sftp:test

# 3. In CPI, trigger or deploy your SFTP iFlow
# 4. Check data/inbox/ (or data/upload/) for files written by CPI
# 5. Check data/outbox/ for files CPI has read and acknowledged
```

## Directory layout

| Local path         | SFTP path         | Purpose                          |
|--------------------|-------------------|----------------------------------|
| `data/upload/`     | `/upload/`        | Lab worker deposits test files here |
| `data/inbox/`      | `/inbox/`         | CPI Sender polls this directory  |
| `data/outbox/`     | `/outbox/`        | CPI Receiver writes output here  |
| `data/archive/`    | `/archive/`       | Processed files moved here       |

## Troubleshooting

- **SCC not connecting**: check BTP subaccount ID and region host exactly match.
- **Port 2222 not reachable**: confirm `npm run lab:sftp` shows the container running,
  then `nc -z localhost 2222` should succeed.
- **CPI adapter timeout**: confirm SCC virtual host is `sftp-lab` (lowercase, exact match).
- **Permission denied**: check `users.conf` password matches the CPI security material.
