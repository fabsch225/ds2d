extends Node2D

onready var body = $StaticBody2D
export var open = false


func _ready():
	pass 

func open():
	print("Open", open)
	if (open):
		close()
		return
	body.set_collision_layer_bit(0, 0)
	open = true
	
func close():
	open = false
	body.set_collision_layer_bit(0, 1)
