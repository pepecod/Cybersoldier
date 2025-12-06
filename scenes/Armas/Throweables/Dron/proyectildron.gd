extends ProyectilBase
class_name ProyectilDron

@export var tiempo_vida: float = 2.0

func _ready():
	# Iniciar timer de vida
	if has_node("TiempoVida"):
		$TiempoVida.start(tiempo_vida)
	
	# Llamar al _ready del padre
	super._ready()

func setup(config: Dictionary):
	if "posicion" in config:
		global_position = config["posicion"]
	
	if "direccion" in config:
		direccion = config["direccion"].normalized()
		rotation = direccion.angle()
	
	if "velocidad" in config:
		speed = config["velocidad"]  # ← Usa speed (del padre)
	elif "velocidad_adicional" in config:
		speed = 500.0 + config["velocidad_adicional"]  # ← Usa speed + valor base
	
	if "daño" in config:
		daño = config["daño"]
	
	if "creador" in config:
		creador = config["creador"]
