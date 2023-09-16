extends Node
var player

var deff_debuff = 0.875


func _ready():
	pass
#	print(to_json(save_data))
#	print(inv_to_text(global.gear_active))
#	print(inv_to_text(inv_to_text(global.gear_active), true))
	
func start():
	reset_upgrades()
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
	player.stamina -= (15 + ((global.weight - 100) / float(buffer))) / float(endourance_factor)
	
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
	player.stamina -= (7 + ((global.weight - 100) / float(buffer))) / float(endourance_factor)

	normalize_stamina()
	
func stamina_heavy():
	var default_weight = 30
	var strength_factor = (global.stats.strength / global.default_stats.strength)
	var weight_difference = global.gear_active[0].weight - default_weight
	
	player.stamina -= ((35 + weight_difference) / strength_factor) / 2
	normalize_stamina()
	
func normalize_stamina():
	if (player.stamina < -35):
		player.stamina = -35

func change_gear(stored_index, active_index):
	var active_d = global.gear_active[active_index]
	
	global.gear_active[active_index] = global.gear_stored[stored_index]
	global.gear_stored[stored_index] = active_d
	
	reset_modifiers()
	
	apply_modifiers()
	mod_stats()
	sync_stats()
	sync_gear()
	
func store(item):
	if (item in global.gear_stored):
		var pos = global.gear_stored.find(item)
		global.gear_stored.insert(pos, item)
	else:
		global.gear_stored.append(item)
	
func move_crafting_gear(stored_index):
	if global.gear_stored[stored_index] in global.crafting or len(global.crafting) < 2:
		global.crafting.append(global.gear_stored[stored_index])
		global.gear_stored.remove(stored_index)
	else:
		var last = global.crafting[0]
		var i = 0
		while i < len(global.crafting):
			if (last != global.crafting[i]):
				return
			i += 1
		global.crafting.append(global.gear_stored[stored_index])
		global.gear_stored.remove(stored_index)
	
func reset_crafting():
	#global.gear_stored.append_array(global.crafting)
	for item in global.crafting:
		store(item)
	global.crafting = []
	
func get_craft_result():
	if global.crafting in recipes:
		return recipes[global.crafting]
	else:
		return null

func craft():
	if (get_craft_result() != null):
		global.gear_stored.append(get_craft_result())
		global.crafting = []
	
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
	player.stamina = global.stats.stamina / 2
	player.healings = global.healings
	
	global.dmg_light = sword.dmg_light * (1 + ((global.stats.strength - global.default_stats.strength) / global.default_stats.strength) / 2)
	global.dmg_heavy = sword.dmg_heavy * (1 + ((global.stats.strength - global.default_stats.strength) / global.default_stats.strength) / 2)
	global.defense = armor.defense * global.modifiers["defense"] * deff_debuff
	print("Damage: ", global.dmg_light, global.dmg_heavy)
	global.weight = armor.weight + sword.weight
	global.weight *= global.modifiers["weight"]
	
	player.less_gravity *= global.modifiers["gravity"]
	
	var buffer1 = 2.2
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
	if (global.temp_points > 0 and global.temp_stats[what] < global.max_stats[what]):
		global.temp_points -= 1
		global.temp_stats[what] += global.stat_upgrades[what]

func reset_upgrades():
	global.temp_points = deep_copy(global.points)
	global.temp_stats = deep_copy(global.pure_stats)

func confirm_upgrades():
	global.points = deep_copy(global.temp_points)
	global.pure_stats = deep_copy(global.temp_stats)
	start()
	
func get_total_spent():
	var v = 0
	for type in global.pure_stats:
		v += (global.pure_stats[type] - global.default_stats[type]) / global.stat_upgrades[type]
	return v
	
func reset_stats():
	global.points += get_total_spent()
	global.pure_stats = global.default_stats
	start()
	
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

