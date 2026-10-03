# Spec Delta

## Purpose

Provide a complete alpha player journey from authenticated lobby participation through tactical play, temporary reconnect, and a persisted match result.

## ADDED Requirements

### Requirement: Stable authenticated player identity
Players SHALL use a server-issued authenticated account/session with a stable player identity. Match and deck operations SHALL be scoped to that identity. Display names, lobby settings, and chat SHALL have validated length and rate limits.

#### Scenario: Identity spoof in lobby data
- **WHEN** a player sends another player's identity in a lobby request
- **THEN** the server uses the authenticated identity and rejects unauthorized changes

### Requirement: Lobby and legal fixed decks
Players SHALL create or join unranked match rooms, occupy assigned team slots, choose a legal deck from the alpha roster, exchange room chat, and mark ready. The room SHALL support 2–64 participants within configured map capacity and begin only with legal teams and ready participants.

#### Scenario: Incomplete room start
- **WHEN** the host attempts to start with an unready participant, invalid deck, or illegal team allocation
- **THEN** the lobby reports the unmet condition and no active match is created

### Requirement: Minimal playable match
The alpha SHALL include one original sector map, headquarters, armor, infantry, recon, decoys, a constructible SIGINT Bureau, and Blitz, Camouflage, Radio Silence, Decoys, and Ghost Radio ruses, with validated starting armies. Headquarters destruction SHALL determine victory; simultaneous destruction SHALL produce a draw. A configured time limit SHALL resolve ties using documented rules.

#### Scenario: Headquarters destroyed
- **WHEN** one team's last headquarters is destroyed while an opposing headquarters remains
- **THEN** the match ends once, orders stop, and participants see the winning team

#### Scenario: Simultaneous destruction
- **WHEN** all remaining opposing headquarters are destroyed in the same tick
- **THEN** the match ends as a draw regardless of entity iteration order

### Requirement: Team-safe HUD and shell
The player interface SHALL show permitted selection details, sector control/supply budget, ruse availability, intelligence facility/feed status, expandable staff evidence and what-if previews, match time, connection status, and results. Shell updates SHALL preserve the mounted battlefield and MUST NOT expose hidden battlefield state. Advice SHALL be visibly distinct from a committed order.

#### Scenario: HUD update during play
- **WHEN** room chat or a ruse cooldown updates while the canvas is mounted
- **THEN** the renderer remains active and the HUD contains only authorized team information

### Requirement: Same-team reconnect
A player reconnecting within a configurable grace period SHALL regain their existing team and owned living units through a fresh authorized snapshot. Units SHALL continue their last legal orders while disconnected. Grace expiry SHALL mark the participant abandoned and reject further commands under the old session.

#### Scenario: Temporary connection loss
- **WHEN** a player returns during the grace period while the match owner is healthy
- **THEN** they resume their assigned team from current state without duplicating their army

### Requirement: Results and diagnostic history
Match completion SHALL persist roster, map/rules versions, seed, outcome, and accepted command/tick history with an explicit completeness status for diagnosis. Participants SHALL access only their authorized summary. Interrupted matches SHALL be marked separately and SHALL not update competitive ratings.

#### Scenario: Completion message repeated
- **WHEN** completion is retried after a persistence timeout
- **THEN** one final result is stored and no duplicate reward or rating effect occurs

#### Scenario: Diagnostic history persistence fails
- **WHEN** sustained storage failure prevents complete command-history persistence
- **THEN** bounded retry handling records an incomplete status and missing sequence range rather than presenting the history as complete
