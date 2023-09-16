extends Area2D


func _ready():
	pass 


func attck(right, n, d = get_parent().DMG):
	#var d = get_parent().DMG
	
	if n == 1:
		$left1.disabled = right
		$right1.disabled = !right
	elif n == 0:
		$left1b.disabled = right
		$right1b.disabled = !right
	elif n == 2:
		$left2.disabled = right
		$right2.disabled = !right
	elif n == 2.5:
		$left2b.disabled = right
		$right2b.disabled = !right
	elif n == 2.75:
		$left2c.disabled = right
		$right2c.disabled = !right
	elif n == 3:
		$left3.disabled = right
		$right3.disabled = !right


	yield(get_tree().create_timer(0.02), "timeout")
	if get_parent().state == 1:
		disable_all()
		return
		
	damage(d)
	
	disable_all()


func disable_all():
	for c in get_children():
		c.disabled = true
#	$left1.disabled = true
#
#	$right1.disabled = true
#
#	$left2.disabled = true
#	$right2.disabled = true
#
#	if ($left1b != null):
#		$left1b.disabled = true
#		$right1b.disabled = true
#
#	if ($left2b != null):
#		$left2b.disabled = true
#		$right2b.disabled = true
#		$left3.disabled = true
#		$right3.disabled = true
	
func disable_visibility():
	$left1.visible = false
	$right1.visible = false
	$left2.visible = false
	$right2.visible = false
	
	

func damage(d):
	
	if overlaps_body(get_parent().player):
		print("Hitting Player")
		get_parent().player.damage(d)