func convert_savedata(revert=false, position=player.position, ingame=false):
	if (revert):
		global.gear_stored = inv_to_text(save_data.gear_stored, true)
		global.gear_active = inv_to_text(save_data.gear_active, true)
		global.points = save_data.points		#the rest could be automated; doesnt make sense for 2 items
		global.healings = save_data.healings
		global.pure_stats = save_data.pure_stats
		global.progress = save_data.progress
		
		var arr = save_data.pos.split(',')
		var x = int(arr[0])
		var y = int(arr[1])
		
		player.position = Vector2(x,y)
		
		var cs = get_tree().get_nodes_in_group("chest")
		var index = 0;
		for c in cs:
			if (index >= len(save_data.chests)):
				break
			var items = save_data.chests[index]
			c.items = items
			c.fill(items)
			index += 1
		
		var els = get_tree().get_nodes_in_group("elevators")
		index = 0
		for e in els:
			if (index >= len(save_data.elevators)):
				break
			var state = save_data.elevators[index]
			if e.at_b != state:
				e.at_b *= -1
				e.sync_position()
			index += 1
		
		var ds = get_tree().get_nodes_in_group("doors")
		index = 0
		#print(save_data.doors[index], "Doors")
		for d in ds:
			if (index >= len(save_data.doors)):
				break
			var state = save_data.doors[index]
			if d.open != state:
				d.open()
			index += 1
		
		
		if (global.gear_active[2] == gear.Suspicious_Ring):
			return
		var bosses = get_tree().get_nodes_in_group("perm_death")
		index = 0
		#print(save_data.perm_dead, "Bosses")
		for b in bosses:
			
			if (index < len(save_data.perm_dead) and save_data.perm_dead[index]):
				#print(b.name)
				b.die()
				b.hp = 0
				b.Php = 0
				b.set_collision_layer_bit(2, 0)
			index += 1
	else:
		save_data.chests = [];
		var cs = get_tree().get_nodes_in_group("chest")
		for c in cs:
			save_data.chests.append(c.items)
		print(save_data.chests)
		save_data.elevators = []
		var els = get_tree().get_nodes_in_group("elevators")
		for el in els:
			save_data.elevators.append(el.at_b)
		save_data.doors = []
		for d in get_tree().get_nodes_in_group("doors"):
			save_data.doors.append(d.open)
			#print("Door ", d.open)
		save_data.perm_dead = []
		var bosses = get_tree().get_nodes_in_group("perm_death")
		for b in bosses:
			#print(b.name, b.state)
			save_data.perm_dead.append(b.state == 1)
		
		save_data.gear_stored = inv_to_text(global.gear_stored)
		save_data.gear_active = inv_to_text(global.gear_active) #the rest can be automated; doesnt make sense for 2 items
		save_data.healings = global.healings
		save_data.pure_stats = global.pure_stats
		save_data.progress = global.progress
		
		if (!ingame):
			save_data.points = global.points
			save_data.pos = position
		
		return save_data

func save_world():
	save_data.chests = [];
	var cs = get_tree().get_nodes_in_group("chest")
	for c in cs:
		save_data.chests.append(c.items)
	
	save_data.elevators = []
	var els = get_tree().get_nodes_in_group("elevators")
	for el in els:
		save_data.elevators.append(el.at_b)
	save_data.doors = []
	for d in get_tree().get_nodes_in_group("doors"):
		save_data.doors.append(d.open)
		#print("Door ", d.open)
	save_data.perm_dead = []
	var bosses = get_tree().get_nodes_in_group("perm_death")
	for b in bosses:
		#print(b.name, b.state)
		save_data.perm_dead.append(b.state == 1)

func s(p=player.position):		#Loading and Saving: Credit to GDquest
	reset_crafting()
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json(convert_savedata(false, p)))
	save_game.close()
	
func s_ingame(p=player.position):		#
	reset_crafting()
	var save_game = File.new()
	save_game.open("user://savegame.save", File.WRITE)
	save_game.store_line(to_json(convert_savedata(false, p, true)))
	save_game.close()
	
