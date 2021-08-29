extends Node2D
var player = null

func _ready():
	pass 
	
func set_player(p):
	player = p

func _on_Area2D_body_entered(body):
	if body == player:
		get_tree().call_group("bg", "sync_Y",position.y)
		
