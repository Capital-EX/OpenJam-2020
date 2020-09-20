extends Node2D
const ProtoAngel := preload("res://scenes/entities/ProtoAngel.tscn")

export(int) var spawn_count := 3
var angels := []


onready var RailNode := $RailCircle/Path2D

func _ready():
	$Timer.wait_time = 1.0/spawn_count
	
	var previous_angel =
	for i in range(spawn_count):
		var angel = ProtoAngel.instance()
		
		var offset := 0.0
		if i > 0:
			offset = angels[i - 1].PathFollowNode.unit_offset
			
		angels.append(angel)
		add_child(angel)
		proto_angel.set_path_2d(RailNode)
		proto_angel.PathFollowNode.unit_offset = 1.0/spawn_count + offset
		proto_angel.spawn()
		proto_angel.connect("killed", self, "_on_angel_killed")
		$Timer.start()
		yield($Timer, "timeout")

func _on_angel_killed(angel):
	

func _on_spawn_timeout():
	pass


