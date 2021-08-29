extends Node
var player

func _ready():
	print(to_json(save_data))
	print(inv_to_text(global.gear_active))
	print(inv_to_text(inv_to_text(global.gear_active), true))
	
func start():
	reset_modifiers()
	apply_modifiers()
	mod_stats()
	sync_stats()
	sync_gear()
	
func take_dmg(d):
	player.health -= (d * (player.defense / 100))
	if (player.health < 0):
		return true
		
func heal(h):
	player.health += (global.stats.health * global.stats.healing / 100)
	if (local.hp > global.max_hp):
		local.hp = global.max_hp

func stamina_dash():
	var buffer = 10
	var endourance_factor = (global.stats.endourance / global.default_stats.endourance)
	player.stamina -= (8 + ((global.weight - 100) / float(buffer))) / float(endourance_factor)
	
	normalize_stamina()
	
func stamina_light():
	var default_weight = 30
	var strength_factor = (global.stats.strength / global.default_stats.strength)
	var weight_difference = global.gear_active[0].weight - default_weight
	#print("Strength Faktor: ", strength_factor)
	player.stamina -= ((20 + weight_difference) / strength_factor) / 2
	normalize_stamina()
	
func stamina_jump():
	var buffer = 8
	var endourance_factor = (global.stats.endourance / global.default_stats.endourance)
	player.stamina -= (3 + ((global.weight - 100) / float(buffer))) / float(endourance_factor)

	normalize_stamina()
	
func stamina_heavy():
	var default_weight = 30
	var strength_factor = (global.stats.strength / global.default_stats.strength)
	var weight_difference = global.gear_active[0].weight - default_weight
	
	player.stamina -= ((35 + weight_difference) / strength_factor) / 2
	normalize_stamina()
	
func normalize_stamina():
	if (player.stamina < -15):
		player.stamina = -15

func change_gear(stored_index, active_index):
	var active_d = global.gear_active[active_index]
	
	
	global.gear_active[active_index] = global.gear_stored[stored_index]
	global.gear_stored[stored_index] = active_d
	
	
	#..
	
	
	
	reset_modifiers()
	
	apply_modifiers()
	mod_stats()
	sync_stats()
	sync_gear()
	
func reset_modifiers():
	player.less_gravity = 3.5
	global.modifiers = deep_copy(global.default_modifiers)	
	
func apply_modifiers():
	print("Modifiers:")
	for g in global.gear_active:
		if g and "modifiers" in g:
			
			print(g.modifiers)
			for k in g.modifiers:
				if global.modifiers.has(k):
					global.modifiers[k] *= g.modifiers[k]
		
func mod_stats(k=null):
	global.stats = deep_copy(global.pure_stats)
	if k:
		global.stats[k] *= global.modifiers[k]
	else:
		for key in global.modifiers:
			if global.stats.has(key):
				global.stats[key] *= global.modifiers[key]
	
