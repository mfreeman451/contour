# Spec Delta

## Purpose

Provide the sole authoritative progression of each RTS match so player orders, movement, and combat produce consistent outcomes independent of client rendering.

## ADDED Requirements

### Requirement: Server authority over match state
The system SHALL accept player intentions and compute positions, health, attacks, ruse effects, and match outcomes on the server. Client-supplied state values MUST NOT override authoritative state.

#### Scenario: Forged health and position
- **WHEN** a client submits health or position overrides instead of a supported order
- **THEN** the command is rejected without changing the entity or advancing its command sequence

### Requirement: Authorized bounded commands
The system SHALL validate match membership, entity ownership, action eligibility, target legality, command sequence, and finite coordinate bounds before accepting an order. Command size, rate, queue depth, and selection count SHALL have documented limits and explicit rejection results.

#### Scenario: Order for an opponent's unit
- **WHEN** a player submits a move order for an entity they do not control
- **THEN** the order is rejected and the response discloses no additional information about that entity

#### Scenario: Duplicate or overloaded input
- **WHEN** a previously accepted sequence is repeated or an input limit is exceeded
- **THEN** the duplicate does not execute again and overload receives a bounded rejection response

#### Scenario: Hidden attack target
- **WHEN** a player submits an entity-targeted attack against an enemy outside their permitted view
- **THEN** the server rejects it without revealing whether the hidden target exists

### Requirement: Ordered reproducible simulation
The system SHALL advance matches in numbered fixed-duration ticks at configurable 10 or 20 Hz. The same versioned rules, initial seed, and tick-assigned accepted commands SHALL reproduce the same outcome on the supported server build. Overruns MUST NOT produce overlapping steps or unbounded catch-up loops.

#### Scenario: Repeated command trace
- **WHEN** the same seed and ordered command trace are executed twice on the same build
- **THEN** tick-state digests and final outcomes match

#### Scenario: Tick overrun
- **WHEN** a step exceeds its scheduled deadline
- **THEN** the next step executes once with a fixed simulation duration and the missed deadline is recorded

### Requirement: Tactical movement and combat
Units SHALL follow traversable routes, obey their configured speed and sector effects, and resolve attacks according to authoritative range, sight, cooldown, and damage rules. Destroyed units SHALL cease acting and leave active membership sets.

#### Scenario: Blocked destination
- **WHEN** a move order targets a disconnected or impassable destination
- **THEN** the order returns a defined failure and the unit does not cross the obstacle

#### Scenario: Successful engagement
- **WHEN** a living attacker has a legal visible target in range and its cooldown expires
- **THEN** the configured damage is applied once and destruction prevents subsequent actions by the target

