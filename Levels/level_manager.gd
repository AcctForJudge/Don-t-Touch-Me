@tool
extends Node2D

signal players_collided

@export var scene: PackedScene

var scenes: Array[PackedScene] = []

var curr_scene: Level
var curr_lvl := 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instantiate_scene(scene)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_players_collided():
	players_collided.emit()

func instantiate_scene(scn: PackedScene):
	curr_scene = scene.instantiate()
	curr_scene.players_collided.connect(_on_players_collided)
	add_child(curr_scene)	
