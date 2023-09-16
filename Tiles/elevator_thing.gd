extends Node2D

export var kills = true

func _ready():
	pass
	
func _on_Area2D_body_entered(body):
	if body == PlayerData.player and !PlayerData.player.on_elevator:
		if kills:
			PlayerData.player.die()
	
	if body.is_in_group("enemy"):
		body.die()
		

