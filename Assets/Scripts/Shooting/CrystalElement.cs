using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CrystalElement : BaseElementClass
{
    [SerializeField]
    GameObject crystalProjectile;

    public float damage;

    public float projectileSpeed;


    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        base.Update();
    }

    public override void ElementEffect()
    {
        base.ElementEffect();

        GameObject newCrystalPro = Instantiate(crystalProjectile, transform.position, Camera.main.transform.rotation);

    }

    public override void ActivateVFX()
    {
        base.ActivateVFX();
    }

    protected override void StartAnims(string animationName)
    {
        base.StartAnims(animationName);


    }
}
