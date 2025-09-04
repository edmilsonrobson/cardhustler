using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class ShaderCode : MonoBehaviour
{
    Image image;
    Material m;
    CardVisual visual;

    // Start is called before the first frame update
    void Start()
    {
        image = GetComponent<Image>();
        m = new Material(image.material);
        image.material = m;
        visual = GetComponentInParent<CardVisual>();

        string[] editions = new string[4];
        editions[0] = "REGULAR";
        editions[1] = "POLYCHROME";
        editions[2] = "REGULAR";
        editions[3] = "NEGATIVE";

        for (int i = 0; i < image.material.enabledKeywords.Length; i++)
        {
            image.material.DisableKeyword(image.material.enabledKeywords[i]);
        }
        image.material.EnableKeyword("_EDITION_" + "NEGATIVE");
    }

    public bool dynamicRotation = false;
    float dynamicX = 0f;
    float dynamicY = 0f;
    public float dynamicSpeedMultiplier = 1f;

    void Update()
    {
        float xAngle,
            yAngle;

        if (dynamicRotation)
        {
            dynamicX += Time.deltaTime * 30f * dynamicSpeedMultiplier;
            dynamicY += Time.deltaTime * 20f * dynamicSpeedMultiplier;
            xAngle = Mathf.Sin(dynamicX * Mathf.Deg2Rad) * 20f;
            yAngle = Mathf.Cos(dynamicY * Mathf.Deg2Rad) * 20f;
        }
        else
        {
            Quaternion currentRotation = transform.parent.localRotation;
            Vector3 eulerAngles = currentRotation.eulerAngles;
            xAngle = eulerAngles.x;
            yAngle = eulerAngles.y;
        }

        xAngle = ClampAngle(xAngle, -90f, 90f);
        yAngle = ClampAngle(yAngle, -90f, 90f);

        m.SetVector(
            "_Rotation",
            new Vector2(
                ExtensionMethods.Remap(xAngle, -20, 20, -.5f, .5f),
                ExtensionMethods.Remap(yAngle, -20, 20, -.5f, .5f)
            )
        );
    }

    // Method to clamp an angle between a minimum and maximum value
    float ClampAngle(float angle, float min, float max)
    {
        if (angle < -180f)
            angle += 360f;
        if (angle > 180f)
            angle -= 360f;
        return Mathf.Clamp(angle, min, max);
    }
}
