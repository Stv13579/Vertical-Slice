using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DecalRendererManager : MonoBehaviour
{
    public GameObject m_DecalRendererPrefab;

    public Vector3 m_OriginPosition = new Vector3(0.0f, 0.0f, 0.0f);
    public float m_Offset = 1.0f;
    public int m_Slots = 10;

    public bool[] m_Available;
    public DecalRenderer[] m_DecalRenderers;

    private void OnValidate()
    {
        m_Available = new bool[m_Slots];
        m_DecalRenderers = new DecalRenderer[m_Slots];
        for (int i = 0; i < m_Slots; i++)
        {
            m_Available[i] = true;
        }
    }

    private void Awake()
    {
        for (int i = 0; i < m_Slots; i++)
        {
            GameObject newRenderer = Instantiate(m_DecalRendererPrefab, transform.position, transform.rotation);
            newRenderer.name = $"Decal Renderer [{i}]";
            
            newRenderer.transform.parent = transform;
            newRenderer.transform.localPosition = m_OriginPosition + new Vector3(m_Offset * i, 0.0f, 0.0f);

            m_DecalRenderers[i] = newRenderer.GetComponent<DecalRenderer>();

            m_DecalRenderers[i].FirstSetup(this);
        }
    }

    //generates the decal
    public DecalRenderer GenerateDecalRenderer(Material _originalMaterial)
    {
        int firstAvailable = -1;
        for (int i = 0; i < m_Available.Length; i++)
        {
            if (m_Available[i])
            {
                firstAvailable = i;
                break;
            }
        }

        // first slot becomes unavailable
        m_Available[firstAvailable] = false;
        // sets up the materials
        m_DecalRenderers[firstAvailable].Setup(_originalMaterial);

        return m_DecalRenderers[firstAvailable];
    }

    // release the decals before its been destroyed
    public void ReleaseDecalRenderer(DecalRenderer _renderer)
    {
        // checks if its the right decal renderer and releases it if its the right one
        for (int i = 0; i < m_DecalRenderers.Length; i++)
        {
            if (m_DecalRenderers[i] == _renderer)
            {
                ReleaseDecalRenderer(i);
            }
        }
    }

    // releases the decalrenderer and sets a spot free
    public void ReleaseDecalRenderer(int _index)
    {
        m_DecalRenderers[_index].Release();
        m_Available[_index] = true;
    }
}
