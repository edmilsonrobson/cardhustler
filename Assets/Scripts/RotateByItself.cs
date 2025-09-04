using UnityEngine;

public class RotateByItself : MonoBehaviour
{
    public float rotationSpeed = 1f;
    public float amplitude = 15f;

    void Update()
    {
        float angleY = Mathf.Sin(Time.time * rotationSpeed) * amplitude;
        float angleX = Mathf.Cos(Time.time * rotationSpeed) * amplitude * 0.5f;
        transform.rotation = Quaternion.Euler(angleX, angleY, 0f);
    }
}
