extends Node2D

var player = null

export var switch_to = 0
export var custom_y = 666.666


func _ready():
	pass 
	
func set_player(p):
	player = p

func _on_Area2D_body_entered(body):
	if body == player:
		if switch_to != 0 and PlayerData.player.bg != switch_to - 1:
			get_tree().call_group("bg", "switch_to",switch_to - 1)
			PlayerData.player.bg = switch_to - 1
		if (custom_y != 666.666 and PlayerData.player.bgY != custom_y):
			get_tree().call_group("bg", "sync_Y",custom_y)
			PlayerData.player.bgY = custom_y
		else:
			print(PlayerData.player.bgY, position.y, name)
			if (PlayerData.player.bgY != position.y):
				get_tree().call_group("bg", "sync_Y",position.y)
				PlayerData.player.bgY = position.y

