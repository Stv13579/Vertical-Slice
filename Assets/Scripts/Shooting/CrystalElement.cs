using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CrystalElement : BaseElementClass
{
    [SerializeField]
    GameObject crystalProjectile;

    public float damage;

    public float projectileSpeed;

    // Update is called once per frame
    void Update()
    {
        base.Update();
    }

    public override void ElementEffect()
    {
        base.ElementEffect();
        for (int i = 0; i < 5; i++)
        {
            GameObject newCrystalPro = Instantiate(crystalProjectile, transform.position, Camera.main.transform.rotation);
            newCrystalPro.transform.rotation = Quaternion.Euler(newCrystalPro.transform.rotation.x, newCrystalPro.transform.rotation.y + (10.0f * i), newCrystalPro.transform.rotation.z);
        }

    }

    public override void ActivateVFX()
    {
        base.ActivateVFX();
    }

    protected override void StartAnims(string animationName)
    {
        base.StartAnims(animationName);
        playerHand.SetTrigger(animationName);

    }
}
