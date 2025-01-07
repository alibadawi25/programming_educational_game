extends TextureButton

func _ready():
	# Ensure the node has a ShaderMaterial
	if material is ShaderMaterial:
		var shader_material = material as ShaderMaterial

		# Pass the button size to the shader
		shader_material.set_shader_param("button_size", rect_size)
