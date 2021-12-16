extends Control

onready var health = $health
onready var stamina = $stamina

onready var heals = $TextureRect/heals
onready var coins = $TextureRect/coins


onready var health_end = $TextureRect/health_filled_end
onready var stamina_end = $TextureRect/stamina_filled_end

var s_end_x
var h_end_x



var current_health		#changes
var current_stamina

var current_health_length
var current_stamina_length



var pot_max_health = 300		#depends on global
var pot_max_stamina = 300

var current_max_health = 100	#depends on global
var current_max_stamina = 100

var default_max_health = 100
var default_max_stamina = 100



var pot_max_health_length = 300			#aesthethic choice
var pot_max_stamina_length = 300

var current_max_health_length = 100		#changes
var current_max_stamina_length = 100

var default_max_health_length = 100
var default_max_stamina_length = 100


var default_scale_stamina = 1
var default_scale_health = 1

func _ready():
	s_end_x = health_end.rect_position.x
	h_end_x = stamina_end.rect_position.x
	
func syncronise():
	upgrade(0,0)
	set_bars(current_health, current_stamina)

	
func set_bars(hp, st):
	heals.text = str(PlayerData.player.healings)
	coins.text = str(PlayerData.global.points)
	
	
	current_health = hp
	current_stamina = st
	
	var health_f = current_max_health_length / float(current_max_health)
	var stamina_f = current_max_stamina_length / float(current_max_stamina)
	
	current_health_length = current_health * health_f
	current_stamina_length = current_stamina * stamina_f
	
	health.value = current_health_length
	stamina.value = current_stamina_length
	
	
	health_end.visible = health.value == current_max_health
	stamina_end.visible = stamina.value == current_max_stamina
	
func upgrade(hp, st):
	
	
	current_max_health += hp
	current_max_stamina += st
	
	var health_f = default_max_health_length / float(default_max_health)
	var stamina_f = default_max_stamina_length / float(default_max_stamina)
	
	current_max_health_length = current_max_health * health_f
	current_max_stamina_length = current_max_stamina * stamina_f
	
	health.max_value = current_max_health_length
	stamina.max_value = current_max_stamina_length
	
	health.rect_scale.x = current_max_health_length / default_max_health_length 
	stamina.rect_scale.x = current_max_stamina_length / default_max_stamina_length


	$TextureRect/health_empty_end.rect_position.x =  float(30) + 42 * health.rect_scale.x + (5 * (health.rect_scale.x - 1))
	$TextureRect/health_filled_end.rect_position.x =  float(30) + 42 * health.rect_scale.x + (5 * (health.rect_scale.x - 1))
	
	$TextureRect/stamina_empty_end.rect_position.x =  float(30) + 42 * stamina.rect_scale.x + (5 * (stamina.rect_scale.x - 1))
	$TextureRect/stamina_filled_end.rect_position.x =  float(30) + 42 * stamina.rect_scale.x + (5 * (stamina.rect_scale.x - 1))
