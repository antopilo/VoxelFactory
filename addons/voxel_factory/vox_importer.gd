tool
extends EditorPlugin

var import_plugin
var control

func _enter_tree():
	#Add import plugin
	import_plugin = ImportPlugin.new()
	add_import_plugin(import_plugin)

func _exit_tree():
	#remove plugin
	remove_import_plugin(import_plugin)
	import_plugin = null

##############################################
#                Import Plugin               #
##############################################
class MagicaVoxelData:
	var pos = Vector3(0,0,0)
	var color
	func init(file):
		pos.x = file.get_8()
		pos.z = -file.get_8()
		pos.y = file.get_8()
		
		color = file.get_8()

class ImportPlugin extends EditorImportPlugin:
	#The Name shown in the Plugin Menu
	func get_importer_name():
		return 'MagicaVoxel-Importer'
	
	#The Name shown under 'Import As' in the Import menu
	func get_visible_name():
		return "MagicaVoxels as Mesh"
	
	#The File extensions that this Plugin can import. Those will then show up in the Filesystem
	func get_recognized_extensions():
		return ['vox']
	
	#The Resource Type it creates. Im still not sure what exactly this does
	func get_resource_type():
		return "ArrayMesh"
	
	#The extenison the imported file will have
	func get_save_extension():
		return 'tres'
	
	#Returns an Array or Dictionaries that declare which options exist.
	#Those options will show up under 'Import As'
	func get_import_options(preset):
		var options = []
		#options.append( { "name":"Pack in scene", "default_value":false } )
		#options.append( { "name":"target_path", "default_value":"" } )
		return options
	
	#The Number of presets
	func get_preset_count():
		return 0
	
	#The Name of the preset.
	func get_preset_name(preset):
		return "Default"
	
	#Gets called when pressing a file gets imported / reimported
	func import( source_path, save_path, options, platforms, gen_files ):
		#Initialize and populate voxel array
		var voxelArray = []
		for x in range(0,128):
			voxelArray.append([])
			for y in range(0,128):
				voxelArray[x].append([])
				voxelArray[x][y].resize(128)
		
		var file = File.new()
		var error = file.open( source_path, File.READ )
		if error != OK:
			if file.is_open(): file.close()
			return error
		
		##################
		#  Import Voxels #
		##################
		var colors = null
		var data = null
		#var derp = PoolByteArray(file.get_8()).get
		var magic = PoolByteArray([file.get_8(),file.get_8(),file.get_8(),file.get_8()]).get_string_from_ascii()
		
		var version = file.get_32()
		 
		# a MagicaVoxel .vox file starts with a 'magic' 4 character 'VOX ' identifier
		if magic == "VOX ":
			var sizex = 0
			var sizey = 0
			var sizez = 0
			
			while file.get_position() < file.get_len():
				# each chunk has an ID, size and child chunks
				var chunkId = PoolByteArray([file.get_8(),file.get_8(),file.get_8(),file.get_8()]).get_string_from_ascii() #char[] chunkId
				var chunkSize = file.get_32()
				var childChunks = file.get_32()
				var chunkName = chunkId
				# there are only 2 chunks we only care about, and they are SIZE and XYZI
				if chunkName == "SIZE":
					sizex = file.get_32()
					sizey = file.get_32()
					sizez = file.get_32()
					 
					file.get_buffer(chunkSize - 4 * 3)
				elif chunkName == "XYZI":
					# XYZI contains n voxels
					var numVoxels = file.get_32()
					
					# each voxel has x, y, z and color index values
					data = []
					for i in range(0,numVoxels):
						var mvc = MagicaVoxelData.new()
						mvc.init(file)
						data.append(mvc)
						voxelArray[mvc.pos.x][mvc.pos.y][mvc.pos.z] = mvc
				elif chunkName == "RGBA":
					colors = []
					 
					for i in range(0,256):
						var r = float(file.get_8() / 255.0)
						var g = float(file.get_8() / 255.0)
						var b = float(file.get_8() / 255.0)
						var a = float(file.get_8() / 255.0)
						
						colors.append(Color(r,g,b,a))
						
				else: file.get_buffer(chunkSize)  # read any excess bytes
			
			if data.size() == 0: return data #failed to read any valid voxel data
			 
			# now push the voxel data into our voxel chunk structure
			for i in range(0,data.size()):
				# use the voxColors array by default, or overrideColor if it is available
				if colors == null:
					data[i].color = Color(voxColors[data[i].color]-1)
				else:
					data[i].color = colors[data[i].color-1]
		file.close()
		
		##################
		#   Create Mesh  #
		##################
		
		#Calculate offset
		var s_x = 1000
		var m_x = -1000
		var s_z = 1000
		var m_z = -1000
		for voxel in data:
			if voxel.pos.x < s_x: s_x = voxel.pos.x
			elif voxel.pos.x > m_x: m_x = voxel.pos.x
			if voxel.pos.z < s_z: s_z = voxel.pos.z
			elif voxel.pos.z > m_z: m_z = voxel.pos.z
		var x_dif = m_x - s_x
		var z_dif = m_z - s_z
		var dif = Vector3(-s_x-x_dif/2.0,0,-s_z-z_dif/2.0)
		
		var mesh = build_culled_mesh(dif,data,voxelArray)
		
		for vox in data:
			mesh.set_meta(str(vox.pos), vox.color)
			
		
		
		var full_path = "%s.%s" % [save_path, get_save_extension()]
		return ResourceSaver.save( full_path, mesh )
	
	func build_culled_mesh(dif,data,voxel_array):
		#Create the mesh
		var st = SurfaceTool.new()
		st.begin(Mesh.PRIMITIVE_TRIANGLES)
		for voxel in data:
			var to_draw = []
			if not above(voxel,voxel_array): to_draw += top
			if not below(voxel,voxel_array): to_draw += down
			if not onleft(voxel,voxel_array): to_draw += left
			if not onright(voxel,voxel_array): to_draw += right
			if not infront(voxel,voxel_array): to_draw += front
			if not behind(voxel,voxel_array): to_draw += back
			
			st.add_color(voxel.color)
			for tri in to_draw:
				st.add_vertex( (tri*0.5)+voxel.pos+dif)
		st.generate_normals()
		
		var material = SpatialMaterial.new()
		material.vertex_color_is_srgb = true
		material.vertex_color_use_as_albedo = true
		material.roughness = 1
		#material.set_flag(material.FLAG_USE_COLOR_ARRAY,true)
		st.set_material(material)
		return st.commit()
	
	#Data
	var voxColors = [
		"00000000", "ffffffff", "ffccffff", "ff99ffff", "ff66ffff", "ff33ffff", "ff00ffff", "ffffccff", "ffccccff", "ff99ccff", "ff66ccff", "ff33ccff", "ff00ccff", "ffff99ff", "ffcc99ff", "ff9999ff",
		"ff6699ff", "ff3399ff", "ff0099ff", "ffff66ff", "ffcc66ff", "ff9966ff", "ff6666ff", "ff3366ff", "ff0066ff", "ffff33ff", "ffcc33ff", "ff9933ff", "ff6633ff", "ff3333ff", "ff0033ff", "ffff00ff",
		"ffcc00ff", "ff9900ff", "ff6600ff", "ff3300ff", "ff0000ff", "ffffffcc", "ffccffcc", "ff99ffcc", "ff66ffcc", "ff33ffcc", "ff00ffcc", "ffffcccc", "ffcccccc", "ff99cccc", "ff66cccc", "ff33cccc",
		"ff00cccc", "ffff99cc", "ffcc99cc", "ff9999cc", "ff6699cc", "ff3399cc", "ff0099cc", "ffff66cc", "ffcc66cc", "ff9966cc", "ff6666cc", "ff3366cc", "ff0066cc", "ffff33cc", "ffcc33cc", "ff9933cc",
		"ff6633cc", "ff3333cc", "ff0033cc", "ffff00cc", "ffcc00cc", "ff9900cc", "ff6600cc", "ff3300cc", "ff0000cc", "ffffff99", "ffccff99", "ff99ff99", "ff66ff99", "ff33ff99", "ff00ff99", "ffffcc99",
		"ffcccc99", "ff99cc99", "ff66cc99", "ff33cc99", "ff00cc99", "ffff9999", "ffcc9999", "ff999999", "ff669999", "ff339999", "ff009999", "ffff6699", "ffcc6699", "ff996699", "ff666699", "ff336699",
		"ff006699", "ffff3399", "ffcc3399", "ff993399", "ff663399", "ff333399", "ff003399", "ffff0099", "ffcc0099", "ff990099", "ff660099", "ff330099", "ff000099", "ffffff66", "ffccff66", "ff99ff66",
		"ff66ff66", "ff33ff66", "ff00ff66", "ffffcc66", "ffcccc66", "ff99cc66", "ff66cc66", "ff33cc66", "ff00cc66", "ffff9966", "ffcc9966", "ff999966", "ff669966", "ff339966", "ff009966", "ffff6666",
		"ffcc6666", "ff996666", "ff666666", "ff336666", "ff006666", "ffff3366", "ffcc3366", "ff993366", "ff663366", "ff333366", "ff003366", "ffff0066", "ffcc0066", "ff990066", "ff660066", "ff330066",
		"ff000066", "ffffff33", "ffccff33", "ff99ff33", "ff66ff33", "ff33ff33", "ff00ff33", "ffffcc33", "ffcccc33", "ff99cc33", "ff66cc33", "ff33cc33", "ff00cc33", "ffff9933", "ffcc9933", "ff999933",
		"ff669933", "ff339933", "ff009933", "ffff6633", "ffcc6633", "ff996633", "ff666633", "ff336633", "ff006633", "ffff3333", "ffcc3333", "ff993333", "ff663333", "ff333333", "ff003333", "ffff0033",
		"ffcc0033", "ff990033", "ff660033", "ff330033", "ff000033", "ffffff00", "ffccff00", "ff99ff00", "ff66ff00", "ff33ff00", "ff00ff00", "ffffcc00", "ffcccc00", "ff99cc00", "ff66cc00", "ff33cc00",
		"ff00cc00", "ffff9900", "ffcc9900", "ff999900", "ff669900", "ff339900", "ff009900", "ffff6600", "ffcc6600", "ff996600", "ff666600", "ff336600", "ff006600", "ffff3300", "ffcc3300", "ff993300",
		"ff663300", "ff333300", "ff003300", "ffff0000", "ffcc0000", "ff990000", "ff660000", "ff330000", "ff0000ee", "ff0000dd", "ff0000bb", "ff0000aa", "ff000088", "ff000077", "ff000055", "ff000044",
		"ff000022", "ff000011", "ff00ee00", "ff00dd00", "ff00bb00", "ff00aa00", "ff008800", "ff007700", "ff005500", "ff004400", "ff002200", "ff001100", "ffee0000", "ffdd0000", "ffbb0000", "ffaa0000",
		"ff880000", "ff770000", "ff550000", "ff440000", "ff220000", "ff110000", "ffeeeeee", "ffdddddd", "ffbbbbbb", "ffaaaaaa", "ff888888", "ff777777", "ff555555", "ff444444", "ff222222", "ff111111"
		]
	
	var top = [
		Vector3( 1.0000, 1.0000, 1.0000),
		Vector3(-1.0000, 1.0000, 1.0000),
		Vector3(-1.0000, 1.0000,-1.0000),
		
		Vector3(-1.0000, 1.0000,-1.0000),
		Vector3( 1.0000, 1.0000,-1.0000),
		Vector3( 1.0000, 1.0000, 1.0000),
	]
	
	var down = [
		Vector3(-1.0000,-1.0000,-1.0000),
		Vector3(-1.0000,-1.0000, 1.0000),
		Vector3( 1.0000,-1.0000, 1.0000),
		
		Vector3( 1.0000, -1.0000, 1.0000),
		Vector3( 1.0000, -1.0000,-1.0000),
		Vector3(-1.0000, -1.0000,-1.0000),
	]
	
	var front = [
		Vector3(-1.0000, 1.0000, 1.0000),
		Vector3( 1.0000, 1.0000, 1.0000),
		Vector3( 1.0000,-1.0000, 1.0000),
		
		Vector3( 1.0000,-1.0000, 1.0000),
		Vector3(-1.0000,-1.0000, 1.0000),
		Vector3(-1.0000, 1.0000, 1.0000),
	]
	
	var back = [
		Vector3( 1.0000,-1.0000,-1.0000),
		Vector3( 1.0000, 1.0000,-1.0000),
		Vector3(-1.0000, 1.0000,-1.0000),
		
		Vector3(-1.0000, 1.0000,-1.0000),
		Vector3(-1.0000,-1.0000,-1.0000),
		Vector3( 1.0000,-1.0000,-1.0000)
	]
	
	var left = [
		Vector3(-1.0000, 1.0000, 1.0000),
		Vector3(-1.0000,-1.0000, 1.0000),
		Vector3(-1.0000,-1.0000,-1.0000),
		
		Vector3(-1.0000,-1.0000,-1.0000),
		Vector3(-1.0000, 1.0000,-1.0000),
		Vector3(-1.0000, 1.0000, 1.0000),
	]
	
	var right = [
		Vector3( 1.0000, 1.0000, 1.0000),
		Vector3( 1.0000, 1.0000,-1.0000),
		Vector3( 1.0000,-1.0000,-1.0000),
		
		Vector3( 1.0000,-1.0000,-1.0000),
		Vector3( 1.0000,-1.0000, 1.0000),
		Vector3( 1.0000, 1.0000, 1.0000),
	]
	
	#Some staic functions
	func above(cube,array): return array[cube.pos.x][cube.pos.y+1][cube.pos.z]
	func below(cube,array): return array[cube.pos.x][cube.pos.y-1][cube.pos.z]
	func onleft(cube,array): return array[cube.pos.x-1][cube.pos.y][cube.pos.z]
	func onright(cube,array): return array[cube.pos.x+1][cube.pos.y][cube.pos.z]
	func infront(cube,array): return array[cube.pos.x][cube.pos.y][cube.pos.z+1]
	func behind(cube,array): return array[cube.pos.x][cube.pos.y][cube.pos.z-1]