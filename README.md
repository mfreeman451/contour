# CONTOUR: Maskirovka

Foundation for an API-driven RTS: Elixir **1.20.4 / OTP 29.1.1**, Phoenix/LiveView, Ash resources and domains, AshPostgres, AshOban, Guardian, Google OIDC, TypeScript, and Tailwind v4. The current UI is an authenticated command-station placeholder; match simulation and Three.js rendering are subsequent alpha work.

## Layout

| Directory | Responsibility |
| --- | --- |
| `elixir/contour/` | Phoenix application, Ash domains/resources, OTP runtime, migrations, HTTP/PostgreSQL integration tests |
| `web/` | Strict TypeScript, CSS, independent npm lockfile, frontend build |
| `k8s/` | Kustomize base, farm01 staging, reserved carverauto production, ArgoCD application |
| `build/`, `third_party/` | Bazel toolchains, pinned dependency artifacts, isolated CI PostgreSQL |
| `scripts/` | Local database, development, cluster smoke, image packaging, secret bootstrap |

## Daily development

Install Elixir/OTP from `.tool-versions`, Node 22, and Apple's [container CLI](https://github.com/apple/container). Docker is supported with `CONTAINER_ENGINE=docker`. Run from the repository root:

```sh
scripts/db up
npm ci --prefix web
scripts/dev setup
scripts/dev phx.server
```

Open **http://localhost:4000**. Phoenix reloads Elixir/HEEx and watches TypeScript and Tailwind. For continuous type checking, use `npm run --prefix web typecheck -- --watch` in another terminal. `scripts/dev` forwards Mix arguments, so `scripts/dev ecto.migrate`, `scripts/dev test`, and `scripts/dev ash_postgres.generate_migrations --name change_name` work normally. You can also `cd elixir/contour` and run Mix directly with the database environment exported.

The database uses the stock CNPG PostgreSQL **18.6** image, pinned by digest, with a standalone initialization wrapper. It runs on **127.0.0.1:55432**, uses SCRAM for TCP authentication, and stores data in `contour-postgres-data`. Credentials are generated once in `.local/postgres.env` (mode 0600). `scripts/db stop` preserves the volume; `scripts/db up` reuses it. No Kubernetes operator is needed locally. The local development role can create the isolated test database; staging uses a database owner without superuser access.

The default local process runs web and core together. Set `CONTOUR_ROLE=web` or `core` to exercise a role separately; clustered nodes require named distribution, a shared cookie, and `CLUSTER_NODES` or `CLUSTER_DNS_NAME`. `scripts/cluster-smoke` exercises three web plus three core BEAM nodes over mutual TLS, adds a fourth core, and checks owner loss and registry convergence. Horde relocates children after node loss; real matches still require the alpha's PostgreSQL lifecycle leases and fencing before this runtime hosts simulations.

## Login and API

Copy `.env.example` to `.env`, then set a Google **Web application** OAuth client ID/secret and `OIDC_REDIRECT_URI=http://localhost:4000/auth/google/callback`. Register that exact callback in Google's console. Restart Phoenix after changing credentials. Login remains disabled until credentials are configured; there is no development authentication bypass.

Google authorization uses state, nonce, and S256 PKCE. Verified issuer/subject identify users; accounts are never linked by email. Browser cookies contain an encrypted opaque session credential; only its hash is persisted. Sessions expire after 12 hours. Ash policies restrict identity and session resources. AshOban prunes expired sessions, OIDC attempts, and quota windows on core nodes.

| Endpoint | Contract |
| --- | --- |
| `GET /auth/google`, `GET /auth/google/callback` | Google authorization/code callback |
| `GET /lobby` | Session-protected LiveView shell |
| `POST /auth/api-token` | Authenticated browser + CSRF; issues a 15-minute API bearer token |
| `POST /auth/logout` | Authenticated browser + CSRF; revokes session |
| `GET /api/v1/me` | Bearer JWT; returns `{data: {id, display_name, email}}` |
| `DELETE /api/v1/session` | Bearer JWT; revokes the session and its API/socket credentials |

API authentication requires the expected issuer, audience, token type, signature, expiry, and a live persisted session. Browser cookies do not authenticate API requests. `/socket` admits validated bearer credentials; match channels are still to be implemented. Connected LiveViews receive revocation broadcasts and recheck session authorization every minute.

Quotas are atomic PostgreSQL fixed windows shared by all pods: **300 API requests/IP/minute**, **120 authenticated API requests/user/minute**, and **20 authentication requests/IP/minute**. Excess returns `429` and `Retry-After`; unavailable quota storage returns `503`. Fixed windows permit a burst across a window boundary. Forwarding headers are ignored locally and only trusted for configured ingress proxy CIDRs in staging.

## Builds and checks

```sh
npm run --prefix web typecheck
scripts/dev format --check-formatted
scripts/dev compile --warnings-as-errors
scripts/dev test
scripts/cluster-smoke
bazel build --config=rbe //:release //web:typecheck
bazel test --config=rbe //elixir/contour:integration //elixir/contour:cluster //scripts:release_smoke //third_party/hex:lock_consistency
```

Bazel uses pinned Elixir/OTP, LLVM, Node, Tailwind, npm integrity hashes, and the project's own Hex lockfile. BuildBuddy uses the ServiceRadar executor fleet, with its executor and workflow images pinned by digest. `.bazelrc.remote` was copied locally from ServiceRadar and is **gitignored**; it contains the API key. Public `buildbuddy.yaml` contains only this project's workflow. Configure the repository in BuildBuddy and its authenticated Bazel wrapper before enabling staging PR/push triggers. No credentials belong in Bazel source globs or artifacts.

Remote integration tests start a private PostgreSQL 18.6 instance over a Unix socket inside the test action and migrate an isolated database. They do not connect to the local developer container or a shared deployment. The CI fixture server is compiled from checksum-pinned upstream source using the digest-pinned executor's build tools; local/staging use the stock CNPG image. Npm and Hex fetching happen in repository resolution, with package checksums. After changing dependencies, run `scripts/npm-bazel` and `bazel run --config=rbe //third_party/hex:write` and review the generated graph. New npm packages also need graph entries in `web/npm_packages.bzl`, `web/BUILD.bazel`, and `MODULE.bazel`.

The packaged release also boots and loads its Elixir/ERTS and digested assets in a native Linux amd64 RBE smoke test. The Linux amd64 image builds locally through Apple container; local execution of that image currently fails in OTP's `prim_tty` under architecture translation. The daily native macOS BEAM development loop works and does not use that translated application image. Run release acceptance on native amd64 staging/RBE. A similar translation failure is tracked [upstream](https://github.com/erlang/otp/issues/10355).

First-party browser code targets **ESNext** with pinned TypeScript/esbuild. WebGPU and renderer feature support will be checked at runtime. See `AGENTS.md` for the integration-first testing policy.

## Occasional staging deployment

See [k8s/README.md](k8s/README.md). Staging runs on **farm01**, with three web pods, three scalable core pods, and three CNPG instances. Production's **carverauto** overlay is reserved; promotion is deferred. Build/test work targets staging, and application deployment is manual until MVP. This foundation does not alter a cluster on checkout or startup.

ServiceRadar's OIDC challenge handling, typed Guardian claims/revocation, cluster placement, and BuildBuddy configuration informed the implementation. This project owns its Ash resources and independent dependencies; it has no sibling-checkout runtime dependency.
