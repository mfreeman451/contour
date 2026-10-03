# Spec Delta

## Purpose

Run isolated authoritative match rooms across a cluster with bounded resource use, explicit failure behavior, reproducible deployment, and measurable alpha release gates.

## ADDED Requirements

### Requirement: Single fenced match owner
A match SHALL have at most one publisher whose ownership epoch is valid at an accepting gateway. Ownership acquisition SHALL be atomic and independent of eventual registry convergence. Owners SHALL stop command processing and publication when ownership expires or cannot be validated.

#### Scenario: Partition creates competing processes
- **WHEN** two cluster processes attempt to own the same match
- **THEN** only the fenced owner can provide accepted ticks or commit results and competing processes terminate or remain inactive

### Requirement: Explicit active-match interruption
Loss of an active owner's in-memory simulation SHALL interrupt that match. A restarted process MUST NOT silently reset or resume the match from its original seed. Other healthy match rooms SHALL continue operating.

#### Scenario: Active owner pod crashes
- **WHEN** a pod hosting an active match is terminated
- **THEN** the match is marked interrupted, connected players receive a terminal status when reachable, and the lobby permits a new match

### Requirement: Admission and graceful draining
Match admission SHALL enforce configured player, entity, and pod resource limits. A draining pod SHALL stop receiving new matches and permit current matches to finish within the configured drain deadline, with remaining matches explicitly interrupted on forced shutdown.

#### Scenario: Full pod
- **WHEN** a new match would exceed the pod's configured resource capacity
- **THEN** admission places it on an eligible pod or returns a capacity result without starting an overloaded room

### Requirement: Single release and relational metadata
The application SHALL deploy as one versioned container image including the runtime, native simulation, and browser assets. Relational player, deck, roster, result, command-history, and ownership metadata SHALL persist outside pods. Local development SHALL work without a cluster.

#### Scenario: Release smoke check
- **WHEN** a release image starts with the declared database and environment configuration
- **THEN** it loads its native library, serves its browser assets, and completes a two-player smoke match

### Requirement: End-to-end tick budget
The reference server workload SHALL run 20,000 entities at 10 and 20 Hz without overlapping steps. After warm-up, every measured authoritative step through all audience projections and frame generation SHALL complete within 15 ms during the ten-minute acceptance run; p50/p95/p99/max and missed deadlines SHALL be reported.

#### Scenario: Full match workload
- **WHEN** the benchmark runs with 64 connected participants and the documented movement, combat, recon, and ruse activity
- **THEN** the stated tick budget is met and player count, distinct audience count, hardware, limits, and command rate accompany the result

### Requirement: Runtime observability and isolation
Operators SHALL observe tick stages, queue depth, native/advisor execution, scheduler pressure, publication/control bytes, resyncs, memory, and ownership transitions. Long native computation and bounded advisor work SHALL preserve ordinary runtime responsiveness. Diagnostics MUST NOT expose genuine enemy state to player interfaces.

#### Scenario: Concurrent native workload
- **WHEN** several matches execute their maximum measured native workload
- **THEN** socket heartbeats and lobby requests remain responsive within the documented baseline and dirty-worker saturation is recorded

### Requirement: Cluster deployment acceptance
The alpha SHALL provide a Kubernetes deployment with clustered application discovery and highly available PostgreSQL management. Acceptance SHALL exercise cross-pod player delivery, owner loss, partition fencing, slow consumers, and database unavailability in addition to the local smoke match.

#### Scenario: Owner loses database access
- **WHEN** an active owner can no longer renew its ownership authorization
- **THEN** it stops publication before authorization expires, clients see a bounded interruption status, and no unfenced result is committed
