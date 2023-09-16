extends Sprite


func _ready():
	pass 
	

func enable(name):
	get_node(name).visible = true

func disable(name):
	if (name == "all"):
		var children = get_children()
		for child in children:
			child.visible = false
	else:
		get_node(name).visible = false
