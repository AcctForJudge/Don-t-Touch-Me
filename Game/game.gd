class_name Game
extends Node2D
@onready var start: Control = $CanvasLayer/Start
@onready var end: Control = $CanvasLayer/End

var started = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_level_manager_players_collided() -> void:
	pass


func _on_start_start() -> void:
	start.queue_free()
	started = true
	


func _on_level_manager_game_ended() -> void:
	end.show()
	$AudioStreamPlayer.play()