func l():
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		s()
	save_game.open("user://savegame.save", File.READ)
	save_data = parse_json(save_game.get_line())
	save_game.close()
	convert_savedata(true)
	start()

var gear = {
	Ghost_Armor = {
		i = 15,
		type = "armor",
		name = "Ghost_Armor",
		defense = 22,
		weight = 1,
	},
	Samurai_Armor = {
		i = 14,
		type = "armor",
		name = "Samurai_Armor",
		defense = 55,
		weight = 70,
	},
	Mantis_Armor = {
		i = 13,
		type = "armor",
		name = "Mantis_Armor",
		defense = 39,
		weight = 34,
	},
	Katana = {
		i = 12,
		type = "sword",
		name = "Katana",
		dmg_light = 60,
		dmg_heavy = 70,
		weight = 28,
	},
	Iron_Sword = {
		i = 7,
		type = "sword",
		name = "Iron_Sword",
		dmg_light = 50,
		dmg_heavy = 80,
		weight = 40,
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
		weight = 52,
	},
	Wooden_Sword = {
		i = 10,
		type = "sword",
		name = "Wooden_Sword",
		dmg_light = 30,
		dmg_heavy = 50,
		weight = 20,
	},
	Golden_Sword  = {
		i = 11,
		type = "sword",
		name = "Golden_Sword",
		dmg_light = 20,
		dmg_heavy = 160,
		weight = 55,
	},
	Iron_Armor = {
		i = 0,
		type = "armor",
		name = "Iron_Armor",
		defense = 35,
		weight = 60,
	},
	Black_Armor = {
		i = 1,
		type = "armor",
		name = "Black_Armor",
		defense = 45,
		weight = 70,
	},
	Crystal_Armor = {
		i = 2,
		type = "armor",
		name = "Crystal_Armor",
		defense = 50,
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
			"agility" : 1.15,
		}
	},
	Stone_Armor = {
		i = 6,
		type = "armor",
		name = "Stone_Armor",
		defense = 74,
		weight = 140,#Machine_Armor
	},
	Machine_Armor = {
		i = 32,
		type = "armor",
		name = "Machine_Armor",
		defense = 65,
		weight = 90,#Machine_Armor
		modifiers = {
			"agility" : 0.9,
		}
	},
	Simple_Ring  = {
		i = 16,
		type = "accs",
		name = "Simple_Ring",
		modifiers = {
			"stamina_regen" : 1.1,
		}
	},
	Better_Ring  = {
		i = 17,
		type = "accs",
		name = "Better_Ring",
		modifiers = {
			"stamina_regen" : 1.25,
		}
	},
	Healthy_Ring = {
		i = 18,
		type = "accs",
		name = "Healthy_Ring",
		modifiers = {
			"health" : 1.4,
			"stamina": 0.8,
		}
	},
	Ring_of_Tank  = {
		i = 19,
		type = "accs",
		name = "Ring_of_Tank",
		modifiers = {
			"defense" : 1.2,
			"strength": 0.6,
		}
	},
	Stabber  = {
		i = 20,
		type = "accs",
		name = "Stabber",
		modifiers = {
			"defense" : 0.25,
			"health": 0.5,
			"strength": 1.6,
		}
	},
	Heavy_Lifter  = {
		i = 21,
		type = "accs",
		name = "Heavy_Lifter",
		modifiers = {
			"weight": 0.8,
		}
	},
	The_Ring_Of_The_Snake = {
		i = 22,
		type = "accs",
		name = "The_Ring_Of_The_Snake",
		modifiers = {
			"agility": 1.2,
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
	},
	Quick_Changer = {
		i = 27,
		type = "accs",
		name = "Quick_Changer",
		modifiers = "Allows changing Items anywhere (with TAB)",
	},
	Suspicious_Ring = {
		i = 26,
		type = "accs",
		name = "Suspicious_Ring",
		modifiers = "Somthing evil happens"
	},
	Talisman_Of_The_Abyss = {
		i = 24,
		type = "accs",
		name = "Talisman_Of_The_Abyss",
		modifiers = "Deal Enhanced Damage to Children Of The Abyss"
	},
	
	
	Bone_Shard = {
		i = 64,
		type = "mat",
		name = "Bone_Shard",
		modifiers = "A Piece of Ancient Bone"
	},
	Rotten_Bone = {
		i = 65,
		type = "mat",
		name = "Rotten_Bone",
		modifiers = "Worthless"
	},
	Ruby = {
		i = 66,
		type = "mat",
		name = "Ruby",
		modifiers = "Can be found in the Mines"
	},
	Purple_Sapphire = {
		i = 67,
		type = "mat",
		name = "Purple_Sapphire",
		modifiers = "Can be found in the Mines, has magical Potenzial"
	},
	Diamond = {
		i = 68,
		type = "mat",
		name = "Diamond",
		modifiers = "Rare Gemstone"
	},
	Amethyst = {
		i = 69,
		type = "mat",
		name = "Amethyst",
		modifiers = "Can be found in the Mines"
	},
	Piece_Of_Gold = {
		i = 70,
		type = "mat",
		name = "Piece_Of_Gold",
		modifiers = "A piece of Gold"
	},
	Bar_of_Brass = {
		i = 71,
		type = "mat",
		name = "Bar_of_Brass",
		modifiers = "Can be crafted into powerful Armor"
	},
	Platinum = {
		i = 72,
		type = "mat",
		name = "Platinum",
		modifiers = "Can be crafted into powerful Armor"
	},
	Lilypad = {
		i = 73,
		type = "mat",
		name = "Lilypad",
		modifiers = "Valuable Apparel"
	},
	Rose = {
		i = 74,
		type = "mat",
		name = "Rose",
		modifiers = "beautiful Flower"
	},
	Nekronomikon = {#
		i = 75,
		type = "mat",
		name = "Nekronomikon",
		modifiers = "Powerful ancient artefact. Last seen in the Hands of Dhoxeor The Sorcerer"
	},
	Goblin_Hide = {#
		i = 76,
		type = "mat",
		name = "Goblin_Hide",
		modifiers = "A Goblin's hide"
	},
	Brute_Brain = {#
		i = 77,
		type = "mat",
		name = "Brute_Brain",
		modifiers = "wasn't used much..."
	},
	Skull = {#
		i = 78,
		type = "mat",
		name = "Skull",
		modifiers = "The Skull of a skeletron. Rare to find one intact"
	},
	Mantis_Scales = {#
		i = 80,
		type = "mat",
		name = "Mantis_Scales",
		modifiers = "The Scales of a giant Mantis"
	},
	Mantis_Fang = {#
		i = 81,
		type = "mat",
		name = "Mantis_Fang",
		modifiers = "a Fang of a giant Mantis"
	},
	Ghostly_Essence = {#
		i = 82,
		type = "mat",
		name = "Ghostly_Essence",
		modifiers = "Supernatural crafting Ingredient"
	},
	Goblin_Tooth = {#
		i = 83,
		type = "mat",
		name = "Goblin_Tooth",
		modifiers = "A Goblin's Tooth"
	},
	
	Bone_Armor = {
		i = 33,
		type = "armor",
		name = "Bone_Armor",
		defense = 45,
		weight = 60,#Machine_Armor
	},
	Goblin_Armor = {
		i = 34,
		type = "armor",
		name = "Goblin_Armor",
		defense = 31,
		weight = 45,#Machine_Armor
	},
	Platinum_Armor = {
		i = 35,
		type = "armor",
		name = "Platinum_Armor",
		defense = 70,
		weight = 110,#Machine_Armor
	},
	
	Rapier_Of_Ice = {
		i = 48,
		type = "sword",
		name = "Rapier_Of_Ice",
		dmg_light = 50,
		dmg_heavy = 50,
		weight = 30,
		modifiers = {
			"agility": 1.8,
			"stamina": 0.55
		}
	},
	Mantis_Scimitar = {
		i = 49,
		type = "sword",
		name = "Mantis_Scimitar",
		dmg_light = 40,
		dmg_heavy = 140,
		weight = 80,
		modifiers = {
			"agility": 1.5,
		}
	},
	Ruby_Sword = {
		i = 50,
		type = "sword",
		name = "Ruby_Sword",
		dmg_light = 58,
		dmg_heavy = 80,
		weight = 50,
		modifiers = {
			"health": 1.2,
		}
	},
	Goblin_Dagger = {
		i = 51,
		type = "sword",
		name = "Goblin_Dagger",
		dmg_light = 40,
		dmg_heavy = 60,
		weight = 30,
		modifiers = {
			"agility": 1.1,
		}
	},
	Blade_Of_Blood = {
		i = 52,
		type = "sword",
		name = "Blade_Of_Blood",
		dmg_light = 100,
		dmg_heavy = 60,
		weight = 55,
		modifiers = {
			"health": 0.65,
		}
	},
	Golem = {
		i = 36,
		type = "armor",
		name = "Golem",
		defense = 50,
		weight = 80,#Machine_Armor
		modifiers = {
			"strength": 1.5,
			"stamina": 1.2
		}
	},
	Divine_Armor = {
		i = 37,
		type = "armor",
		name = "Divine_Armor",
		defense = 70,
		weight = 77,#Machine_Armor
		modifiers = {
			"strength": 0.9,
			"health": 0.8
		}
	},
	Corrupted_Skull = {#
		i = 79,
		type = "mat",
		name = "Corrupted_Skull",
		modifiers = " Th   e   Skul       l o  f   a sk     e l  e t   ron?"
	},
}

