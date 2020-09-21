extends Control
const MainScene := preload("res://Main.tscn")

onready var main_scene = MainScene.instance()

func _ready():
	 $CenterContainer/HBoxContainer/Play.connect("pressed", self, "_on_play_pressed")

func _on_play_pressed():
	$AnimationPlayer.play("take-flight")
	$AnimationPlayer.connect("animation_finished", self, "_on_animation_finished")
	
func _on_animation_finished(_anim_name: String):
	get_tree().change_scene_to(MainScene)
	queue_free()
