extends Control

onready var bar = $TextureRect/TextureRect
onready var boss = $TextureRect/RichTextLabel

var original_health = 100

func update_health(health):
	bar.rect_scale.x = health / original_health


func start(h,n):
	if h <= 0:
		return
	visible = true
	original_health = h
	boss.text = n
	
	
func stop():
	visible = false
