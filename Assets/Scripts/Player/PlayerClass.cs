using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class PlayerClass : MonoBehaviour
{
    public float currentHealth;
    public float currentMana;

    public float maxHealth;
    public float maxMana;

    public float money;

    //A list of items which are collectible objects which add extra effects to the player
    public List<Item> heldItems = new List<Item>();

    [HideInInspector]
    public GameObject itemUI;

    public GameObject gameOverScreen;
    bool dead = false;

    public Transform fallSpawner;

    /// <summary>
    /// Pushing Away When Hit
    /// </summary>
    public float pushDuration;
    float pushStrength;
    float currentPushDuration;
    Vector3 pushDir;

    [SerializeField]
    float fallDamage;

    void Start()
    {
        currentHealth = maxHealth;
        currentMana = maxMana;
        money = 0.0f;
        itemUI = GameObject.Find("ItemArray");

        //TEST IMPLEMENTATION

        //Item newItem = new Item(Instantiate(testItemUIWidget));

        //AddItem(newItem);
    }

    void Update()
    {
        if (transform.position.y <= -30)
        {
            transform.position = fallSpawner.position;
            ChangeHealth(-fallDamage);
            Debug.Log("Reset Position");
        }

        if (transform.position.y > 70)
        {
            transform.position = fallSpawner.position;
            //ChangeHealth(-fallDamage);
            Debug.Log("Reset Position");
        }

        Push();
    }

    public void AddItem(Item newItem)
    {
        //Other functionality.
        newItem.AddEffect(this); 
    }

    void Death()
    {
        for (int i = 0; i < heldItems.Count; i++)
        {
            heldItems[i].DeathTriggers();
        }
        itemUI.transform.parent.gameObject.SetActive(false);
        Instantiate(gameOverScreen);
        dead = true;
        this.gameObject.GetComponent<PlayerLook>().ableToMove = false;
        this.gameObject.GetComponent<PlayerLook>().LockCursor();

        this.gameObject.GetComponent<PlayerMovement>().ableToMove = false;
        this.gameObject.GetComponent<Shooting>().ableToShoot = false;


    }

    public void ChangeHealth(float healthAmount)
    {
        currentHealth = Mathf.Min(currentHealth + healthAmount, maxHealth);
        if (currentHealth <= 0 && !dead)
        {
            Death();
        }
    }

    //Get hit and bounce
    public void ChangeHealth(float healthAmount, Vector3 enemyPos, float pushForce)
    {
        currentHealth = Mathf.Min(currentHealth + healthAmount, maxHealth);

        Vector3 bounceVec = transform.position - enemyPos;

        pushDir = bounceVec.normalized;
        pushDir.y = 1;
        pushStrength = pushForce;
        currentPushDuration = 0;

        if (currentHealth <= 0 && !dead)
        {
            Death();
        }
    }

    public void Push()
    {
        if(currentPushDuration < pushDuration)
        {
            currentPushDuration += Time.deltaTime;
            transform.position += pushDir * Time.deltaTime * pushStrength;
        }
    }

    public void ChangeMana(float manaAmount)
    {
        currentMana = Mathf.Min(currentMana + manaAmount, maxMana);
        currentMana = Mathf.Max(currentMana, 0);
    }

    public void ChangeMoney(float moneyAmount)
    {
        money = Mathf.Max(money + moneyAmount, 0);
    }
}
