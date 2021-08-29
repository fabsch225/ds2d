extends Control

onready var active = $TextureRect/VBoxContainer/active
onready var stored = $TextureRect/VBoxContainer/stored

onready var dragger = $Icon
var drag_index = null
var dragging = false


func _ready():
	dragger.visible = false;
	
func _process(delta):
	dragger.global_position = get_viewport().get_mouse_position()
	
func update():
	active.set_items()
	stored.set_items()

func start_drag(index, i):
	dragger.visible = true;
	dragger.frame = i
	dragging = true
	drag_index = index
	set_process(true)

func stop_drag():
	print("Heyyy")
	dragging = false
	dragger.visible = false;
	set_process(false)


func _on_active_mouse_entered():
	if dragging:
		dragging = false
		stop_drag()
		
		var drag_item = PlayerData.global.gear_stored[drag_index]
		
		match drag_item.type:
			"sword":
				PlayerData.change_gear(drag_index,0)
			"armor":
				PlayerData.change_gear(drag_index,1)
			"accs":
				PlayerData.change_gear(drag_index,2)
				
		
		update()
		

