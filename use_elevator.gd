extends Control

var current_elevator = null

func _ready():
	pass 

func display(el):
	current_elevator = el
	visible = true

func stop():
	visible = false

func _on_rest_pressed():
	current_elevator.start()
