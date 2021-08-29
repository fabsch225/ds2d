extends Area2D


func _ready():
	pass 


func attck(right):
	var d = get_parent().DMG
	

	$left.disabled = right
	$right.disabled = !right

	print(right, !get_parent().get_node("AnimatedSprite").flip_h)

	#$left.visible = !get_parent().facing_right
	#$right.visible = get_parent().facing_right
	
	yield(get_tree().create_timer(0.02), "timeout")
	damage(d)
		
	#yield(get_tree().create_timer(0.5), "timeout")
	#disable_visibility()
	disable_all()


func disable_all():
	$left.disabled = true
	$right.disabled = true
	
	
func disable_visibility():
	$left.visible = false
	$right.visible = false
	
	

func damage(d):
	
	if overlaps_body(get_parent().player):
		print("Hitting Player")
		get_parent().player.damage(d)
