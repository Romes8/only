extends Node2D

const Tiles = preload("res://sprites/tileset.png")
const _Grass : PackedScene = preload("res://objects/surface_objects/Grass.tscn")

const TILE_SIZE : Vector2 = Vector2(8, 8)

onready var collision_shape = $CollisionShape2D

var radius : float = 63.0
var tiles : Array = [0]
var grass : Array = [0]

func spawn_grass() -> void:
	var circumference : float = radius * 2.0 * PI
	for i in range(0, circumference, 10.0):
		var angle : float = (i / circumference) * PI * 2.0
		var which_tile : int = (i / 8) % 4
		var which_type : int = grass[(i / 8) % grass.size()]
		var grass = _Grass.instance()
		var pos : Vector2 = Vector2.RIGHT.rotated(angle) * radius
		grass.position = pos
		grass.rotation = angle + (PI/2.0)
		add_child(grass)
		grass.set_tile(Vector2(which_tile, which_type))

func _draw() -> void:
	draw_circle(Vector2.ZERO, radius-5.0, Color.black)
	# Draw surface
	var circumference : float = radius * 2.0 * PI
	for i in range(0, circumference/8):
		var pos : float = i * 8.0
		var angle : float = (pos / circumference) * PI * 2.0
		var which_tile : Vector2 = Vector2(4 + (i % 4), tiles[i % tiles.size()])
		draw_set_transform(Vector2.RIGHT.rotated(angle) * radius, angle + (PI/2.0), Vector2.ONE)
		draw_texture_rect_region(Tiles, Rect2(Vector2(-4, -2), TILE_SIZE), Rect2(which_tile * TILE_SIZE, TILE_SIZE))

func _ready() -> void:
	randomize()
	collision_shape.shape.radius = radius
