# Voxel Factory 📦 :factory: 

![logo](https://i.imgur.com/uxXe4hy.png)

> Voxel Factory is a simple Godot C# library that allows you to create voxel mesh easily using cubes. It handles the meshing for you and optimize it. 

## Voxel editor
The plugins also comes with a voxel editor where you can create your own voxel models from godot. This is a good alternative if you are using magica voxel for small models. I don't recommended editing big models with this plugin as it is not suited yet for big mesh. The voxel editor can open **.vox** files from magica voxel without any problem atm. The only downside is that all change made from the voxel editor will not apply on the vox file directly. I'm currently storing the changes as meta-data on the file and not in binary format.

## Usage

VoxelFactory can be used for anything in your project that needs procedural meshing. If you have a way to feed it some data. Then it will create the mesh no problem. You could use the library to create some voxel Items like in minecraft from pngs. You could feed it some chunk data so it will create the chunk mesh for you. If you want to create a procedural landscape using this library, you will need to handle the generation and multi-threading yourself.



## Installation
Just import the source `VoxelFactory.cs` class to your project. 
Nuget package and `dll` coming soon.
GDscript version coming soon.

## Exemples

If you have an image that you would like to extrude in voxels, all you need is the path to your image.

```csharp
 var VoxelFactory = new VoxelFactory();
 Mesh = VoxelFactory.CreateMeshFromIMG("res://New Piskel.png");
```

You can also add voxels manually like so:

```csharp
var VoxelFactory = new VoxelFactory();

VoxelFactory.AddVoxel(0, 0, 0, new Color(1, 0, 0));
VoxelFactory.AddVoxel(0, 1, 0, new Color(0, 1, 0));
Mesh = VoxelFactory.CreateMesh();
```

If you have a sprite node that has a texture that you want to extrude. 

```csharp
 var VoxelFactory = new VoxelFactory();
 var mySpriteNode = (Sprite)GetNode("mySpriteNode");
 Mesh = VoxelFactory.CreateMeshFromSprite(mySpriteNode);
```



## Documentation

#### Propreties

| Type     | Name            |
| -------- | --------------- |
| Material | DefaultMaterial |
| float    | VoxelSize       |

#### Methods

| Return type | Name                 |
| ----------- | -------------------- |
| Mesh        | CreateMeshFromIMG    |
| Mesh        | CreateMeshFromSprite |
| Mesh        | CreateMesh           |
| void        | AddVoxel             |
| void        | AddVoxels            |
| void        | ClearVoxels          |


#### Propreties Descriptions

- Default Material

The default material used on the mesh. By default, only the `VertexColorUseAsAlbedo`is enabled. You can override this before create a mesh to use a custom material.

- VoxelSize 

The size of a voxel. Default is `1` unit.

#### Methods Descriptions

- `Mesh` CreateMeshFromIMG(`string` path)

This will create a mesh from an image specified as `path`. For each pixel in the image, a voxel with the same color will be created. If the pixel is fully transparent, no voxel will be created.

- `Mesh` CreateMeshFromSprite(`Sprite` node)

This will create a mesh from a Sprite node. It will use the sprite texture as an image.

- `void` CreateMesh() 

Create a `Mesh` from the current data in the VoxelFactory. Use this if you are adding Voxels manually.

- `void` AddVoxel(`int` x, `int` y , `int` z, `Color` color, [`bool` overwrite = false])
- `void` AddVoxel(`Vector3` position, `Color` color)

Add a voxel at a specified position with a color to the VoxelFactory dataset. You can either use a Vector3 for the position or specify them one by one. You can specify if you want to overwrite if a voxel already exists at the position specified

- `void` AddVoxels(Dictionary<`Vector3`, `Color`>, [`bool` overwrite = false])

Add a bunch of voxels all at once that are in a Dictionary with the position as the key, and the color as the value. You can specify if you want to overwrite if a voxel already exists at the position specified

- `void` ClearVoxels()

Clears the dataset in the VoxelFactory
