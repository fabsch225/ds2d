extends VBoxContainer

onready var col_template = preload("res://UI/rest/Upgrade_Bar.tscn")

func _ready():
	pass # Replace with function body.

func fill():
	delete_children()
	for i in range(len(PlayerData.stat_names)):
		var c = col_template.instance()
		add_child(c)
		c.fill(i)
		c.parent = self

func delete_children():
	for n in get_children():
		remove_child(n)
		n.queue_free()
