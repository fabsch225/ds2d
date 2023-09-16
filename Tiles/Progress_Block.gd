extends Node2D

export var level = 0
export var block_message = "This path is blocked"

func _ready():
	pass 
	


func _on_Area2D_body_entered(body):
	if (body == PlayerData.player):
		if (PlayerData.global.progress >= level):
			print("Open")
			#$StaticBody2D/CollisionShape2D.disabled = true
			$StaticBody2D.set_collision_mask_bit(1, false)
		else:
			Hud.show_message(block_message)
