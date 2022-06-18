using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestroyAfterSeconds : MonoBehaviour
{
    public float m_Timer = 2.0f;

    private void Update()
    {
        m_Timer -= Time.deltaTime;
        if (m_Timer < 0.0f)
        {
            Destroy(gameObject);
        }
    }
}
