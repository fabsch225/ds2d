extends Control

var current_caller = null

func _ready():
	pass 

func display(el):
	current_caller = el
	visible = true

func stop():
	visible = false

func _on_rest_pressed():
	current_caller.action()
