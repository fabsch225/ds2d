extends Area2D

var direction
var speed = 0

var DMG = 27

func _ready():
	
	direction = (PlayerData.player.position - position).normalized()
	$AnimationPlayer.play("start")
	
func _physics_process(delta):
	var new_direction = (PlayerData.player.position - position).normalized()
	direction -= (direction - new_direction) / 5
	
	direction = direction.normalized()
	
	position += direction * speed * delta
	speed += 60 * delta
	
	rotation_degrees += delta * speed / 10

func _on_Area2D_body_entered(body):
	if body.is_in_group("walls"):
		speed = 0
		$AnimationPlayer.play("stop")
		yield(get_tree().create_timer(0.55), "timeout")
		queue_free()
		
	if body == PlayerData.player:
		speed = 0
		
		if (body.get_node("hurtbox") in get_overlapping_areas()):
			pass
		else:
			body.damage(DMG)
		
		$AnimationPlayer.play("stop")
		yield(get_tree().create_timer(0.55), "timeout")
		queue_free()
