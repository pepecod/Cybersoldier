extends Node2D

@export var mina_scene: PackedScene
@export var cantidad_por_oleada: int = 2
@export var radio_spawn: float = 100.0
@export var intervalo_spawn: float = 5.0

var jugador: CharacterBody2D
var timer: Timer

func _ready() -> void:
	print("🔧 Lanzaminas _ready() iniciado")
	
	# Buscar jugador
	jugador = get_parent().get_parent()
	print("🔧 Jugador encontrado: ", jugador)
	
	# Verificar que tenemos la escena
	if not mina_scene:
		print("❌ ERROR: mina_scene no está asignada!")
		return
	
	print("✅ Mina scene asignada: ", mina_scene.resource_path)
	
	# Timer
	timer = Timer.new()
	timer.wait_time = intervalo_spawn
	timer.timeout.connect(spawnear_grupo)
	add_child(timer)
	timer.start()
	
	# Spawn inmediato
	spawnear_grupo()
	print("🎯 Sistema de minas activo")

func spawnear_grupo() -> void:
	print("🔄 Spawneando grupo de minas...")
	for i in cantidad_por_oleada:
		spawnear_mina()

func spawnear_mina() -> void:
	if not mina_scene:
		print("❌ No hay mina_scene")
		return
	
	print("💣 Intentando spawnear mina...")
	var mina = mina_scene.instantiate()
	
	var angulo = randf() * TAU
	var distancia = radio_spawn
	var offset = Vector2(cos(angulo), sin(angulo)) * distancia
	
	get_tree().current_scene.add_child(mina)
	mina.global_position = jugador.global_position + offset
	
	print("💣 Mina spawneada en: ", mina.global_position)