func sync_stats():
	var sword = global.gear_active[0]
	var armor = global.gear_active[1]
	var accs = global.gear_active[2]		#ignore for now
	
	player.health = global.stats.health
	player.stamina = 0#global.stats.stamina
	
	
	global.dmg_light = sword.dmg_light * 1 + ((global.stats.strength - global.default_stats.strength) / global.default_stats.strength) / 2
	global.dmg_heavy = sword.dmg_heavy * 1 + ((global.stats.strength - global.default_stats.strength) / global.default_stats.strength) / 2
	global.defense = armor.defense * global.modifiers["defense"]
	
	global.weight = armor.weight + sword.weight
	global.weight *= global.modifiers["weight"]
	
	player.less_gravity *= global.modifiers["gravity"]
	
	var buffer1 = 1.5
	var buffer2 = 1.4
	
	var modifier = 1 + ((global.stats.endourance - global.default_stats.endourance) / global.default_stats.endourance)
	var diff = player.default_move_speed - (global.weight - global.default_weight) / float(buffer1)
	
	player.move_speed = diff# / float(buffer1)
	
	modifier /= float(buffer2)
	if modifier < 1:
		modifier = 1
	
	player.move_speed *= modifier
	
	if (player.move_speed < player.min_move_speed):
		player.move_speed = player.min_move_speed
	elif (player.move_speed > player.max_move_speed):
		var d = player.move_speed - player.max_move_speed
		player.move_speed = player.max_move_speed
		player.move_speed += d / 4
	
	print("Weight: ", global.weight, " Speed: ", player.move_speed, "Difference ", diff, "Modifier: ", modifier)
	
	player.move_speed_modifier = float(player.move_speed) /  player.default_move_speed
	player.normal_speed = player.move_speed
	
	player.stamina_recharge = float(global.stats.stamina) * global.modifiers["stamina_regen"] * (float(1) / 60)		#60hz, 
	print("Recharge Rate: ", player.stamina_recharge)
	
	player.agility = global.stats.agility / global.default_stats.agility
	print(player.agility)
	
	Hud.bars.pot_max_health = global.max_stats.health
	Hud.bars.pot_max_stamina = global.max_stats.stamina
	Hud.bars.current_max_health = global.stats.health
	Hud.bars.current_max_stamina = global.stats.stamina
	Hud.bars.set_bars(global.stats.health,  global.stats.stamina)
	Hud.bars.upgrade(0,0)
	
func sync_gear():
	player.get_node("Base_Sprite").disable("all")
	player.get_node("Base_Sprite").enable(global.gear_active[0].name)
	player.get_node("Base_Sprite").enable(global.gear_active[1].name)
	
func upgrade(what):
	if (global.pure_stats[what]):
		global.pure_stats[what] += global.pure_stat_upgrades[what]
		mod_stats(what)
	else:
		print("Does not exist dumbass")

func inv_to_text(inv, revert=false):
	var space = "#"
	var nil = "%"
	
	if (revert):
		var list = []
		var current_item = ""
		for ch in inv:
			
			if ch == space:
				list.append(gear[current_item])
				current_item = ""
			elif ch == nil:
				list.append(null)
				current_item = ""
			else:
				current_item += ch
		
		return list
	else:
		var string = ""
		
		for item in inv:
			if (item == null):
				string += nil
			else:
				string += item.name + space
		
		return string

func convert_savedata(revert=false, position=player.position):
	if (revert):
		global.gear_stored = inv_to_text(save_data.gear_stored, true)
		global.gear_active = inv_to_text(save_data.gear_active, true)
		global.points = save_data.points		#the rest can be automated; doesnt make sense for 2 items
		global.pure_stats = save_data.pure_stats
		
		var arr = save_data.pos.split(',')
		var x = int(arr[0])
		var y = int(arr[1])
		
		player.position = Vector2(x,y)
	else:
		save_data.gear_stored = inv_to_text(global.gear_stored)
		save_data.gear_active = inv_to_text(global.gear_active)
		save_data.points = global.points		#the rest can be automated; doesnt make sense for 2 items
		save_data.pure_stats = global.pure_stats
		
		save_data.pos = position
		return save_data

func s(p=player.position):		#Loading and Saving: Credit to GDquest
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json(convert_savedata(false, p)))
	
func l():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
	save_game.open("user://savegame.save", File.READ)
	save_data = parse_json(save_game.get_line())
	
	convert_savedata(true)
	start()

