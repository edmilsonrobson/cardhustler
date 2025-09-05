using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent(typeof(BoxCollider))]
public class IsoPlayerMovement : MonoBehaviour
{
    public static IsoPlayerMovement Instance { get; private set; }

    [SerializeField]
    private float moveSpeed = 5f;

    [SerializeField]
    private LayerMask obstacleMask;

    [SerializeField]
    private float skin = 0.02f;

    [Header("Visual facing")]
    [SerializeField]
    private Transform visualRoot; // assign Player_Visual

    [SerializeField]
    private float rotateSpeedDeg = 720f;

    private InputSystem_Actions inputActions;
    private BoxCollider box;

    private Vector3 isoUp = new Vector3(1, 0, 1).normalized;
    private Vector3 isoRight = new Vector3(1, 0, -1).normalized;

    private PlayerInteractor playerInteractor;

    [SerializeField]
    private PlayerVisual playerVisual;

    private void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(gameObject);
            return;
        }
        Instance = this;
        inputActions = new InputSystem_Actions();
        box = GetComponent<BoxCollider>();
        playerInteractor = GetComponent<PlayerInteractor>();
    }

    private void OnEnable() => inputActions.Enable();

    private void OnDisable() => inputActions.Disable();

    private void Update()
    {
        if (inputActions.Player.Interact.WasPressedThisFrame())
            playerInteractor.OnInteract();

        Vector2 moveInput = inputActions.Player.Move.ReadValue<Vector2>();
        Vector3 wishDir = (isoRight * moveInput.x + isoUp * moveInput.y);
        playerVisual.SetIsWalking(moveInput.sqrMagnitude > 0.0001f);
        if (wishDir.sqrMagnitude < 0.0001f)
            return;

        wishDir.Normalize();
        Vector3 delta = wishDir * moveSpeed * Time.deltaTime;

        Bounds b = box.bounds;
        Vector3 halfExtents = b.extents - Vector3.one * 0.001f;
        Quaternion orientation = transform.rotation;

        Vector3 center = b.center;
        Vector3 applied = Vector3.zero;

        Vector3 dx = new Vector3(delta.x, 0f, 0f);
        ApplyAxis(ref center, halfExtents, orientation, dx, ref applied.x);

        Vector3 dz = new Vector3(0f, 0f, delta.z);
        ApplyAxis(ref center, halfExtents, orientation, dz, ref applied.z);

        transform.position += applied;

        // rotate visual to face move direction (keeps collider axis-aligned)
        if ((wishDir.x * wishDir.x + wishDir.z * wishDir.z) > 0.0001f)
        {
            Vector3 face = new Vector3(wishDir.x, 0f, wishDir.z);
            Quaternion target = Quaternion.LookRotation(face, Vector3.up);
            transform.rotation = Quaternion.RotateTowards(
                transform.rotation,
                target,
                rotateSpeedDeg * Time.deltaTime
            );
        }

        DepenetrateIfNeeded();
    }

    private void ApplyAxis(
        ref Vector3 center,
        Vector3 halfExtents,
        Quaternion orientation,
        Vector3 move,
        ref float appliedComponent
    )
    {
        float distance = move.magnitude;
        if (distance <= 0f)
            return;

        Vector3 dir = move.normalized;

        bool hit = Physics.BoxCast(
            center,
            halfExtents,
            dir,
            out RaycastHit hitInfo,
            orientation,
            distance + skin,
            obstacleMask,
            QueryTriggerInteraction.Ignore
        );

        if (hit)
        {
            float allowed = Mathf.Max(0f, hitInfo.distance - skin);
            appliedComponent = allowed * dir.x + allowed * dir.z;
            center += dir * allowed;
            Debug.DrawRay(center, dir * 0.2f, Color.red, 0.1f);
        }
        else
        {
            appliedComponent = distance * dir.x + distance * dir.z;
            center += dir * distance;
            Debug.DrawRay(center, dir * 0.2f, Color.green, 0.1f);
        }
    }

    private void DepenetrateIfNeeded()
    {
        Bounds b = box.bounds;
        Vector3 halfExtents = b.extents - Vector3.one * 0.001f;

        Collider[] hits = Physics.OverlapBox(
            b.center,
            halfExtents,
            transform.rotation,
            obstacleMask,
            QueryTriggerInteraction.Ignore
        );
        foreach (var other in hits)
        {
            if (other == null || other.transform == transform)
                continue;

            if (
                Physics.ComputePenetration(
                    box,
                    transform.position,
                    transform.rotation,
                    other,
                    other.transform.position,
                    other.transform.rotation,
                    out Vector3 direction,
                    out float distance
                )
            )
            {
                Vector3 fix = direction * Mathf.Max(0f, distance + skin);
                transform.position += fix;
            }
        }
    }

    public void BlockPlayerActions()
    {
        inputActions.Player.Disable();
    }

    public void UnblockPlayerActions()
    {
        inputActions.Player.Enable();
    }
}
