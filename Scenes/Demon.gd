extends KinematicBody2D

onready var hp_bar = $HPBar
onready var animation_player = $AnimationPlayer
onready var player_radar = $PlayerRadar

func _ready():
	pass

func getHit(damage = 10):
	hp_bar.setHP(hp_bar.hp - damage)
	animation_player.play("hit")
	
#func _process(delta):
#	player_radar.
