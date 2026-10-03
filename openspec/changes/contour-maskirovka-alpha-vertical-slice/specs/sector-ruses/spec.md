# Spec Delta

## Purpose

Make sector control, supply connectivity, and timed information warfare abilities understandable strategic rules that apply consistently to units crossing sector boundaries.

## ADDED Requirements

### Requirement: Unambiguous sector membership
Every active on-map entity SHALL belong to exactly one sector. Maps SHALL define convex polygons, traversable adjacency, and a deterministic boundary rule. Invalid overlaps, gaps in playable terrain, or references to missing sectors MUST prevent map activation.

#### Scenario: Crossing a boundary
- **WHEN** a unit crosses from one sector to another
- **THEN** it leaves the source membership and enters the destination membership within the same tick

#### Scenario: Unit on a shared edge
- **WHEN** a unit lies exactly on an edge shared by two sectors
- **THEN** the documented tie-break assigns exactly one sector on every repeated evaluation

### Requirement: Sector control and supply connectivity
The system SHALL determine sector control from eligible living units and configured capture rules. A sector SHALL provide supply benefits and configured income only when its controlled traversable route reaches the team's headquarters. Contested or disconnected sectors SHALL not provide those benefits. Ruses and intelligence construction/upkeep SHALL debit one bounded authoritative team supply budget.

#### Scenario: Cutting a supply route
- **WHEN** an opponent captures the only sector connecting a controlled sector to headquarters
- **THEN** the disconnected sector loses its supply benefit on the next evaluated tick

### Requirement: Timed team ruse activation
Players SHALL activate eligible ruses for their own team on a legal sector subject to authoritative cost, cooldown, and duration. Effects SHALL be team-scoped, use simulation time, and have a deterministic stacking rule.

#### Scenario: Expiry and same-ruse stacking
- **WHEN** a ruse reaches its expiry tick or a second activation of the same team/ruse/sector is attempted while active
- **THEN** the expired effect is removed and the overlapping activation is rejected

#### Scenario: Enemy units in an affected sector
- **WHEN** both teams have units in a sector with an allied ruse active
- **THEN** only the activating team's eligible units receive its beneficial effect

### Requirement: Blitz movement effect
Blitz SHALL increase eligible allied movement speed by 50% while the unit is inside the active sector. The server SHALL apply the effect; visual interpolation SHALL not grant additional movement authority.

#### Scenario: Leaving Blitz coverage
- **WHEN** a moving unit exits a sector with active allied Blitz
- **THEN** subsequent authoritative movement uses its normal speed unless another eligible effect applies

### Requirement: Distinct concealment rules
Camouflage SHALL suppress enemy visual and radar detection of eligible units unless enemy recon reveals them. Radio Silence SHALL suppress enemy radar detection and configured genuine radio emissions while preserving permitted direct sight and recon detection. Allied visibility SHALL remain available. Synthetic Ghost Radio emissions SHALL follow their separate ruse rules.

#### Scenario: Radio-silent unit in direct sight
- **WHEN** an enemy directly observes a unit affected by Radio Silence
- **THEN** that enemy receives the permitted visible representation despite radar suppression

#### Scenario: Recon enters a camouflaged sector
- **WHEN** enemy recon satisfies the reveal rules for a camouflaged unit
- **THEN** the unit becomes visible for that audience while remaining concealed from other audiences without recon coverage

### Requirement: Decoy creation and restrictions
A legal Decoys activation SHALL create configured mock units within the chosen sector subject to match capacity and placement limits. Decoys SHALL follow server movement orders, have their configured vulnerability, and inflict no real attack damage.

#### Scenario: Decoy attack animation
- **WHEN** a decoy depicts firing at an enemy
- **THEN** the presentation does not reduce the enemy's authoritative health

#### Scenario: Entity capacity reached
- **WHEN** a Decoys activation would exceed the match's entity cap
- **THEN** the activation is rejected without charging its cost or starting its cooldown
