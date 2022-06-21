using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CrystalElement : BaseElementClass
{
    [SerializeField]
    private GameObject crystalProjectile;

    [SerializeField]
    private float damage;
    public float damageMultiplier = 1;

    [SerializeField]
    private float projectileSpeed;

    [SerializeField]
    private AnimationCurve damageCurve;

    [SerializeField]
    private float lifeTimer;

    [SerializeField]
    private float damageLimit;

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
            for (int j = 0; j < 2; j++)
            {

                GameObject newCrystalPro = Instantiate(crystalProjectile, shootingTranform.position, Camera.main.transform.rotation);
                //changes the angle of where they are being fired to
                newCrystalPro.transform.RotateAround(shootingTranform.position, Camera.main.transform.up, 3.0f * i - 5.0f);
                newCrystalPro.transform.RotateAround(shootingTranform.position, Camera.main.transform.right, 3.0f * j - 5.0f);

                // setting the varibles from CrystalProj script
                newCrystalPro.GetComponent<CrystalProj>().SetVars(projectileSpeed, damage * damageMultiplier, damageCurve, lifeTimer, attackTypes, damageLimit);
            }
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
