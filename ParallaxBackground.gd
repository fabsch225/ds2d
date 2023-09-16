extends ParallaxBackground


func _ready():
	pass # Replace with function body.

func sync_Y(y):
	scroll_base_offset.y = y * 2
	
func switch_to(i):
	var children = get_children()
	for child in children:
		disable_all(child)
		child.get_child(i).visible = true
	
func disable_all(layer):
	var children = layer.get_children()
	for child in children:
		child.visible = false
