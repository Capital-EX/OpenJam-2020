extends Node2D
const RingGroup := preload("res://scenes/enemy-groups/RingGroup.tscn")
const EightGroup := preload("res://scenes/enemy-groups/EightGroup.tscn")
const TripleLineGroup := preload("res://scenes/enemy-groups/TripleLineGroup.tscn")

const AMMO_FORMAT := "Ammo %d/%d"
const HEALTH_FORMAT := "HEALTH %d/%d"

var spawning := 10
var angels_killed := 0
var max_ammo := 5
var max_health := 5
var current_pattern := 0
var patterns = [
	RingGroup,
	EightGroup,
	TripleLineGroup,
]
var pattern_queue := [
	0, 0, 0,
	1, 1, 1,
	2, 2, 2
]

var lower := 3
var upper := 5
var enemies

onready var PlayerNode := $Player
onready var HealthLabel := $CanvasLayer/Container/Hud/HealthContainer/HealthLabel
onready var HealthBar := $CanvasLayer/Container/Hud/HealthContainer/HealthBar
onready var HealthBarTween := $CanvasLayer/Container/Hud/HealthContainer/HealthBar/HealthBarTween

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	randomize()
	pattern_queue.shuffle()
	$AnimationPlayer.play("fade-in")
	yield($AnimationPlayer, "animation_finished")
	
	$Player/AnimationPlayer.play("intro")
	HealthBarTween.interpolate_property(
		HealthBar, "value", 
		0, PlayerNode.health, $Player/AnimationPlayer.current_animation_length
	)
	HealthBarTween.start()
	HealthLabel.text = HEALTH_FORMAT % [PlayerNode.health, max_health]
	yield($Player/AnimationPlayer, "animation_finished")
	
	PlayerNode.connect("shot", self, "_on_player_shot")
	PlayerNode.connect("struck", self, "_on_player_struck")
	$Timer.start()
	yield($Timer, "timeout")
	
	enemies = patterns[pattern_queue[current_pattern]].instance()
	current_pattern += 1
	if current_pattern >= len(patterns) - 1:
		current_pattern = 0
		pattern_queue.shuffle()
	enemies.PlayerNode = PlayerNode
	
	var spawn = []
	for i in range(randi() % (upper - lower) + lower):
		match randi() % 3:
			0:
				spawn.append(Angels.ProtoAngel)
			1:
				spawn.append(Angels.RotoAngel)
			2:
				spawn.append(Angels.SpikerAngel)
	enemies.spawn_sequence = spawn
	enemies.connect("wave_completed", self, "_on_wave_completed")
	enemies.connect("angel_killed", self, "_on_angel_killed")
	add_child(enemies)
	

func _on_wave_completed():
	enemies = patterns[pattern_queue[current_pattern]].instance()
	current_pattern += 1
	if current_pattern >= len(patterns) - 1:
		current_pattern = 0
		pattern_queue.shuffle()
	enemies.PlayerNode = PlayerNode
	
	var spawn = []
	for i in range(randi() % (upper - lower) + lower):
		match randi() % 3:
			0:
				spawn.append(Angels.ProtoAngel)
			1:
				spawn.append(Angels.RotoAngel)
			2:
				spawn.append(Angels.SpikerAngel)
	enemies.spawn_sequence = spawn
	enemies.connect("wave_completed", self, "_on_wave_completed")
	enemies.connect("angel_killed", self, "_on_angel_killed")
	add_child(enemies)

func _on_angel_killed():
	angels_killed += 1
	

func _on_timer_timeout():
	pass

func _on_player_shot(bullet):
	add_child(bullet)

func _on_player_struck(health):
	HealthLabel.text = HEALTH_FORMAT % [health, max_health]
	HealthBar.value = health
	if health <= 0:
		if enemies:
			enemies.AttackTimerNode.stop()
		PlayerNode.die()
		yield(PlayerNode,"death_sequence_completed")
		$AnimationPlayer.play_backwards("fade-in")
		yield($AnimationPlayer, "animation_finished")
		Scoreboard.score = angels_killed
		get_tree().change_scene("res://scenes/menus/GameOverScreen.tscn")
		
func _process(delta):
	$CrossHair.position = get_local_mouse_position()

func _on_angel_shot():
	pass
