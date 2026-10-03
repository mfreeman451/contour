# Tasks

**Game:** CONTOUR: Maskirovka

## 1. Application and shared native bootstrap

- [ ] 1.1 Generate the `Contour`/`ContourWeb` Phoenix application and asset setup with compatible toolchains; verify local startup serves an authenticated-shell placeholder and record reproducible setup commands in README.
- [ ] 1.2 Pin the ServiceRadar-resolved Phoenix 1.8.15, LiveView 1.2.12, Bandit 1.12.5, Ecto SQL 3.14.0, Postgrex 0.22.4, Rustler 0.38.0, Horde 0.10.0, and libcluster 3.5.0 baselines with compatible JS assets; verify clean dependency resolution and independent project lockfiles.
- [ ] 1.3 Create pure simulation/protocol crates plus thin native and WASM targets using Arrow array/IPC/schema 59.2.0, Roaring 0.11.4, and petgraph 0.8.3; verify native compilation and `wasm32-unknown-unknown` compilation with only required features enabled.
- [ ] 1.4 Adapt ServiceRadar's checked native-binary boundary and WASM instantiation/allocation lifecycle into a synthetic round-trip spike; verify an Arrow batch and portable bitmap survive native -> BEAM -> browser worker -> WASM decoding with no sibling-checkout runtime dependency.
- [ ] 1.5 Add local developer checks for Elixir formatting/compilation, Rust formatting/clippy, JS build, and target compilation; verify the documented check commands run on a fresh checkout and record ServiceRadar provenance/retained notices for adapted source.
- [ ] 1.6 Select and pin a mutually compatible published DeepCausality/core/ethos/uncertainty family and Rust toolchain using official docs, independent of ServiceRadar; verify a native spike evaluates a Context/Causaloid, factual/alternate comparison, bounded seeded uncertainty, and frozen/verified Ethos verdict, and record the exact APIs/releases in docs/staff-intelligence.md.

## 2. Versioned protocol and bounded client storage

- [ ] 2.1 Define envelope v1, exact field widths/limits, fixed component schemas, sorted bitmap row mapping, snapshot chunk rules, and allowed enums in `docs/protocol.md`; verify synthetic golden fixtures decode identically with Rust and a JS Apache Arrow oracle.
- [ ] 2.2 Implement native fixed-schema IPC group encoding and schema bootstrap with measured Vec-to-OwnedBinary copies; verify transform-only, health-only, appearance, introductions, and removal fixtures use the documented groups and report total encoded bytes.
- [ ] 2.3 Implement checked envelope/bitmap/IPC decoding and atomic staging in the shared client protocol layer; verify truncated lengths, duplicate groups, bad row counts, invalid enums, nonfinite transforms, and oversized buffers reject without changing the live slab.
- [ ] 2.4 Implement public-handle -> local-slot mapping and component slab patching; verify remove/reveal/reuse cases clear transform, appearance, and selection while unrelated records remain unchanged.
- [ ] 2.5 Implement bounded chunked snapshots, per-connection generations, baseline continuity, and applied-frame acknowledgements; verify interrupted snapshots, gaps, duplicate/stale frames, wrong audience/epoch, and reconnect cannot patch an incompatible baseline.
- [ ] 2.6 Build a controlled worker harness with reusable transferable staging buffers and memory-growth view refresh; verify synthetic dirty ranges update the expected slots and repeated decode cycles reclaim temporary allocations.

## 3. Authoritative state and tactical simulation

