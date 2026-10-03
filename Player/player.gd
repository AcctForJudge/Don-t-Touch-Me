class_name Player
extends Node2D

signal collided

@export var enemy: bool = false
@export var partner: Player
@export var colour: Color = Color.WHITE
var tile_size: int = 64
var inputs = {"right": Vector2.RIGHT, "left": Vector2.LEFT,
			  "up": Vector2.UP, "down": Vector2.DOWN}
var moving: bool = false
@onready var ray: RayCast2D = $RayCast2D
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready():
	snap()
	sprite_2d.modulate = colour

func _unhandled_input(event):
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
	if not ray.is_colliding():
		return 0
	return floori((ray.get_collision_point() - global_position).dot(d) / tile_size)

func step(dir: String):
	var d1: Vector2 = inputs[dir]
	var d2 := Vector2(-d1.x, d1.y)  # enemy mirrors left/right only
	var m1 := wall_moves(d1)
	var m2 := partner.wall_moves(d2)
	moving = true
	var rel := partner.position - position
	if absf(rel.cross(d1)) < 1.0:  # same row/column
		var n := roundi(rel.dot(d1) / tile_size)  # signed tiles from me to partner along d1
		if d1.x != 0:  # opposite directions
			if n > 0:  # converging
				var free := n - 1
				var a := mini(m1, ceili(free / 2.0))
				var b := mini(m2, free - a)
				m1 = mini(m1, free - b)
				m2 = b
				if not enemy:
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
	
func snap():
	position = position.snapped(Vector2.ONE * tile_size) + Vector2.ONE * tile_size / 2
