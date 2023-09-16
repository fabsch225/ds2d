extends Control

var current_chest = null
onready var Dname = $TextureRect/open/RichTextLabel


func _ready():
	pass 

func start(c, n):
	current_chest = c
	Dname.text = "Search " + n
	visible = true

func stop():
	visible = false
	current_chest = null

func _on_open_pressed():
	current_chest.open()
	stop()
