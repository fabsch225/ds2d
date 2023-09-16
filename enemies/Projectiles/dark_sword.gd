extends Area2D

var direction
var speed = 120

var DMG = 35

func _ready():
	#if get_parent().dir != null:
	direction = get_parent().get_parent().get_parent().dir
	
func _physics_process(delta):
	position += direction * speed * delta


func _on_Area2D_body_entered(body):
	if body.is_in_group("walls"):
		speed = 0
		$AnimatedSprite.animation = "stop"
		yield(get_tree().create_timer(0.55), "timeout")
		queue_free()
		
	if body == PlayerData.player:
		speed = 0
		
		if (body.get_node("hurtbox") in get_overlapping_areas()):
			pass
		else:
			body.damage(DMG)
		
		$AnimatedSprite.animation = "stop"
		yield(get_tree().create_timer(0.55), "timeout")
		queue_free()
