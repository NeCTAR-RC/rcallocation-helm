# rcallocation-helm

Helm chart for [rcallocation](https://github.com/NeCTAR-RC/rcallocation),
the Nectar Research Cloud allocation system API: one Deployment running
gunicorn, a pre-upgrade Job that applies the database migrations, and the
Service, HTTPRoute, PodDisruptionBudget and NetworkPolicy that
[nectarlib](https://github.com/NeCTAR-RC/nectarlib-helm) renders for
every Nectar API.

The API is served under `/v1/`. The keystone catalog entry for service
type `allocations` must point at `https://<hostname>/v1` so that
`python-nectarallocationclient` and the dashboard find it.

## Configuration

Everything non-secret lives under `conf:` in `values.yaml` and is rendered
into `/etc/rcallocation/rcallocation.conf` and
`/etc/rcallocation/mappings.yaml` by the chart's ConfigMap. The site and
zone mappings (`conf.mappings`) are deployment data, so the chart ships
them empty; set them in the environment's values overlay. `oslo_policy:`
renders into `policy.yaml` for rule overrides.

Secrets come from Vault. The pod annotations render the secret at
`vault.settings_secret` into `/etc/rcallocation/rcallocation.conf.d/secrets.conf`,
which oslo.config reads alongside the main file. The secret holds:

| Key | Used for |
|---|---|
| `database_connection` | `[database] connection`, the MariaDB URL |
| `keystone_password` | the service user's password for `[keystone_authtoken]` and `[service_auth]` |
| `secret_key` | `[flask] secret_key` (optional) |
| `sentry_dsn` | `[sentry] dsn` (optional) |

The service user (`conf.keystone.username`) validates tokens with a
project scoped login and uses a system scoped login for the taynac email
client and the tenantmanager role assignment lookups behind
`GET /v1/allocations/?mine=true`, so it needs the `service` and `reader`
roles on the system in keystone.

Each deployment also needs an HTTPRoute hostname (`api.gateway.hostname`
or `api.gateway.hostnames`) and `conf.keystone.auth_url`.

## Working on the chart

```sh
helm dependency update . --skip-refresh
helm lint .
helm template . -f <values overlay>
```

Bump `version:` in `Chart.yaml` for any change. Do not hand-edit
`appVersion`: Jenkins bumps it when a new rcallocation image is built and
packages the chart to `oci://registry.rc.nectar.org.au/nectar-helm`.
Review is through Gerrit (`git review`, see `.gitreview`); the GitHub repo
is a mirror.
