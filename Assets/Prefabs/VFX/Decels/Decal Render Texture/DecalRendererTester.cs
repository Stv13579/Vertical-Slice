using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DecalRendererTester : MonoBehaviour
{
    public GameObject m_DecalPrefab;
    public DecalRendererManager m_DecalManager;

    public float m_DropLength = 2.0f;
    public float m_DropTimer = 0.0f;

    public float m_RandomSize = 10.0f;

    private void Awake()
    {
        m_DecalManager = FindObjectOfType<DecalRendererManager>();
        m_DropTimer = m_DropLength;
    }

    private void GenerateDecal()
    {
        float angle = Random.Range(0.0f, Mathf.PI * 2.0f);
        Vector3 forward = new Vector3(Mathf.Cos(angle), 0.0f, Mathf.Sin(angle));
        GameObject decal = Instantiate(m_DecalPrefab, transform.position, Quaternion.LookRotation(Vector3.down, forward));
        GeneratedDecal generatedDecal = decal.GetComponent<GeneratedDecal>();

        generatedDecal.Setup(m_DecalManager);
    }

    private void Update()
    {
        m_DropTimer -= Time.deltaTime;
        if (m_DropTimer < 0.0f)
        {
            m_DropTimer = m_DropLength;
            Vector3 pos = new Vector3(transform.position.x, transform.position.y, transform.position.z);
            pos.x = Random.Range(-m_RandomSize, m_RandomSize);
            pos.z = Random.Range(-m_RandomSize, m_RandomSize);
            transform.position = pos;
            GenerateDecal();
        }
    }
}
