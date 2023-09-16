extends Node2D

onready var bar = $Sprite/Sprite

var current
var original

func _ready():
	original = get_parent().Php
	current = original
	
func update():
	
	
	current = get_parent().hp
	if (current < 0):
		current = 0
	if (original == 0):
		return
	var percent = current  / original
		
	bar.scale.x = percent
	bar.position.x = - 7 * (1 - percent)
