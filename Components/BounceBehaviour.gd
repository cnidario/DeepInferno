extends Node
class_name BounceBehaviour

onready var animation_player = $AnimationPlayer

export (NodePath) var target = NodePath("ColorRect")
export (String) var property = "position:x"

var status = "end"
var anim
var node_path
var full_path
var initial_value
var track_index
var keys = []

func removeTrack(tidx):
	anim.remove_track(tidx)
func createTrack():
	initial_value = get_node(node_path).get_indexed(property)
	var tidx = anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(tidx, full_path)
	anim.track_insert_key(tidx, 0.0, initial_value)
	anim.track_insert_key(tidx, 0.5, initial_value - 100)
	return tidx
	
func _ready():
	var target_node = get_node(target)
	anim = animation_player.get_animation("bounce")
	node_path = str(target_node.get_path())
	full_path = node_path + ":" + property

func bounce():
	if status == "end":
		if track_index != null:
			removeTrack(track_index)
		track_index = createTrack()
		status = "start"
		animation_player.play("bounce")
	
func bounce_started():
	print("bounce started")
	pass
func bounce_finished():
	status = "end"
