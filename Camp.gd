extends Node2D

var player = null

func _ready():
	pass 

func _process(delta):
	pass

func set_player(p):
	player = p

func _on_Area2D_body_entered(body):
	print(body, player)
	if (body == player):
		Hud.camp_fire.activate(player.position)
		print(player.position)
#	if (body == player):
#		set_process(true)


func _on_Area2D_body_exited(body):
	if (body == player):
		Hud.camp_fire.activate(player.position)
#	if (body == player):
#		set_process(false)
