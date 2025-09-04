using UnityEngine;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
public class InteractionConeVisual : MonoBehaviour
{
    [Header("Link this to your PlayerInteractor")]
    public PlayerInteractor interactor;

    [Header("Look")]
    public Color color = new Color(1f, 0.8f, 0.1f, 0.25f);

    [Range(6, 128)]
    public int segments = 48; // arc smoothness
    public float yOffset = 0.02f; // avoid z-fighting with floor

    private Mesh mesh;
    private MeshFilter mf;
    private MeshRenderer mr;
    private Material mat;

    private static readonly int ColorID = Shader.PropertyToID("_BaseColor"); // URP Unlit
    private static readonly int TintColorID = Shader.PropertyToID("_Color"); // Sprites/Default fallback

    private void Awake()
    {
        mf = GetComponent<MeshFilter>();
        mr = GetComponent<MeshRenderer>();

        mesh = new Mesh();
        mesh.name = "InteractionCone";
        mf.sharedMesh = mesh;

        // Try URP Unlit, fallback to Sprites/Default so it also works in Built-in RP
        Shader s = Shader.Find("Universal Render Pipeline/Unlit");
        if (s == null)
            s = Shader.Find("Sprites/Default");

        mat = new Material(s);
        mr.sharedMaterial = mat;
        mr.shadowCastingMode = UnityEngine.Rendering.ShadowCastingMode.Off;
        mr.receiveShadows = false;
        mr.allowOcclusionWhenDynamic = false;

        RebuildMesh(1.5f, 60f); // initial dummy
        ApplyColor();
    }

    private void LateUpdate()
    {
        if (!interactor)
            return;

        // Keep the cone on the ground and oriented with player forward
        transform.position = interactor.transform.position + Vector3.up * yOffset;
        transform.rotation = Quaternion.LookRotation(
            Flat(interactor.transform.forward),
            Vector3.up
        );

        // Rebuild if values changed
        RebuildMesh(interactor.radius, interactor.angleDeg);
        ApplyColor();
    }

    private void ApplyColor()
    {
        if (mat.HasProperty(ColorID))
            mat.SetColor(ColorID, color);
        if (mat.HasProperty(TintColorID))
            mat.SetColor(TintColorID, color);
    }

    private static Vector3 Flat(Vector3 v)
    {
        v.y = 0f;
        return v.sqrMagnitude > 0.000001f ? v.normalized : Vector3.forward;
    }

    private void RebuildMesh(float radius, float angleDeg)
    {
        int vertsCount = segments + 2; // center + segments+1 along arc
        var verts = new Vector3[vertsCount];
        var tris = new int[segments * 3];

        verts[0] = Vector3.zero;

        float half = angleDeg * 0.5f * Mathf.Deg2Rad;
        // Build arc from -half to +half around Y, in XZ plane, forward = +Z
        for (int i = 0; i <= segments; i++)
        {
            float t = (float)i / segments; // 0..1
            float ang = Mathf.Lerp(-half, +half, t); // rad
            float x = Mathf.Sin(ang) * radius;
            float z = Mathf.Cos(ang) * radius;
            verts[i + 1] = new Vector3(x, 0f, z);
        }

        int tri = 0;
        for (int i = 0; i < segments; i++)
        {
            // triangle fan: center, i+1, i+2
            tris[tri++] = 0;
            tris[tri++] = i + 1;
            tris[tri++] = i + 2;
        }

        mesh.Clear();
        mesh.SetVertices(verts);
        mesh.SetTriangles(tris, 0, true);
        mesh.RecalculateNormals(); // not really needed for unlit
        mesh.RecalculateBounds();
    }
}
