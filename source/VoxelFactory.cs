using Godot;

public struct Voxel{
    public Color color;
}

public class VoxelFactory
{
    public float VoxelSize = 1f;
    public Material Material = new Material();
    private Dictionnary<Vector3, Voxel> Voxels;
    private SurfaceTool SurfaceTool = new SurfaceTool();
    
    // Cube vertices
    private static Vector3[] Vertices = { 
        new Vector3(0, 0, 0), new Vector3(1, 0, 0), 
        new Vector3(1, 0, 1), new Vector3(0, 0, 1), 
        new Vector3(0, 1, 0), new Vector3(1, 1, 0),
        new Vector3(1, 1, 1), new Vector3(0, 1, 1) 
    };


    // FromImageData
    public void CreateMeshFromPNG(ImageData data)
    {

    }

    // SpriteNode
    public void CreateMeshFromSprite(Sprite sprite)
    {

    }

    // Read MagicaVoxel file.
    public void CreateMeshFromMagica(string path)
    {

    }

     // Adds a new Voxel to the dataset.
    public void AddVoxel(Vector3 position, Color color)
    {
        Voxel voxel = new Voxel();
        voxel.color = color;
        Voxels.Add(position, voxel);
    }

    public void AddVoxel(int x, int y, int z, Color color)
    {
        var position = new Vector3(x, y, z);
        var voxel = new Voxel();
        voxel.color = color;
        Voxels.Add(position, voxel);
    }


    public void AddVoxels(Dictionnary<Vector3, Voxel> voxels, bool overrideVox = false)
    {
        if(overrideVox)
        {
            foreach(var v in voxels.Keys)
                AddVoxel(v, voxels[v]);
        }
        else
        {
            foreach(var v in voxels.Keys)
            {
               if(!Voxels.ContainsKey(v))
                   AddVoxel(v, voxels[v]);
            }
        }
    }


    private Mesh CreateMesh()
    {
        SurfaceTool.Begin(Mesh.PrimitiveType.Triangles);
        Material mat = VoxMaterial as Material;
        SurfaceTool.SetMaterial(mat);

        foreach(Voxel voxel in Voxels)
            CreateVoxel(voxel);

        SurfaceTool.Index();
        return SurfaceTool.Commit();
    }

    private void CreateVoxel(Voxel voxel)
    {
        bool left   = !Voxels.ContainsKey(voxel.position - new Vector3(1, 0, 0));
        bool right  = !Voxels.ContainsKey(voxel.position + new Vector3(1, 0, 0));
        bool back   = !Voxels.ContainsKey(voxel.position - new Vector3(1, 0, 0));
        bool front  = !Voxels.ContainsKey(voxel.position + new Vector3(0, 0, 1));
        bool top    = !Voxels.ContainsKey(voxel.position - new Vector3(0, 1, 0));
        bool bottom = !Voxels.ContainsKey(voxel.position + new Vector3(1, 0, 0));

        if (left && right && front && back && top && bottom)
            return;

        pSurfaceTool.AddColor(voxel.color);
                
        Vector3 vertexOffset = new Vector3(x, y, z);
        if (top) // Above
        {
            SurfaceTool.AddNormal(new Vector3(0, 1, 0));
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

