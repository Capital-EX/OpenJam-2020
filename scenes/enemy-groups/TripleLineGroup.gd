extends Node2D
signal wave_completed
signal next_attack_step(skip)
signal angel_killed()

const RAIL_PATTERNS = [
	[0, 1, 2]
]

var angels: int
var PlayerNode
var spawn_sequence := []
var attacker = null

onready var RailNode := $Rail/Path2D
onready var SpawnTimerNode := $SpawnTimer
onready var AttackTimerNode := $AttackTimer

func _ready():
	angels = len(spawn_sequence)
	SpawnTimerNode.wait_time = 1.0/angels
	
	var previous_angel = null
	var angels_per_rail = angels / 3
	var remander = angels % 3
	var current_rail = 0
	var rails = $Rail.get_children()
	var n = 0
	for i in range(angels - remander):
		n = i
		var id = spawn_sequence[i]
		var angel = Angels.AngelScenes[id].instance()
		
		var offset := 0.0
		if previous_angel:
			offset = previous_angel.PathFollowNode.unit_offset
		
		add_child(angel)
		angel.set_path_2d(rails[current_rail])
		
		angel.PathFollowNode.unit_offset = 1.0/angels + offset
		angel.spawn()
		angel.connect("killed", self, "_on_angel_killed")
		SpawnTimerNode.start()
		current_rail += 1
		current_rail %= len(rails)
		yield(SpawnTimerNode, "timeout")
		previous_angel = angel
	
	# Please forgive my copy and paste
	match remander:
		1:
			n += 1
			var id = spawn_sequence[n]
			var angel = Angels.AngelScenes[id].instance()
			var offset := 0.0
			if previous_angel:
				offset = previous_angel.PathFollowNode.unit_offset
			
			add_child(angel)
			angel.set_path_2d(rails[1])
			
			angel.PathFollowNode.unit_offset = 1.0/angels + offset
			angel.spawn()
			angel.connect("killed", self, "_on_angel_killed")
			SpawnTimerNode.start()
			current_rail += 1
			current_rail %= len(rails)
			yield(SpawnTimerNode, "timeout")
			previous_angel = angel
			
		2:
			n += 1
			var id = spawn_sequence[n]
			var angel = Angels.AngelScenes[id].instance()
			var offset := 0.0
			if previous_angel:
				offset = previous_angel.PathFollowNode.unit_offset
			
			add_child(angel)
			angel.set_path_2d(rails[current_rail])
			
			angel.PathFollowNode.unit_offset = 1.0/angels + offset
			angel.spawn()
			angel.connect("killed", self, "_on_angel_killed")
			SpawnTimerNode.start()
			yield(SpawnTimerNode, "timeout")
			previous_angel = angel
			
			n += 1
			id = spawn_sequence[n]
			angel = Angels.AngelScenes[id].instance()
			offset = 0.0
			if previous_angel:
				offset = previous_angel.PathFollowNode.unit_offset
			
			add_child(angel)
			angel.set_path_2d(rails[2])
			
			angel.PathFollowNode.unit_offset = 1.0/angels + offset
			angel.spawn()
			angel.connect("killed", self, "_on_angel_killed")
			SpawnTimerNode.start()
			yield(SpawnTimerNode, "timeout")
			previous_angel = angel
			
	AttackTimerNode.connect("timeout", self, "_on_attack_timer_timeout")
	AttackTimerNode.start()


func _on_attack_timer_timeout():
	var angel_list = get_tree().get_nodes_in_group("Angels")
	print(angel_list)
	if len(angel_list) <= 0:
		return
	
	for angel in angel_list:
		angel.modulate = Color(0.457031, 0.457031, 0.457031)
	angel_list.shuffle()
	
	var attacks = randi() % len(angel_list) + 1
	for i in range(attacks):
		attacker = angel_list.pop_front()
		if attacker == null or attacker.state != 1:
			for _j in range(len(angel_list)):
				angel_list.append(attacker)
				attacker = angel_list.pop_front()
				if attacker != null and attacker.state == 1:
					break
			if attacker == null or attacker.state != 1:
				break
		attacker.connect("prep_completed", self, "_on_prep_completed", [], CONNECT_ONESHOT)
		if attacker is ProtoAngel:
			attacker.connect("attack_started", self, "_on_attack_started", [], CONNECT_ONESHOT)
		else:
			attacker.connect("attack_completed", self, "_on_attack_completed", [], CONNECT_ONESHOT)
		attacker.start_pulse()
		attacker.prep(PlayerNode.position)
		if yield(self, "next_attack_step"):
			continue
		
		if attacker == null:
			continue
			
		attacker.attack(PlayerNode.position)
		if yield(self, "next_attack_step"):
			continue
		
		if attacker == null:
			continue
		
		attacker.stop_pulse()
		attacker.modulate = Color(0.457031, 0.457031, 0.457031)
		attacker = null
	
	angel_list = get_tree().get_nodes_in_group("Angels")
	for angel in angel_list:
		angel.stop_pulse()
		angel.modulate = Color(1,1,1)
	
	print("Timer started?")
	if attacks > 5:
		AttackTimerNode.wait_time = rand_range(1, 2)
	elif attacks > 2:
		AttackTimerNode.wait_time = rand_range(0.5, 1.5)
	else:
		AttackTimerNode.wait_time = rand_range(0.2, 0.5)
	AttackTimerNode.start()

func _on_prep_completed(angle):
	emit_signal("next_attack_step", false)

func _on_attack_completed(angle):
	emit_signal("next_attack_step", false)

func _on_attack_started(angel):
	emit_signal("next_attack_step", false)

func _on_attack_interupted(angel):
	emit_signal("next_attack_step", true)

func _on_angel_killed(angel):
	angels -= 1
	emit_signal("angel_killed")
	if angel == attacker:
		emit_signal("next_attack_step", true)
		
	if angels <= 0:
		emit_signal("wave_completed")
		queue_free()
		
	angel.queue_free()
	

func _on_spawn_timeout():
	pass
