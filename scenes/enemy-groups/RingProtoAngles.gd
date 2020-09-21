extends Node2D
signal wave_completed
signal next_attack_step(skip)

var angels
var PlayerNode
var spawn_sequence := []

onready var RailNode := $RailCircle/Path2D
onready var SpawnTimerNode := $SpawnTimer
onready var AttackTimerNode := $AttackTimer

func _ready():
	angels = len(spawn_sequence)
	SpawnTimerNode.wait_time = 1.0/angels
	
	var previous_angel = null
	for id in spawn_sequence:
		var angel = Angels.AngelScenes[id].instance()
		
		var offset := 0.0
		if previous_angel:
			offset = previous_angel.PathFollowNode.unit_offset
		
		add_child(angel)
		angel.set_path_2d(RailNode)
		angel.PathFollowNode.unit_offset = 1.0/angels + offset
		angel.spawn()
		angel.connect("killed", self, "_on_angel_killed")
		SpawnTimerNode.start()
		yield(SpawnTimerNode, "timeout")
		previous_angel = angel
	AttackTimerNode.connect("timeout", self, "_on_attack_timer_timeout")
	AttackTimerNode.start()


func _on_attack_timer_timeout():
	print("attacking")
	var angel_list = get_tree().get_nodes_in_group("Angels")
	for angel in angel_list:
		angel.modulate = Color(0.765625, 0.765625, 0.765625)
	angel_list.shuffle()
	var attacks = 5 # randi() % int(ceil(angels/2.0)) + 1.0
	for i in range(attacks):
		var attacker = angel_list.pop_front()
		if attacker == null:
			continue
		attacker.connect("prep_completed", self, "_on_prep_completed", [], CONNECT_ONESHOT)
		attacker.connect("attack_completed", self, "_on_attack_completed", [], CONNECT_ONESHOT)
		attacker.connect("killed", self, "_on_attack_interupted", [], CONNECT_ONESHOT)
		attacker.start_pulse()
		attacker.prep(PlayerNode.position)
		if yield(self, "next_attack_step"):
			continue
			
		attacker.attack(PlayerNode.position)
		if yield(self, "next_attack_step"):
			continue
		
		attacker.stop_pulse()
		attacker.modulate = Color(0.765625, 0.765625, 0.765625)
		angel_list.append(attacker)
	

	for angel in angel_list:
		angel.modulate = Color(1,1,1)

func _on_prep_completed(angle):
	emit_signal("next_attack_step", false)

func _on_attack_completed(angle):
	emit_signal("next_attack_step", false)

func _on_attack_interupted(angel):
	emit_signal("next_attack_step", true)

func _on_angel_killed(angel):
	angels -= 1
	if angels <= 0:
		emit_signal("wave_completed")
	angel.queue_free()
	

func _on_spawn_timeout():
	pass


