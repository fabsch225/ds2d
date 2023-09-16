extends Area2D


func _ready():
	pass 


func attck(right):
	var d = get_parent().DMG
	

	$left.disabled = right
	$right.disabled = !right

	yield(get_tree().create_timer(0.02), "timeout")
	if get_parent().state != 1:
		damage(d)

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
