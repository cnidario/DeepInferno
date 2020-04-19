extends KinematicBody2D

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var state_machine = $AnimationTree.get("parameters/playback")
onready var peace_timer = $PeaceTimer
onready var area2D = $Area2D

var attacking = false
var attacked = []

func _ready():
	state_machine.start("idle")
func peaceTimerTimeout():
	state_machine.travel("idle")
func attack():
	state_machine.travel("attack")
	peace_timer.start()

func attack_peak():
	attacking = false
	attacked = []
func attack_started():
	attacking = true
	
func is_on_hit_yaxis(body):
	var ydst = global_position.y - body.global_position.y
	return ydst <0 and ydst > -8
	
func canAttack(body):
	return !body in attacked and body.name == "Demon" and is_on_hit_yaxis(body)

func _process(delta):
	if attacking:
		var bodies = area2D.get_overlapping_bodies()
		for body in bodies:
			if canAttack(body):
				body.getHit()
				attacked.append(body)

