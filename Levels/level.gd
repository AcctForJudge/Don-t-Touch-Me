class_name Level
extends Node2D

signal players_collided
signal completed 

@export var p1: Player
@export var p2: Player

var players_completed := 0
var p1_c = false
var p2_c = false
var mid_point := Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_player_1_collided() -> void:
	players_collided.emit()
	

func _on_player_1_completed() -> void:
	p1_c = true
	check_completed()
	
func _on_player_2_completed() -> void:
	p2_c = true
	check_completed()
	
func check_completed():
	if p1_c and p2_c:
		completed.emit()
		
func get_mid_point() -> Vector2:
	return (p1.global_position + p2.global_position) / 2.0
