# Spec Delta

## Purpose

Ensure every player receives only their team's authorized battlefield view, with deception enforced before any state or event becomes observable on the client.

## ADDED Requirements

### Requirement: Server-projected audience views
The system SHALL produce a shared authorized view per team from allied units, base detection, direct sight, radar, recon, and active concealment. Unauthorized entity records and hidden attributes MUST be excluded from snapshots, deltas, events, HUD data, advisor inputs/reports, and reconnect responses. SIGINT SHALL authorize only its documented coarse sensor observations.

#### Scenario: Hidden unit moves and fires
- **WHEN** an enemy unit remains outside a team's permitted detection while moving or firing
- **THEN** that team's decoded traffic contains no entity record, hidden position, or hidden-source event for the unit

#### Scenario: Allies remain known
- **WHEN** an allied unit enters an allied camouflaged sector
- **THEN** its team's authorized view retains the genuine allied representation

### Requirement: Visibility transitions independent of dirty state
The system SHALL send a complete permitted record when an entity enters an audience's view and remove its active client representation when it leaves. These transitions SHALL occur even when the entity's physical state is unchanged. Removal MUST NOT disclose an otherwise hidden destruction or concealment reason.

#### Scenario: Stationary unit revealed
- **WHEN** recon reveals a stationary enemy with no movement or health change
- **THEN** the next published view introduces the complete permitted record

#### Scenario: Stationary unit concealed
- **WHEN** camouflage hides a previously visible stationary enemy
- **THEN** the next published view removes its live representation and further hidden updates are absent

#### Scenario: Destruction outside sight
- **WHEN** a previously removed enemy is destroyed outside an audience's view
- **THEN** no new destruction notification for that hidden entity is sent to that audience

### Requirement: Consistent decoy projections
Enemy audiences without qualifying recon SHALL receive the decoy's configured apparent archetype and permitted apparent attributes. They MUST NOT receive genuine mock-unit flags, archetypes, diagnostics, or metadata that directly expose the deception. Allies and qualifying recon SHALL receive the allowed genuine representation.

#### Scenario: Opponent inspects a decoy payload
- **WHEN** an opponent decodes every field of an unrevealed decoy's snapshot and updates
- **THEN** the record identifies the apparent combat unit without a genuine decoy marker

#### Scenario: Recon changes appearance without movement
- **WHEN** recon reveals or stops revealing a stationary decoy
- **THEN** the next published view replaces its appearance according to current reveal rules even if its transform is unchanged

### Requirement: Public handles reveal no global allocation state
Entity references exposed to a team SHALL identify only entities introduced to that audience and SHALL not expose global entity allocation counts or server memory indices. Never-seen hidden entities MUST have no assigned public representation for that team.

#### Scenario: Hidden reinforcement allocation
- **WHEN** entities are created outside an enemy team's view
- **THEN** that team's public handle allocation and payload metadata do not enumerate those entities

### Requirement: Equivalent hidden states yield equivalent permitted records
For identical authorized observations, planning inputs, and accepted commands, changing only hidden entities SHALL not change decoded entity, event, or advisor content for an audience. Authorized observations SHALL include permitted SIGINT measurements. This guarantee SHALL cover payload content and schema metadata; it SHALL not claim constant network timing or packet length.

#### Scenario: Paired hidden-state fixtures
- **WHEN** two simulations differ only in units outside all permitted observation and interaction
- **THEN** their decoded audience records and events are equivalent
