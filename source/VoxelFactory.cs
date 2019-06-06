using Godot;
using System;
using System.Collections.Generic;

public class VoxelFactory
{
    public float VoxelSize = 1f;
    public Material DefaultMaterial = new SpatialMaterial() 
    {
        VertexColorUseAsAlbedo = true 
    };

    private Dictionary<Vector3, Color> Voxels = new Dictionary<Vector3, Color>();
    private SurfaceTool SurfaceTool = new SurfaceTool();
    
    // Cube vertices
    private static Vector3[] Vertices = { 
        new Vector3(0, 0, 0), new Vector3(1, 0, 0), 
        new Vector3(1, 0, 1), new Vector3(0, 0, 1), 
        new Vector3(0, 1, 0), new Vector3(1, 1, 0),
        new Vector3(1, 1, 1), new Vector3(0, 1, 1) 
    };

    // FromImageData
    public Mesh CreateMeshFromIMG(string path)
    {
        // Load image
        var image = new Image();
        image.Load(path);

        return CreateMeshFromImage(image);
    }

    // SpriteNode
    public Mesh CreateMeshFromSprite(Sprite sprite)
    {
        var image = sprite.Texture.GetData();
        return CreateMeshFromImage(image);
    }


    private Mesh CreateMeshFromImage(Image image)
    {
        Voxels.Clear();
        var imageSize = image.GetSize();

        // Flip because its upside down by default, and lock it.
        image.FlipY(); 
        image.Lock();

        // Create data.
        for(int x = 0; x < imageSize.x; x++)
            for(int y = 0; y < imageSize.y; y++)
                AddVoxel(x, y, 0, image.GetPixel(x, y));

        // Unlock and return the mesh.
        image.Unlock();
        return CreateMesh();
    }


    public void AddVoxel(Vector3 position, Color color, bool overwrite = false)
    {
        if(color.a == 0f)
            return;

        if(Voxels.ContainsKey(position) && overwrite)
            Voxels[position] = color;
        else if(!Voxels.ContainsKey(position))
            Voxels.Add(position, color);
    }


    public void AddVoxel(int x, int y, int z, Color color, bool overwrite = false)
    {
        var position = new Vector3(x, y, z);
        AddVoxel(position, color, overwrite);
    }


    public void AddVoxels(Dictionary<Vector3, Color> voxels, bool overrideVox = false)
    {
        foreach(Vector3 v in voxels.Keys)
        {
            if(overrideVox)
                AddVoxel(v, voxels[v]);
            else if(!Voxels.ContainsKey(v))
                AddVoxel(v, voxels[v]);
        }
    }

    public void ClearVoxels()
    {
        Voxels.Clear();
    }


    public Mesh CreateMesh()
    {
        SurfaceTool.Begin(Mesh.PrimitiveType.Triangles);
        SurfaceTool.SetMaterial(DefaultMaterial);

        foreach(var voxel in Voxels.Keys)
            CreateVoxel(Voxels[voxel], voxel);
        
        SurfaceTool.Index();
        return SurfaceTool.Commit();
    }

    private void CreateVoxel(Color color, Vector3 position)
    {
        bool left   = !Voxels.ContainsKey(position - new Vector3(1, 0, 0));
        bool right  = !Voxels.ContainsKey(position + new Vector3(1, 0, 0));
        bool back   = !Voxels.ContainsKey(position - new Vector3(0, 0, 1));
        bool front  = !Voxels.ContainsKey(position + new Vector3(0, 0, 1));
        bool top    = !Voxels.ContainsKey(position + new Vector3(0, 1, 0));
        bool bottom = !Voxels.ContainsKey(position - new Vector3(0, 1, 0));

        if (left && right && front && back && top && bottom)
            return;

        SurfaceTool.AddColor(color);
                
        Vector3 vertexOffset = position;
        if (top) // Above
        {
            SurfaceTool.AddNormal(new Vector3(0, -1, 0));
            SurfaceTool.AddVertex(Vertices[4] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[5] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[7] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[5] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[6] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[7] + vertexOffset);
        }
        if (right) // Right
        {
            SurfaceTool.AddNormal(new Vector3(1, 0, 0));
            SurfaceTool.AddVertex(Vertices[2] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[5] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[1] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[2] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[6] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[5] + vertexOffset);
            
        }
        if (left) // Left
        {
            SurfaceTool.AddNormal(new Vector3(-1, 0, 0));
            SurfaceTool.AddVertex(Vertices[0] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[7] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[3] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[0] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[4] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[7] + vertexOffset);
        }
        if (front) // Front
        {
            SurfaceTool.AddNormal(new Vector3(0, 0, 1));
            SurfaceTool.AddVertex(Vertices[3] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[6] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[2] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[3] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[7] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[6] + vertexOffset);
        }
        if (back) // Above
        {
            SurfaceTool.AddNormal(new Vector3(0, 0, -1));
            SurfaceTool.AddVertex(Vertices[0] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[1] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[5] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[5] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[4] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[0] + vertexOffset);
        }
        if (bottom)
        {
            SurfaceTool.AddNormal(new Vector3(0, 1, 0));
            SurfaceTool.AddVertex(Vertices[1] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[3] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[2] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[1] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[0] + vertexOffset);
            SurfaceTool.AddVertex(Vertices[3] + vertexOffset);
        }
    } 
}

