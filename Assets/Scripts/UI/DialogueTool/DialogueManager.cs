using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
public class DialogueManager : MonoBehaviour
{
    private TextMeshProUGUI nameText;
    private TextMeshProUGUI dialogueText;
    private Button dialogueOption1Button;
    private Button dialogueOption2Button;
    private Button dialogueOption3Button;
    private Button dialogueOption4Button;
    private TextMeshProUGUI dialogueOption1Text;
    private TextMeshProUGUI dialogueOption2Text;
    private TextMeshProUGUI dialogueOption3Text;
    private TextMeshProUGUI dialogueOption4Text;
    private TextMeshProUGUI nextText;
    [Header("into this slot")]
    [Header("you will need to drag the DialogueUIHolder")]
    [Header("After creating your dialogueBox")]
    public GameObject dialogueBox;
    public BoxTrigger boxTrigger;
    public GameObject player;
    public int dialogueIndex;
    public int dialoguePairIndex;
    public int typingIndex;
    public string typingString;
    public DialogueData dialogueData;

    // finds the objects in the scene so that the player doesnt have to drag them in
    void OnValidate()
    {
        if (!player)
        {
            player = GameObject.Find("Player");
        }
        if (!nameText)
        {
            nameText = GameObject.Find("Dialogue Tool/DialogueCanvas/DialogueUIHolder/NPCNameText").GetComponent<TextMeshProUGUI>();
        }
        if (!dialogueText)
        {
            dialogueText = GameObject.Find("Dialogue Tool/DialogueCanvas/DialogueUIHolder/DialogueText").GetComponent<TextMeshProUGUI>();
        }
        if (!nextText)
        {
            nextText = GameObject.Find("Dialogue Tool/DialogueCanvas/DialogueUIHolder/BackButton/ButtonText").GetComponent<TextMeshProUGUI>();
        }
        if (!dialogueOption1Button)
        {
            dialogueOption1Button = GameObject.Find("Dialogue Tool/DialogueCanvas/DialogueUIHolder/PlayerOption1").GetComponent<Button>();
        }
        if (!dialogueOption2Button)
        {
            dialogueOption2Button = GameObject.Find("Dialogue Tool/DialogueCanvas/DialogueUIHolder/PlayerOption2").GetComponent<Button>();
        }
        if (!dialogueOption3Button)
        {
            dialogueOption3Button = GameObject.Find("Dialogue Tool/DialogueCanvas/DialogueUIHolder/PlayerOption3").GetComponent<Button>();
        }
        if (!dialogueOption4Button)
        {
            dialogueOption4Button = GameObject.Find("Dialogue Tool/DialogueCanvas/DialogueUIHolder/PlayerOption4").GetComponent<Button>();
        }
        if (!dialogueOption1Text)
        {
            dialogueOption1Text = GameObject.Find("Dialogue Tool/DialogueCanvas/DialogueUIHolder/PlayerOption1/PlayerOption1Text").GetComponent<TextMeshProUGUI>();
        }
        if (!dialogueOption2Text)
        {
            dialogueOption2Text = GameObject.Find("Dialogue Tool/DialogueCanvas/DialogueUIHolder/PlayerOption2/PlayerOption2Text").GetComponent<TextMeshProUGUI>();
        }
        if (!dialogueOption3Text)
        { 
            dialogueOption3Text = GameObject.Find("Dialogue Tool/DialogueCanvas/DialogueUIHolder/PlayerOption3/PlayerOption3Text").GetComponent<TextMeshProUGUI>();
        }
        if (!dialogueOption4Text)
        {
            dialogueOption4Text = GameObject.Find("Dialogue Tool/DialogueCanvas/DialogueUIHolder/PlayerOption4/PlayerOption4Text").GetComponent<TextMeshProUGUI>();
        }
    }

    private void Start()
    {
        dialogueIndex = 0;
        dialoguePairIndex = 0;
        dialogueBox.SetActive(false);
    }
    // prints out the NPC dialogue
    // making it nicer
    private void FixedUpdate()
    {
        typingIndex++;
        typingIndex = Mathf.Min(typingIndex, typingString.Length);
        string sub = typingString.Substring(0, typingIndex);
        dialogueText.text = sub;
    }