var recipes = {
	#[gear.Iron_Sword,gear.Iron_Sword]: gear.Black_Sword,
	#[gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard]: gear.Black_Sword,
	[gear.Mantis_Scales,gear.Mantis_Scales,gear.Mantis_Scales]: gear.Mantis_Armor,
	[gear.Mantis_Fang,gear.Mantis_Fang,gear.Mantis_Fang,gear.Mantis_Fang,gear.Platinum]: gear.Mantis_Scimitar,
	[gear.Goblin_Hide, gear.Goblin_Hide]: gear.Goblin_Armor,
	[gear.Goblin_Tooth, gear.Goblin_Tooth]: gear.Goblin_Dagger,
	[gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard]: gear.Bone_Armor,
	[gear.Ruby, gear.Ruby, gear.Platinum]: gear.Ruby_Sword,
	[gear.Platinum,gear.Platinum,gear.Platinum,gear.Platinum]: gear.Platinum_Armor,
	[gear.Diamond, gear.Bar_of_Brass]: gear.Crystal_Sword,
	[gear.Diamond, gear.Diamond,gear.Lilypad]: gear.Rapier_Of_Ice,
	[gear.Ruby, gear.Ruby, gear.Skull]: gear.Nekronomikon,
	[gear.Piece_Of_Gold,gear.Piece_Of_Gold,gear.Piece_Of_Gold,gear.Piece_Of_Gold,gear.Piece_Of_Gold]: gear.Golden_Sword,
	[gear.Amethyst,gear.Amethyst,gear.Amethyst,gear.Machine_Armor]: gear.Divine_Armor,
	[gear.Ghostly_Essence,gear.Ghostly_Essence, gear.Purple_Sapphire]: gear.Talisman_Of_The_Abyss,
	[gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard, gear.Nekronomikon]: gear.Golem,
	[gear.Heavy_Lifter, gear.Purple_Sapphire,gear.Purple_Sapphire,gear.Purple_Sapphire]: gear.Quick_Changer,
	[gear.Skull, gear.Brute_Brain]: gear.Corrupted_Skull,
	[gear.Rotten_Bone,gear.Rotten_Bone,gear.Rotten_Bone,gear.Rotten_Bone,gear.Rotten_Bone]: gear.Heavy_Lifter,
	[gear.Rotten_Bone,gear.Rotten_Bone,gear.Rotten_Bone, gear.Corrupted_Skull]: gear.Suspicious_Ring,
	[gear.Rose, gear.Rose, gear.Ruby_Sword]: gear.Blade_Of_Blood,

}

