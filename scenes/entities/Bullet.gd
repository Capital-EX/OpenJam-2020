extends Area2D

var spawn_point: Vector2 = Vector2.ZERO
var target_point: Vector2 = Vector2.ZERO
var last_area: Object = null
var is_vanishing: bool = false


func _ready():
	position = spawn_point
	rotation = spawn_point.angle_to_point(target_point) + PI
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exit")
	$Tween.interpolate_property(self, "position", spawn_point, target_point, 5.0/60.0)
	$Tween.connect("tween_completed", self, "_check_hit", [true], CONNECT_ONESHOT)
	$Tween.interpolate_property(
		self, 
		"position", 
		target_point, 
		target_point + Vector2(cos(rotation), sin(rotation)) * 100, 
		5.0/60.0,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT,
		5.0/60.0
	)
	$Tween.interpolate_property(
		self, 
		"scale", 
		scale, 
		Vector2.ZERO, 
		5.0/60.0, 
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT,
		5.0/60.0
	)
	$Tween.connect("tween_all_completed", self, "queue_free")
	$Tween.start()


func _on_area_entered(area: Area2D) -> void:
	last_area = area

func _on_area_exit(area: Area2D) -> void:
	if last_area == area:
		last_area = null

func _check_hit(_a, _b, hit_point):
	if last_area != null and last_area.has_method("hurt"):
		last_area.hurt()
		queue_free()
	
