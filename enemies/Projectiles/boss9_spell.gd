extends Area2D

var direction
var speed = 700
var revert = 1
var has_hit = false
var moving = 1
var DMG = 80

func _ready():
	
	direction = (PlayerData.player.position - position).normalized()
	$AnimatedSprite.animation = "default"
	$AnimatedSprite.frame = 0
	yield(get_tree().create_timer(0.55), "timeout")
	speed = 0
	moving = 0
	if (PlayerData.player in get_overlapping_bodies()):
		PlayerData.player.damage(DMG)
	yield(get_tree().create_timer(0.25), "timeout")
	queue_free()
	
func _physics_process(delta):
	var new_direction = (PlayerData.player.position - position).normalized()
	direction -= (direction - new_direction) / 5
	
	#direction = direction.normalized()
	
	position.x += direction.x * speed * delta

	speed += 360 * delta * moving

#func _on_Area2D_body_entered(body):
#	print("Wave has hit:" + body.name)
#	if body.is_in_group("barrier"):
#		speed = 0
#		moving = 0
#		$AnimatedSprite.animation = "stop"
#		has_hit = true
#
#		yield(get_tree().create_timer(1.25), "timeout")
#		queue_free()
#
#	if body == PlayerData.player and !has_hit:
#		if (body.get_node("hurtbox") in get_overlapping_areas()):
#			has_hit = true
#		else:
#			body.damage(DMG)
#			has_hit = true

		
		
