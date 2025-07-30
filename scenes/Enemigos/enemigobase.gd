extends CharacterBody2D
class_name EnemigoBase

@export var velocidad: float = 100.0
@export var vida_max: int = 30

var vida_actual: int
var objetivo: Node2D = null

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	vida_actual = vida_max
	anim_sprite.play("default")
	add_to_group("enemigo")
	await get_tree().create_timer(0.1).timeout
	objetivo = get_tree().get_first_node_in_group("jugador")

	if objetivo:
		nav_agent.set_navigation_map(get_world_2d().navigation_map)
		nav_agent.target_position = objetivo.global_position

func _physics_process(delta):
	if not objetivo:
		return

	nav_agent.target_position = objetivo.global_position

	if not nav_agent.is_navigation_finished():
		var siguiente_punto = nav_agent.get_next_path_position()
		var direccion = (siguiente_punto - global_position).normalized()
		velocity = direccion * velocidad
		move_and_slide()

func recibir_daño(cantidad: float) -> void:
	vida_actual -= cantidad
	anim_sprite.play("recibir")
	if vida_actual <= 0:
		morir()

func morir():
	anim_sprite.play("morir")
	await anim_sprite.animation_finished
	queue_free()

func _on_Hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("get_daño"):
		recibir_daño(area.get_daño())
		area.queue_free()
