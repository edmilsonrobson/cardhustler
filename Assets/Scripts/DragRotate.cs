using UnityEngine;
using UnityEngine.UI;

public class DragRotate : MonoBehaviour
{
    [Header("Rotation")]
    public float rotateSpeed = 200f;
    public Vector2 pitchClamp = new Vector2(-20f, 20f);
    public bool invertY = false;

    [Header("Optional")]
    public bool requireMouseButton = false; // set true if you want to rotate only while LMB is held

    bool inspectActive = false;
    float yaw,
        pitch;

    public Sprite sprite;
    public Image img;

    void OnEnable()
    {
        var e = transform.eulerAngles;
        yaw = e.y;
        pitch = e.x;
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Q))
        {
            Debug.Log("trying to replace texture");
            // Make sure img has a URP/Lit material assigned in the inspector
            var mat = img.materialForRendering;

            // Set the texture
            mat.SetTexture("_BaseMap", sprite.texture);

            // If sprite comes from an atlas, also fix tiling/offset
            Rect r = sprite.textureRect;
            Vector4 st = new Vector4(
                r.width / sprite.texture.width, // tiling X
                r.height / sprite.texture.height, // tiling Y
                r.x / sprite.texture.width, // offset X
                r.y / sprite.texture.height // offset Y
            );

            mat.SetVector("_BaseMap_ST", st);
        }

        // Toggle inspect with R
        if (Input.GetKeyDown(KeyCode.R))
        {
            inspectActive = !inspectActive;
            Debug.Log(
                inspectActive
                    ? "[DragRotate] Inspect ENABLED (R)"
                    : "[DragRotate] Inspect DISABLED (R)"
            );
        }

        // Allow quick exit with ESC
        if (inspectActive && Input.GetKeyDown(KeyCode.Escape))
        {
            inspectActive = false;
            Debug.Log("[DragRotate] Inspect DISABLED (ESC)");
        }

        if (!inspectActive)
            return;

        // If you want to require holding LMB to rotate, enable requireMouseButton
        if (requireMouseButton && !Input.GetMouseButton(0))
            return;

        // Mouse deltas
        float dx = Input.GetAxis("Mouse X");
        float dy = Input.GetAxis("Mouse Y");
        if (invertY)
            dy = -dy;

        // Apply rotation
        yaw += dx * rotateSpeed * Time.deltaTime;
        pitch = Mathf.Clamp(
            pitch - dy * rotateSpeed * 0.5f * Time.deltaTime,
            pitchClamp.x,
            pitchClamp.y
        );

        transform.rotation = Quaternion.Euler(pitch, yaw, 0f);
    }
}