var recipes_accses = [
	#[gear.Iron_Sword,gear.Iron_Sword,gear.Black_Sword],
	#[gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Black_Sword],
	[gear.Mantis_Scales,gear.Mantis_Scales,gear.Mantis_Scales,gear.Mantis_Armor],
	[gear.Mantis_Fang,gear.Mantis_Fang,gear.Mantis_Fang,gear.Mantis_Fang,gear.Platinum, gear.Mantis_Scimitar],
	[gear.Goblin_Hide, gear.Goblin_Hide, gear.Goblin_Armor],
	[gear.Goblin_Tooth, gear.Goblin_Tooth, gear.Goblin_Dagger],
	[gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard, gear.Bone_Armor],
	[gear.Ruby, gear.Ruby, gear.Platinum, gear.Ruby_Sword],
	[gear.Platinum,gear.Platinum,gear.Platinum,gear.Platinum, gear.Platinum_Armor],
	[gear.Diamond, gear.Bar_of_Brass, gear.Crystal_Sword],
	[gear.Diamond, gear.Diamond,gear.Lilypad,gear.Rapier_Of_Ice],
	[gear.Ruby, gear.Ruby, gear.Skull, gear.Nekronomikon],
	[gear.Piece_Of_Gold,gear.Piece_Of_Gold,gear.Piece_Of_Gold,gear.Piece_Of_Gold,gear.Piece_Of_Gold, gear.Golden_Sword],
	[gear.Amethyst,gear.Amethyst,gear.Amethyst,gear.Machine_Armor,gear.Divine_Armor],
	[gear.Ghostly_Essence, gear.Ghostly_Essence, gear.Purple_Sapphire, gear.Talisman_Of_The_Abyss],
	[gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard,gear.Bone_Shard, gear.Nekronomikon, gear.Golem],
	[gear.Heavy_Lifter, gear.Purple_Sapphire,gear.Purple_Sapphire,gear.Purple_Sapphire, gear.Quick_Changer],
	[gear.Skull, gear.Brute_Brain, gear.Corrupted_Skull],
	[gear.Rotten_Bone,gear.Rotten_Bone,gear.Rotten_Bone,gear.Rotten_Bone,gear.Rotten_Bone,gear.Heavy_Lifter],
	[gear.Rotten_Bone,gear.Rotten_Bone,gear.Rotten_Bone, gear.Corrupted_Skull, gear.Suspicious_Ring],
	[gear.Rose, gear.Rose, gear.Ruby_Sword, gear.Blade_Of_Blood],
	
	]

