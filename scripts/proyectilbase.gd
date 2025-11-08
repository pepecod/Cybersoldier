extends Area2D
class_name ProyectilDron

@export var velocidad: float = 500.0
@export var daño: float = 10.0
@export var tiempo_vida: float = 2.0

var direccion: Vector2 = Vector2.RIGHT
var creador: Node = null

func _ready():
	$TiempoVida.start(tiempo_vida)
	set_physics_process(true)

func setup(config: Dictionary):
	if "posicion" in config:
		global_position = config["posicion"]
	if "direccion" in config:
		direccion = config["direccion"].normalized()
	if "velocidad" in config:
		velocidad = config["velocidad"]
	if "daño" in config:
		daño = config["daño"]
	if "creador" in config:
		creador = config["creador"]

	rotation = direccion.angle()

func _physics_process(delta):
	position += direccion * velocidad * delta

func _on_Timer_timeout():
	queue_free()

func get_daño() -> float:
	return daño
	
func destruir():
	print("destruyendo")
	# Efectos opcionales antes de eliminar (partículas, sonido, etc)
	queue_free()
