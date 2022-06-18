using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DecalRenderer : MonoBehaviour
{
    public DecalRendererManager m_Manager;
    public int m_DecalIndex;

    public Camera m_Camera;
    public MeshRenderer m_Quad;

    public int m_RenderTextureSize = 128;

    public RenderTexture m_RenderTexture;
    public Material m_MaterialInstance;

    public void Release()
    {
        m_Camera.enabled = false;
    }

    public void FirstSetup(DecalRendererManager _manager)
    {
        m_Manager = _manager;

        m_RenderTexture = new RenderTexture(m_RenderTextureSize, m_RenderTextureSize, 0, UnityEngine.Experimental.Rendering.DefaultFormat.LDR);
        m_RenderTexture.antiAliasing = 1; // none to keep cheap - probably don't change this
        m_RenderTexture.autoGenerateMips = false; // could change this so it looks better at a distance!
        m_RenderTexture.anisoLevel = 0; // this will make it look worse at oblique angles (i.e. you're close to the ground and it's on the ground so maybe change (bump it up))
        m_RenderTexture.filterMode = FilterMode.Bilinear; // this is fine, don't change unless you want pixel art style
        m_RenderTexture.useMipMap = false; // change with the auto generate mips above
        m_RenderTexture.graphicsFormat = UnityEngine.Experimental.Rendering.GraphicsFormat.R8G8B8A8_UNorm; // probably fine
        m_RenderTexture.depth = 0;

        m_Camera.targetTexture = m_RenderTexture;

        m_Camera.enabled = false;
    }

    public void Setup(Material _originalMaterial)
    {
        m_MaterialInstance = new Material(_originalMaterial);
        m_MaterialInstance.name = $"{_originalMaterial.name} [Instance]";
        m_Quad.material = m_MaterialInstance;

        m_Camera.enabled = true;
    }
}
