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

    [SerializeField]
    float timeBetweenAttacks;
    float currentAttackTime;

    /// <summary>
    /// Fire Type Properties
    /// </summary>
    [SerializeField]
    float fireChargeDuration;
    float currentChargeDuration;
    [SerializeField]
    float fireChargeSpeed;
    Vector3 chargeVec;
    [SerializeField]
    private LayerMask trailLayerMask;
    float trailCastDistance = 1.0f;
    float backCastDistance = 0.1f;
    float trailOffset = 0.01f;
    [SerializeField]
    private Vector3 fireTrailScale;
    public GameObject enemyTrail;


    public override void Start()
    {
        base.Start();
        moveDirection = player.transform.position;
        currentChangeTime = changeTime;
        mat1 = rend.material;
        mat2 = rend.material;
        currentAttackTime = timeBetweenAttacks;
        currentChargeDuration = fireChargeDuration;
    }

    protected override void Update()
    {
        if(!ExecuteAttack())
        {
            moveDirection = player.transform.position;
            base.Update();

            chargeVec = (moveDirection - transform.position).normalized;

            SwitchType();
        }

        //If the boss is on fire mode, make the fire trail
        if(currentType == Type.fire)
        {
            RaycastHit hit;
            Vector3 Back = new Vector3(0f, backCastDistance, 0f);
            // check of the ray cast line is hitting the ground
            if (Physics.Raycast(transform.position + Back, -transform.up, out hit, trailCastDistance + backCastDistance, trailLayerMask))
            {
                // rotate the go if it hits a flat surface or an angled surface
                Quaternion newrotation = Quaternion.FromToRotation(transform.up, hit.normal);
                // creates a plane which is the trail of the fire slime
                GameObject tempEnemyTrail = Instantiate(enemyTrail, hit.point + hit.normal * trailOffset, newrotation);
                // sets the damage
                tempEnemyTrail.GetComponent<FireSlimeTrail>().SetVars(damageAmount);
                // sets the scale of the firetrail as there are different sizes of enemies
                tempEnemyTrail.transform.localScale = fireTrailScale;
                audioManager.Stop("Fire Slime Trail Initial");
                audioManager.Play("Fire Slime Trail Initial", player.transform, this.transform);
            }
        }
        
        
        UpdateMaterials();
    }

    //Execute the attack based on the type it currently is
    private bool ExecuteAttack()
    {
        if(currentAttackTime > 0)
        {
            currentAttackTime -= Time.deltaTime;
            return false;
        }

        switch (currentType)
        {
            case Type.crystal:
                //Slowly send crystals out which bombard the arena, giving some telegraph to their landing zones
                currentAttackTime = timeBetweenAttacks;
                break;
            case Type.fire:
                //Periodically charge in a straight line, setting the ground on fire.
                FireAttack();
                break;
            case Type.normal:
                //Periodically jump up high and slam down.
                currentAttackTime = timeBetweenAttacks;
                break;
            default:
                break;
        }

        //Reset attack time when ready
        //currentAttackTime = timeBetweenAttacks;
        return true;

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

    //Attacks

    private void FireAttack()
    {
        if (currentChargeDuration > 0)
        {
            Vector3 moveVec = chargeVec * moveSpeed * fireChargeSpeed * Time.deltaTime;
            moveVec.y = 0;
            moveVec.y -= 1 * Time.deltaTime;
            transform.position += moveVec;
            currentChargeDuration -= Time.deltaTime;
        }
        else
        {
            currentChargeDuration = fireChargeDuration;
            currentAttackTime = timeBetweenAttacks;
        }
    }


    //Change mats
    private void SwitchToCrystal()
    {
        mat2 = crystalMat;
        currentType = Type.crystal;
    }

    private void SwitchToFire()
    {
        mat2 = fireMat;
        currentType = Type.fire;
    }

    private void SwitchToNormal()
    {
        mat2 = normalMat;
        currentType = Type.normal;
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
