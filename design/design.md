> [Back to Index](<./index.md>)

```
["Movement Shooter RTS",["Skill mastery",["Dodging enemies and positioning well",["all characters have dash mechanic (hold jump)"],["being surrounded is dangerous, standoff distance is safety"]],["Aiming at enemies",["hitting enemies directly does more damage than AoE"],["enemies spawn and move in groups"],["enemies have weakpoints"]]],["Strategy and anticipation tension",["Building structures needed for defense",["players can build turrets and economy and ammo buildings"],["buildings make survival more long term"]],["Deciding when to reload or use cooldown skills",["some skills (dash, etc) have a cooldown and windup"],["many weapons have magazines and long reloads"],["reloading still happens even when not wielding the weapon (?)"]],["Managing economy",["turrets use resources to shoot"],["mines need resources to function"],["buildings need to be linked by pylons to share resources"],["each buiding can be connected to only one pylon, but pylons may connect to many buildings"]],["Managing ammunition",["most weapons have limited ammunition"],["players can resupply at some buildings"]],["Gathering initial resources",["player team starts with no resources and must forage"],["there are single use resources scattered in map which give many resources fast"],["there are infinite use resource nodes scattered in map"]]]]
```

# Amnos-V (`amnos_v`)
This would be a mech and building game. Buildings are part of a shared economy. Most buildings are entities but some spawn nodes, such as fortification walls.

# Universal Constants
- all players have a shield which recharges after a time, and health which can only be recovered with resupplying
- you can't dig terrain easily but all player placed structures are destructible
- all terrain must be supported (no floating masses)
- most weapons do friendly fire but only until 20% HP
- if placing a building with the build planner and the player has that building held (they have picked up one) then it is built instantly

# Resources
Each resource has infinite nodes and limited nodes. The limited nodes can only be harvested by hand. All resource nodes can be harvested by hand even when they have a mine attached.
- Metal --> building
- Octate --> fuel
- Annite --> ammo
- Peryite --> money + xp and main objective

# Development Details
## Licenses
- Project license and configuration will be 0BSD, but all modules will have their own license which supersedes it.
- APIs will be anything non-viral, 0BSD or MIT preferred.
- Content will be under MPL 2.0 to discourage flips (soft copyleft / non viral, requires providing access and license to source code).
- Media will be under CC-BY 4.0 or less restrictive.

## Leads
Each lead has final word over that portion of the project. For example the code lead can decide a feature will be written this way instead of that way, but the design lead decides whether that feature exists in the first place. The lead has total control over that aspect but may still delegate tasks, so that everyone knows what they are doing and who is responsible for each thing. Others may offer their opinion, but the lead is the one responsible for that category.

### Game Design
Lead: `Sumi`

Game design is the set of statements about the game that describe it, so that gameplay will happen provided those statements are true. For example:
> enemies usually appear in groups

> most enemies are melee only

> the player can move and has a dash ability

> the player has weapons to fight the enemies

Now, there needs to be a feature coded into the game that makes these statements true. If all the statements in a game's design are true, it should be the case that the game works as intended and is enjoyable to play. In the above case this would result in a movement shooter where positioning, strategy and not getting outmaneuvered are the most important things.

### Aesthetic / Art Design
Lead: `Sumi`
Secondary: ?

What each thing looks / feels / sounds like. e.g. whether it's steampunk or modern or scifi, what resolution textures should be and so on.

### Code
Candidates: `Sumi`

All code and infrastructure, APIs, how content and systems are built.

### Gamestate
Candidates: `Sumi`

All code regarding gamestate and gamemode / match flow. For example, the system that makes the game end when objectives are all met, or which handles how players join and leave.

### Textures
Candidates: `Sumi`

All textures, and their art style, possibly excluding textures for 3D assets. This is also what these things look like within the aesthetic bounds.

### Models and Animations
Candidates: `Sumi`

All 3d assets and animations.

### Sound Effects
Candidates: `Sumi`

All sound assets for things that appear in the game (excluding music).


# Design Statements
- players start in a lobby area and must interact with something in order to join a match
- there can be multiple matches happening (?)
- in the lobby only, the player can change class
- when joining, the player has full ammo and health
- you may join a match that is ongoing
- 
- 
- 
- 
- 
- 
- 
- 
