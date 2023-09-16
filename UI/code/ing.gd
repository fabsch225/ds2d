extends HBoxContainer

onready var grid = $TextureRect/grid
onready var prev = $TextureRect/result/Icon
onready var item_template = preload("res://Icons/Icon.tscn")

func _ready():
	pass 

func set_items():
	var items = PlayerData.global.crafting
	var index = 0
	var past_items = []
	
	grid.delete_children()
	for item in items:
		
		var icon = item_template.instance()
		icon.draggable = true
		icon.recipe = true
		icon.r_item = item
		if (item in past_items):
			var loc = past_items.find(item)
			grid.get_child(loc).amount += 1
			grid.get_child(loc).set_icon(item.name)
		else:
			grid.add_child(icon)
			icon.set_icon(item.name)
			icon.index = index
			
			past_items.append(item)
			
		index += 1
		
	
	
	#print(grid.get_children())
	if (PlayerData.get_craft_result() != null):
		prev.frame = PlayerData.get_craft_result().i
	else:
		prev.frame = 100