- [ ] 3.1 Implement bounded structure-of-arrays entity state, non-reused internal IDs, validated creation, and match-owned Rustler resources; verify capacity rejection, invalid input, independent match resources, and cleanup through public native APIs.
- [ ] 3.2 Implement the versioned rules/seed fixture and fixed tick progression with per-component dirty tracking across unpublished ticks; verify repeated accepted command traces yield identical digests on the same supported build.
- [ ] 3.3 Implement bounded command syntax/sequence/ownership/action/target validation with uniform unknown/hidden-target errors; verify forged health/position, enemy-unit control, replayed sequences, stale generations, nonfinite coordinates, and selection limits fail without state mutation.
- [ ] 3.4 Implement sector-route A* and bounded local traversability/separation movement; verify impassable/disconnected targets fail and legal routes obey configured speed without crossing blocked terrain.
- [ ] 3.5 Implement combat sight/range/cooldown/damage and same-tick destruction resolution; verify attacks apply once, destroyed units leave active sets, and mutually destroyed headquarters yield iteration-order-independent outcomes.
- [ ] 3.6 Document native resource ownership, step results, error semantics, and benchmark invocation; verify all nontrivial step/projection/encoding NIF exports use DirtyCpu and the documented synthetic match runs without Phoenix.

## 4. Sectors, supply, and ruse rules

- [ ] 4.1 Author an eight-sector synthetic alpha map and implement convex coverage/adjacency/obstacle validation with deterministic shared-boundary ownership; verify invalid maps cannot activate and edge/vertex fixtures assign one sector.
- [ ] 4.2 Implement the spatial candidate grid and per-sector/team/archetype membership bitmaps; verify movement transitions remove source membership and add destination membership in the same tick, including high-speed boundary crossings.
- [ ] 4.3 Implement uncontested infantry capture, contested state, graph supply connectivity, configured out-of-combat recovery, and connected-sector income; verify cutting the only headquarters route removes supply/recovery/income and restoring it restores the permitted benefits without budget overflow.
- [ ] 4.4 Implement team/sector ruse cost, cooldown, expiry, eligibility, and stacking rules with configurable alpha values; verify illegal, insufficient-resource, expired, and overlapping activation cases and publish the rules-data contract.
- [ ] 4.5 Implement authoritative Blitz and distinct Camouflage/Radio Silence detection effects; verify Blitz changes speed only inside coverage and direct sight versus radar versus recon produce the specified concealment behavior.
- [ ] 4.6 Implement bounded legal decoy spawning, harmless fire presentation, vulnerability, and movement; verify no damage authority, no capacity overflow, and failed placement/capacity charges no ruse resources.

## 5. Audience projection and information fairness

- [ ] 5.1 Implement geometric base/direct/radar/recon detection with static obstacle occlusion and bitmap concealment composition; verify allied visibility, sensor boundaries, occlusion, and distinct ruse/recon interactions with synthetic fixtures.
- [ ] 5.2 Implement per-team public handles allocated only on introduction and stable within owner epochs; verify never-seen hidden creation changes no exposed allocator metadata and one teammate's resync does not change another's handles.
- [ ] 5.3 Implement introductions/removals and component/appearance invalidation against prior published views; verify stationary reveal/hide and static decoy unmask/remask produce required lifecycle records without relying on physical dirty flags.
- [ ] 5.4 Implement allowlisted genuine/allied and apparent/enemy decoy records, including health/state/effect policy; verify decoded snapshots and every component group omit genuine flags/archetypes/diagnostics for unrevealed enemies.
- [ ] 5.5 Route combat events, sector/ruse HUD data, command responses, advisor input/output, and reconnect snapshots through the projection boundary; verify hidden-source effects, hidden destruction, and genuine signal/decoy provenance do not escape in auxiliary outputs.
- [ ] 5.6 Add paired hidden-state content-equivalence and cross-audience regression coverage plus `docs/visibility.md`; verify all snapshot/delta/event paths satisfy the synthetic fairness scenarios and document the scope of timing/length guarantees.

## 6. Staff intelligence and electronic warfare

