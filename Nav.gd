extends Timer

#var requests = 0
#var limit = 5
#
#func nav_request(a,b,old):
#	if (requests == limit):
#		return old
#	else:
#		requests += 1
#		var p = get_tree().get_node("Navigation2D").get_simple_path(a,b,false)
#		requests -= 1
#		return p

var queue = []
var names = []

func reset():
	queue = []
	names = []

func add_request(a,b,caller):
	if (names.has(caller) && is_instance_valid(caller)):
		if (queue.size() != 0):
			queue[names.find(caller)] = {"a":a,"b":b,"caller": caller}
	else:
		queue.append({"a":a,"b":b,"caller": caller})
		names.append(caller)

#func _process(delta):
#	if (len(queue) >= 1):
#		#var thread = Thread.new()
#		#thread.start(self, "create_path")
#		#thread.wait_to_finish()
#		create_path()
#		queue.remove(0)
#		names.remove(0)

func create_path():
	if (is_instance_valid(queue[0]["caller"])):
		queue[0]["caller"].path = get_tree().get_root().get_node("World/Navigation2D").get_simple_path(queue[0]["a"],queue[0]["b"])


func _on_Timer_timeout():
	if (len(queue) >= 1):
		
		create_path()
		queue.remove(0)
		names.remove(0)