    // turns on the players dialogue options buttons
    public void DisplayPlayerOptions(int numberActive)
    {
        dialogueOption1Button.gameObject.SetActive(numberActive > 0);
        dialogueOption2Button.gameObject.SetActive(numberActive > 1);
        dialogueOption3Button.gameObject.SetActive(numberActive > 2);
        dialogueOption4Button.gameObject.SetActive(numberActive > 3);
    }
    // starts the dialogue of the NPC
    public void StartDialogue()
    {
        dialogueIndex = 0;
        dialoguePairIndex = 0;
        player.GetComponentInChildren<PlayerLook>().enabled = false;
        Cursor.visible = true;
        Cursor.lockState = CursorLockMode.None;
        player.GetComponent<PlayerMovement>().enabled = false;
        DisplayNPCDialogue();
    }
    // after the player has chosen a responce it it checks if its the end of the dialogue or it
    // continues with the NPC dialogue
    public void SubmitPlayerResponse(int option)
    {
        dialoguePairIndex = 0;
        int outcome = dialogueData.dialoguePairs[dialogueIndex].outcomeIndex[option];
        if (outcome < 0)
        {
            EndDialogue();
        }
        else
        {
            dialogueIndex = outcome;
            DisplayNPCDialogue();
        }
    }
    // when player presses the next button it checks again if is the final dialogue or
    // displays the players dialogue
    public void ProgressDialogue()
    {
        dialoguePairIndex++;
        bool final = dialogueIndex >= dialogueData.dialoguePairs.Count - 1 &&
        (dialogueData.dialoguePairs[dialogueIndex].playerOptions == null ||
        dialogueData.dialoguePairs[dialogueIndex].playerOptions.Count == 0);
        if (final)
        {
            EndDialogue();
        }
        else
        {
            DisplayPlayerDialogue();
        }
    }

    // displays the players dialogue
    public void DisplayPlayerDialogue()
    {
        int options = dialogueData.dialoguePairs[dialogueIndex].playerOptions.Count;
        DisplayPlayerOptions(options);
        nextText.transform.parent.gameObject.SetActive(false);

        //dialogueText.GetComponent<Text>().text = "...";
        dialogueOption1Text.text = options > 0 ? dialogueData.dialoguePairs[dialogueIndex].playerOptions[0] : "";
        dialogueOption2Text.text = options > 1 ? dialogueData.dialoguePairs[dialogueIndex].playerOptions[1] : "";
        dialogueOption3Text.text = options > 2 ? dialogueData.dialoguePairs[dialogueIndex].playerOptions[2] : "";
        dialogueOption4Text.text = options > 3 ? dialogueData.dialoguePairs[dialogueIndex].playerOptions[3] : "";
    }

    // displays the NPCs dialogue
    public void DisplayNPCDialogue()
    {
        DisplayPlayerOptions(0);
        nextText.transform.parent.gameObject.SetActive(true);
        //dialogueText.GetComponent<Text>().text = script.dialoguePairs[dialogueIndex].npcDialogue;
        typingString = dialogueData.dialoguePairs[dialogueIndex].npcDialogue;
        typingIndex = 0;
        nameText.text = dialogueData.npcName;

        bool final = dialogueIndex >= dialogueData.dialoguePairs.Count - 1 &&
        (dialogueData.dialoguePairs[dialogueIndex].playerOptions == null ||
        dialogueData.dialoguePairs[dialogueIndex].playerOptions.Count == 0);

        nextText.text = final ? "Exit" : "Next";
    }
    // updates the NPC or players dialogue
    public void UpdateDialogue()
    {
        if (dialoguePairIndex > 1)
        {
            dialoguePairIndex = 0;
            dialogueIndex++;
        }
        if(dialoguePairIndex == 0)
        {
            dialogueText.text = dialogueData.dialoguePairs[dialogueIndex].npcDialogue;
        }
        else
        {
            dialogueText.text = dialogueData.dialoguePairs[dialogueIndex].playerOptions[0];
        }
    }
    // ends dialogues
    // activates back the players movement and mouse look script
    public void EndDialogue()
    {
        dialogueBox.SetActive(false);
        Cursor.lockState = CursorLockMode.Locked;
        Cursor.visible = false;
        player.GetComponent<PlayerLook>().enabled = true;
        player.GetComponent<PlayerMovement>().enabled = true;
    }
}
