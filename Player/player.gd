@tool
class_name Player
extends Node2D

signal collided
signal completed

const ENEMY = preload("uid://bjgvb6d304oc0")
const PLAYER = preload("uid://co6xuuetol8fv")
const MOVE = preload("uid://cpeu6cd0yy42l")

@export var enemy: bool = false
@export var partner: Player
@export var goal: Checkpoint


var tile_size: int = 64
var inputs = {"right": Vector2.RIGHT, "left": Vector2.LEFT,
			  "up": Vector2.UP, "down": Vector2.DOWN}
var moving: bool = false
var complete := false
var game: Game
@onready var ray: RayCast2D = $RayCast2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	sprite_2d.texture = ENEMY if enemy else PLAYER
	snap()
	game = get_parent().get_parent().get_parent()

func _unhandled_input(event):
	if not game.started:
		return
	if moving:
		return
	if enemy:
		return  # only the main player handles input and drives both
	for dir in inputs.keys():
		if event.is_action_pressed(dir):
			step(dir)

# tiles this player can travel in d before hitting a wall
func wall_moves(d: Vector2) -> int:
	ray.target_position = d * tile_size * 1000
	ray.force_raycast_update()
	if not ray.is_colliding() or complete:
		return 0
	var m := floori((ray.get_collision_point() - global_position).dot(d) / tile_size)
	if goal:
		var rel := goal.global_position - global_position
		if absf(rel.cross(d)) < 1.0 and rel.dot(d) > 0:  # goal is ahead on this line
			m = mini(m, roundi(rel.dot(d) / tile_size))
	return m

func step(dir: String):
	var d1: Vector2 = inputs[dir]
	var d2 := Vector2(-d1.x, d1.y)  # enemy mirrors left/right only
	var m1 := wall_moves(d1)
	var m2 := partner.wall_moves(d2)
	moving = true
	var rel := partner.position - position
	if absf(rel.cross(d1)) < 1.0:  # same row/column
		var n := roundi(rel.dot(d1) / tile_size)  # signed tiles from me to partner along d1
		if n > 0:  # converging
			var free := n - 1
			var met := m1 + m2 >= free  # no wall stops them before they meet
			var a := mini(m1, ceili(free / 2.0))
			var b := mini(m2, free - a)
			m1 = mini(m1, free - b)
			m2 = b
			if met and not enemy:
				collided.emit()
		else:  # same direction: follower stops behind leader
			if n > 0:
				m1 = mini(m1, m2 + n - 1)
			elif n < 0:
				m2 = mini(m2, m1 - n - 1)

	tween_to(position + d1 * m1 * tile_size)
	partner.tween_to(partner.position + d2 * m2 * tile_size)

func tween_to(pos: Vector2):
	await create_tween().tween_property(self, "position", pos, 0.25).finished
	moving = false
	play(MOVE)
	if goal and position.is_equal_approx(goal.global_position):
		complete = true
		completed.emit()

func snap():
	position = position.snapped(Vector2.ONE * tile_size) + Vector2.ONE * tile_size / 2

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area == goal:
		complete = true
		completed.emit()

func play(sound):
	audio_stream_player.stream = sound
	audio_stream_player.play()
