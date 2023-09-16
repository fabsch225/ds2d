extends Node2D

export var just_message = false
export var level = 0
export var unlock_message = "Something unlocked"

func _ready():
	pass # Replace with function body.


func _on_Area2D_body_entered(body):
	if (body == PlayerData.player):
		if (just_message):
			Hud.show_message(unlock_message)
		elif (PlayerData.global.progress < level):
			PlayerData.global.progress = level
			Hud.show_message(unlock_message)
			if (PlayerData.player.WITH_SAVES):
				PlayerData.s(PlayerData.save_data.pos)
