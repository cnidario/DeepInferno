extends KinematicBody2D

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var character = $Character
onready var shadow = $Shadow

export var state: Dictionary = {
	moving = "idle",
	facing = "right",
	turning = false,
	falling = false,
	jumping = false,
}
const SPEED = 75
const ACCELERATION = 150
const EPSILON = 5
var velocity: Vector2 = Vector2.ZERO
var original_y
export var z = 0
var jump_velocity = 0
var weapon

onready var state_machine = animation_tree.get("parameters/playback")

func _ready():
	state_machine.start("idle")
	weapon = $Character/Hand/Sword
	original_y = character.position.y

func process_jump(delta):
	z += jump_velocity * delta
	if z < 0:
		z = 0
		jump_velocity = 0
		state.jumping = false
	jump_velocity -= 300*delta
	print(jump_velocity)

func jump():
	jump_velocity = 100
	state.jumping = true

func fall():
	state.falling = true
	state_machine.stop()
	shadow.visible = false
	state_machine.travel("fall")

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
	character.position.y = original_y
	var input = get_input()
	if Input.is_action_just_pressed("action"):
		attack()
	var new_moving_state = calc_movement(input)
	var turn_to = must_turn(state.facing, new_moving_state)
	if state.turning or state.falling:
		pass
	else:
		if Input.is_action_just_pressed("jump"):
			jump()
		if state.jumping:
			print("proc jump")
			process_jump(delta)
		if turn_to:
			state.facing = new_moving_state
			state.turning = true
			state_machine.travel(turn_to)
		elif is_walking(new_moving_state):
			state.moving = "walking"
			state_machine.travel("walk-cycle")
		elif state.moving != "idle":
			state_machine.travel("idle")
			state.moving = "idle"
	
	var new_velocity = velocity
	if state.falling:
		new_velocity = velocity - velocity * 1.8 * delta
	elif is_walking(new_moving_state):
		new_velocity = velocity + ACCELERATION * input * delta
		if new_velocity.length_squared() > SPEED*SPEED:
			new_velocity = new_velocity.normalized() * SPEED
	elif velocity.length_squared() > EPSILON*4:
		new_velocity = velocity - ACCELERATION * 2 * velocity.normalized() * delta
	else:
		new_velocity = Vector2.ZERO
	velocity = move_and_slide(new_velocity, Vector2(1, 0))
	
func _process(delta):
	original_y = character.position.y
	character.position.y -= z

