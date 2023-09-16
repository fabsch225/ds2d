extends Area2D

var direction
var speed = 90
var revert = 1
var has_hit = false
var can_hit_shooter = false
var moving = 1
var shooter
var DMG = 51

func _ready():
	
	direction = (PlayerData.player.position - position).normalized()
	#direction = get_parent().dir
	
	$AnimatedSprite.animation = "default"
	yield(get_tree().create_timer(0.25), "timeout")
	can_hit_shooter = true
	
func _physics_process(delta):

	var new_direction = (PlayerData.player.position - position).normalized()
	direction -= (direction - new_direction) / 80
	
	#direction = direction.normalized()
	
	position += direction * speed * delta

	speed += 160 * delta * moving
	


	rotation_degrees = atan2(direction.normalized().x, direction.normalized().y) * 57.2958 + 90

func _on_Area2D_body_entered(body):
	print("Wave has hit:" + body.name)
	if body.is_in_group("barrier") or body.is_in_group("walls"):
		speed = 0
		moving = 0
		#$AnimatedSprite.animation = "stop"
		has_hit = true
		queue_free()
		
		#yield(get_tree().create_timer(1.25), "timeout")
	elif body == shooter and can_hit_shooter:
		shooter.dmg(DMG / 2)
		speed = 0
		moving = 0
		has_hit = true
		queue_free()


	elif body == PlayerData.player and !has_hit:
		if (body.get_node("hurtbox") in get_overlapping_areas()):
			has_hit = true
		else:
			body.damage(DMG)
			has_hit = true

		speed = 0
		moving = 0
		
		
		
		#yield(get_tree().create_timer(1.25), "timeout")
		queue_free()

		
		
