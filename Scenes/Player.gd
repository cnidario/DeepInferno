extends KinematicBody2D

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree

export var state: Dictionary = {
	moving = "idle",
	facing = "right",
	turning = false,
}
const SPEED = 75
const ACCELERATION = 150
const EPSILON = 5
var velocity: Vector2 = Vector2.ZERO
var weapon

onready var state_machine = animation_tree.get("parameters/playback")

func _ready():
	animation_tree["parameters/conditions/walking"] = false
	state_machine.start("idle")
	weapon = $CollisionShape2D/Hand/Sword
	
func turning_ended():
	state.turning = false

func get_input():
	var x = Input.get_action_strength("right") - Input.get_action_strength("left")
	var y = Input.get_action_strength("down") - Input.get_action_strength("up")
	return Vector2(x, y).normalized()

func must_turn(old, new):
	if old == "right" and new == "left":
		return "turn-left"
	elif old == "left" and new == "right":
		return "turn-right"
	else:
		return false
func is_walking(st):
	return st != "idle"

func calc_movement(input: Vector2):
	if input.length_squared() < 0.1 * 0.1:
		return "idle"
	var alpha = input.angle()
	if alpha >= PI/4 and alpha <= (PI - PI/4):
		return "down"
	elif abs(alpha) >= (PI - PI/4):
		return "left"
	elif -alpha >= PI/4 and -alpha <= (PI - PI/4):
		return "up"
	else:
		return "right"
		
func attack():
	weapon.attack()
	
func _physics_process(delta):
	var input = get_input()
	if Input.is_action_just_pressed("action"):
		attack()
	var new_moving_state = calc_movement(input)
	if is_walking(new_moving_state):
		animation_tree["parameters/conditions/walking"] = true
		state.moving = "walking"
		state_machine.travel("walk-cycle")
		var turn_to = must_turn(state.facing, new_moving_state)
		if turn_to:
			state.facing = new_moving_state
			state.turning = true
			state_machine.travel(turn_to)
	else:
		if state_machine.get_current_node() and state_machine.get_current_node() != "idle":
			state_machine.travel("idle")
		state.moving = "idle"
		animation_tree["parameters/conditions/walking"] = false
	
	var new_velocity = velocity
	if is_walking(new_moving_state):
		new_velocity = velocity + ACCELERATION * input * delta
		if new_velocity.length_squared() > SPEED*SPEED:
			new_velocity = new_velocity.normalized() * SPEED
	elif velocity.length_squared() > EPSILON*4:
		new_velocity = velocity - ACCELERATION * 2 * velocity.normalized() * delta
	else:
		new_velocity = Vector2.ZERO
	velocity = move_and_slide(new_velocity, Vector2(1, 0))

