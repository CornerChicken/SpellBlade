export type SpellId = "Fireball" | "DashStrike" | "StunBolt"

export type SpellDef = {
	name: string,
	cooldown: number,
	channelTime: number,
	damage: number,
	speed: number?,
	lifetime: number?,
	range: number?,
	stunDuration: number?,
}

local Spells: { [SpellId]: SpellDef } = {
	Fireball = {
		name = "Fireball",
		cooldown = 6.0,
		channelTime = 0.3,
		damage = 25,
		speed = 60,
		lifetime = 4.0,
	},
	DashStrike = {
		name = "Dash Strike",
		cooldown = 8.0,
		channelTime = 0.1,
		damage = 15,
		range = 25,
	},
	StunBolt = {
		name = "Stun Bolt",
		cooldown = 12.0,
		channelTime = 0.4,
		damage = 10,
		speed = 45,
		lifetime = 3.0,
		stunDuration = 1.5,
	},
}

return Spells