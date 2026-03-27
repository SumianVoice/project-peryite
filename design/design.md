> [Back to Index](<./index.md>)

# Project Peryite
This would be a mech shooter and building game. Buildings are part of a shared economy. You fight enemies, expand defenses, defend your buildings, and then get to extraction.

## Design Statements
- players start in a lobby area and must interact with something in order to join a match
- there can be multiple matches happening (?)
- in the lobby only, the player can change class
- when joining, the player has full ammo and health
- you may join a match that is ongoing

## Universal Constants
- all players have a shield which recharges after a time, and health which can only be recovered with resupplying
- you can't dig terrain easily but all player placed structures are destructible
- all terrain must be supported (no floating masses)
- most weapons do friendly fire but only until 20% HP
- if placing a building with the build planner and the player has that building held (they have picked up one) then it is built instantly

## Resources
Each resource has infinite nodes and limited nodes. The limited nodes can only be harvested by hand. All resource nodes can be harvested by hand even when they have a mine attached.
- Metal --> building
- Octate --> fuel
- Annite --> ammo
- Peryite --> xp and main objective
