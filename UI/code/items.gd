extends HBoxContainer

onready var grid = $grid
onready var item_template = preload("res://Icons/Chest_Icon.tscn")

func _ready():
	pass 

func set_items(chest):
	var items = chest.storage
	var index = 0
	grid.delete_children()
	for item in items:
		
		var icon = item_template.instance()
		
	
		grid.add_child(icon)	
		icon.set_icon(item.name)
		icon.set_chest(chest)
		icon.index = index
		
		index += 1
	#print(grid.get_children())

