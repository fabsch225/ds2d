extends Control

onready var active = $TextureRect/VBoxContainer/HBoxContainer/VBoxContainer/active_big
onready var stored = $TextureRect/VBoxContainer/HBoxContainer/VBoxContainer/stored_big
onready var info = $TextureRect/VBoxContainer/HBoxContainer/VBoxContainer2/item_info/text
onready var active_info= $TextureRect/VBoxContainer/HBoxContainer/VBoxContainer2/general_info/text

onready var dragger = $Icon
var drag_index = null
var dragging = false

var Cindex = {
	true: "green",
	false: "red"
}


func _ready():
	dragger.visible = false;
	set_info(PlayerData.global.gear_stored[randi() % PlayerData.global.gear_stored.size()])
	
	
func _process(delta):
	dragger.global_position = get_viewport().get_mouse_position()
	

func set_active_info(type):
	var item
	
	match type:
		"sword":
			item = PlayerData.global.gear_active[0]
		"armor":
			item = PlayerData.global.gear_active[1]
		"accs":
			item = PlayerData.global.gear_active[2]
	
	var text = ""
	
	var name = "Aktive Gear: \n\n\n\n" + item.name.replace("_", " ")
	var mods = ""
	var has_mods = "modifiers" in item
	if has_mods:
		mods = "\n\n"
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
			text = name + "\n\nDamage: " + str(item.dmg_light) + "\nHeavy: " + str(item.dmg_heavy) + "\nWeight: " + str(item.weight) + mods
		"armor":
			text = name + "\n\nDefense: " + str(item.defense) +  "\nWeight: " + str(item.weight) + mods
		"accs":
			text = name + mods
			
	active_info.set_bbcode(text)
	active_info.get_parent().get_node("Icon").frame = item.i
	
func set_info(item):
	set_active_info(item.type)
	
	var text = ""
	var comp
	var name = "Selected Gear: \n\n\n\n" + item.name.replace("_", " ")
	var mods = ""
	var has_mods = "modifiers" in item
	if has_mods:
		mods = "\n\n"
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
			comp = PlayerData.global.gear_active[0]
			
			var dl = item.dmg_light
			var dh = item.dmg_heavy
			var w = item.weight
			
			var cdl = comp.dmg_light
			var cdh = comp.dmg_heavy
			var cw = comp.weight
			
			var Color_dl = Cindex[dl > cdl]
			var Color_dh = Cindex[dh > cdh]
			var Color_w = Cindex[!w > cw]
			
			var dl_Str = "[color=" + Color_dl + "]" + str(dl) + "[/color] (" + str(cdl) + ")"
			var dh_Str = "[color=" + Color_dh + "]" + str(dh) + "[/color] (" + str(cdh) + ")"
			var w_Str = "[color=" + Color_w + "]" + str(w) + "[/color] (" + str(cw) + ")"
			
			text = name + "\n\nDamage: " + dl_Str + "\nHeavy: " + dh_Str + "\nWeight: " + w_Str + mods
		"armor":
			comp = PlayerData.global.gear_active[1]
			
			var d = item.defense
			var w = item.weight
			
			var cd = comp.defense
			var cw = comp.weight
			
			var Color_d = Cindex[d > cd]
			var Color_w = Cindex[!w > cw]
			
			var d_Str = "[color=" + Color_d + "]" + str(d) + "[/color] (" + str(cd) + ")"
			
			var w_Str = "[color=" + Color_w + "]" + str(w) + "[/color] (" + str(cw) + ")"
			
			text = name + "\n\nDefense: " + d_Str +  "\nWeight: " + w_Str + mods
		"accs":
			comp = PlayerData.global.gear_active[2]
			text = name + mods
			
	info.set_bbcode(text)
	info.get_parent().get_node("Icon").frame = item.i

func update():
	active.set_items()
	stored.set_items()

func start_drag(index, i):
	dragger.visible = true;
	dragger.frame = i
	dragging = true
	drag_index = index
	set_process(true)

func stop_drag():
	print("Heyyy")
	dragging = false
	dragger.visible = false;
	set_process(false)


func _on_active_mouse_entered():
	if dragging:
		dragging = false
		stop_drag()
		
		var drag_item = PlayerData.global.gear_stored[drag_index]
		
		match drag_item.type:
			"sword":
				PlayerData.change_gear(drag_index,0)
			"armor":
				PlayerData.change_gear(drag_index,1)
			"accs":
				PlayerData.change_gear(drag_index,2)
				
		
		update()
		get_tree().call_group("icons", "set_target",self)




func _on_exit_pressed():
	PlayerData.s(PlayerData.player.position)
	get_tree().reload_current_scene()
	#Hud.change_mode("game")
