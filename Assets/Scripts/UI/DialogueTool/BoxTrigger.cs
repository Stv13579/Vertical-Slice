using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class BoxTrigger : MonoBehaviour
{
    public GameObject interactButton;
    public DialogueManager dialogueManager;
    [Header("You Need to drag the right scriptable object for the right NPC dialogue")]
    public DialogueData dialogueData;
    // finds the interact button and dialoguemanager so that the user doesnt have to drag and drop it every time
    private void OnValidate()
    {
        if (!interactButton)
        {
            interactButton = GameObject.Find("Dialogue Tool/DialogueCanvas/InteractWithNPC");
        }
        if(!dialogueManager)
        {
            dialogueManager = GameObject.Find("Dialogue Tool").GetComponent<DialogueManager>();
        }
    }
    // once player has entered the trigger
    // show the interact button
    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            interactButton.SetActive(true);
        }

    }
    // if player stays in the trigger and
    // if player press e in the trigger then
    // start conversation
    private void OnTriggerStay(Collider other)
    {
        if(other.tag == "Player")
        {
            if (Input.GetKey(KeyCode.E))
            {
                interactButton.SetActive(false);
                dialogueManager.dialogueBox.SetActive(true);
                dialogueManager.boxTrigger = this;
                dialogueManager.dialogueData = dialogueData;
                dialogueManager.StartDialogue();
            }
        }

    }
    // disable the interact button if player is out of trigger
    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            interactButton.SetActive(false);
        }

    }
}
