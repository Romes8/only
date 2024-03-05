extends Node2D

const _SpikeFloor : PackedScene = preload("res://objects/surface_objects/SpikeFloor.tscn")

var spike_altitude : float
var number_of_spikes : int

var planet : Node2D

func make_ring() -> void:
	for i in range(0, number_of_spikes):
		var angle : float = (float(i) / float(number_of_spikes)) * PI * 2.0
		var spike : Node2D = _SpikeFloor.instance()
		spike.position = Vector2.RIGHT.rotated(angle) * (planet.radius + spike_altitude)
		spike.rotation = angle
		planet.add_child(spike)

func _ready() -> void:
	make_ring()
