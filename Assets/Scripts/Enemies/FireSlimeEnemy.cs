using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FireSlimeEnemy : NormalSlimeEnemy
{
    public GameObject enemyTrail;
    [SerializeField]
    private LayerMask trailLayerMask;
    [SerializeField]
    private Vector3 enemyFireTrailScale;
    [SerializeField]
    private DecalRendererManager decalManager;
    [SerializeField]
    private float spawnTimer;
    [SerializeField]
    private float spawnTimerLength = 1.0f;
    public override void Start()
    {
        base.Start();
        decalManager = FindObjectOfType<DecalRendererManager>();
    }
    new private void Update()
    {
        base.Update();
        spawnTimer -= Time.deltaTime;
    }
    public override void Attacking()
    {
        base.Attacking();
    }

    public void FireSlimeAttack()
    {
        if (spawnTimer <= 0.0f)
        { 
            float angle = Random.Range(0.0f, Mathf.PI * 2.0f);
            Vector3 forward = new Vector3(Mathf.Cos(angle), 0.0f, Mathf.Sin(angle));
            // creates a plane which is the trail of the fire slime
            GameObject tempEnemyTrail = Instantiate(enemyTrail, transform.position, Quaternion.LookRotation(Vector3.down, forward));
            tempEnemyTrail.transform.localScale = enemyFireTrailScale;
            tempEnemyTrail.GetComponent<FireSlimeTrail>().SetVars(damageAmount);
            audioManager.Stop("Fire Slime Trail Initial");
            audioManager.Play("Fire Slime Trail Initial", player.transform, this.transform);
            spawnTimer = spawnTimerLength;
        }
    }
    public override void Movement(Vector3 positionToMoveTo)
    {
        base.Movement(positionToMoveTo);
    }

    public override void OnCollisionEnter(Collision collision)
    {
        base.OnCollisionEnter(collision);
        if (collision.gameObject.layer == 10)
        {
            FireSlimeAttack();
        }
    }
    public override void OnCollisionStay(Collision collision)
    {
        base.OnCollisionStay(collision);
    }

    public override void OnTriggerEnter(Collider other)
    {
        base.OnTriggerEnter(other);
    }

    public override void OnTriggerStay(Collider other)
    {
        base.OnTriggerStay(other);
    }
}
