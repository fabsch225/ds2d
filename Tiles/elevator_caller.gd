extends Node2D

export var eID = 1
export var dID = 0

func _ready():
	pass


func action():
	if (dID != 0):
		get_tree().call_group("dID" + String(dID), "open")
	elif (eID != 0):
		get_tree().call_group("eID" + String(eID), "start")
	$AnimatedSprite.frame = 0


func _on_Area2D_body_entered(body):
	if body == PlayerData.player:
		Hud.call_elevator.display(self)


func _on_Area2D_body_exited(body):
	if body == PlayerData.player:
		Hud.call_elevator.stop()
