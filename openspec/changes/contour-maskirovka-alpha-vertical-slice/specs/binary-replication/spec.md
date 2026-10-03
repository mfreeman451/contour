# Spec Delta

## Purpose

Define a compact interoperable binary replication contract that preserves authorized entity lifecycle changes and recovers correctly when a client's state is no longer current.

## ADDED Requirements

### Requirement: Versioned binary contract
Replication SHALL use a documented binary envelope carrying protocol version, match identity, owner epoch, audience, view generation, frame sequence, simulation tick/time, baseline, and length-delimited sections. Entity columns SHALL use Arrow IPC and row handles SHALL use portable Roaring serialization with explicit sorted row mapping.

#### Scenario: Valid frame in another implementation
- **WHEN** the reference client decodes a server-produced golden frame
- **THEN** bitmap cardinality and sorted handles map exactly to the documented column rows and lifecycle sections

#### Scenario: Unsupported version or malformed lengths
- **WHEN** a client receives an unsupported version, truncated section, or mismatched row count
- **THEN** it rejects the complete frame without partially changing live entity state

### Requirement: Fixed schema agreement
Each replication component group SHALL have a versioned fixed Arrow schema. Schema agreement SHALL be established before dependent batches, and fields MUST NOT be silently added, omitted, or retyped within a group.

#### Scenario: Health-only update
- **WHEN** health changes without a transform or appearance change
- **THEN** the frame uses the agreed health/state group and the other components retain their previous values

### Requirement: Atomic snapshots and deltas
A snapshot SHALL atomically replace an audience's active view. A delta SHALL atomically apply introductions, removals, component patches, and permitted events against its stated baseline. Snapshot chunks MUST be bounded and MUST NOT become live until complete.

#### Scenario: Introduction and patch at one tick
- **WHEN** a frame introduces a unit and patches its transform at the same tick
- **THEN** the client commits one coherent record using the documented lifecycle ordering

#### Scenario: Interrupted snapshot transfer
- **WHEN** a connection closes before the final snapshot chunk
- **THEN** the incomplete snapshot is discarded and reconnect requires a fresh authorized snapshot

### Requirement: Authorized subscriptions
The server SHALL derive audience membership from authenticated match participation and authorize every join and resync request. A client MUST NOT select another team's replication topic or continue receiving data after membership revocation.

#### Scenario: Opponent topic guessed
- **WHEN** a participant attempts to join another team's topic
- **THEN** the join is rejected without a snapshot or subsequent frames

### Requirement: Baseline continuity and resynchronization
Clients SHALL reject duplicate, stale, wrong-audience, wrong-epoch, or wrong-generation frames. A sequence gap or missing baseline SHALL suspend dependent patching and request a current authorized snapshot. Reconnect SHALL not replay an obsolete delta backlog.

#### Scenario: Frame skipped by a slow client
- **WHEN** frame 12 is missing and frame 13 depends on frame 12
- **THEN** frame 13 is not applied and the client obtains a fresh view generation and snapshot

#### Scenario: New owner epoch
- **WHEN** a frame belongs to a different owner epoch
- **THEN** it cannot patch state from the prior epoch and terminal or fresh-session handling occurs

### Requirement: Bounded delivery and explicit bandwidth budgets
Slow clients SHALL have bounded pending frames and bytes and SHALL resynchronize or disconnect when limits are exceeded. The reference 200-unit workload at 10 Hz publication with active bounded staff reports SHALL average less than 4,000 bytes per client per publication interval and less than 40,000 bytes/s, including replication, staff/control data, channel, and WebSocket framing.

#### Scenario: Slow receiver under sustained load
- **WHEN** a receiver cannot consume deltas within the documented acknowledgement window
- **THEN** pending delivery remains bounded and dependent deltas are replaced only through a new snapshot baseline or the receiver is disconnected

#### Scenario: Measured reference traffic
- **WHEN** the documented representative workload is measured after schema and snapshot initialization
- **THEN** both mean update size and mean downstream rate meet the stated limits, with snapshots, tail sizes, and 20 Hz publication measured separately
