using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Visutronik
{
    public class DemoCardShow : MonoBehaviour
    {
        List<Transform> Cards = new List<Transform>();

        float MaxRot = 25;
        float RotX = 0;
        float RotY = 0;
        float RotSpeed = 10f;
        bool PositivX = true;
        bool PositivY = true;
        bool TurnX = true;

        // Start is called before the first frame update
        void Start()
        {
            Transform tThis = this.gameObject.transform;

            foreach (Transform t in this.GetComponentsInChildren<Transform>(true))
            {
                if (t != tThis)
                {
                    Cards.Add(t);
                }
            }
        }

        // Update is called once per frame
        void Update()
        {
            if (TurnX == true)
            {
                RotX += (PositivX == true ? RotSpeed : RotSpeed * -1) * Time.deltaTime;
            }
            else
            {
                RotY += (PositivY == true ? RotSpeed : RotSpeed * -1) * Time.deltaTime;
            }

            foreach (Transform t in Cards)
            {
                t.localRotation = Quaternion.Euler(RotX, RotY, 0);
            }

            if (TurnX == true)
            {
                if (PositivX == true)
                {
                    if (RotX > MaxRot)
                    {
                        PositivX = false;
                        TurnX = false;
                    }
                }
                else
                {
                    if (RotX < MaxRot * -1)
                    {
                        PositivX = true;
                        TurnX = false;
                    }
                }
            }
            else
            {
                if (PositivY == true)
                {
                    if (RotY > MaxRot)
                    {
                        PositivY = false;
                        TurnX = true;
                    }
                }
                else
                {
                    if (RotY < MaxRot * -1)
                    {
                        PositivY = true;
                        TurnX = true;
                    }
                }
            }
        }
    }

}