- [ ] 6.1 Define immutable audience-only evidence snapshots, authorized observation history, report codes/parameters, and model/evidence versions; verify the advisor API cannot receive unrestricted native state, genuine decoy flags, enemy recon/supply, or emission provenance.
- [ ] 6.2 Implement ordered team supply income/debits and SIGINT Bureau placement, build delay, health, enable/disable, upkeep, coverage, destruction, and rebuilding; verify failed construction charges nothing and disconnected/unpaid/destroyed facilities stop collection immediately.
- [ ] 6.3 Implement bounded coarse sector radio measurements and Ghost Radio cost/cooldown/expiry, with Radio Silence suppressing genuine emissions; verify synthetic and real emissions use the same public observation contract, absence of coverage is unknown, and observations create no entity handles or hidden attack targets.
- [ ] 6.4 Author versioned Context/Causaloid logistics models with deterministic evidence chains and templated own-force explanations; verify a known crossing loss explains configured supply/recovery effects without unsupported factories, deadlines, or hidden enemy facts.
- [ ] 6.5 Implement bounded factual-versus-alternate what-if evaluation for supported own-force plans and known terrain; verify assumption/evidence-age display and identical live state/resources/command trace before and after previews.
- [ ] 6.6 Implement enemy threat/authenticity hypotheses from authorized evidence with qualitative confidence, reliability, alternatives, and insufficient-evidence results; verify Ghost Radio can mislead, silent real armor can be under-assessed, and uncalibrated percentages or certain decoy/intent claims cannot appear.
- [ ] 6.7 Implement frozen/verified Effect Ethos doctrine norms and explained warning-only verdicts with defined inconclusive/error handling; verify ignoring a budget/concealment warning leaves normal legal command acceptance intact and no advisor/CSM action can dispatch or veto an order.
- [ ] 6.8 Implement one-job-per-team supervised DirtyCpu evaluation with bounded snapshots, stages, sampling, queue replacement, requests, output, expiry, and delivery fences; verify late/over-budget results cannot overwrite current evidence and Bureau loss/revocation prevents fresh enemy report delivery.
- [ ] 6.9 Add synthetic paired-observation fairness, seeded model reproducibility, doctrine conflict, Bureau-loss/reconnect, and counter-deception fixtures plus docs/staff-intelligence.md; verify evidence/explanations agree for equivalent observed worlds and record official documentation, chosen APIs, and report/sensor/balance contracts.

## 7. Session coordination and binary Channels

- [ ] 7.1 Implement the match GenServer lifecycle and monotonic 10/20 Hz timer with one in-flight native step and 10 Hz default publication; verify overruns do not overlap steps or create unbounded catch-up messages and document cadence configuration.
- [ ] 7.2 Implement socket authentication, roster-derived team assignment, scoped internal PubSub topics, and binary Phoenix pushes; verify authorized browsers receive binary Arrow payloads and guessed opponent topics receive no data.
- [ ] 7.3 Implement Channel size/rate/selection limits, bounded session admission queues, and explicit command acknowledgements; verify the proposed limits reject overload before mailbox growth while legal orders reach the assigned tick once.
- [ ] 7.4 Implement shared team component payloads with per-connection generation envelopes and applied-frame tracking; verify a reconnecting/slow teammate resynchronizes independently while healthy teammates keep valid baselines.
- [ ] 7.5 Implement five-frame/256-KiB/500-ms acknowledgement-window limits, bounded mailboxes, snapshot throttling, and slow-consumer close behavior; verify skipped dependent deltas trigger a fresh baseline and repeated slow receivers cannot accumulate unbounded memory.
- [ ] 7.6 Implement join/resync/command reauthorization and active membership revocation; verify revoked sessions stop receiving frames and cannot restore access through a prior match token.
- [ ] 7.7 Add real binary socket integration fixtures and `docs/transport.md`, including bounded staff control messages sharing audience/epoch/revocation fences; verify end-to-end native -> PubSub -> Channel -> worker/HUD covers introduction, concealment, recon appearance change, report expiry, Bureau loss, disconnect, and resync.

## 8. WebGPU renderer and battlefield interaction

