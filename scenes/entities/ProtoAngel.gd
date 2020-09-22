extends Area2D
class_name ProtoAngel

signal shot(object)
signal killed(object)
signal prep_completed(object)
signal attack_started(object)
signal attack_completed(object)

const HitParticles := preload("res://scenes/entities/HitParticles.tscn")
const DeathParticles := preload("res://scenes/entities/DeathParticles.tscn")
const SPAWN_SPEED = 15 / 60.0
const PREP_SPEED = 6 / 60.0
const PULL_BACK_WAIT = 7.5 / 60.0
const PULL_BACK_SPEED = 7.5 / 60.0
const ATTACK_DELAY = 7.5 / 60.0
const ATTACK_SPEED = 15 / 60.0
const REHOME_SPEED = 15.0 / 60.0

enum State { Spawning, Idling, Prepping, Attacking, Rehoming }

var state : int = State.Spawning
var PathFollowNode := PathFollow2D.new()
var Path2DNode : Path2D = null
var health : int = 4
var interpolate_progress : float = 0.0
var original_color : Color = modulate
var player

onready var ShakeNode = $Sprite/Shake
onready var BlinkNode = $Blink
onready var PulseNode = $Pulse
onready var screen_center = get_viewport_rect().size / 2

func _ready():
	connect("area_entered", self, "_on_area_entered")

func _on_area_entered(area: Area2D):
	if area.name == "Player" and state == State.Attacking:
		area.hurt()

func _physics_process(delta):
	PathFollowNode.unit_offset += delta * 0.3
	match state:
		State.Spawning:
			spawning(delta)
		State.Idling:
			idling(delta)
		State.Prepping:
			prepping(delta)
		State.Attacking:
			attacking(delta)
		State.Rehoming:
			rehoming(delta)

func set_path_2d(path_2d: Path2D):
	Path2DNode = path_2d
	Path2DNode.add_child(PathFollowNode)
	
func spawning(delta):
	interpolate_progress += 1.0 / SPAWN_SPEED * delta
	global_position = lerp(screen_center, PathFollowNode.global_position, interpolate_progress)
	if interpolate_progress >= 1:
		change_state(State.Idling)

func idling(delta):
	global_position = PathFollowNode.global_position

func prepping(delta):
	interpolate_progress += 1.0 / PREP_SPEED * delta
	interpolate_progress = min(1.0, interpolate_progress)
	global_position = lerp(PathFollowNode.global_position, screen_center, interpolate_progress)
	if interpolate_progress >= 1:
		emit_signal("prep_completed", self)

func attacking(delta):
	pass


func rehoming(delta):
	interpolate_progress += 1.0 / REHOME_SPEED * delta
	global_position = lerp(global_position, PathFollowNode.global_position, interpolate_progress)
	if interpolate_progress >= 1:
		change_state(State.Idling)

func prep(target_position: Vector2):
	self.raise()
	change_state(State.Prepping)
	
func attack(target_position: Vector2):
	change_state(State.Attacking)
	var angle = position.angle_to_point(target_position)
	var pull_back_position = 100 * Vector2(cos(angle), sin(angle))
	$Tween.interpolate_property(
		self, "position", 
		position, position + pull_back_position, 
		PULL_BACK_SPEED, Tween.TRANS_CUBIC, Tween.EASE_OUT, PULL_BACK_WAIT
	)
	$Tween.connect("tween_all_completed", self, "lunge", [target_position], CONNECT_ONESHOT)
	$Tween.start()
	
func lunge(target_position: Vector2):
	$Tween.interpolate_property(
		self, "position", 
		position, target_position, 
		ATTACK_SPEED, Tween.TRANS_CUBIC, Tween.EASE_OUT, ATTACK_DELAY
	)
	$CollisionShape2D.disabled = false
	$Tween.connect("tween_started", self, "_on_strike_started", [], CONNECT_ONESHOT)
	$Tween.connect("tween_all_completed", self, "_on_strike_completed", [], CONNECT_ONESHOT)
	$Tween.start()

func _on_strike_started(_a, _b):
	emit_signal("attack_started", self)

func _on_strike_completed():
	emit_signal("attack_completed", self)
	change_state(State.Rehoming)



func hurt():
	var particle = HitParticles.instance()
	shake(ShakeNode, $Sprite, -10, 10, $Sprite.position, Vector2.ZERO)
	add_child(particle)
	particle.position = get_local_mouse_position()
	BlinkNode.play("blink")
	
	health -= 1
	if health <= 0:
		var death_particles := DeathParticles.instance()
		get_tree().root.add_child(death_particles)
		death_particles.position = self.global_position
		emit_signal("killed", self)

func shake(tween: Tween, target: Node2D,
		lower: float, upper: float, 
		start_position: Vector2, end_position: Vector2, 
		shake_rate: float = 0.05, shakes = 4) -> void:
	
	tween.stop_all()
	var shake_pos = Vector2(rand_range(lower, upper), rand_range(lower, upper))
	for i in range(shakes):
		tween.interpolate_property(
			target, "position", 
			start_position, shake_pos, shake_rate, 
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, i * shake_rate
		)
		start_position = shake_pos
		shake_pos = Vector2(rand_range(lower, upper), rand_range(lower, upper))
	
	tween.interpolate_property(
		target, "position", 
		shake_pos, end_position, shake_rate, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, shakes * shake_rate
	)
	tween.start()
	

func spawn():
	scale = Vector2.ZERO
	$Tween.interpolate_property(
		self, "scale", 
		Vector2.ZERO, Vector2(1,1), 
		SPAWN_SPEED, Tween.TRANS_BOUNCE, Tween.EASE_OUT
	)
	$Tween.start()
	
	state = State.Spawning

func start_pulse():
	PulseNode.play("agro-pulse")
	
func stop_pulse():
	PulseNode.stop()

func change_state(new_state: int):
	state = new_state
	interpolate_progress = 0.0
			
	

