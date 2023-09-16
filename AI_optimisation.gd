extends Node2D

func _ready():
	yield(get_tree().create_timer(0.1), "timeout")
	if (PlayerData.player in $Area2D.get_overlapping_bodies()):
		pass
	else:
		off()

func _on_Area2D_body_exited(body):
	if body == PlayerData.player:
		off()
		
func _on_Area2D_body_entered(body):
	if body == PlayerData.player:
		on()

func rest(_on):
	if (PlayerData.player in $Area2D.get_overlapping_bodies()):
		if (_on):
			on()
		else:
			off()

func on():
	
	print("on")
	var bs = $Area2D.get_overlapping_bodies()
	for b in bs:
		if b.is_in_group("enemy"):
			b.set_physics_process(true)
			b.set_process(true)
			
			b.get_node("Shoot").start()
			b.get_node("Timer").start()
	
func off():
	
	print("off")
	var bs = $Area2D.get_overlapping_bodies()
	print(len(bs))
	for b in bs:
		if b.is_in_group("enemy"):
			b.set_physics_process(false)
			b.set_process(false)
			
			b.get_node("Shoot").stop()
			b.get_node("Timer").stop()
			
func respawn():
	print("respawn")
	var bs = $Area2D.get_overlapping_bodies()
	for b in bs:
		
		if b.is_in_group("enemy") and b.state == 1 and !b.boss and !b.is_in_group("perm_death"):
			b.hp = b.Php
			b.state = 2
			if (b.get_node("Chest") != null):
				b.get_node("Chest").queue_free()
			b.get_node("Enemy_Health_bar").update()
			b.set_collision_layer_bit(2,true)
