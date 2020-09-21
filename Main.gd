extends Node2D
const RingGroup := preload("res://scenes/enemy-groups/RingGroup.tscn")
const AMMO_FORMAT := "Ammo %d/%d"
const HEALTH_FORMAT := "HEALTH %d/%d"

var spawning := 10
var max_ammo := 5
var max_health := 5

onready var PlayerNode := $Player
onready var HealthLabel := $CanvasLayer/Container/Hud/HealthContainer/HealthLabel
onready var HealthBar := $CanvasLayer/Container/Hud/HealthContainer/HealthBar

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	PlayerNode.connect("shoot", self, "_on_shoot")
	$Timer.connect("timeout", self, "_on_timer_timeout", [], CONNECT_ONESHOT)
	$Timer.start()
	HealthLabel.text = HEALTH_FORMAT % [PlayerNode.health, max_health]

func _on_timer_timeout():
	var enemies := RingGroup.instance()
	enemies.PlayerNode = PlayerNode
	enemies.spawn_sequence = [
		Angels.ProtoAngel,
		Angels.ProtoAngel,
		Angels.ProtoAngel,
		Angels.ProtoAngel,
		Angels.ProtoAngel,
	]
	add_child(enemies)

func _on_shoot(bullet):
	add_child(bullet)

func _process(delta):
	$CrossHair.position = get_local_mouse_position()

func _on_angel_shot():
	pass
