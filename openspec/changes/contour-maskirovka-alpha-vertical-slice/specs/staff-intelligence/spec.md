# Spec Delta

## Purpose

Give commanders explainable planning support and contestable electronic intelligence while preserving their command decisions, uncertainty, and the opponent's ability to deceive.

## ADDED Requirements

### Requirement: Player retains command decisions
The staff advisor SHALL explain observations, compare player-requested plans, and warn about doctrine. It MUST NOT issue orders, select tactical actions for execution, or block otherwise legal player commands. Advice availability SHALL not be a prerequisite for accepting an order.

#### Scenario: Player ignores a doctrine warning
- **WHEN** a player commits a legal attack after seeing an advisory concealment warning
- **THEN** normal command validation accepts the attack regardless of the advisor's verdict

#### Scenario: Advisor unavailable
- **WHEN** staff evaluation fails or exceeds its bounded work budget
- **THEN** the interface shows advice unavailable and legal player orders remain usable

### Requirement: Evidence-scoped reasoning
Every advisor input, hypothesis, explanation, and what-if result SHALL use only the team's permitted observations and explicitly declared hypothetical assumptions. Hidden enemy state and true decoy/signal provenance MUST NOT enter the reasoning context. Equal permitted evidence and model inputs SHALL produce equal report content on the supported build.

#### Scenario: Same observation from different hidden forces
- **WHEN** real armor and mock armor produce identical permitted visual and radio observations in paired fixtures
- **THEN** report content and evidence trails are equivalent despite the different hidden truth

#### Scenario: Forged enemy what-if query
- **WHEN** a client requests hidden enemy supply, recon, positions, or true archetypes through a planning query
- **THEN** the request is rejected or answered as unknown without revealing those facts

### Requirement: Explainable own-force analysis
The advisor SHALL explain supported own-force logistics and operational effects with authorized evidence, source tick, model version, and assumptions. Missing observations SHALL remain unknown. Explanations MUST NOT fabricate production systems, deadlines, opponent intentions, or effects absent from the active rules.

#### Scenario: Own supply connection cut
- **WHEN** losing a known crossing disconnects an allied sector from headquarters
- **THEN** staff can explain that route loss stopped the sector's configured supply benefit using the known causal chain

### Requirement: Read-only what-if comparisons
Players SHALL preview supported changes to their own plans against a fixed permitted baseline. Results SHALL identify changed assumptions, estimated consequences, evidence age, and unknown enemy reactions. A preview MUST NOT mutate the live match or deduct resources.

#### Scenario: Hypothetical crossing retaken
- **WHEN** a player previews retaking a named sector in the planning graph
- **THEN** the comparison shows the conditional supply effect without capturing the sector, spending resources, or issuing an order

### Requirement: Contestable intelligence infrastructure
Advanced enemy SIGINT analysis SHALL require a constructed, living, enabled SIGINT Bureau with headquarters supply connectivity and paid upkeep. Construction SHALL obey placement, capacity, delay, and shared supply-budget rules. Failure SHALL charge no construction cost. Facility loss, disconnection, shutdown, or unpaid upkeep SHALL stop fresh collection at the evaluated tick.

#### Scenario: Bureau destroyed during analysis
- **WHEN** the Bureau is destroyed while an enemy-intelligence job is in flight
- **THEN** no result is delivered as fresh SIGINT and the HUD marks the feed offline

#### Scenario: Construction races for shared supplies
- **WHEN** ordered team requests cannot all afford construction and ruse costs
- **THEN** accepted requests debit the shared budget once in authoritative command order and rejected requests debit nothing

#### Scenario: Upkeep or connection lost
- **WHEN** an operating Bureau cannot pay upkeep or loses its headquarters connection
- **THEN** fresh collection stops and retained reports show their stale evidence age rather than refreshing

### Requirement: Bounded authorized radio observations
Operating SIGINT SHALL collect documented coarse sector observations within its coverage. Reports MUST NOT expose hidden entity records, exact emitter locations/counts, true archetypes, or whether an emission is synthetic. Missing coverage SHALL be distinct from an observed quiet sample. A radio observation SHALL not grant a unit handle or entity-targeted attack.

#### Scenario: Covered sector produces a sample
- **WHEN** an operating Bureau senses a sector without direct unit sight
- **THEN** its team receives only permitted coarse evidence and cannot target an unseen unit from that sample

#### Scenario: No sensor coverage
- **WHEN** a queried sector is outside operating coverage
- **THEN** its signal state is unknown rather than evidence that enemy forces are absent

### Requirement: Intelligence can be deceived
Ghost Radio Broadcast SHALL create plausible sector radio evidence at authoritative supply cost, cooldown, and duration without creating combat units. Radio Silence SHALL suppress configured genuine emissions. Enemy reports SHALL evaluate the resulting permitted evidence without a privileged true/false marker or guaranteed decoy identification.

#### Scenario: Decoys with Ghost Radio
- **WHEN** mock armor and Ghost Radio produce a plausible armored-activity observation
- **THEN** the advisor can assess an armor threat without automatically exposing the deception

#### Scenario: Real armor under Radio Silence
- **WHEN** genuine armor produces weak or quiet permitted radio evidence while concealed
- **THEN** the advisor retains uncertainty and may under-assess the threat instead of consulting its hidden true identity

### Requirement: Honest intelligence confidence
Enemy assessments SHALL identify confidence, evidence reliability/age, and plausible alternatives, including insufficient evidence. No report SHALL claim certain enemy authenticity or intent from SIGINT alone. Numerical probabilities or intervals SHALL require documented model/distribution assumptions and calibration; uncalibrated ratings SHALL use labeled qualitative bands.

#### Scenario: Quiet apparent armor contact
- **WHEN** an apparent armor contact has a quiet radio sample but no qualifying recon identification
- **THEN** the report permits silence, missing emissions, or decoy hypotheses and does not state that the column is certainly a decoy

### Requirement: Advisory doctrine explanations
Doctrine previews SHALL return an explained advisory verdict under versioned rules with authorized evidence and applicable rule identifiers. Conflicts, missing context, and evaluation errors SHALL return a defined unavailable/inconclusive status. Doctrine SHALL not change player command acceptance or force an action.

#### Scenario: Draft ruse threatens intelligence upkeep
- **WHEN** a player previews an affordable ruse that would leave insufficient supplies for the Bureau's next upkeep interval
- **THEN** the interface warns about the known budget consequence and identifies the applicable doctrine rule without executing or vetoing the ruse

### Requirement: Bounded fresh report delivery
Evaluation, planning requests, retained evidence, report rate/size, and alert lifetime SHALL have documented bounds. Report delivery SHALL revalidate audience, owner epoch, evidence age, and required facility operation. Stale jobs SHALL not overwrite newer evidence. Reconnect and revocation SHALL preserve the same intelligence authorization boundary.

#### Scenario: Repeated requests and obsolete results
- **WHEN** planning requests exceed limits or an older job completes after its evidence is superseded
- **THEN** work and memory stay bounded, overload is explicit, and the obsolete result is not shown as current

#### Scenario: Reconnect after Bureau loss
- **WHEN** a player reconnects after their Bureau was destroyed
- **THEN** they receive the current offline state and no fresh feed from the old connection or facility
