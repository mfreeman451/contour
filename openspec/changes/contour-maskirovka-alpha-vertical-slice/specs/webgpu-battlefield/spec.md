# Spec Delta

## Purpose

Present the team's permitted battlefield as an interactive browser diorama with smooth movement, large unit counts, and reliable rendering resource lifecycle behavior.

## ADDED Requirements

### Requirement: Capability-gated battlefield startup
The client SHALL start the battlefield only after a supported WebGPU adapter/device and required limits are available. Unsupported browsers SHALL receive an actionable capability message while retaining access to the lobby.

#### Scenario: Browser without a usable adapter
- **WHEN** a player tries to enter a match and device initialization fails
- **THEN** the lobby remains usable and the client explains that the battlefield requires a supported WebGPU browser/device

### Requirement: Authorized entity memory and sparse updates
The client SHALL maintain only currently permitted active entity records and map public handles to compact local slots. Removed records SHALL cease rendering and picking. Sparse component updates SHALL patch their associated slots without rebuilding all active records each update.

#### Scenario: Removal and slot reuse
- **WHEN** a hidden entity is removed and its local slot is reused for another introduced entity
- **THEN** the previous transform, appearance, and selection do not leak into the new entity

### Requirement: Smooth bounded interpolation
Rendering SHALL interpolate between authoritative transform samples using their simulation timestamps at display rate. The client MUST NOT invent authoritative movement, damage, or ruse effects; prolonged missing samples SHALL freeze the last permitted state and show a connection warning.

#### Scenario: Jittered server updates
- **WHEN** 10 Hz transform samples arrive with the documented network jitter
- **THEN** displayed motion remains timestamp-based and interpolation does not advance beyond its bounded sample horizon

### Requirement: Diorama interaction and visual clarity
The battlefield SHALL support pan, zoom from sector overview to unit detail, allied unit selection, contextual movement/attack orders, visible sector boundaries, and authorized ruse targeting. PBR terrain, shadows, and bounded combat effects SHALL make the tactical state legible without revealing hidden entities.

#### Scenario: Selection and camera zoom
- **WHEN** a player selects allied units, zooms toward them, and issues a legal order
- **THEN** the selection remains coherent and the command is sent through the authoritative command interface

### Requirement: Large-scene rendering acceptance
The reference 20,000-unit scene SHALL sustain at least 60 FPS during a recorded ten-minute run on the documented supported baseline hardware/browser/settings. Frame-time p50/p95/p99, resolution, draw calls, and memory SHALL be reported. 120 FPS SHALL be a stretch target, not a baseline guarantee.

#### Scenario: Reference rendering benchmark
- **WHEN** the prescribed scene runs after warm-up at the baseline resolution and quality profile
- **THEN** average FPS is at least 60 and p95 frame time is at most 16.7 ms, with tail stalls reported separately

### Requirement: Canvas lifecycle cleanup
Leaving a battlefield SHALL stop its animation and decoding loops, terminate workers, remove event listeners, and dispose rendering resources. Device loss SHALL stop play input and provide a recoverable status.

#### Scenario: Repeated mount and unmount
- **WHEN** a player enters and leaves the battlefield repeatedly
- **THEN** there is one active renderer/worker per mounted battlefield and no continuing network or animation work from prior mounts

