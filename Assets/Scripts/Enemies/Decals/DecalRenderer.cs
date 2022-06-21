using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DecalRenderer : MonoBehaviour
{
    public DecalRendererManager manager;

    public int decalIndex;

    public Camera orthoCamera;

    [SerializeField]
    private Material decalMaterialOriginal;

    public Material decalMaterial;

    [SerializeField]
    private MeshRenderer quad;

    [SerializeField]
    private int renderTextureSize = 128;

    public RenderTexture renderTexture;
    public Material materialInstance;


    // turns the camera off
    public void Release()
    {
        orthoCamera.enabled = false;
    }
    // sets ups the decal renderers once
    public void FirstSetup(DecalRendererManager _manager)
    {
        //orthoCamera = GetComponentInChildren<Camera>();
        //quad = GetComponentInChildren<MeshRenderer>();
        manager = _manager;

        renderTexture = new RenderTexture(renderTextureSize, renderTextureSize, 0, UnityEngine.Experimental.Rendering.DefaultFormat.LDR);
        renderTexture.antiAliasing = 1; // none to keep cheap - probably don't change this
        renderTexture.autoGenerateMips = false; // could change this so it looks better at a distance!
        renderTexture.anisoLevel = 0; // this will make it look worse at oblique angles (i.e. you're close to the ground and it's on the ground so maybe change (bump it up))
        renderTexture.filterMode = FilterMode.Bilinear; // this is fine, don't change unless you want pixel art style
        renderTexture.useMipMap = false; // change with the auto generate mips above
        renderTexture.graphicsFormat = UnityEngine.Experimental.Rendering.GraphicsFormat.R8G8B8A8_UNorm; // probably fine
        renderTexture.depth = 0;
        decalMaterial = new Material(decalMaterialOriginal);
        decalMaterial.SetTexture("_MainTex", renderTexture);
        orthoCamera.targetTexture = renderTexture;

        orthoCamera.enabled = false;
    }
    // sets up the decal renderer during updates
    public void Setup(Material _originalMaterial)
    {
        materialInstance = new Material(_originalMaterial);
        materialInstance.name = $"{_originalMaterial.name} [Instance]";
        quad.material = materialInstance;

        orthoCamera.enabled = true;
    }
}