var gear = {
	Iron_Sword = {
		i = 7,
		type = "sword",
		name = "Iron_Sword",
		dmg_light = 50,
		dmg_heavy = 80,
		weight = 30,
	},
	
	Black_Sword = {
		i = 8,
		type = "sword",
		name = "Black_Sword",
		dmg_light = 70,
		dmg_heavy = 130,
		weight = 60,
	},
	
	Crystal_Sword = {
		i = 9,
		type = "sword",
		name = "Crystal_Sword",
		dmg_light = 80,
		dmg_heavy = 90,
		weight = 40,
	},
	
	Wooden_Sword = {
		i = 10,
		type = "sword",
		name = "Wooden_Sword",
		dmg_light = 30,
		dmg_heavy = 50,
		weight = 10,
	},
	
	Golden_Sword  = {
		i = 11,
		type = "sword",
		name = "Golden_Sword",
		dmg_light = 20,
		dmg_heavy = 160,
		weight = 40,
	},
	
	Iron_Armor = {
		i = 0,
		type = "armor",
		name = "Iron_Armor",
		defense = 40,
		weight = 70,
	},
	
	Black_Armor = {
		i = 1,
		type = "armor",
		name = "Black_Armor",
		defense = 60,
		weight = 120,
	},
	
	Crystal_Armor = {
		i = 2,
		type = "armor",
		name = "Crystal_Armor",
		defense = 60,
		weight = 90,
	},
	
	Fabric_Suit = {
		i = 3,
		type = "armor",
		name = "Fabric_Suit",
		defense = 20,
		weight = 30,
	},
	
	Neon_Suit = {
		i = 4,
		type = "armor",
		name = "Neon_Suit",
		defense = 5,
		weight = 20,
	},
	
	Ninja_Suit = {
		i = 5,
		type = "armor",
		name = "Ninja_Suit",
		defense = 28,
		weight = 50,
		modifiers = {
			"agility" : 1.3,
		}
	},
	
	Stone_Armor = {
		i = 6,
		type = "armor",
		name = "Stone_Armor",
		defense = 90,
		weight = 150,
	},
	
	Simple_Ring  = {
		i = 16,
		type = "accs",
		name = "Simple_Ring",
		modifiers = {
			"stamina_regen" : 1.2,
		}
	},
	Better_Ring  = {
		i = 17,
		type = "accs",
		name = "Better_Ring",
		modifiers = {
			"stamina_regen" : 1.4,
		}
	},
	Healthy_Ring = {
		i = 18,
		type = "accs",
		name = "Healthy_Ring",
		modifiers = {
			"health" : 1.3,
			"stamina": 0.8,
		}
	},
	Ring_of_Tank  = {
		i = 19,
		type = "accs",
		name = "Ring_of_Tank",
		modifiers = {
			"defense" : 2,
			"strength": 0.4,
		}
	},
	Stabber  = {
		i = 20,
		type = "accs",
		name = "Stabber",
		modifiers = {
			"defense" : 0.25,
			"health": 0.5,
			"strength": 3,
		}
	},
	Heavy_Lifter  = {
		i = 21,
		type = "accs",
		name = "Heavy_Lifter",
		modifiers = {
			"weight": 0.7,
		}
	},
	The_Ring_Of_The_Snake = {
		i = 22,
		type = "accs",
		name = "The_Ring_Of_The_Snake",
		modifiers = {
			"agility": 1.4,
			"strength": 0.8,
		}
	},
	Ring_Of_Mobility = {
		i = 23,
		type = "accs",
		name = "Ring_Of_Mobility",
		modifiers = {
			"gravity": 0.7
		}
	}
}

var save_data = {
	gear_stored = "Text",
	gear_active = "Text",
	points = 100,	

	position = Vector2(0,0),

	pure_stats = {
		"health" : 100,
		"stamina" : 190,
		"healing" : 20,
		"strength" : 100,
		"endourance" : 100,
		"agility" : 100,
	},
}

