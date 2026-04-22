> [Back to Index](<./index.md>)

# Code Architecture
```
amnv_game.matches = {
	match {
		player data (pi) {
			[player] = {
			}
		}
		player list {
			player:get_inventory() -->
				weapons,
				skills,
				ammunition?
		}
		FSM states {
			state list
		}
		team list {
			team {
				player list {}
				resource list {
					octate = 134, ...
				}
			}
		}
	}
	biomes {
	}
	character classes {
		weapon ItemStack,
		weapon ItemStack,
		skill ItemStack,
	}
	weapon mods {
		[item name] = {
			mod = {details}
		}
	}
}

mapgen env {
	biomes {
	}
}
```

For unsupported nodes:
- use aStar to find a path to bedrock at this XZ pos
- if no path, do node update and fill the area with digs
