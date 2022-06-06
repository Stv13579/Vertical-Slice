using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShopkeeperScript : MonoBehaviour
{
    bool inRange = false;
    public GameObject shopUI;
    GameObject instantiatedShopUI = null;
    bool inShop = false;
    PlayerMovement playerMove;
    PlayerLook playerLook;
    Shooting shooting;
    void Update()
    {
        if(Input.GetKeyDown(KeyCode.T) && inRange && !inShop)
        {
            //If the shop hasn't yet been opened, create it so that it generates appropriate items, otherwise reopen it
            if(instantiatedShopUI == null)
            {
                instantiatedShopUI = Instantiate(shopUI);
                instantiatedShopUI.GetComponent<ShopUI>().shopkeeper = this;
            }
            else
            {
                instantiatedShopUI.SetActive(true);
            }
            inShop = true;

            playerLook.LockCursor();
            playerMove.ableToMove = false;
            playerLook.ableToMove = false;
            shooting.ableToShoot = false;


        }

        if (Input.GetKeyDown(KeyCode.Escape) && inRange && inShop)
        {
            instantiatedShopUI.GetComponent<ShopUI>().CloseShop();
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.tag == "Player")
        {
            inRange = true;
            playerMove = other.gameObject.GetComponent<PlayerMovement>();
            playerLook = other.gameObject.GetComponent<PlayerLook>();
            shooting = other.gameObject.GetComponent<Shooting>();
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            inRange = false;
        }
    }

    public void LeaveShop()
    {
        inShop = false;
        instantiatedShopUI.SetActive(false);
        playerLook.LockCursor();
        playerMove.ableToMove = true;
        playerLook.ableToMove = true;
        shooting.ableToShoot = true;


    }
}
