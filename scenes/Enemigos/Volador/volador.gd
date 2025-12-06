extends EnemigoBase
class_name Volador

@export var xp: float = 10.0

func _ready():
	super._ready()
	anim_sprite.play("volar")

func _perseguir() -> void:
	super._perseguir()
	
	# Flip horizontal según dirección
	if objetivo:
		anim_sprite.flip_h = objetivo.global_position.x < global_position.x

func take_damage(cantidad: float) -> void:
	# Animación especial de recibir daño
	anim_sprite.play("recibir")
	velocity = Vector2.ZERO
	await anim_sprite.animation_finished
	
	# Llamar al padre para aplicar daño
	super.take_damage(cantidad)
	
	# Volver a volar si sigue vivo
	if vida_actual > 0:
		anim_sprite.play("volar")

func morir():
	GameState.add_xp(xp)
	velocity = Vector2.ZERO
	nav_agent.set_velocity(Vector2.ZERO)
	set_physics_process(false)
	
	anim_sprite.play("morir")
	await anim_sprite.animation_finished
	queue_free()

func _on_animation_finished() -> void:
	# Sobrescribir para manejar animaciones específicas del volador
	if anim_sprite.animation == "atacar":
		anim_sprite.play("volar")
	elif anim_sprite.animation == "recibir":
		if vida_actual > 0:
			anim_sprite.play("volar")
