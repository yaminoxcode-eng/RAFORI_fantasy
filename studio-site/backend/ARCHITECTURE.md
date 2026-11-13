# RAFORI persistent accounts and multiplayer — implementation plan

## Architecture decision

- **Supabase Auth + PostgreSQL**: phone OTP sign-in, player identity, character records, versioned cloud saves, teams and authoritative loot ledger.
- **Game client (Three.js)**: receives a short-lived authenticated session; never owns the source of truth for inventory, combat results, team membership or loot.
- **Dedicated authoritative game server**: persistent WebSocket sessions, player movement validation, world instances, monster AI/combat, party scaling, spawn allocation and loot distribution. Keep this process separate from static hosting; deploy it on an always-on service (for example Railway/Render) rather than relying on a static Vercel page.
- **AF GAMER CI website**: account UI, studio information, codex and launcher. The same identity can later unlock additional studio games.

## First migration included

`supabase/migrations/0001_rafori_core.sql` creates:
- player profiles;
- characters and cloud save records;
- teams and memberships;
- several distinct spawn zones;
- a character creation RPC that grants every new character the bound starter sword and a separate spawn zone;
- owner/member read policies and no direct client write access to game-critical data.

The migration is a reviewed starting point, not a deployed database. It has not been applied to a live Supabase project.

## Account flow

1. Supabase Phone OTP verifies control of the phone number.
2. User chooses a public player name; phone number remains private in the auth provider.
3. Password-based login can be enabled if the product requirement remains phone + password; it requires secure password handling and an OTP/phone-verification policy. Do not store passwords in application tables.
4. The client receives a short-lived session and refreshes it through the SDK.
5. A server-side profile endpoint creates/updates the public player profile.

## Save contract

- Save only validated state from the authoritative game server.
- Store schema version, character ID, owner ID, world position, inventory, equipment, quests and progression.
- Use optimistic version checks to reject stale writes.
- Keep periodic backups and test restoration before public launch.

## Multiplayer rules

- Distinct spawn zones are allocated server-side; capacity and occupancy must be enforced transactionally before selecting a spawn.
- Team size is bounded (initial target 2–8).
- Monster strength is calculated server-side from the number of active party members in the encounter, with explicit caps and difficulty curves.
- Loot is awarded in one database transaction with a unique encounter/reward key to prevent duplicate claims. Distribution rules must be deterministic and visible.
- WebSocket messages are validated, rate-limited and authenticated. Clients cannot tell the server that a monster died or that an item was earned.

## Required before public launch

- Connect the Supabase project and apply migrations in a staging environment first.
- Configure phone OTP/SMS provider and Côte d'Ivoire delivery tests (+225); SMS pricing and sender availability must be checked with the selected provider.
- Implement server endpoints and authoritative WebSocket runtime.
- Add integration tests for account creation, login, save/load across devices, party membership, separate spawns, monster scaling and exactly-once loot.
- Run load, abuse and recovery tests; add privacy policy, terms and account deletion/export workflows.

## Current truth

The website is a static first draft. Account forms are intentionally non-functional and do not transmit credentials. No live accounts, cloud saves or multiplayer sessions exist until the database, SMS provider and game server are connected and tested.