var gear_accses = [
	gear.Iron_Sword, gear.Black_Sword, 
	gear.Crystal_Sword, gear.Wooden_Sword,
	gear.Katana, gear.Golden_Sword, 
	gear.Iron_Armor, gear.Black_Armor, 
	gear.Crystal_Armor, gear.Fabric_Suit, 
	gear.Neon_Suit, gear.Ninja_Suit, 
	gear.Stone_Armor,gear.Samurai_Armor, 
	gear.Mantis_Armor,gear.Ghost_Armor,
	gear.Machine_Armor,#17
	gear.Simple_Ring, gear.Better_Ring, 
	gear.Healthy_Ring, gear.Ring_of_Tank, 
	gear.Stabber, gear.Heavy_Lifter,
	gear.The_Ring_Of_The_Snake, gear.Ring_Of_Mobility, 
	gear.Quick_Changer, gear.Suspicious_Ring,
	gear.Talisman_Of_The_Abyss,#28
	gear.Bone_Shard, gear.Rotten_Bone, gear.Ruby, gear.Purple_Sapphire,#32
	 gear.Diamond,
	gear.Amethyst,gear.Piece_Of_Gold, gear.Bar_of_Brass, gear.Platinum, gear.Lilypad,
	gear.Rose, gear.Nekronomikon, gear.Goblin_Hide, gear.Brute_Brain, gear.Skull,
	gear.Mantis_Scales, gear.Mantis_Fang, gear.Ghostly_Essence,#46
	 gear.Goblin_Tooth,

	gear.Bone_Armor, gear.Goblin_Armor, gear.Platinum_Armor, gear.Rapier_Of_Ice, gear.Mantis_Scimitar, 
	gear.Ruby_Sword, gear.Goblin_Dagger, #55
	gear.Blade_Of_Blood, gear.Golem, gear.Divine_Armor,gear.Corrupted_Skull,
]