- [ ] 8.1 Pin Three.js and implement capability/limit detection plus a renderer-owned storage-buffer update adapter; verify supported devices initialize and unsupported/device-loss paths retain a usable lobby status.
- [ ] 8.2 Build the homogeneous 20,000-instance proxy scene and sparse upload bridge; verify actual GPU buffers reflect dirty local-slot ranges, record upload bytes/calls, and demonstrate the expected homogeneous draw batching.
- [ ] 8.3 Implement timestamp-based compute interpolation, bounded delay/freeze, heading wrap, teleport snap, and slot reset; verify a controlled jitter/gap trace yields correct transforms and no stale interpolation after removal/reuse.
- [ ] 8.4 Implement pan/diorama zoom, authorized picking/selection, contextual move/attack orders, sector boundaries, and ruse targeting; verify browser interaction sends legal intention messages without local authority over movement or combat.
- [ ] 8.5 Implement the stable-ID ignored canvas hook, resize handling, worker/listener disposal, and device-loss recovery; verify repeated mount/unmount leaves one active renderer/worker and frees prior render resources.
- [ ] 8.6 Add original low-poly archetype batches and PBR terrain splatting behind a recorded quality profile; verify visual legibility from sector overview to unit detail and record draw-call/geometry budgets with synthetic scenes.
- [ ] 8.7 Add shadow cascades and bounded firing/smoke effects with audience-safe event sourcing; verify concealed entities create no unauthorized effects and compare frame-time budgets with each visual layer enabled.
- [ ] 8.8 Document renderer/worker buffer ownership, supported capability checks, and the GPU benchmark; verify a 1920x1080 acceptance scene records mean FPS, p50/p95/p99 frame times, memory, and actual draw passes.

## 9. Player identity, lobby, decks, HUD, and results

- [ ] 9.1 Implement authenticated account/session identity and required-auth lobby/match routes with scoped metadata contexts; verify spoofed identities and unauthenticated socket/LiveView access are rejected, and document the router/live_session boundary.
- [ ] 9.2 Implement relational match/participant/deck metadata and fixed alpha deck validation; verify ownership, cost/slot constraints, legal starting armies, and additive migrations on an empty development database.
- [ ] 9.3 Implement unranked create/join rooms, team slots, bounded room chat, readiness, and capacity rules for 2–64 participants; verify illegal teams, unready starts, and oversized rooms cannot spawn an active match.
- [ ] 9.4 Implement the team-safe HUD for selection, sector control/shared supply, ruses, Bureau construction/operation/feed state, expandable staff evidence, what-if previews, doctrine warnings, match timer, and connection state; verify previews are distinct from committed orders, stale/offline reports are labeled, shell updates preserve the canvas, and hidden fields are absent.
- [ ] 9.5 Implement headquarters victory, same-tick draw, and the versioned time-limit tie-break; verify completed matches reject commands and display one consistent outcome to all participants.
- [ ] 9.6 Implement 60-second proposed reconnect grace, continuing legal orders, abandoned-session handling, and fresh snapshots; verify a reconnect resumes owned units without duplication or team switching and expired sessions cannot command them.
- [ ] 9.7 Implement bounded asynchronous accepted-command/tick history batches and idempotent result persistence with completeness/missing-range status; verify repeated finalization creates one result, history failure stays bounded, and no raw history leaks to participants.
- [ ] 9.8 Document alpha play/ruse/intelligence rules and complete a two-browser two-team match on the seed map; verify movement, combat, capture/supply, all five ruses, recon, Bureau upkeep/destruction, spoofable reports, what-if previews, ignored doctrine warnings, temporary reconnect, victory, and persisted authorized summaries.

## 10. Cluster ownership, admission, and supervision