var global = {
	gear_stored = [gear.Black_Sword, gear.Iron_Armor,gear.Neon_Suit,gear.Iron_Sword, 
	gear.Golden_Sword, gear.Stone_Armor, gear.Crystal_Sword, gear.Crystal_Armor, gear.Fabric_Suit, gear.Ninja_Suit,
	gear.Simple_Ring, gear.Better_Ring, gear.Healthy_Ring, gear.Ring_of_Tank, gear.Stabber, gear.Heavy_Lifter,
	gear.Heavy_Lifter,gear.The_Ring_Of_The_Snake, gear.Ring_Of_Mobility, gear.Wooden_Sword 
	],
	
	#gear_active = [gear.Black_Sword, gear.Stone_Armor,gear.Iron_Armor],
	gear_active = [gear.Golden_Sword, gear.Neon_Suit,gear.Ring_Of_Mobility],
	
	points = 166,
	
	dmg_light = 50,
	dmg_heavy = 150,
	defense = 40,
	
	weight = 100,
	default_weight = 100,
	slowdown = 0,
	
	stats = {
		"health" : 100,
		"stamina" : 100,
		"healing" : 20,
		"strength" : 100,
		"endourance" : 100,
		"agility" : 100,
	},
	
	pure_stats = {
		"health" : 100,
		"stamina" : 100,
		"healing" : 20,
		"strength" : 300,
		"endourance" : 100,
		"agility" : 100,
	},
	
	default_stats = {
		"health" : 100,
		"stamina" : 100,
		"healing" : 20,
		"strength" : 100,
		"endourance" : 100,
		"agility" : 100,
	},
	max_stats = {
		"health" : 300,
		"stamina" : 300,
		"healing" : 50,
		"strength" : 300,
		"endourance" : 300,
		"agility" : 150,
	},
	stat_upgrades = {
		"health" : 20,
		"stamina" : 20,
		"healing" : 5,
		"strength" : 20,
		"endourance" : 20,
		"agility" : 5,
		
	},
	
	modifiers = {
		"stamina_regen": 0.08,	#per second
		
		"health" : 1,
		"stamina" : 1,
		"healing" : 1,
		"strength" : 1,
		"endourance" : 1,
		"agility" : 1,
		
		"defense": 1,
		"weight": 1,
		"gravity": 1,
	},
	
	default_modifiers = {
		"stamina_regen": 0.08,	#per second
		
		"health" : 1,
		"stamina" : 1,
		"healing" : 1,
		"strength" : 1,
		"endourance" : 1,
		"agility" : 1,
		
		"defense": 1,
		"weight": 1,
		"gravity": 1,
	},
	
	modifier_names = {
		"stamina_regen": "Stamina Regeneration",	#per second
		
		"health" : "Health",
		"stamina" : "Stamina",		#Boosts your...
		"healing" : "Healing power",
		"strength" : "Strength",
		"endourance" : "Endourance",
		"agility" : "Agility",
		
		"defense": "Defense",
		"weight": "Carrying Burden",
		"gravity": "Falling",
	}
	
	
}

var tips = [
	"Try jumping to evade enemies",
	"Try dashing to evade enemies",
	"You can dash through enemies",
	"Try jumping over enemies",
	"Dash to evade enemie blows",
	"Hold shift + A/D while attacking to dash right after",
	"Your movement depends on the weight of your equiptment",
	"Invest in agility to attack faster",
	"Always watch your stamina bar!",
	"most actions cost stamina",
	"Hold space while in the air to perform a jump-attack",
	"Try jumping over enemies",
	"Dash to evade enemie blows",
	"Attack while dashing to do heavy damage",
	"Be careful: enemies are still approaching!",
	"Upgrade endourance to carry more weight and move faster",
	"Some gear has special effects",
	
]


var local = {
	hp = 100,
	stamina = 100,
}

static func deep_copy(v):		#credit: someone on reddit
	var t = typeof(v)

	if t == TYPE_DICTIONARY:
		var d = {}
		for k in v:
			d[k] = deep_copy(v[k])
		return d

	elif t == TYPE_ARRAY:
		var d = []
		d.resize(len(v))
		for i in range(len(v)):
			d[i] = deep_copy(v[i])
		return d

	elif t == TYPE_OBJECT:
		if v.has_method("duplicate"):
			return v.duplicate()
		else:
			print("Found an object, but I don't know how to copy it!")
			return v

	else:
		# Other types should be fine,
		# they are value types (except poolarrays maybe)
		return v
