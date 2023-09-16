extends HBoxContainer

onready var my_children = {
	"sword": $sword,
	"armor": $armor,
	"accs": $accs
}

onready var info = $TextureRect/text

func _ready():
	pass 

func set_items():
	var act = PlayerData.global.gear_active
	for slot in act:
		
		my_children[slot.type].get_child(0).frame = slot.i
		print(my_children[slot.type].get_child(0).frame)

	

func set_info(item, amount):
	var name = item.name.replace("_", " ")
	var mods = ""
	var has_mods = "modifiers" in item
	if has_mods:
		mods = "\n"
		if typeof(item["modifiers"]) == TYPE_STRING:
			mods += item["modifiers"]
		else:
			for k in PlayerData.global.modifiers:
				if item["modifiers"].has(k):
					if item["modifiers"][k] > 1:
						mods += "Boosts " + PlayerData.global.modifier_names[k] + " By " + str(item["modifiers"][k]) + "  "
					else:
						mods += "Lessens " + PlayerData.global.modifier_names[k] + " By " + str(1 - item["modifiers"][k]) + "  "
	match item.type:
		"sword":
			info.text = name + "\nDamage: " + str(item.dmg_light) + "\nHeavy: " + str(item.dmg_heavy) + "\nWeight: " + str(item.weight) + mods
		"armor":
			info.text = name + "\nDefense: " + str(item.defense) +  "\nWeight: " + str(item.weight) + mods
		"accs":
			info.text = name + mods
		


func _on_sword_pressed():
	var item = PlayerData.global.gear_active[0]
	set_info(item, 1)


func _on_armor_pressed():
	var item = PlayerData.global.gear_active[1]
	set_info(item, 1)
	
func _on_accs_pressed():
	var item = PlayerData.global.gear_active[2]
	set_info(item, 1)
