extends KinematicBody2D

onready var hp_bar = $HPBar

func _ready():
	pass

func getHit():
	print("no me jodas")
	hp_bar.setHP(hp_bar.hp - 10)
	
