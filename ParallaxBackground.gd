extends ParallaxBackground


func _ready():
	pass # Replace with function body.

func sync_Y(y):
	scroll_base_offset.y = y
	
#	var children = get_children()
#	for child in children:
#		#print(child)
#		#var oo = 
#
#		child.motion_offset.y = y#((int(y) % 1280))
#		#print(y, child.motion_offset.y)
