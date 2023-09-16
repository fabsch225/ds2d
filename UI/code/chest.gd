extends Control

onready var stored = $TextureRect/VBoxContainer/items
onready var info = $TextureRect/VBoxContainer/interfaceA/TextureRect/text

var sel_index = null
var current_chest = null
var dragging = false

func _ready():
	pass
	
func start():
	visible = true
	
func stop():
	visible = false

func _update(chest):
	sel_index = null
	stored.set_items(chest)
	current_chest = chest

func set_info(item):
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



func _on_take_pressed():
	if (current_chest != null and sel_index != null):
		current_chest.take(sel_index)
		_update(current_chest)


func _on_takeAll_pressed():
	if (current_chest != null):
		current_chest.take_all()
		_update(current_chest)
