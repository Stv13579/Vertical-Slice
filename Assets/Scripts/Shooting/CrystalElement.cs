using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CrystalElement : BaseElementClass
{
    [SerializeField]
    GameObject crystalProjectile;

    public float damage;

    public float projectileSpeed;

    [SerializeField]
    AnimationCurve damageCurve;

    [SerializeField]
    float lifeTimer;

    // Update is called once per frame
    protected override void Update()
    {
        base.Update();
    }

    public override void ElementEffect()
    {
        base.ElementEffect();
        // for loop to instaniate it 5 times
        for (int i = 0; i < 5; i++)
        {
            GameObject newCrystalPro = Instantiate(crystalProjectile, transform.position, Camera.main.transform.rotation);
            //changes the angle of where they are being fired to
            newCrystalPro.transform.RotateAround(Camera.main.transform.position, Camera.main.transform.up, 10.0f * i - 25.0f);
            // setting the varibles from CrystalProj script
            newCrystalPro.GetComponent<CrystalProj>().SetVars(projectileSpeed, damage, damageCurve, lifeTimer, attackTypes);

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
