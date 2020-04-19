extends KinematicBody2D

onready var hp_bar = $HPBar
onready var animation_player = $AnimationPlayer

func _ready():
	pass

func getHit():
	hp_bar.setHP(hp_bar.hp - 10)
	animation_player.play("hit")
	