- [ ] 10.1 Implement local registry/supervision and optional Horde/libcluster cluster configuration adapted from ServiceRadar; verify named local nodes discover sessions and Kubernetes DNS strategy settings are environment-driven with explicit membership/sync bounds.
- [ ] 10.2 Implement atomic PostgreSQL lifecycle ownership/epoch acquisition, token-checked renewal, conservative monotonic deadlines, and independent supervised lease renewal; verify competing starters cannot both become running owners.
- [ ] 10.3 Implement session and gateway lease/epoch gates with bounded cached authorization; verify delayed renewal responses, stale epochs, database loss, and partitioned contenders cannot publish accepted unfenced ticks or commit results.
- [ ] 10.4 Implement expired-lease reconciliation and owner-resource-loss interruption without seed reconstruction; verify owner process/pod loss terminates the affected match and unrelated healthy rooms continue.
- [ ] 10.5 Implement per-pod player/entity/match admission and draining; verify a full/draining pod starts no new match and deadline-expired active matches receive explicit interrupted status.
- [ ] 10.6 Add telemetry for tick stages, queue wait/depth, publication bytes, acknowledgements/resync, scheduler pressure, memory, membership churn, and ownership; verify operators can distinguish CPU, transport, and lease failures without player-visible hidden state.
- [ ] 10.7 Document cluster failure semantics, lease parameters, drain/recovery procedures, and test configuration; verify local multi-node exercises cover competing starts, owner loss, partitions, and database unavailability with explicit failure assertions.

## 11. Combined release and Kubernetes alpha environment

- [ ] 11.1 Build one immutable image containing the Phoenix release/ERTS, compatible compiled NIF, browser bundle, and WASM asset; verify startup loads the NIF and serves the worker and renderer assets on the target container architecture.
- [ ] 11.2 Add application Kubernetes manifests, DNS discovery, named distribution nodes, restricted distribution connectivity, probes, resource budgets, and drain configuration; verify rendered manifests and a multi-pod discovery smoke check.
- [ ] 11.3 Add CloudNativePG cluster/application database wiring and additive migration execution; verify fresh-environment bootstrap, application connectivity, and database outage behavior without importing reference deployment secrets or data.
- [ ] 11.4 Document alpha deployment, rollout/drain, protocol compatibility, and rollback commands; verify the combined release completes a two-player smoke match and incompatible client/protocol versions are rejected.

## 12. Full alpha acceptance and measured scaling

- [ ] 12.1 Create the versioned benchmark manifest for playable, 200-active-unit, 20,000-entity, visibility/decoy-churn, active staff/SIGINT/spoofing, 2/64-connection, and 64-synthetic-audience cases; verify fixed seeds, activity mix, model/sample caps, hardware/browser/quality settings, warm-up, and ten-minute measurement commands are recorded.
- [ ] 12.2 Run native/BEAM server acceptance at 10 and 20 Hz with full simulation/projection/encoding and 64 participants; verify every measured authoritative step is at most 15 ms and archive p50/p95/p99/max, scheduling/queue timings, memory, and missed deadlines.
- [ ] 12.3 Run 10 Hz publication bandwidth acceptance through real Channels/WebSockets for the representative 200-moving/20-firing workload with active bounded staff/control traffic; verify combined mean downstream is below 4,000 bytes per publication interval and 40,000 bytes/s, and report snapshots, churn tails, TCP/TLS overhead, and 20 Hz publication separately.
- [ ] 12.4 Run the full 20,000-unit 1920x1080 browser scene on recorded M-series and available second baseline GPU hardware with usable WebGPU adapters; verify 60+ mean FPS and p95 frame time at most 16.7 ms, report tails/memory/draw passes, and label 120 FPS results as stretch.
- [ ] 12.5 Run increasing concurrent matches with active staff jobs and same-pod/cross-pod receivers; verify reference-team evaluations stay within 5 ms CPU, heartbeat/lobby/command responsiveness holds, and measured safe admission limits account for DirtyCpu pressure, tick budgets, and memory.
- [ ] 12.6 Run integrated owner-loss, partition, database-outage, slow-consumer, reconnect, unauthorized-join, and decoded-traffic fairness acceptance; verify each capability's failure scenarios still hold across the deployed release.
- [ ] 12.7 Publish a synthetic-data-only acceptance report linked to rules/protocol/image versions and all eight capability specs; verify every release gate has an explicit pass/fail and unresolved failures remain visible before declaring the alpha complete.