var save_data = {
	perm_dead = [false, false, true, false],
	elevators = [-1, -1, 1, 1],
	doors = [false, false, true, false],
	
	gear_stored = inv_to_text([], true),
	gear_active = inv_to_text([gear.Wooden_Sword, gear.Fabric_Suit,gear.Simple_Ring]),
	points = 5,
	healings = 8,

	pos = Vector2(0,0),

	pure_stats = {
		"health" : 100,
		"stamina" : 100,
		"healing" : 30,
		"strength" : 100,
		"endourance" : 100,
		"agility" : 100,
	},
}

var global = {
	gear_stored = [
	],
	
	#gear_active = [gear.Black_Sword, gear.Stone_Armor,gear.Iron_Armor],
	gear_active = [gear.Wooden_Sword, gear.Fabric_Suit,gear.Simple_Ring],
	
	crafting = [],
	is_full = false,
	
	points = 5,
	healings = 8,
	progress = 0,
	
	dmg_light = 50,
	dmg_heavy = 150,
	defense = 40,
	
	weight = 100,
	default_weight = 100,
	slowdown = 0,
	
	temp_stats = {
		"health" : 100,
		"stamina" : 100,
		"healing" : 30,
		"strength" : 100,
		"endourance" : 100,
		"agility" : 100,
	},
	temp_points = 5,
	
	stats = {
		"health" : 100,
		"stamina" : 100,
		"healing" : 30,
		"strength" : 100,
		"endourance" : 100,
		"agility" : 100,
	},
	
	pure_stats = {
		"health" : 100,
		"stamina" : 100,
		"healing" : 30,
		"strength" : 100,
		"endourance" : 100,
		"agility" : 100,
	},
	
	default_stats = {
		"health" : 100,
		"stamina" : 100,
		"healing" : 30,
		"strength" : 100,
		"endourance" : 100,
		"agility" : 100,
	},
	max_stats = {
		"health" : 200,
		"stamina" : 200,
		"healing" : 40,
		"strength" : 200,
		"endourance" : 200,
		"agility" : 150,
	},
	stat_upgrades = {
		"health" : 10,
		"stamina" : 10,
		"healing" : 1,
		"strength" : 10,
		"endourance" : 10,
		"agility" : 5,
		
	},
	
	modifiers = {
		"stamina_regen": 0.095,	#per second ; was 0.08
		
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

var stat_names = [
	["health","Health","Your potential health pool"],
	["stamina","Stamina","Your available Stamina"],
	["healing","Healing Power","Percantage of health you gain when healing"],
	["strength","Strength","You wield you weapons with more Force"],
	["endourance","Endourance","You can carry your armor more easily"],
	["agility","Agility","You wield you weapons with increased skill"],
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





#1000 yay
