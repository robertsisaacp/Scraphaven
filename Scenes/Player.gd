extends Actor
class_name Player


const FLOOR_DETECT_DISTANCE = 40.0

onready var platform_detector = $PlatformDetector
onready var animation_player = $AnimationPlayer
onready var sprite = $Player_Sheet

"""
    1. Calculates the move direction.
    2. Calculates the move velocity.
    3. Moves the character.
    4. Updates the sprite direction.
    5. Updates the animation.
"""

func _physics_process(_delta):
    var direction = get_direction()

    var is_jump_interrupted = Input.is_action_just_released("ui_accept") and _velocity.y < 0.0
    _velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)

    # Ternary <3
    var snap_vector = Vector2.DOWN * FLOOR_DETECT_DISTANCE if direction.y == 0.0 else Vector2.ZERO
    var is_on_platform = platform_detector.is_colliding()
    _velocity = move_and_slide_with_snap(
        _velocity, snap_vector, FLOOR_NORMAL, not is_on_platform, 4,  0.9, false
    )

    if direction.x != 0:
        sprite.scale.x = direction.x

    var animation = get_new_animation()
    if animation != animation_player.current_animation:  # and shoot_timer.is_stopped():
        animation_player.play(animation)


func get_direction():
    return Vector2(
        Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
        -Input.get_action_strength("ui_accept") if is_on_floor() and Input.is_action_just_pressed("ui_accept") else 0.0
    )


# returns a new velocity, accounting for jump interrupts
func calculate_move_velocity(
        linear_velocity,
        direction,
        speed,
        is_jump_interrupted
    ):
    var velocity = linear_velocity
    velocity.x = speed.x * direction.x

    if direction.y != 0.0:
        velocity.y = speed.y * direction.y
    if is_jump_interrupted:
        velocity.y = 0.0
    return velocity


func get_new_animation():
    var animation_new = ""
    if is_on_floor():
        animation_new = "Run" if abs(_velocity.x) > 0.1 else "Idle"
    else:
        animation_new = "Jump_Land" if _velocity.y > 0 else "Jump_Up"
    # if is_shooting:
    #   animation_new += "_weapon"
    return animation_new
