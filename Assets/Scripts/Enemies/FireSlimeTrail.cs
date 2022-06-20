using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireSlimeTrail : MonoBehaviour
{
    private float trailDamage;
    private float trailDuration = 0.0f;
    private float trailLength = 5.0f;

    static float trailDamageTicker = 1.0f;
    static int frame = 0;

    private AudioManager audioManager;
    private GameObject player;

    [SerializeField]
    private MeshRenderer decal;

    private DecalRendererManager decalManager;

    public DecalRenderer decalRenderer;

    [SerializeField]
    private Material effectMaterial;

    [SerializeField]
    private Material decalMaterialInstance;

    [SerializeField]
    private AnimationCurve fireTrailAnimation = AnimationCurve.EaseInOut(1.0f, 1.0f, 0.0f, 0.0f);

    [SerializeField]
    private GameObject fireParticles;
    //public float m_AnimationValue; // <-- animate this to move it on the actual renderer
    private void Start()
    {
        player = GameObject.Find("Player");
        audioManager = GameObject.Find("Audio Manager").GetComponent<AudioManager>();
        decalManager = FindObjectOfType<DecalRendererManager>();

        decalRenderer = decalManager.GenerateDecalRenderer(effectMaterial);
        decalMaterialInstance = new Material(decal.sharedMaterial);
        decalMaterialInstance.SetTexture("_MainTex", decalRenderer.renderTexture);
        decal.material = decalMaterialInstance;

        audioManager.Stop("Fire Slime Trail Alive");
        audioManager.Play("Fire Slime Trail Alive", player.transform, this.transform);
    }
    // Update is called once per frame
    void Update()
    {
        trailDuration += Time.deltaTime;
        decalRenderer.materialInstance.SetFloat("_CenterPoint", fireTrailAnimation.Evaluate(trailDuration / trailLength));
        //m_DecalRenderer.m_MaterialInstance.SetFloat("_CenterPoint", m_AnimationValue); // <-- pass value through here from animator
        Countdown();
        // deletes the trail after trailDuration >= trailLength
        if (trailDuration >= trailLength)
        {
            audioManager.Stop("Fire Slime Trail Alive");
            decalManager.ReleaseDecalRenderer(decalRenderer);
            Destroy(gameObject);
        }
        // turn on particle
        if(trailDuration >= 1.0f)
        {
            fireParticles.SetActive(true);
        }
        // turn off particle
        if (trailDuration >= 4.0f)
        {
            fireParticles.SetActive(false);
        }
    }

    static void Countdown()
    {
        if(frame != Time.frameCount)
        {
            trailDamageTicker -= Time.deltaTime;
            frame = Time.frameCount;
        }
    }

    // setter
    public void SetVars(float damage)
    {
        trailDamage = damage;
    }

    // player takes damage when entering the trail
    //private void OnTriggerEnter(Collider other)
    //{
    //    if(other.GetComponent<PlayerClass>())
    //    {
    //        other.GetComponent<PlayerClass>().ChangeHealth(-trailDamage);
    //        audioManager.Stop("Player Damage");
    //        audioManager.Play("Player Damage");
    //    }
    //}

    // player takes damage over time when they are still in the trail
    private void OnTriggerStay(Collider other)
    {
        if (other.GetComponent<PlayerClass>())
        {
            if(trailDamageTicker <= 0)
            {
                other.GetComponent<PlayerClass>().ChangeHealth(-trailDamage);
                trailDamageTicker = 1.0f;
                audioManager.Stop("Player Damage");
                audioManager.Play("Player Damage");
            }
        }
    }
}
