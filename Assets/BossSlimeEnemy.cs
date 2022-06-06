using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BossSlimeEnemy : NormalSlimeEnemy
{
    public enum Type
    {
        normal,
        fire,
        crystal
    }
    public Type currentType = Type.normal;

    //Properties for the material editing
    Material mat1;
    Material mat2;

    [SerializeField]
    Material normalMat;
    [SerializeField]
    Material fireMat;
    [SerializeField]
    Material crystalMat;

    [SerializeField]
    Renderer rend;

    /// <summary>
    /// The duration of the lerp between mats
    /// </summary>
    [SerializeField]
    float matLerpMax;

    float currentMatLerp;

    //Properties for type transitions
    /// <summary>
    /// The time it takes before a type switch occurs
    /// </summary>
    [SerializeField]
    float changeTime;
    float currentChangeTime;

    public override void Start()
    {
        base.Start();
        moveDirection = player.transform.position;
        currentChangeTime = changeTime;
        mat1 = rend.material;
        mat2 = rend.material;
    }

    protected override void Update()
    {
        moveDirection = player.transform.position;
        base.Update();

        ExecuteAttack();
        
        SwitchType();
        UpdateMaterials();
    }

    //Execute the attack based on the type it currently is
    private void ExecuteAttack()
    {
        switch (currentType)
        {
            case Type.crystal:
                //Slowly send crystals out which bombard the arena, giving some telegraph to their landing zones


                break;
            case Type.fire:
                //Periodically charge in a straight line, setting the ground on fire.

                break;
            case Type.normal:
                //Periodically jump up high and slam down.

                break;
            default:
                break;
        }
    }

    //Choose a type at random, and switch up weak point, mats and enum
    private void SwitchType()
    {
        if(currentChangeTime < changeTime)
        {
            currentChangeTime += Time.deltaTime;

            return;
        }

        currentChangeTime = 0;

        //Set material lerping properties
        currentMatLerp = 0;
        mat1 = mat2;

        int choice = Random.Range(0, 2);

        switch (currentType)
        {
            case Type.crystal:

                if (choice == 0)
                {
                    SwitchToFire();
                }
                else
                {
                    SwitchToNormal();
                }

                break;
            case Type.fire:

                if (choice == 0)
                {
                    SwitchToCrystal();
                }
                else
                {
                    SwitchToNormal();
                }

                break;
            case Type.normal:

                if (choice == 0)
                {
                    SwitchToFire();
                }
                else
                {
                    SwitchToCrystal();
                }

                break;
            default:

                break;
        }
    }


    //Change mats
    private void SwitchToCrystal()
    {
        mat2 = crystalMat;
    }

    private void SwitchToFire()
    {
        mat2 = fireMat;
    }

    private void SwitchToNormal()
    {
        mat2 = normalMat;
    }

    private void UpdateMaterials()
    {
        if(currentMatLerp < matLerpMax)
        {
            currentMatLerp += Time.deltaTime;
        }

        rend.material = mat2;
        
    }

}
