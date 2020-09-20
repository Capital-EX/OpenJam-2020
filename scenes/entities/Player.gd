extends Node2D
signal shoot(bullet)

const BulletScene := preload("res://scenes/entities/Bullet.tscn")

enum Verticle { Up, Down }
const VerticleName := ["up", "down"]

enum Horizontal { Left, Right }
const HorizontalName := ["left", "right"]

enum State { Low, High, HighDodge, Dropping }

const MAX_HOVER_TIME : float = 20.0 / 60.0
const DASH_SPEED : float = 0.2
const LEFT := 42
const RIGHT := 566

var h_state : int = Horizontal.Left
var v_state : int = Verticle.Down
var state : int = State.Low
var health : int = 5

func _ready():
	position = Vector2(42, 250)
	pass


func _process(delta):
	if Input.is_action_pressed("move_left") and not $Tween.is_active() and h_state == Horizontal.Right:
		$Tween.interpolate_property(self, "position:x", RIGHT, LEFT, DASH_SPEED, Tween.TRANS_EXPO,Tween.EASE_IN_OUT)
		$Tween.start()
		h_state = Horizontal.Left
		$AnimationPlayer.play("%s-%s" % [VerticleName[v_state], HorizontalName[h_state]])
	
		
	elif Input.is_action_pressed("move_right") and not $Tween.is_active() and h_state == Horizontal.Left:
		$Tween.interpolate_property(self, "position:x", LEFT, RIGHT, DASH_SPEED, Tween.TRANS_EXPO,Tween.EASE_IN_OUT)
		$Tween.start()
		h_state = Horizontal.Right
		$AnimationPlayer.play("%s-%s" % [VerticleName[v_state], HorizontalName[h_state]])
		
		
		
	elif Input.is_action_pressed("move_up") and not $Tween.is_active() and v_state == Verticle.Down:
		$Tween.interpolate_property(self, "position:y", 250, 54, DASH_SPEED / 2, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
		$Tween.start()
		v_state = Verticle.Up
		$AnimationPlayer.play("%s-%s" % [VerticleName[v_state], HorizontalName[h_state]])
	
	elif Input.is_action_pressed("move_down") and not $Tween.is_active() and v_state == Verticle.Up:
		$Tween.interpolate_property(self, "position:y", 54, 250, DASH_SPEED / 2, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
		$Tween.start()
		v_state = Verticle.Down
		$AnimationPlayer.play("%s-%s" % [VerticleName[v_state], HorizontalName[h_state]])
	
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.is_pressed():
			var bullet = BulletScene.instance()
			bullet.spawn_point = $PlayerSprite/GunShotSprite.global_position
			bullet.target_point = get_global_mouse_position()
			emit_signal("shoot", bullet)
			
			$GunShotAnimation.play("gun-shot-%s-%s" % [VerticleName[v_state], HorizontalName[h_state]])
