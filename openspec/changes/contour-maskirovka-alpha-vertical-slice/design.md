# Design

**Game:** CONTOUR: Maskirovka

## Context

See [proposal.md](proposal.md) for motivation and scope. This repository has `README.md`, a spec-driven OpenSpec configuration, and no application or existing capability specs. The user's PRD fixes the main architecture and exclusions. Its earlier conversation excerpts contain superseded NATS, graph-database, and MMO-sharding suggestions; the PRD's final choices govern this change.

The user identified `/Users/mfreeman/src/serviceradar` as the implementation reference. Read-only inspection used clean commit `816f08685f7bf02cb8f192ad9fffd9aaf182d3ca`. Its implementation confirms working building blocks, not the game's performance envelope. No captured deployment data or production fixtures will be imported.

### Approved foundation refinements

The user approved implementation with Elixir 1.20.4 / OTP 29.1.1, Ash resources/domains and AshPostgres, AshOban, Guardian with Google OIDC, Tailwind v4, and strict TypeScript for all first-party browser code. TypeScript/esbuild target ESNext with pinned tools. Organize the application in `elixir/contour/`, browser source in `web/`, and Kustomize manifests in `k8s/`; future Rust work stays in `native/`.

Separate three web and three core replicas. Registry visibility spans both roles, but only core nodes participate in Horde placement. Discovery uses environment-driven libcluster DNS polling against a shared headless service, named releases, bounded CRDT settings, a shared secret cookie, and mutual TLS distribution. Horde relocation is infrastructure behavior; the later match ownership/lease work must prevent recreating lost native state.

Daily development runs native BEAM/Phoenix against the stock CNPG PostgreSQL 18.6 image in Apple's container system. Bazel/BuildBuddy RBE build the Linux amd64 release and run isolated PostgreSQL/HTTP and TLS multi-node integration tests. The user authorized copying ServiceRadar's private BuildBuddy configuration into gitignored local files; operational credentials remain excluded from source and build inputs. Public workflow configuration is project-owned.

Staging uses farm01, the stock CNPG image, Kustomize, and a manual ArgoCD application. Production configuration reserves carverauto; promotion is deferred. This phase implements and validates the foundation, not the entire playable alpha or a live cluster rollout. Prefer meaningful workflow integration/E2E tests; unit tests are reserved for hard invariants and regressions.

### Reference inventory and reuse boundaries

Paths below are relative to that ServiceRadar checkout. Exact observed resolved versions come from its lockfiles; declaration ranges are not mistaken for installed versions.

| Game concern | ServiceRadar evidence | Adaptation |
| --- | --- | --- |
| Rust columnar encoding | `Cargo.toml`, `Cargo.lock`; `elixir/web-ng/native/god_view_nif/Cargo.toml`; `src/core/arrow_serde.rs` | Use Apache `arrow-array`, `arrow-ipc`, and `arrow-schema` **59.2.0**, rather than choosing another Arrow implementation. Native God View uses `RecordBatch` and `FileWriter`; the game uses fixed-schema IPC streams/component groups. |
| Sparse sets | Root lockfile; `god_view_nif/src/core/arrow_serde.rs:serialize_bitmap` | Use **roaring 0.11.4**, portable `serialize_into`, and cross-language golden fixtures. Replace causal-state sets with entity, sector, dirty-component, and audience sets. |
| Elixir/native boundary | Both Mix lockfiles; root Rust lockfile; `god_view_nif/src/lib.rs` | Use **rustler 0.38.0** in Elixir and Rust. Retain DirtyCpu scheduling and checked allocation. `vec_into_binary` copies from a Vec into OwnedBinary; do not describe it as allocation-free. |
| Web shell | `elixir/web-ng/mix.lock`, `mix.exs` | Baseline **Phoenix 1.8.15**, **LiveView 1.2.12**, **Bandit 1.12.5**; pin compatible Phoenix JS assets to the server version. Use a separate game application and match-scoped authorization. |
| Database client | `elixir/web-ng/mix.lock` | Baseline **ecto_sql 3.14.0** and **postgrex 0.22.4**. Use project-owned Ash domains/resources through AshPostgres for metadata; do not import ServiceRadar monitoring domains. |
| Cluster registry/supervision | `elixir/serviceradar_core/lib/serviceradar/registry/process_registry.ex`; both Mix lockfiles | Baseline **Horde 0.10.0** and **libcluster 3.5.0**. Retain explicit membership/placement settings and configurable CRDT sync bounds. ServiceRadar's 3-second sync interval is evidence of a tuning concern, not an RTS default. |
| Discovery | `elixir/web-ng/config/runtime.exs` cluster section; core `cluster_supervisor.ex` | Use `Cluster.Strategy.Kubernetes.DNS` against the headless service, plus explicit EPMD development configuration; exclude monitoring-specific deployment identifiers. |
| Browser column validation | `assets/js/lib/god_view/world_tile_decode.js`, `snapshot_columns.js` | Reuse the approach: validate encoded size, schema/version, types, row counts, bounds, and generation before allocating/publishing state; retain typed arrays and avoid per-unit JS objects. |
| WASM lifecycle | `assets/wasm/god_view_exec/`; `assets/js/wasm/god_view_exec_runtime.js` | Retain explicit allocation/free discipline and streaming instantiation fallback. That inspected WASM crate has no Arrow dependencies; God View decodes Arrow with JS `apache-arrow` (declared `^16.1.0`) and uses WASM helpers. Build the proposed Rust Arrow/Roaring worker, with JS Arrow retained only as a diagnostic interop oracle. |
| Stream generation and cancellation | `channels/topology_tile_channel.ex`, God View stream/cache code | Adapt generation fences, acknowledgement of actually retained state, supervised bounded work, and stale-task cancellation. Tile hints and HTTP snapshot fetching do not constitute the game's 10–20 Hz binary match channel. |
| Native raw-binary transport | `channels/arrow_stream_handler.ex` | Reference its binary WebSock/NIF boundary, but keep the approved Phoenix Channel game transport and team-safe PubSub fanout. FieldSurvey ingestion and database writes are unrelated. |
| Renderer | `assets/package.json`, `WorldMapRenderer.js` | Its Deck.gl/Luma.gl implementation informs buffer/camera/lifecycle pitfalls. Use the PRD's Three.js WebGPURenderer for the game's PBR/compute pipeline. |

