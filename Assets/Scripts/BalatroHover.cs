using UnityEngine;
using UnityEngine.EventSystems;

[RequireComponent(typeof(RectTransform))]
public class HoverTilt
    : MonoBehaviour,
        IPointerEnterHandler,
        IPointerExitHandler,
        IPointerMoveHandler
{
    [Header("Tilt amount (degrees)")]
    [Tooltip("Max rotation around X when cursor is at top/bottom edge.")]
    public float maxXAngle = 12f;

    [Tooltip("Max rotation around Y when cursor is at left/right edge.")]
    public float maxYAngle = 12f;

    [Tooltip("Optional subtle roll around Z based on horizontal offset.")]
    public float maxZRoll = 6f;

    [Header("Behavior")]
    [Tooltip("How quickly to move toward the target tilt.")]
    [Min(0f)]
    public float tiltLerpSpeed = 14f;

    [Tooltip("How quickly to return to idle after exit.")]
    [Min(0f)]
    public float returnLerpSpeed = 10f;

    [Tooltip("Clamp the input so the very corners don't over-tilt.")]
    [Range(0.1f, 1.5f)]
    public float edgeFalloff = 1f;

    [Header("Axis options")]
    public bool enableX = true;
    public bool enableY = true;
    public bool enableZRoll = true;

    [Tooltip("Invert the sign if your tilt looks backwards.")]
    public bool invertX = false;
    public bool invertY = false;
    public bool invertZ = false;

    [Header("Extras")]
    [Tooltip("Optional scale punch while hovering.")]
    public bool scaleOnHover = true;

    [Range(0f, 0.5f)]
    public float hoverScaleAmount = 0.06f;

    [Min(0f)]
    public float scaleLerpSpeed = 12f;

    RectTransform _rt;
    Quaternion _baseRotation;
    Vector3 _baseScale;
    bool _hovering;
    Vector2 _lastLocalCursor; // cached from IPointerMove
    Camera _uiCamera; // optional: set if your canvas uses Screen Space - Camera or World Space

    void Awake()
    {
        _rt = GetComponent<RectTransform>();
        _baseRotation = _rt.localRotation;
        _baseScale = _rt.localScale;

        // Try to find a Canvas camera if in Screen Space - Camera or World Space
        var canvas = GetComponentInParent<Canvas>();
        if (canvas != null && canvas.renderMode != RenderMode.ScreenSpaceOverlay)
        {
            _uiCamera = canvas.worldCamera;
        }
    }

    void Update()
    {
        // Decide target rotation based on whether we're hovering
        Quaternion targetRot = _baseRotation;
        Vector3 targetScale = _baseScale;

        if (_hovering)
        {
            // Convert last cursor pos to normalized [-1, 1] in both axes, 0 = center
            Vector2 size = _rt.rect.size;
            if (size.x > 0f && size.y > 0f)
            {
                // local cursor is in rect local space with (0,0) at rect center when using RectTransformUtility
                float nx = Mathf.Clamp(_lastLocalCursor.x / (size.x * 0.5f), -1f, 1f);
                float ny = Mathf.Clamp(_lastLocalCursor.y / (size.y * 0.5f), -1f, 1f);

                // Apply edge falloff shaping so corners are not too extreme
                if (edgeFalloff != 1f)
                {
                    nx = Mathf.Sign(nx) * Mathf.Pow(Mathf.Abs(nx), edgeFalloff);
                    ny = Mathf.Sign(ny) * Mathf.Pow(Mathf.Abs(ny), edgeFalloff);
                }

                // Balatro feel:
                // - cursor at top center tilts around X
                // - cursor at right tilts around Y
                float tiltX = enableX ? (ny * maxXAngle) : 0f; // top -> +X
                float tiltY = enableY ? (-nx * maxYAngle) : 0f; // right -> -Y for a natural lean
                float rollZ = enableZRoll ? (-nx * maxZRoll) : 0f; // subtle roll with horizontal

                if (invertX)
                    tiltX = -tiltX;
                if (invertY)
                    tiltY = -tiltY;
                if (invertZ)
                    rollZ = -rollZ;

                targetRot = _baseRotation * Quaternion.Euler(tiltX, tiltY, rollZ);
            }

            if (scaleOnHover)
            {
                targetScale = _baseScale * (1f + hoverScaleAmount);
            }
        }

        // Smooth rotate and scale
        float rotLerp = (_hovering ? tiltLerpSpeed : returnLerpSpeed) * Time.unscaledDeltaTime;
        _rt.localRotation = Quaternion.Slerp(
            _rt.localRotation,
            targetRot,
            1f - Mathf.Exp(-rotLerp)
        );

        float sclLerp = scaleLerpSpeed * Time.unscaledDeltaTime;
        _rt.localScale = Vector3.Lerp(_rt.localScale, targetScale, 1f - Mathf.Exp(-sclLerp));
    }

    public void OnPointerEnter(PointerEventData eventData)
    {
        _hovering = true;
        UpdateLocalCursor(eventData);
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        _hovering = false;
    }

    public void OnPointerMove(PointerEventData eventData)
    {
        if (!_hovering)
            return;
        UpdateLocalCursor(eventData);
    }

    void UpdateLocalCursor(PointerEventData eventData)
    {
        // Translate screen to local rect space centered at rect's pivot
        Vector2 localPoint;
        if (
            RectTransformUtility.ScreenPointToLocalPointInRectangle(
                _rt,
                eventData.position,
                _uiCamera,
                out localPoint
            )
        )
        {
            // Recenter to rect center regardless of pivot by subtracting pivot offset
            // localPoint from the utility is already centered at the rect's pivot,
            // so we need to shift to center coordinates:
            Vector2 pivotOffset = new Vector2(
                (0.5f - _rt.pivot.x) * _rt.rect.width,
                (0.5f - _rt.pivot.y) * _rt.rect.height
            );
            _lastLocalCursor = localPoint + pivotOffset;
        }
    }

    // Optional: call this at runtime if you change base transform via code and want the idle to match
    public void RecalibrateBase()
    {
        _baseRotation = _rt.localRotation;
        _baseScale = _rt.localScale;
    }
}
