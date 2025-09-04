using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerInteractor : MonoBehaviour
{
    [Header("Scan")]
    public float radius = 1.75f;

    [Range(1f, 179f)]
    public float angleDeg = 60f; // cone half-angle
    public LayerMask interactableMask;
    public LayerMask losObstaclesMask; // walls etc. (optional)
    public bool requireLineOfSight = true;

    [Header("Debug")]
    public bool debugDraw = true;

    private Interactable current;

    // Reuse buffer to avoid GC
    private readonly Collider[] hits = new Collider[16];

    private InputSystem_Actions inputActions;

    public void OnInteract()
    {
        if (current != null)
            current.Interact(transform);
    }

    private void Awake()
    {
        inputActions = new InputSystem_Actions();
    }

    private void Update()
    {
        Interactable best = FindFrontInteractable();

        if (best != current)
        {
            current?.OnInteractEnd();
            current = best;
            current?.OnInteractStart();
        }
    }

    private Interactable FindFrontInteractable()
    {
        int count = Physics.OverlapSphereNonAlloc(
            transform.position,
            radius,
            hits,
            interactableMask,
            QueryTriggerInteraction.Ignore
        );
        if (count == 0)
            return null;

        Vector3 origin = transform.position;
        Vector3 fwd = transform.forward;
        fwd.y = 0f;
        fwd.Normalize();
        float cosThresh = Mathf.Cos(angleDeg * Mathf.Deg2Rad);

        Interactable best = null;
        float bestDist = float.MaxValue;

        for (int i = 0; i < count; i++)
        {
            var col = hits[i];
            if (!col)
                continue;
            if (!col.TryGetComponent<Interactable>(out var it))
                continue;

            Vector3 target = it.GetFocusPosition();
            Vector3 to = target - origin;
            to.y = 0f;
            float dist = to.magnitude;
            if (dist <= 0.0001f)
                continue;

            Vector3 dir = to / dist;
            float dot = Vector3.Dot(fwd, dir);
            if (dot < cosThresh)
                continue; // outside cone

            if (requireLineOfSight)
            {
                // Raycast slightly above ground to avoid floor hits
                Vector3 rayStart = origin + Vector3.up * 0.1f;
                Vector3 rayEnd = target + Vector3.up * 0.1f;
                Vector3 rayDir = (rayEnd - rayStart).normalized;
                float rayDist = Vector3.Distance(rayStart, rayEnd);

                if (
                    Physics.Raycast(
                        rayStart,
                        rayDir,
                        out RaycastHit hit,
                        rayDist,
                        losObstaclesMask,
                        QueryTriggerInteraction.Ignore
                    )
                )
                {
                    // blocked by something that isn't this interactable
                    if (hit.collider != col)
                        continue;
                }
            }

            if (dist < bestDist)
            {
                bestDist = dist;
                best = it;
            }

            if (debugDraw)
                Debug.DrawLine(
                    origin + Vector3.up * 0.1f,
                    target + Vector3.up * 0.1f,
                    Color.yellow,
                    0f,
                    false
                );
        }

        if (debugDraw)
        {
            // visualize cone
            DebugDrawCone(origin, fwd, radius, angleDeg, Color.cyan);
        }

        return best;
    }

    private void OnDrawGizmosSelected()
    {
        if (!debugDraw)
            return;
        Gizmos.color = Color.cyan;
        Gizmos.DrawWireSphere(transform.position, radius);
        if (current)
        {
            Gizmos.color = Color.green;
            Gizmos.DrawSphere(current.GetFocusPosition(), 0.05f);
        }
    }

    private static void DebugDrawCone(
        Vector3 origin,
        Vector3 fwd,
        float radius,
        float angleDeg,
        Color color
    )
    {
        Vector3 right = Quaternion.AngleAxis(angleDeg, Vector3.up) * fwd;
        Vector3 left = Quaternion.AngleAxis(-angleDeg, Vector3.up) * fwd;
        Debug.DrawRay(origin, fwd.normalized * radius, color, 0f, false);
        Debug.DrawRay(origin, right.normalized * radius, color, 0f, false);
        Debug.DrawRay(origin, left.normalized * radius, color, 0f, false);
    }
}