Implementation will adapt these patterns into project-owned code with attribution where source is copied and compatible license notices retained. Do not link this game's build to a sibling checkout or copy ServiceRadar's entire dependency graph, NATS pipeline, Ash domains, graph services, or checked-in operational credentials.

### DeepCausality reference boundary

DeepCausality is grounded exclusively in its official documentation, as requested; ServiceRadar's causal implementation and the local DeepCausality checkout are not design references. Official concepts document Causaloids, Context, effect propagation, CausalFlow, CSM, uncertainty, and Effect Ethos as distinct pieces. Use authored, versioned game models, not runtime causal discovery or autonomous command execution. [Official concepts](https://docs.deepcausality.com/concepts/), [Causaloid](https://docs.deepcausality.com/concepts/causaloid/)

Choose a compatible published set of `deep_causality`, `deep_causality_core`, `deep_causality_ethos`, and, where used, `deep_causality_uncertain`, then pin exact versions and the required Rust toolchain during bootstrap. These crates publish independently; the official site's examples and docs.rs pages can describe different releases. Prove Context/Causaloid evaluation, factual-versus-alternate evaluation, bounded uncertainty sampling, and a verified Ethos verdict in one native compilation spike before adopting API signatures. DeepCausality remains server-native; the browser receives reports, not models or private contexts. [Official install guidance](https://docs.deepcausality.com/getting-started/install/)

## Goals / Non-Goals

**Goals:** A single serialized authority per match; audience projection as a mandatory serialization and advisor-input boundary; interoperable typed wire data; bounded memory and queues; GPU rendering independent of LiveView patch frequency; contestable intelligence that can be deceived; player authority over all orders; reproducible acceptance measurements.

**Non-Goals:** One process per unit, durable storage in the tick hot path, cross-machine lockstep determinism, a single draw call for all heterogeneous meshes/materials/shadow passes, an end-to-end zero-copy guarantee, and restoration of native match memory merely by restarting a supervisor child. These boundaries preserve the approved architecture while making its guarantees precise.

## Decisions

### 1. One Phoenix application, one authority resource per match

Use `Contour` and `ContourWeb` namespaces with a Mix application under `elixir/contour/`, a Rust workspace, and TypeScript browser assets:

| Proposed location | Responsibility |
| --- | --- |
| `elixir/contour/lib/contour/matches/` | Room lifecycle, admission, session coordination, ownership fencing |
| `elixir/contour/lib/contour/accounts/`, `elixir/contour/lib/contour/decks/` | Identity and relational metadata through scoped Ash domains/resources |
| `elixir/contour/lib/contour_web/live/`, `channels/` | Authenticated lobby/match shell and authorized command/replication transport |
| `native/simulation/` | Pure Rust simulation library, no Rustler dependency, usable by benchmarks |
| `native/protocol/` | Shared schemas, envelope validation, portable bitmap codec, golden fixtures |
| `native/authoritative_core/` | Thin Rustler resource boundary over simulation/protocol |
| `native/client_core/` | Rust Arrow/Roaring WASM worker library and compact client slab |
| `native/staff_intelligence/` | Pure Rust evidence models, explanations, what-if comparisons, and advisory doctrine |
| `web/src/battlefield/` | Worker bridge, Three.js GPU adapter, interaction, hook lifecycle |
| `elixir/contour/priv/maps/`, `priv/rules/` | Versioned synthetic map and rules inputs |
| `bench/`, `k8s/` | Reproducible acceptance workloads, image and Kubernetes manifests |

The match GenServer is justified by persistent mutable state, ordered commands, timers, and lifecycle transitions. It alone owns a Rustler resource containing structure-of-arrays state, entity allocator, graph/spatial index, rules, and per-audience history. Stateless map validation and codecs remain plain functions. Avoid mirroring 20,000 mutable unit structs in Elixir/ETS. Expose small safe diagnostic summaries rather than dumping the native resource.

