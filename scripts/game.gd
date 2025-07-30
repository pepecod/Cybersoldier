extends Node2D

@export var escenas_enemigos: Array[PackedScene] = [
	preload("res://scenes/Enemigos/Volador/volador.tscn")
]
@export var max_enemigos: int = 10

@onready var jugador := get_node("TileMap/Jugador")
@onready var enemigos_node := get_node("TileMap/Enemigos")
@onready var spawn_timer := get_node("TileMap/SpawnTimer")
@onready var spawns := get_node("TileMap/Spawns")

func _ready():
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	if enemigos_node.get_child_count() >= max_enemigos:
		return

	if not jugador:
		return

	var escena_random = escenas_enemigos[randi() % escenas_enemigos.size()]
	var enemigo = escena_random.instantiate()

	# Elige un punto de spawn aleatorio
	var puntos = spawns.get_children()
	if puntos.is_empty():
		push_warning("No hay puntos de spawn")
		return

	var spawn_punto = puntos[randi() % puntos.size()]
	enemigo.global_position = spawn_punto.global_position

	enemigos_node.add_child(enemigo)
