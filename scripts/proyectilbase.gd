extends Area2D
class_name ProyectilBase

signal destruido()

@export var speed: float = 600.0
@export var daño: float = 10.0
@export var lifetime: float = 5.0

var direccion: Vector2 = Vector2.ZERO
var creador: Node = null

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	if has_node("TiempoVida"):
		var timer = get_node("TiempoVida")
		if not timer.timeout.is_connected(_on_timeout):
			timer.timeout.connect(_on_timeout)

func _physics_process(delta: float) -> void:
	position += direccion.normalized() * speed * delta

func _on_body_entered(body: Node) -> void:
	if body == creador:
		return
	
	if body.is_in_group("enemigo") and body.has_method("take_damage"):
		body.take_damage(get_daño())
		_destruir()

func _on_timeout() -> void:
	_destruir()

func _destruir() -> void:
	destruido.emit()

func get_daño() -> float:
	return daño
