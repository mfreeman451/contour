# Proposal

**Game:** CONTOUR: Maskirovka

## Why

CONTOUR: Maskirovka needs a playable browser RTS foundation that makes sector control and deception central to strategy. This alpha will validate the approved Elixir/Rustler, Arrow/Roaring, and WebGPU architecture with an end-to-end match and reproducible scale measurements before expanding game content.

## What Changes

- Establish a Phoenix/LiveView application with a Rustler simulation core and a Rust WASM client worker. This game repository contains only a README and OpenSpec scaffolding. Use the inspected `~/src/serviceradar` implementation as the reference for dependency versions, Arrow/Roaring encoding, NIF scheduling, browser column validation, WASM lifecycle, and Horde/libcluster configuration; game-specific integration and performance acceptance remain new work.
- Add authoritative movement, combat, sector ownership and supply connectivity, bounded command ingestion, and a minimal playable match with a lobby, fixed decks, recon, and a victory condition.
- Implement shared team Fog of War and sector ruses: Blitz, Camouflage, Radio Silence, and Decoys. Project each audience's permitted representation before serialization, including visibility transitions and recon-driven changes to decoy appearance.
- Add a DeepCausality staff advisor for explainable own-force logistics, bounded what-if comparisons, and doctrine warnings. Gate enemy SIGINT analysis behind a constructible, destructible, supply-consuming Intelligence HQ / SIGINT Bureau. Add Ghost Radio Broadcast as a counter-ruse that can mislead intelligence reports. The advisor receives only authorized evidence, presents uncertainty, and never issues or blocks player orders.
- Stream versioned binary snapshots and deltas through authenticated Phoenix Channels and Phoenix.PubSub, using Apache Arrow IPC and portable Roaring Bitmaps. Include resynchronization and bounded slow-client handling.
- Render the permitted state with Three.js WebGPURenderer, WASM decoding, sparse GPU updates, and compute interpolation between server updates. Deliver diorama navigation, PBR terrain, shadows, and bounded combat effects.
- Run discrete 2–64-player match rooms with Horde/libcluster and PostgreSQL metadata; package the release and NIFs together for Kubernetes with CloudNativePG. Specify fenced match ownership and explicit interrupted-match behavior rather than assuming Horde restores Rust memory.
- Add reproducible acceptance workloads for 20,000 entities, 10–20 Hz simulation, 60+ FPS rendering, and the PRD's tick and bandwidth budgets. Performance values are release targets, not verified properties of the proposed stack.

The first interactive milestone is a two-player, two-team match on one original map; the completed alpha also includes the 64-player scale harness. The alpha adds one intelligence facility and a shared supply budget for ruses, construction, and upkeep; a broad construction/production economy, faction EW upgrade tree, public ranked matchmaking, a large faction roster, campaign/AI opponents, cosmetics, polished replay playback, and seamless recovery of a failed active match are deferred. NATS/JetStream, a dedicated graph database, Deck.gl/Luma.gl, and continuous MMO sharding remain excluded.

## Capabilities

### New Capabilities

- `authoritative-simulation`: Match-owned Rust state, validated commands, movement/combat, and deterministic tick progression.
- `sector-ruses`: Convex sector membership, control/supply graph, and team-scoped timed ruses.
- `audience-visibility`: Server-side team visibility and deception projections across every entity lifecycle transition.
- `staff-intelligence`: Evidence-scoped causal advice, player-controlled what-if planning, contestable SIGINT, Ghost Radio, uncertainty, and advisory doctrine.
- `binary-replication`: Arrow/Roaring wire contracts, authorized delivery, snapshots, deltas, and resynchronization.
- `webgpu-battlefield`: WASM entity storage, instanced WebGPU rendering, interpolation, and battlefield interaction.
- `match-experience`: Player identity, lobby/decks/chat, playable match flow, HUD, results, and reconnect behavior.
- `match-runtime`: Supervision, cluster placement, fenced ownership, metadata persistence, deployment, and operational measurements.

### Modified Capabilities

None. There are no existing capability specs in this repository.

## Impact

All application components are additions. Proposed implementation locations are `lib/contour/`, `lib/contour_web/`, `native/authoritative_core/`, `native/client_core/`, `native/staff_intelligence/`, `assets/`, `priv/`, `bench/`, and `deploy/`; none exist yet. New interfaces include command envelopes, audience-specific replication frames, bounded advisor evidence/report contracts, Rustler resource calls, and the WASM/GPU buffer contract. Dependencies include Phoenix/LiveView/Ecto, Rustler, Horde/libcluster, Rust Arrow/Roaring and graph/spatial libraries, DeepCausality, Three.js, PostgreSQL, and CloudNativePG. Start from ServiceRadar's resolved versions for the existing architecture foundations. For DeepCausality, use its official documentation and pin a compatible published crate family independently. ServiceRadar is a read-only reference, not a runtime dependency. No existing application API or data migration compatibility is required.
