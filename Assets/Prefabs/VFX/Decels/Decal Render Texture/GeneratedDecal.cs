using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GeneratedDecal : MonoBehaviour
{
    public MeshRenderer m_Decal;
    public DecalRendererManager m_DecalManager;
    public DecalRenderer m_DecalRenderer;

    public float m_LifeLength;
    public float m_LifeTimer;

    public Material m_EffectMaterial;
    public Material m_DecalMaterialInstance;

    public AnimationCurve m_Animation = AnimationCurve.EaseInOut(1.0f, 1.0f, 0.0f, 0.0f);

    //public float m_AnimationValue; // <-- animate this to move it on the actual renderer

    public void Setup(DecalRendererManager _manager)
    {
        m_DecalManager = _manager;
        m_DecalRenderer = m_DecalManager.GenerateDecalRenderer(m_EffectMaterial); 
        
        m_DecalMaterialInstance = new Material(m_Decal.sharedMaterial);
        m_DecalMaterialInstance.SetTexture("_MainTex", m_DecalRenderer.m_RenderTexture);
        m_Decal.material = m_DecalMaterialInstance;
    }

    private void Update()
    {
        m_LifeTimer += Time.deltaTime;

        m_DecalRenderer.m_MaterialInstance.SetFloat("_CenterPoint", m_Animation.Evaluate(m_LifeTimer / m_LifeLength));
        //m_DecalRenderer.m_MaterialInstance.SetFloat("_CenterPoint", m_AnimationValue); // <-- pass value through here from animator

        if (m_LifeTimer > m_LifeLength)
        {
            m_DecalManager.ReleaseDecalRenderer(m_DecalRenderer);
            Destroy(gameObject);
        }
    }
}
