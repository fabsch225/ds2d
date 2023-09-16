extends VBoxContainer

func delete_children():
	for n in get_children():
		remove_child(n)
		n.queue_free()
