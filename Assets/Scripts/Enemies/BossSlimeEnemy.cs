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

    //Properties for the material editig

    [SerializeField]
    Renderer rend;

    BossSpawn spawner;

    /// <summary>
    /// Weak point objects
    /// </summary>
    [SerializeField]
    GameObject firePoint, normalPoint, crystalPoint;

    /// <summary>
    /// The duration of the lerp between mats
    /// </summary>
    [SerializeField]
    float matLerpMax;

    float currentMatLerp;

    float crystalLerpValue;
    float fireLerpValue;

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
    public float currentChargeDuration;
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

    /// <summary>
    /// Normal Type Properties
    /// </summary>
    [SerializeField]
    float normalSlimeJumpForce;
    bool startAttack;
    bool endAttack;
    float cachedMoveSpeed;
    [SerializeField]
    float airSpeed;
    float previousY;
    [SerializeField]
    GameObject slamEffect;

    /// <summary>
    /// Crystal Type Properties
    /// </summary>
    [SerializeField]
    GameObject crystalProjectiles;
    [SerializeField]
    Vector3 projScale;

    /// <summary>
    /// Fire Trail Stuff
    /// </summary>
    public DecalRendererManager decalManager;
    float spawnTimer;

    /// <summary>
    /// Hits
    /// </summary>
    [SerializeField]
    GameObject crystalHit, crystalDeath, fireHit, fireDeath, normalHit, normalDeath;

    public override void Start()
    {
        base.Start();
        moveDirection = player.transform.position;
        currentChangeTime = changeTime;
        currentAttackTime = timeBetweenAttacks;
        currentChargeDuration = fireChargeDuration;
        decalManager = FindObjectOfType<DecalRendererManager>();
        currentMatLerp = 0;
        spawner = GameObject.Find("BossSpawner").GetComponent<BossSpawn>();
        
    }

    protected override void Update()
    {

        Death();

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
            spawnTimer -= Time.deltaTime;

            
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
                CrystalAttack();
                break;
            case Type.fire:
                //Periodically charge in a straight line, setting the ground on fire.
                FireAttack();
                break;
            case Type.normal:
                //Periodically jump up high and slam down.
                NormalAttack();
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
    private void NormalAttack()
    {
        if(!startAttack)
        {
            GetComponent<Rigidbody>().AddForce(0, normalSlimeJumpForce, 0);
            startAttack = true;
            cachedMoveSpeed = moveSpeed;
            previousY = transform.position.y;
        }
        else
        {
            if(transform.position.y > previousY)
            {
                moveSpeed = cachedMoveSpeed * airSpeed;
            }
            else
            {
                moveSpeed = cachedMoveSpeed;
            }

            previousY = transform.position.y;

            moveDirection = player.transform.position;
            base.Update();
        }

        if(endAttack)
        {
            startAttack = false;
            endAttack = false;
            currentAttackTime = timeBetweenAttacks;
            moveSpeed = cachedMoveSpeed;
            Instantiate(slamEffect, this.transform.position, slamEffect.transform.rotation);
        }
    }

    //Crystal attack very similar to the crystal slime
    private void CrystalAttack()
    {
        for (int i = 0; i < 5; i++)
        {
            GameObject tempEnemyProjectile = Instantiate(crystalProjectiles, transform.position + new Vector3(0.0f, 3.0f, 0.0f), Quaternion.identity);
            // ignores physics for the with the crystal slime and the enemy crystal slime projectiles 
            Physics.IgnoreCollision(this.gameObject.GetComponent<Collider>(), tempEnemyProjectile.GetComponent<Collider>());
            // setting scale of enemy projectile based on enemy size
            tempEnemyProjectile.transform.localScale = projScale;
            // setter to set variables from CrystalSlimeProject
            tempEnemyProjectile.GetComponent<CrystalSlimeProjectile>().SetVars(damageAmount);
            //setting the rotations of the projectiles so that it spawns in like a circle
            tempEnemyProjectile.transform.eulerAngles = new Vector3(tempEnemyProjectile.transform.eulerAngles.x, tempEnemyProjectile.transform.eulerAngles.y + (360.0f / 5.0f * i), tempEnemyProjectile.transform.eulerAngles.z);
            audioManager.Stop("Crystal Slime Projectile");
            // play SFX
            audioManager.Play("Crystal Slime Projectile", player.transform, this.transform);
            enemyAnims.SetTrigger("Shoot");
        }

        currentAttackTime = timeBetweenAttacks;
    }

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

        currentType = Type.crystal;
        crystalPoint.SetActive(true);
        firePoint.SetActive(false);
        normalPoint.SetActive(false);
        hitSpawn = crystalHit;
        deathSpawn = crystalDeath;
    }

    private void SwitchToFire()
    {

        currentType = Type.fire;
        crystalPoint.SetActive(false);
        firePoint.SetActive(true);
        normalPoint.SetActive(false);
        hitSpawn = fireHit;
        deathSpawn = fireDeath;
    }

    private void SwitchToNormal()
    {

        currentType = Type.normal;
        crystalPoint.SetActive(false);
        firePoint.SetActive(false);
        normalPoint.SetActive(true);
        hitSpawn = normalHit;
        deathSpawn = normalDeath;
    }

    private void UpdateMaterials()
    {
        if(currentMatLerp < matLerpMax)
        {
            currentMatLerp += Time.deltaTime;
        }
        else
        {
            currentMatLerp = matLerpMax;
        }    

        switch(currentType)
        {
            case Type.crystal:

                crystalLerpValue -= Time.deltaTime;
                fireLerpValue += Time.deltaTime;

                break;
            case Type.fire:

                crystalLerpValue -= Time.deltaTime;
                fireLerpValue -= Time.deltaTime;

                
                break;
            case Type.normal:

                crystalLerpValue += Time.deltaTime;
                fireLerpValue += Time.deltaTime;

                break;
        }

        crystalLerpValue = Mathf.Clamp(crystalLerpValue, -1, 1);
        fireLerpValue = Mathf.Clamp(fireLerpValue, -1, 1);


        rend.sharedMaterial.SetFloat("_FireTextureLerp", fireLerpValue);
        rend.sharedMaterial.SetFloat("_CrystalTextureLerp", crystalLerpValue);
        
        
    }

    public override void OnCollisionEnter(Collision collision)
    {

        if (currentType == Type.normal && startAttack && (collision.gameObject.layer == 10 || collision.gameObject.tag == "Player" || collision.gameObject.layer == 18) )
        {
            endAttack = true;
        }

        if(currentType == Type.fire)
        {
            if (spawnTimer <= 0.0f)
            {
                float angle = Random.Range(0.0f, Mathf.PI * 2.0f);
                Vector3 forward = new Vector3(Mathf.Cos(angle), 0.0f, Mathf.Sin(angle));
                // creates a plane which is the trail of the fire slime
                Vector3 trailPos = transform.position;
                trailPos.y -= 0.5f;

                GameObject tempEnemyTrail = Instantiate(enemyTrail, trailPos, Quaternion.LookRotation(Vector3.down, forward));
                tempEnemyTrail.transform.localScale = fireTrailScale;
                tempEnemyTrail.GetComponent<FireSlimeTrail>().SetVars(damageAmount);
                audioManager.Stop("Fire Slime Trail Initial");
                audioManager.Play("Fire Slime Trail Initial", player.transform, this.transform);
                spawnTimer = 1.0f;
            }
        }

        

        base.OnCollisionEnter(collision);
    }

    public override void OnTriggerEnter(Collider other)
    {
        base.OnTriggerEnter(other);
    }

    public override void OnTriggerStay(Collider other)
    {
        base.OnTriggerStay(other);
    }

    public override void Death()
    {
        if(currentHealth <= 0)
        {
            spawner.bossDead = true;
        }
        base.Death();

        
    }

    public override void TakeDamage(float damageToTake, List<Types> attackTypes, float extraSpawnScale = 1)
    {
        base.TakeDamage(damageToTake, attackTypes, 2);
    }

    public void PushAway()
    {
        //GetComponent<Rigidbody>().AddForce( -(player.transform.position - transform.position).normalized * pushForce);
        GetComponent<Rigidbody>().AddForce((player.transform.position - transform.position).normalized.x * pushForce, 5 * pushForce, (player.transform.position - transform.position).normalized.z * pushForce);
    }

}
