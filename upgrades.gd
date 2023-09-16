extends VBoxContainer

onready var list = $list
onready var points = $upgrade/TextureRect2/points
onready var info = $upgrade/TextureRect/info

func _ready():
	pass 


func update():
	list.fill()
	points.text = str(PlayerData.global.temp_points)

func set_stat_info(s):
	info.text = PlayerData.stat_names[s][2]

func _on_confirm_pressed():
	PlayerData.confirm_upgrades()
	update()

func _on_chancel_pressed():
	PlayerData.reset_upgrades()
	update()

func _on_reset_pressed():
	PlayerData.reset_stats()
	update()
