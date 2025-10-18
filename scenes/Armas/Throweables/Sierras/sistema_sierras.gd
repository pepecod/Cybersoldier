extends Node2D

@export var sierra_scene: PackedScene
@export var nivel_inicial: int = 1

var nivel_actual: int = 1
var sierras: Array = []

func _ready() -> void:
	print("🔧 SistemaSierras _ready() iniciado")
	
	if not sierra_scene:
		print("❌ ERROR: sierra_scene no está asignada!")
		return
	
	print("✅ Sierra scene asignada: ", sierra_scene.resource_path)
	
	nivel_actual = nivel_inicial
	crear_sierras(nivel_actual)
	
	print("🎯 Sistema de sierras activo")

func crear_sierras(nivel: int) -> void:
	destruir_sierras()
	
	var cantidad = nivel * 2
	print("🔄 Creando ", cantidad, " sierras...")
	
	for i in cantidad:
		var sierra = sierra_scene.instantiate()
		
		# Añadir como hijo de ESTE nodo (que es hijo del PassiveHolder)
		add_child(sierra)
		
		# Asignar ángulo inicial para distribuirlas uniformemente
		var angulo_inicial = (TAU / cantidad) * i
		sierra.angulo = angulo_inicial
		
		sierras.append(sierra)
		print("🪚 Sierra ", i + 1, " creada con ángulo: ", angulo_inicial)

func destruir_sierras() -> void:
	for sierra in sierras:
		if is_instance_valid(sierra):
			sierra.queue_free()
	sierras.clear()

func subir_nivel() -> void:
	nivel_actual += 1
	crear_sierras(nivel_actual)

func _exit_tree() -> void:
	destruir_sierras()
