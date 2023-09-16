extends TileMap

var act = false

func _ready():
	pass 

func start():
	if (act):
		return
	act = true
	visible = true
	set_collision_mask_bit(1, true)
	set_collision_layer_bit(1, true)


func stop():
	if (!act):
		return
	act = false
	visible = false
	set_collision_mask_bit(1, false)
	set_collision_layer_bit(1, false)
