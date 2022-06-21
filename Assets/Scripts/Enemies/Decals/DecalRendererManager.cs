using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DecalRendererManager : MonoBehaviour
{
    [SerializeField]
    private GameObject decalRendererPrefab;
    [SerializeField]
    private Vector3 originPosition = new Vector3(0.0f, 0.0f, 0.0f);
    [SerializeField]
    private float offset = 1.0f;

    [SerializeField]
    private int slots = 10;
    [SerializeField]
    private bool[] available;
    [SerializeField]
    private DecalRenderer[] decalRenderers;

    private void OnValidate()
    {
        available = new bool[slots];
        decalRenderers = new DecalRenderer[slots];
        for (int i = 0; i < slots; i++)
        {
            available[i] = true;
        }
    }

    // instanciates the cameras and the material with the animation
    // leaves them off at the a start when not being used
    private void Awake()
    {
        for (int i = 0; i < slots; i++)
        {
            GameObject newRenderer = Instantiate(decalRendererPrefab, transform.position, transform.rotation);

            newRenderer.name = $"Decal Renderer [{i}]";
            
            
            newRenderer.transform.parent = transform;
            newRenderer.transform.localPosition = originPosition + new Vector3(offset * i, 0.0f, 0.0f);

            decalRenderers[i] = newRenderer.GetComponent<DecalRenderer>();

            decalRenderers[i].FirstSetup(this);
        }
    }

    //generates the material with animation and turns on the camera
    public DecalRenderer GenerateDecalRenderer(Material _originalMaterial)
    {
        int firstAvailable = -1;
        for (int i = 0; i < available.Length; i++)
        {
            if (available[i])
            {
                firstAvailable = i;
                break;
            }
        }

        // first slot becomes unavailable
        available[firstAvailable] = false;
        // sets up the materials
        decalRenderers[firstAvailable].Setup(_originalMaterial);

        return decalRenderers[firstAvailable];
    }

    // release the decals before its been destroyed
    public void ReleaseDecalRenderer(DecalRenderer _renderer)
    {
        // checks if its the right decal renderer and releases it if its the right one
        for (int i = 0; i < decalRenderers.Length; i++)
        {
            if (decalRenderers[i] == _renderer)
            {
                ReleaseDecalRenderer(i);
            }
        }
    }

    // disables camera and sets a spot free
    public void ReleaseDecalRenderer(int _index)
    {
        decalRenderers[_index].Release();
        available[_index] = true;
    }
}
