extends Node2D

export var rate = 0.25
export var dmg = 20

func _ready():
	$Timer.wait_time = rate

func _on_Timer_timeout():
	if (PlayerData.player in $Area2D.get_overlapping_bodies()):
		print("spike!")
		PlayerData.player.damage(dmg, true);


func _on_Area2D_body_entered(body):
	if (body == PlayerData.player):
		PlayerData.player.damage(dmg, true);
