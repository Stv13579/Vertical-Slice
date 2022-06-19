using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

[ExecuteInEditMode]
[CreateAssetMenu(menuName = "DialogueData", fileName = "DialogueData")]
public class DialogueData : ScriptableObject
{
    [Header("NPC Name")]
    public string npcName;
    [Header("Outcome (-1 means end conversation)")]
    [Header("or you can have differnt numbers depending on the mood of the NPC")]
    [Header("for example if you wanna continue with the player you go up numbers")]
    [Header("Outcome Index is how the NPC reacts on what the players choose")]
    [Header("Then in each element you give a string of what you want the player to say")]
    [Header("Player option (MAX 4)")]
    [Header("Give player option a sizes meaning that it gives the player different options to choose from")]
    [Header("NPC Dialogue is the Dialouge you give the NPC")]
    [Header("Snippet Name is the name on how the NPC reacts or if the NPC begins")]
    [Header("Give the Dialogue pair a size (how much dialogue you want for the NPC and the player)")]
    [Header("This is where you can give the NPC and Player Dialogue")]
    public List<DialoguePair> dialoguePairs;

    public Image dialogueBox;

    public TextMeshProUGUI dialogueText;
    public TextMeshProUGUI nameText;

    public Button backButton;

    public TMP_FontAsset nameFont;
    public TMP_FontAsset dialogueFont;

    public Image interactImage;

    public Button dialogueOptionButton;
}
