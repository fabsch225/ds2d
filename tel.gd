extends Node2D


func _ready():
	pass


func _on_Area2D_body_entered(body):
	if (body == PlayerData.player):
#		print(position + get_node("Node2D").position)
#		PlayerData.player.position = get_node("Node2D").position + position
		Hud.teleport(PlayerData.player, get_node("Node2D").position + position)
