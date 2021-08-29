extends HBoxContainer

onready var grid = $ScrollContainer/grid
onready var item_template = preload("res://Icons/Icon.tscn")

func _ready():
	pass 

func set_items():
	var items = PlayerData.global.gear_stored
	var index = 0
	grid.delete_children()
	for item in items:
		
		var icon = item_template.instance()
		
	
		grid.add_child(icon)	
		icon.set_icon(item.name)
		icon.index = index
		
		index += 1
	#print(grid.get_children())

