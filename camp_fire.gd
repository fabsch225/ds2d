extends Control

var act = false
var current_position = Vector2()

func _ready():
	pass 

func activate(position):
	if (act):
		act = !act
		visible = false
	else:
		act = true
		if Hud.mode != "rest":
			visible = true
			current_position = position
		


func _on_rest_pressed():
	PlayerData.s(current_position)
	Hud.change_mode("rest")


func _on_save_pressed():
	PlayerData.s(current_position)
