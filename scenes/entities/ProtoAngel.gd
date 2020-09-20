extends Area2D
signal shot(object)
signal killed(object)
const HitParticles := preload("res://scenes/entities/HitParticles.tscn")
const DeathParticles := preload("res://scenes/entities/DeathParticles.tscn")

enum State { Spawning, Idling, Attacking }

var state : int = State.Spawning
var PathFollowNode := PathFollow2D.new()
var Path2DNode : Path2D
var health : int = 4

func _ready():
	pass


func _physics_process(delta):
	match state:
		State.Idling:
			idling(delta)
		State.Attacking:
			pass

func set_path_2d(path_2d: Path2D):
	Path2DNode = path_2d
	Path2DNode.add_child(PathFollowNode)
	

func idling(delta):
	PathFollowNode.unit_offset += delta * 0.3
	global_position = PathFollowNode.global_position
	

func hurt():
	var particle = HitParticles.instance()
	shake($Shake, $Sprite, -10, 10, $Sprite.position, Vector2.ZERO)
	add_child(particle)
	particle.position = get_local_mouse_position()
	$AnimationPlayer.play("blink")
	
	health -= 1
	if health <= 0:
		var death_particles := DeathParticles.instance()
		get_tree().root.add_child(death_particles)
		death_particles.position = self.global_position
		emit_signal("died", self)
		queue_free()

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
	# PathFollowNode.unit_offset = randf()
	$Tween.interpolate_property(self, "scale", Vector2.ZERO, Vector2(1,1), 0.5, Tween.TRANS_BOUNCE, Tween.EASE_OUT, 0.5)
	$Tween.interpolate_property(self, "position", get_viewport_rect().size / 2, PathFollowNode.position, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.5)
	state = State.Idling
	$Tween.start()

func change_state(new_state: int):

	state = new_state
	
func attacking():
	pass

