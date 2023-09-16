extends Area2D

var direction
var speed = 90
var revert = 1
var has_hit = false
var moving = 1
var DMG = 51

func _ready():
	
	direction = Vector2(0,-1)#(PlayerData.player.position - position).normalized()
	$AnimatedSprite.animation = "start"
	yield(get_tree().create_timer(0.415), "timeout")
	$AnimatedSprite.animation = "default"
	
func _physics_process(delta):

	var new_direction = (PlayerData.player.position - position).normalized()
	direction -= (direction - new_direction) / 50
	
	#direction = direction.normalized()
	
	position += direction * speed * delta

	speed += 20 * delta * moving
	
	#rotation_degrees += delta * speed / 10

func _on_Area2D_body_entered(body):
	print("Wave has hit:" + body.name)
	if body.is_in_group("barrier"):
		speed = 0
		moving = 0
		$AnimatedSprite.animation = "stop"
		has_hit = true
		
		yield(get_tree().create_timer(1.25), "timeout")
		queue_free()
		
	if body == PlayerData.player and !has_hit:
		if (body.get_node("hurtbox") in get_overlapping_areas()):
			has_hit = true
		else:
			body.damage(DMG)
			has_hit = true

		speed = 0
		moving = 0
		$AnimatedSprite.animation = "stop"
		
		
		yield(get_tree().create_timer(1.25), "timeout")
		queue_free()

		
		
