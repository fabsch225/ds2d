extends HBoxContainer

onready var s_name = $getInfo/RichTextLabel
onready var level = $TextureRect2/RichTextLabel
onready var button = $TextureButton

var type
var parent 
var ind

func _ready():
	pass 


func fill(what):
	ind = what
	type = PlayerData.stat_names[what][0]
	s_name.text = PlayerData.stat_names[what][1] 
	var v = (PlayerData.global.pure_stats[type] - PlayerData.global.default_stats[type]) / PlayerData.global.stat_upgrades[type]
	var pv = (PlayerData.global.temp_stats[type] - PlayerData.global.default_stats[type]) / PlayerData.global.stat_upgrades[type]
	if (PlayerData.global.pure_stats[type] == PlayerData.global.max_stats[type] or PlayerData.global.temp_points == 0):
		button.disabled = true
	if (v == pv):
		level.set_bbcode("Level " + str(v))
	else:
		level.set_bbcode("Level [color=green]" + str(pv) + "[/color]")
	
	#return v


func _on_TextureButton_pressed():
	PlayerData.upgrade(type)
	parent.get_parent().update()

func _on_getInfo_pressed():
	print(parent.get_parent())
	parent.get_parent().set_stat_info(ind)