Resource operations are create, validated step, authorized snapshot/projection, summary, and release. Calls return tagged failures, bounded binaries, tick metadata, and summaries. Run nontrivial simulation/projection/encoding on DirtyCpu and permit one in-flight mutating call per resource. Place checked capacity bounds at the NIF boundary. Native memory faults can affect the whole VM, so Rust memory safety and native validation remain essential even with supervised matches. [Rustler scheduling documentation](https://docs.rs/rustler/0.38.0/rustler/attr.nif.html)

Alternative: per-entity actors or an Elixir copy of every entity. Both add synchronization and allocation costs without helping the required serialized authority. A pure Rust library plus a thin NIF also avoids making the benchmark depend on a running web application.

### 2. Fixed steps, bounded ingress, and separate publication cadence

Default to 20 Hz simulation and 10 Hz publication; support 10 Hz simulation and opt-in 20 Hz publication for benchmarks. Commands use Phoenix's control messages with a versioned schema: command sequence, selected public handles, action, and a typed target (sector, visible entity, or finite `x/y` coordinate). Player/team identity comes from the socket, not command fields. The PRD's protobuf snippet expresses intentions; its single integer coordinate is not the final wire contract. JSON control messages keep the alpha free of a second code-generation toolchain; high-volume state remains binary.

Proposed configurable starting bounds: 4 KiB command messages, 64 selected handles, 20 commands/s/player with burst 40, 1,024 pending commands/match, and 256 accepted orders applied per tick. Reject overload before queueing. Perform syntax/rate checks at the Channel and ownership/target/action checks in native authority. Rejected unknown and hidden targets use the same public error. No dynamic atoms from player data.

Assign accepted orders to a tick and total order, deduplicate sequences, and log that accepted trace. Schedule from monotonic deadlines with one pending tick; use fixed simulation `dt`, record lateness, and skip expired wall-clock scheduling slots without replaying unbounded timer backlogs. Dirty sets accumulate across simulation steps until publication succeeds. Lobby heartbeat responsiveness and scheduler pressure are separate measurements from native step time.

Alternative: send every command without limits or use arbitrary elapsed wall time for simulation. This creates uncontrolled queues and irreproducible combat. Replaying stale delivery backlogs also defeats current-state resynchronization.

### 3. Sector bitmaps complement a real spatial index

Use convex map polygons with half-open shared-boundary ownership, tie-break by lowest sector ID for coincident vertices, and validated traversable coverage. Candidate sectors come from a bounded spatial grid; exact point-in-polygon checks happen when position changes across possible boundaries. Maintain Roaring sets per sector/team/archetype and a compact adjacency graph (petgraph baseline **0.8.3**, observed in ServiceRadar's lockfile).

Bitmaps accelerate sector/team intersections after geometric membership is known; they do not calculate membership, recon circles, terrain occlusion, or line of sight themselves. Use the same bounded spatial grid to find nearby sight/combat candidates, then deterministic range/occlusion checks against static terrain blockers. Route macro movement with A* over sectors and a local traversability grid; use bounded separation for close units, not rigid-body vehicle physics.

The versioned alpha map has eight convex sectors, two headquarters, authored obstacles, and traversable supply edges. These are proposed seed defaults. Living infantry capture after a configurable uncontested dwell; contested sectors provide no supply. Supply connectivity is BFS through allied controlled, uncontested sectors to an allied headquarters. Initial armies come from fixed budget-validated decks. Connected controlled sectors provide configured out-of-combat recovery and tick-based income into a bounded team supply budget. Ruses, SIGINT Bureau construction, and upkeep compete for that budget; wider unit production and building economies are deferred. All balance values live in rules data.

Ruses store `(team, sector, kind, start_tick, expiry_tick)` with team-wide resource/cooldown accounting. Same-ruse overlap is rejected; distinct ruses combine according to fixed priority. Proposed starting durations/costs are rules data, not hard-coded acceptance assumptions. Blitz changes authoritative speed. Radio Silence suppresses radar and genuine radio emissions; Camouflage suppresses direct/radar detection for eligible ground units; recon overrides entity concealment. Decoys create bounded harmless mock units with projected combat appearances. Ghost Radio Broadcast adds synthetic sector emissions; it does not create combat units or reveal an unseen entity. Its explicit synthetic emissions can coexist with Radio Silence, which still suppresses genuine emissions.

Alternative: blanket claims of collision-free or sub-microsecond visibility. Bitmap intersection can be fast, while the geometric work and dirty-set construction still require measured budgets.

### 4. Project views before touching network encoders

Define a view audience as a team: all teammates share battlefield knowledge, while control rights remain per player. The alpha has no unrestricted spectator or live all-seeing replay endpoint. Let `O` be allied entities, `B` base detection, `D` direct sight, `R` radar, `Q` recon reveal, `C` enemy camouflage, and `S` enemy Radio Silence:

`V = O union Q union (((B union D) minus C) union (R minus (C union S)))`

Detection sources are computed geometrically before bitmap combinations; eligibility sets determine which unit categories each concealment applies to. Sensor ranges and occlusion are rules-driven. Dead entities are removed from the active visibility domain.

For prior and current published view sets `V_prev` and `V_now`:

- `introduced = V_now minus V_prev`: full permitted records, even if not physically dirty.
- `removed = V_prev minus V_now`: generic removal of previously known handles; do not reveal whether an unseen entity died or became concealed.
- `updated = dirty_components intersect V_now`: only permitted component patches for retained records.
- `appearance_changed`: invalidate archetype/apparent attributes when recon, ruses, or reveal state changes, even for stationary entities.

The projector returns allowlisted audience records, sensor evidence, and authorized events. The encoder and staff advisor receive these projections, never the unrestricted resource. Snapshots, HUD summaries, combat particles, selection metadata, command responses, advisor reports/explanations, and diagnostics obey the same projection. Genuine decoy archetype/flag/internal health and ability state cannot slip into auxiliary columns; define apparent health/state and animation fields in a versioned projection policy. SIGINT deliberately authorizes coarse sector observations within operating sensor coverage, not entity coordinates, identifiers, or genuine archetypes. Paired-state fairness compares identical authorized observations, including those sensor observations. Expected visible interactions can still reveal a bluff through gameplay. Do not claim protection against all traffic-analysis timing/length side channels.

Internally entities use monotonic non-reused `u32` IDs. Each team maps introduced entities to its own monotonic public handles, allocated only on first introduction; never-visible units have no public handle for that audience. An entity's known handle can be reused on re-reveal, but a destroyed handle is not reassigned to a new entity. Client local slab slots are separate and reusable. Team handles remain stable for the owner epoch across individual reconnects. A new per-connection view generation resets that client's slab/schemas, not other teammates' handles; commands from old connection generations are rejected. This prevents global allocator/index leakage and stale-slot confusion.

Alternative: send genuine state and let the client hide or relabel it. That violates the PRD's memory fairness guarantee. Filtering only `dirty intersect visible` also misses introductions, removals, and static decoy transitions.

### 5. A bounded envelope around fixed-schema Arrow groups

Protocol v1 uses a little-endian length-delimited envelope with magic/version, match UUID, owner epoch, audience ID, view generation, frame sequence, simulation tick/time, baseline sequence, frame kind, and a bounded section directory. Cap encoded delta frames at 256 KiB and snapshot chunks at 256 KiB; snapshot total decoded entities cannot exceed the 20,000-entity cap. Schema/bitmap/section sizes are validated before allocations; duplicate group IDs, bad cardinality/order, nonfinite transforms, unknown enum values, and out-of-bounds handles reject the entire frame.

Each component group has a fixed schema, optional portable Roaring handle mask, and an Arrow IPC payload:

| Group | Columns / semantics |
| --- | --- |
| Introductions/snapshot | `x/y/heading: Float32`, `health: UInt16`, `state: UInt8`, `apparent_archetype: UInt16`, permitted owner/team/category fields |
| Transform | `x/y/heading: Float32` |
| Health/state | `health: UInt16`, `state: UInt8` |
| Appearance | permitted apparent archetype/owner/category fields only |
| Removals | Previously introduced public handles only; generic removal semantics |
| Events | Bounded authorized effect records and team-safe sector/ruse/HUD changes |

The Roaring set is sorted ascending and defines row-to-handle mapping; no redundant global entity ID column. All rows in a component group share its schema. This is a family of agreed IPC streams, not one stream whose columns change per tick: Arrow streams require a stable schema. Bootstrap each group schema during view initialization; delta payloads contain encapsulated record-batch messages under that schema. Decoder and writer adapters must prove compatibility with Arrow 59 on native/WASM targets and a JS `apache-arrow` oracle. Snapshot/resync reestablishes schemas. [Apache Arrow IPC specification](https://arrow.apache.org/docs/format/Columnar.html#ipc-streaming-format)

Validate and stage complete frames, then apply removals, introductions, component patches, and events atomically. A transform or health patch referring to a handle absent after lifecycle processing is invalid. Snapshot chunks are staged with sequence/count/total-size bounds and committed together; never patch partially installed snapshots.

Native writers initially use the checked Vec-to-OwnedBinary path from ServiceRadar, with one measured boundary copy. Same-node binary reuse reduces copying between BEAM processes, but cross-node distribution, WebSocket/TLS handling, WASM ingestion, and GPU upload have their own costs. Optimize writer-to-owned-buffer construction only after profiling. [Erlang binary handling](https://www.erlang.org/doc/system/binaryhandling.html)

Alternative: repeat variable schemas every tick or presume Arrow/Roaring compress all numeric state for free. Three Float32 transform columns for 200 rows already require 2,400 bytes before framing; the 4,000-byte budget must include health/state, bitmap, IPC, channel, and WebSocket overhead. Quantization/compression is a versioned measured optimization if needed, never a silent wire change.

### 6. Team-safe PubSub and client acknowledgement windows

Join `match:<id>` using an authenticated socket; derive the audience from persisted roster/session authorization. Subscribe internally to `match:<id>:epoch:<epoch>:team:<team>`. The session publishes a prefiltered binary to that internal topic; the Channel validates its epoch/generation and pushes `{:binary, payload}`. Standard Phoenix Channel framing remains present; use the official binary support without JSON/base64 state wrapping. [Phoenix Channel binary push contract](https://phoenix.hexdocs.pm/Phoenix.Channel.html#module-pushes)

Use scoped PubSub topics, not per-socket late filtering of unrestricted state. Reauthorize resync, command acceptance, and membership changes; revocation actively unsubscribes/closes associated Channels. Share component-section bytes among teammates. Add a small per-connection envelope for view generation and baseline bookkeeping; a single reconnect must not reset the whole team. Track each connection's acknowledgement of fully applied `(epoch, generation, sequence)`.

Default maximum unacknowledged delivery: five frames, 256 KiB, or 500 ms, whichever occurs first. Gate delivery before socket pushes and bound mailboxes; stop dependent deltas at the limit. For a short gap, start a fresh authorized snapshot generation; repeated resync failure or a client that cannot consume a bounded snapshot closes with a retryable slow-consumer status. A skipped baseline cannot be repaired merely by sending the next dirty frame. Throttle snapshot requests, and pause deltas until snapshot commit is acknowledged. Coalesce only by building a correct fresh baseline or a complete cumulative update from a known baseline.

Sequence gaps, wrong match/team/generation/epoch, stale frames, and reconnect invalidate delta continuity. Reconnect gets current authorized state with no obsolete tick replay. Retain only bounded recent metadata/payloads for acknowledgement accounting, not a broker-backed tick log.

Alternative: unrestricted broadcast then Channel filtering or silently dropping arbitrary queued deltas. The first risks disclosure; the second leaves client state permanently wrong. Raw WebSock transport exists in ServiceRadar but is not needed to bypass supported Phoenix binary payloads in this alpha.

### 7. Rust WASM worker and renderer-owned GPU buffers

Use the same Arrow 59.2.0 and Roaring 0.11.4 families in a `wasm32-unknown-unknown` client library with only required features. Prove compilation, IPC subset support, and golden-frame decoding in the first integration milestone. Use a dedicated worker; transfer incoming ArrayBuffers to it, validate/decode, then patch a compact structure-of-arrays slab. Refresh typed views after WASM memory growth. Transferred buffers avoid one JS worker copy but do not make a received ArrayBuffer the same allocation as WASM linear memory.

Start with reusable transferable staging buffers containing merged dirty local-slot ranges. This works without SharedArrayBuffer/cross-origin-isolation requirements; measure copy/upload costs. The main thread owns Three.js's renderer/device and receives bounded staging updates from the worker. Keep previous/next transform samples and tick timestamps in storage buffers; compute interpolation per render frame, then render instanced archetype/LOD batches. Snap removals/introductions and explicit teleports rather than interpolating stale slot contents.

Use Three.js StorageBufferAttribute/TSL compute with a small GPU adapter for version-specific update-range handling. `device.queue.writeBuffer` is the upload primitive, but all writes target renderer-owned compatible buffers: do not assume access to a renderer-private GPUBuffer is a stable public API. Pin Three.js during bootstrap and verify partial upload behavior on that exact version. Use WGSL through supported node/custom compute integration where necessary. [Three.js storage buffers](https://threejs.org/docs/pages/StorageBufferAttribute.html), [attribute update ranges](https://threejs.org/docs/pages/BufferAttribute.html#addUpdateRange)

One homogeneous benchmark archetype can demonstrate one instanced unit draw per pass. Real gameplay uses batches per geometry/material/LOD, plus terrain, shadow, and particle passes. Report actual draw calls instead of promising one total draw. Stage visual complexity: instanced proxies first, then original low-poly meshes, PBR terrain splatting, diorama camera, shadow cascades, and bounded fire/smoke effects with a documented performance quality profile.

Use an interpolation delay of one published interval initially, bounded by 250 ms; freeze after 500 ms without valid samples and display reconnect status. Inputs produce orders only. Canvas hook uses a stable DOM ID and `phx-update="ignore"`, owns resizing, workers/listeners/animation cleanup, and device-loss recovery. LiveView owns slow shell/HUD state; no entity-by-entity DOM patches. Authenticated lobby and match pages live inside the required-auth router/live_session scope because roster and battlefield access require a stable identity.

Alternative: shared memory from day one or per-unit JS objects on every frame. Transferable buffers reduce integration constraints; a future shared-memory path must justify its COOP/COEP and deployment costs with measurements.

### 8. Horde placement with explicit failure semantics and fencing

Start local development with a normal DynamicSupervisor/Registry; cluster mode adapts ServiceRadar's Horde patterns with libcluster DNS polling. Web and core pods use the same combined image, with only core pods hosting sessions. Placement respects per-pod match/entity capacity. Track membership churn and configurable CRDT sync interval/max-sync size, and test pod rollouts; do not copy a monitoring-specific sync interval without measurements.

Horde is eventually consistent and restarts child processes without preserving their state. It provides discovery/placement, not a strong ownership lock or native state checkpoint. [Horde's documented consistency and restart semantics](https://horde.hexdocs.pm/Horde.DynamicSupervisor.html)

Acquire a PostgreSQL match-ownership row atomically when transitioning `lobby -> starting`, with unique match ID, owner token/node, increasing epoch, lease expiry, and lifecycle state. A match becomes `running` only under that token after native creation. Running matches are never transparently reassigned: an owner restart, lost resource, expired lease, or forced shutdown produces `interrupted`. A competing Horde child sees an already claimed/running row and cannot reconstruct it from seed.

A supervised lease process renews at 1 s with a proposed 5 s TTL, independently of tick computation, using compare-and-set on owner token/epoch. Compute conservative local monotonic validity deadlines from database-observed remaining lease time and request-start time, with a safety margin; discard late renewal responses. Session and Channel gateways fail closed at that local deadline. Gateways refresh bounded lease-cache authorization and accept only its epoch/token; they do not query Postgres for every unit or tick. Result/history commits compare owner epoch/token and live lease. Explicitly test delayed messages, lease expiry, database outage, and stale cached authority.

Since alpha never starts a replacement owner for a running match, an expired owner cannot overlap a resumed authority. A lifecycle reconciler atomically marks expired running rows interrupted; disconnected gateways eventually provide terminal status or return it on reconnect. Future seamless failover needs native snapshots, accepted-command recovery, fresh epochs, and stronger cross-gateway fencing tests as a separate change.

Drain pods by removing them from admission, letting matches finish, then interrupting remaining rooms at a configured deadline. Do not claim a PodDisruptionBudget guarantees indefinite active-match survival. Dirty scheduler saturation across several NIF-heavy matches is an admission problem; expose stage timings and scheduler pressure.

Alternative: rely on Horde unique keys to guarantee a single active owner across partitions. Eventual convergence can temporarily duplicate processes, and a restarted Rust resource is empty. PostgreSQL lifecycle/lease fencing provides an explicit alpha correctness boundary without adding a broker.

### 9. Minimal alpha rules and relational metadata

Use authenticated accounts and stable sessions, unranked create/join room matching, two teams, per-player ownership, ready checks, and fixed valid deck templates. Support 2–64 players subject to map/pod capacity; the interactive fixture starts with two. Seed armor, infantry, recon, and headquarters with deck cost/slot constraints; Decoys spawns mock armor through its ruse. Start with an HQ-elimination victory condition, same-tick draw handling, and a 20-minute proposed rules-data time limit resolved by surviving headquarters, then controlled sectors, then draw. Disconnect grace defaults to 60 s; last accepted orders continue, expired participants abandon control. No automatic ally ownership transfer in this alpha.

Persist accounts/session tokens, deck definitions/selections, matches, participants, owner epochs/leases, and unique results. Batch accepted commands and periodic tick digests into bounded diagnostic-history storage away from the hot loop; do not write 20,000 entity rows each tick. History is server-only until a separately authorized replay feature exists. Persistence retries must be idempotent and bounded; on sustained history failure, mark history incomplete with the missing sequence range and expose it to operators. Persist that completeness status with the result. Results remain durable before a match is reported finalized.

Alternative: import ServiceRadar's complete Ash/monitoring schema or persist all runtime entity state. The game has small independent metadata domains and transient match-native state; AshPostgres stores project-owned metadata resources, and AshOban handles bounded background maintenance. This does not change battlefield contracts.

### 10. A staff advisor and contestable electronic intelligence

The user selected explanations and what-if analysis with doctrine warnings. Every move, attack, construction, and ruse order remains a player decision. The advisor neither submits commands nor vetoes a legal command. Ordinary legality, ownership, resources, and cooldown checks still apply independently. No LLM or learned opponent-intent classifier is required.

**Model structure.** Put game-authored Causaloids and Context adapters in `native/staff_intelligence/`. Represent owned supply paths, sector connectivity, recovery eligibility, own budgets, facility status, observation age, and permitted contacts as typed context facts. Compose logistics and threat hypotheses through effect propagation/CausalFlow with explicit evidence references and assumptions. Static model/rule versions and stable evaluation ordering define reproducibility; do not let models rewire themselves during a match. If CSM is used to manage alert state, its actions only emit bounded report candidates, with no command-dispatch capability. Templates turn report codes and parameters into text; raw library logs never become player text.

The official documentation distinguishes value/state/context alternation from graph-layer intervention. The alpha compares a factual model evaluation with a copied, explicitly altered planning context; it does not claim that substituting an input alone proves a Pearl-style causal effect about the opponent. [Official counterfactual documentation](https://docs.deepcausality.com/concepts/counterfactuals/), [CausalFlow API](https://docs.rs/deep_causality_core/latest/deep_causality_core/struct.CausalFlow.html)

**Two information scopes.** Basic staff analysis explains facts already available about the player's own force: for example, “Losing the crossing disconnected Sector 2; recovery there has stopped.” Player-requested what-if comparisons can assume retaking a named sector, moving owned units along known terrain, changing Bureau operation, or activating an available ruse. Show the baseline tick, changed assumptions, estimated effects, and unknown enemy reactions. A hypothetical sector capture changes only the copied planning graph. Geometry analysis uses known static terrain and own sensor characteristics, never concealed enemy positions. Factory upgrades, future reinforcements, ammunition throughput, artillery placement, and exact starvation countdowns are outside the current rules and receive no fabricated forecasts.

Advanced enemy force-authenticity/SIGINT analysis requires an operational Intelligence HQ / SIGINT Bureau. The alpha has one facility type, one construction slot per team, a construction delay, finite health, build cost, and per-simulation-second upkeep. Players place it on legal allied controlled terrain connected to headquarters and may toggle operation or rebuild after destruction. Construction validates placement, capacity, and budget atomically; an invalid request charges nothing. Construction completion precedes operation, and an operating Bureau pays upkeep only when it can pay the full configured interval. Loss of supply connectivity, insufficient budget, player shutdown, or destruction turns collection off at that tick. Re-enabling requires a legal connected facility and sufficient upkeep. Bureau health/position follows normal ally visibility and enemy Fog of War; its defender can see its own status, while opponents learn it only through permitted observation.

Proposed initial coverage is the Bureau's sector plus adjacent sectors in the authored sector graph; coverage does not depend on hidden enemy facts. Configured sector income, Bureau cost/upkeep, and ruse costs share one bounded supply pool. Simultaneous team requests execute in command order. This creates a contestable opportunity cost between intelligence and ruses in the alpha; buying replacement armor and a faction EW upgrade tree belong to the later production economy. No airstrike or paratrooper unit is added solely for the example: existing combat can destroy the Bureau.

**Measurements precede inference.** The simulation generates bounded coarse radio measurements only for covered sectors while collection is online. Rules define quantized activity classes, noise, missed readings, and observation timestamps. Real emissions depend on configured activity and Radio Silence; Ghost Radio produces a plausible alternate emission pattern at supply cost/cooldown/duration. The audience projector publishes only the resulting sector observation, with public source type, age, and sensor-quality band. It excludes true emitter counts/positions, genuine unit types, actual enemy budget, transmitter IDs, and a synthetic/real provenance flag. No signal coverage means “unobserved”; an observed quiet sample is distinct and still compatible with Radio Silence, missed emissions, or a decoy. Radar concealment and SIGINT observation are separate rules; a signal observation creates no live unit handle and grants no entity-targeted attack.

An advisor consumes only this audience evidence plus permitted visual/recon contacts. It never receives the authoritative decoy set, actual enemy recon coverage, enemy plans, hidden supply graph, or true emission provenance, including through a counterfactual request. Authorized observation history has explicit age/expiry and cannot silently refresh while the Bureau is offline. Facility loss invalidates in-flight enemy analysis and marks retained reports stale/offline immediately; recon and own-force explanations continue under their independent rules. Rebuilding restarts collection from fresh samples; a reconnect cannot resume a supposedly live hidden feed.

**Deception remains effective.** Ghost Radio can raise an armor-threat hypothesis from the same apparent evidence as real traffic. Real armor under Radio Silence can leave weak/quiet evidence and receive a low-confidence threat assessment. A silent decoy can lower perceived authenticity, but the report presents alternatives and recommends recon. Equivalent projected observations produce equivalent report content even if one hidden world contains real tanks and the other mock units. The advisor does not identify the ruse that generated an adversary's signal or assert that observed redeployment was caused by a bluff. Direct recon remains the existing gameplay mechanism for genuine unit identification.

Report contract: report ID, audience, owner epoch, connection generation, input tick/evidence version, model/rules version, expiry, kind/severity, confidence band, authorized evidence references, assumption codes, alternative hypotheses, and localized explanation code/parameters. Start with explicit `low / medium / high / insufficient evidence` bands and separate measurement reliability from hypothesis confidence. These are authored model ratings, not advertised calibrated probabilities. Numerical probabilities or intervals may be displayed only when the implemented sensor/model distribution and synthetic calibration report justify them; never present an invented “45%” as measured accuracy. Missing enemy production/logistics observations cannot establish that an army is impossible. [Official uncertainty documentation](https://docs.deepcausality.com/concepts/uncertainty/)

**Doctrine warns.** Use verified Effect Ethos norms to evaluate a player-selected draft action against permitted own-force context. For example, an affordable Ghost Radio activation that would leave insufficient supplies for the Bureau's next upkeep interval yields a warning, with the applicable rule identifiers. A concealment warning must describe a consequence actually defined by current ruse/combat rules. Map `Obligatory`, `Impermissible`, and `Optional` outcomes to advice labels; they do not change command admission or create forced actions. Inconclusive/error results show doctrine unavailable and never invent a verdict. The official library supplies a justified verdict and requires a frozen/verified norm graph; the application's warning-only integration is a deliberate game choice. [Official Effect Ethos documentation](https://docs.deepcausality.com/concepts/effect-ethos/)

**Bounded evaluation away from the tick.** The authority exports a small immutable evidence snapshot after projection. Snapshot construction and radio measurement are inside the 15 ms authoritative-step boundary; the staff evaluation runs in a separately supervised bounded task through a DirtyCpu NIF, without borrowing or locking the mutable match resource. Initially evaluate at most once per team per simulation second, one in-flight job per team, with only the latest replacement snapshot retained. Share reports among teammates; rate-limit what-if requests to one per player per two seconds and the same team job capacity. Proposed caps are a 64 KiB evidence snapshot, 200 sector facts, 16 hypothesis candidates, 32 evidence references/report, four report candidates/evaluation, 2 KiB report message, and 4 KiB/s total staff/control output per recipient. Final combined traffic must still meet the downstream budget.

Bound model nodes, what-if horizon/steps, and uncertainty sample counts; use seeded sessions if the selected published uncertainty API samples. Check a cooperative deadline between bounded stages, target at most 5 ms evaluation CPU per team job on the recorded reference server, and discard results older than two simulation seconds or with obsolete epoch/evidence/generation/facility authorization. A BEAM task timeout alone cannot preempt a running NIF, so bound the native algorithms themselves. Failed/over-budget jobs produce unavailable advice and do not delay commands; deduplicate repeated warnings and expire alerts when their evidence expires. Send the bounded report contract over the authenticated team Channel as low-frequency control data, sharing the match's authorization, revocation, and acknowledgement/delivery limits. Revalidate authorization and active Bureau status at delivery. LiveView/JS HUD exposes expandable evidence and an explicit “preview” action; committing an order uses the existing command interface.

Alternative: reason over omniscient simulation state and redact the final sentence, display uncalibrated probability percentages, or wire CSM/Ethos to player command execution. Those approaches would undermine both information fairness and player agency. Evaluation latency is a measured release target, not a microsecond guarantee inherited from the library.

### 11. Performance gates are reproducible workloads

Use two workload classes: a playable scene and synthetic stress scenes. Record seed, code/rules/map/protocol versions, CPU/GPU/RAM, pod resource requests/limits, browser/driver, resolution, distinct audiences, activity mix, command rate, and connection placement. Warm up for one minute, measure for ten minutes, and retain machine-readable results with p50/p95/p99/max rather than a single best result.

| Gate | Acceptance and measurement boundary |
| --- | --- |
| Tick | 20,000 entities at 10 and 20 Hz; every measured step from command application through all audience projections and encoded outputs at most 15 ms. Report coordinator scheduling, NIF queue wait, publish/delivery latency, max and overruns separately as well. |
| Bandwidth | 200 moving units, 20 of those firing and changing health/state each publication, stationary background units, stable visibility, 10 Hz publication with active bounded staff reports: mean total downstream replication/staff/control/channel/WebSocket bytes less than 4,000 per publication interval and 40,000/s/client. Report TCP/TLS wire bytes separately, initialization/resync separately, and visibility/decoy-churn tail workloads. |
| Cadence | 20 Hz simulation/10 Hz publication is the default budget case. At 20 Hz publication, a 4,000-byte frame would approach 80,000 bytes/s; retaining 40,000/s requires mean frames below 2,000 bytes. Report this explicitly rather than equating tick and publication rates. |
| Client | 20,000 permitted units at 1920x1080, documented performance profile, 60+ mean FPS and p95 at most 16.7 ms. Validate M-series and an available GTX 1060/RX 580-or-newer machine only where the actual OS/browser supplies a usable WebGPU adapter; 120 FPS is stretch. |
| Multiplayer | 2 and 64 connected participants on both same-pod and cross-pod delivery. Start with two shared team views; include 64 distinct synthetic views to measure serialization growth, without claiming 64 teams as gameplay scope. |
| Runtime | Run one match, then increasing concurrent matches to determine safe admission limits. Record memory, ordinary scheduler responsiveness, DirtyCpu queue pressure, and resync rates; do not assume a 4-vCPU pod runs dozens of matches. |
| Intelligence | Operating/offline/destroyed Bureau, supply contention, real/decoy/Ghost Radio/Radio Silence fixtures, own-force what-if comparisons, and doctrine warnings; reference-team jobs at most 5 ms CPU, bounded work/output, and no command latency regression. Include active staff workload during the concurrent-match run and total staff/control bytes in the downstream gate. |
| Fairness | Compare decoded snapshots/deltas/events/advisor reports for paired synthetic worlds with identical permitted observations; exercise stationary reveal/hide, decoy unmask/remask, hidden death, forged targeting, unauthorized joins, resync, revocation, and forged advisor queries. |

Reference server hardware is selected and recorded in the benchmark manifest before accepting results; the proposal makes no unsupported absolute throughput claim for an unspecified CPU. Failure of a budget remains a failed release gate. Profile and optimize the offending stage, update an explicitly versioned encoding if necessary, or revise the requirement through a subsequent OpenSpec review rather than reporting success from a smaller workload.

## Risks / Trade-offs

- [Per-audience geometry/projection/encoding may dominate] -> Cache reusable detection sets, share team views, and measure 2 versus 64 synthetic audiences before scaling match admission.
- [Arrow metadata plus sparse groups can exceed the bandwidth target] -> Use bootstrap schemas, fixed component groups, actual all-in byte counts, and versioned quantization only if profiling warrants it.
- [Native work can saturate DirtyCpu schedulers or native memory] -> Bound entity/command capacities, serialize each resource, stress concurrent matches, and enforce admission from measured budgets.
- [Three.js compute and partial-upload APIs evolve] -> Pin the renderer, isolate a GPU adapter, and validate real buffers and draw passes early; no private-buffer API assumption is a release guarantee.
- [Fog of War bugs can escape through events/HUD/metadata] -> Centralize allowlisted projection and inspect decoded bytes across all transport paths, including reconnect.
- [Advisor context or explanation trails can disclose hidden truth] -> Build the input solely from authorized evidence and compare report/explanation content across equivalent observations; recheck Bureau state and audience at delivery.
- [SIGINT becomes a free truth oracle or overwhelms ruse choices] -> Charge construction/upkeep from the shared supply budget, allow sensor spoofing/suppression, preserve competing hypotheses, and playtest fragile-facility counterplay before balance sign-off.
- [Causal models or uncertainty APIs are mistaken for calibrated accuracy] -> Version authored assumptions, pin a compatible official crate family in the API spike, bound seeded sampling, and use qualitative ratings until calibration justifies numerical probabilities.
- [Advisory work consumes native scheduler capacity] -> Evaluate immutable evidence off the serialized step with bounded tasks/stages and measure active staff workloads in admission and tick-budget acceptance.
- [Cluster interruption is visible to players] -> Fail clearly, preserve summaries, drain admission, and defer seamless recovery until checkpoint/replay authority is designed.
- [Reference implementation is useful but has different transport/render semantics] -> Keep the inventory above and transfer bounded patterns rather than topology, telemetry, and GIS-specific behavior.
- [Visual fidelity can consume the frame budget] -> Integrate shadows/terrain/particles incrementally and make the accepted quality profile reproducible.

## Migration Plan

This is greenfield; no existing production API or schema requires migration. Bootstrap locally, validate native/worker protocol fixtures, add the playable match, then exercise the combined release image. Deploy to an isolated Kubernetes alpha environment with CloudNativePG, named release nodes, restricted distribution connectivity, DNS discovery, and generated synthetic fixtures only.

Apply additive database migrations before starting the first alpha image. Publish protocol/rules/map versions together, and reject mixed incompatible clients. During image changes, stop new room admission, drain running matches, then reconnect clients into new rooms; do not hot-swap NIF resources mid-match. Roll back to the previous image only when its schema/protocol remains compatible, otherwise keep the environment unavailable until migration recovery. Render manifests and test release loading before any cluster rollout.

## Open Questions

- Which available baseline CPU and second GPU machine will be used for the recorded acceptance runs? The measurement boundaries and gates are already fixed; hardware availability changes the run environment, not the behavior contract.
- Which original map/mesh assets should replace the synthetic alpha proxies after the rendering budgets pass? Asset authoring does not change the eight-sector seed fixture or the simulation contracts.
