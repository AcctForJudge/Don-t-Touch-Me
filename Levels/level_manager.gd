extends Node2D

signal players_collided
signal game_ended

const EXPLOSION = preload("uid://dmy7i6rdgekcc")

@export var scenes: Array[PackedScene]

var curr_scene: Level
var curr_lvl := 0


func _ready() -> void:
	instantiate_scene(scenes[curr_lvl])


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reset"):
		reload_level()


func _on_players_collided() -> void:
	players_collided.emit()
	var target := curr_scene.get_mid_point()
	var e: AnimatedSprite2D = EXPLOSION.instantiate()
	e.global_position = target
	await get_tree().create_timer(0.2).timeout
	add_child(e)
	e.play("default")
	e.animation_finished.connect(reload_level)
	
func _on_level_completed() -> void:
	await get_tree().create_timer(0.5).timeout
	curr_scene.queue_free()
	await curr_scene.tree_exited
	curr_lvl += 1
	if curr_lvl < scenes.size():
		instantiate_scene(scenes[curr_lvl])
	else:
		game_ended.emit()

func reload_level() -> void:
	if curr_scene:
		curr_scene.queue_free()
		await curr_scene.tree_exited
	instantiate_scene(scenes[curr_lvl])


func instantiate_scene(scn: PackedScene) -> void:
	curr_scene = scn.instantiate()
	curr_scene.players_collided.connect(_on_players_collided)
	curr_scene.completed.connect(_on_level_completed)
	add_child(curr_scene)
