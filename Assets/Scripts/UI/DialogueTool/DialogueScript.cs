using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using TMPro;
#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.Events;
#endif

[System.Serializable]
public class DialoguePair
{
    public string snippetName;
    public string npcDialogue;
    public List<string> playerOptions;
    public List<int> outcomeIndex;
}
public class DialogueScript : MonoBehaviour
{
    [Header("each Scriptable Object can get the right components")]
    [Header("you create a new Scriptable Object so that")]
    [Header("This will need to change everytime")]
    public DialogueData dialogueData;
    public GameObject dialogueUIHolder;

#if UNITY_EDITOR
    [MenuItem("DialogueTool/Create DialogueTool")]
    private static void DialogueTool()
    {
        // creates the dialogue Tool e.g creating this allows the user to create all the dialogue Ui visuals
        // this only needs to be created once
        var dialogueTool = new GameObject("Dialogue Tool");
        dialogueTool.AddComponent<DialogueScript>();
        dialogueTool.GetComponent<DialogueScript>().dialogueData = (DialogueData)Resources.Load("ScriptableObjects/DialogueData");
        dialogueTool.AddComponent<DialogueManager>();
    }
    [MenuItem("DialogueTool/Create NPCDialogueBoxTrigger")]
    private static void NPCDialogueManager()
    {
        // this needs to be attached to the NPC the player wants to talk to
        var npcDialogueManager = new GameObject("NPCDialogue");
        npcDialogueManager.AddComponent<BoxCollider>();
        npcDialogueManager.GetComponent<BoxCollider>().isTrigger = true;
        npcDialogueManager.GetComponent<BoxCollider>().size = new Vector3(5, 3, 5);
        npcDialogueManager.AddComponent<BoxTrigger>();
    }

#endif

    // allows the player to create a canvas and creates an event system
    public void CreateCanvas()
    {
        var canvas = new GameObject("DialogueCanvas");
        canvas.AddComponent<Canvas>();
        canvas.GetComponent<Canvas>().renderMode = RenderMode.ScreenSpaceOverlay;
        canvas.AddComponent<CanvasScaler>();
        canvas.GetComponent<CanvasScaler>().uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        canvas.GetComponent<CanvasScaler>().referenceResolution = new Vector2(1920, 1080);
        canvas.GetComponent<CanvasScaler>().screenMatchMode = CanvasScaler.ScreenMatchMode.MatchWidthOrHeight;
        canvas.GetComponent<CanvasScaler>().matchWidthOrHeight = 0.5f;
        canvas.GetComponent<CanvasScaler>().referencePixelsPerUnit = 100.0f;
        canvas.AddComponent<GraphicRaycaster>();
        canvas.GetComponent<RectTransform>().SetParent(transform);
        dialogueUIHolder = new GameObject("DialogueUIHolder");
        dialogueUIHolder.transform.parent = canvas.transform;
        var interactWithNPC = dialogueData.interactImage;
        Image interactWithNPCtemp = Instantiate(interactWithNPC, new Vector3(960, 550, 0), Quaternion.identity, canvas.transform);
        interactWithNPCtemp.name = "InteractWithNPC";
        var eventSystem = new GameObject("EventSystem");
        eventSystem.AddComponent<EventSystem>();
        eventSystem.AddComponent<StandaloneInputModule>();
        eventSystem.GetComponent<Transform>().SetParent(transform);
    }

    // creates the dialogue box Image
    // basically the dialogue background so that the player can read the text
    public void CreateDialogueBox()
    {
        var DB = dialogueData.dialogueBox;
        Image dialogueBox = Instantiate(DB, new Vector3(960,805,0), Quaternion.identity, dialogueUIHolder.transform);
        dialogueBox.name = "DialogueBoxImage";
    }

    // creates the text of the NPC name and creates a little background for the name
    public void CreateNameText()
    {
        var NT = dialogueData.nameText;
        TextMeshProUGUI nameText = Instantiate(NT, new Vector3(500, 790, 0), Quaternion.Euler(0.0f, 0.0f, 10.0f), dialogueUIHolder.transform);
        nameText.name = "NPCNameText";
        nameText.font = dialogueData.nameFont;
        nameText.text = dialogueData.npcName;
        nameText.alignment = TextAlignmentOptions.Center;
    }
    // creates the text for the dialogue
    // if players have already made the scriptable object and it has text
    // it will show the first sentence of the NPC
    public void CreateDialogueText()
    {
        var DT = dialogueData.dialogueText;
        TextMeshProUGUI dialogueText = Instantiate(DT, new Vector3(960, 975, 0), Quaternion.identity, dialogueUIHolder.transform);
        dialogueText.name = "DialogueText";
        dialogueText.font = dialogueData.dialogueFont;
    }
#if UNITY_EDITOR
    // creates a button for the player to progress through the text
    public void CreateNextExitButton()
    {
        var NEB = dialogueData.backButton;
        Button backButton = Instantiate(NEB, new Vector3(960, 180, 0), Quaternion.identity, dialogueUIHolder.transform);
        backButton.name = "BackButton";
        backButton.GetComponentInChildren<TextMeshProUGUI>().font = dialogueData.nameFont;
        backButton.GetComponentInChildren<TextMeshProUGUI>().name = "ButtonText";
        DialogueManager dM = FindObjectOfType<DialogueManager>();
        var targetInfo = UnityEvent.GetValidMethodInfo(dM, nameof(DialogueManager.ProgressDialogue), new System.Type[0]);
        UnityAction del = System.Delegate.CreateDelegate(typeof(UnityAction), dM, targetInfo)as UnityAction;
        backButton.GetComponent<Button>().onClick = new Button.ButtonClickedEvent();
        UnityEventTools.AddPersistentListener(backButton.GetComponent<Button>().onClick, del);
    }

    // this is for the player options when they get dialogue
    public void CreatePlayerOption1Button()
    {
        var NEB = dialogueData.dialogueOptionButton;
        Button backButton = Instantiate(NEB, new Vector3(960, 420, 0), Quaternion.identity, dialogueUIHolder.transform);
        backButton.name = "PlayerOption1";
        backButton.GetComponentInChildren<TextMeshProUGUI>().font = dialogueData.nameFont;
        backButton.GetComponentInChildren<TextMeshProUGUI>().name = "PlayerOption1Text";
        DialogueManager dM = FindObjectOfType<DialogueManager>();
        var targetInfo = UnityEvent.GetValidMethodInfo(dM, nameof(DialogueManager.SubmitPlayerResponse), new System.Type[] {typeof(int) });
        UnityAction<int> del = System.Delegate.CreateDelegate(typeof(UnityAction<int>), dM, targetInfo) as UnityAction<int>;
        backButton.GetComponent<Button>().onClick = new Button.ButtonClickedEvent();
        UnityEventTools.AddIntPersistentListener(backButton.GetComponent<Button>().onClick, del, 0);
    }

    public void CreatePlayerOption2Button()
    {
        var NEB = dialogueData.dialogueOptionButton;
        Button backButton = Instantiate(NEB, new Vector3(960, 370, 0), Quaternion.identity, dialogueUIHolder.transform);
        backButton.name = "PlayerOption2";
        backButton.GetComponentInChildren<TextMeshProUGUI>().font = dialogueData.nameFont;
        backButton.GetComponentInChildren<TextMeshProUGUI>().name = "PlayerOption2Text";
        DialogueManager dM = FindObjectOfType<DialogueManager>();
        var targetInfo = UnityEvent.GetValidMethodInfo(dM, nameof(DialogueManager.SubmitPlayerResponse), new System.Type[] { typeof(int) });
        UnityAction<int> del = System.Delegate.CreateDelegate(typeof(UnityAction<int>), dM, targetInfo) as UnityAction<int>;
        backButton.GetComponent<Button>().onClick = new Button.ButtonClickedEvent();
        UnityEventTools.AddIntPersistentListener(backButton.GetComponent<Button>().onClick, del, 1);
    }

    public void CreatePlayerOption3Button()
    {
        var NEB = dialogueData.dialogueOptionButton;
        Button backButton = Instantiate(NEB, new Vector3(960, 320, 0), Quaternion.identity, dialogueUIHolder.transform);
        backButton.name = "PlayerOption3";
        backButton.GetComponentInChildren<TextMeshProUGUI>().font = dialogueData.nameFont;
        backButton.GetComponentInChildren<TextMeshProUGUI>().name = "PlayerOption3Text";
        DialogueManager dM = FindObjectOfType<DialogueManager>();
        var targetInfo = UnityEvent.GetValidMethodInfo(dM, nameof(DialogueManager.SubmitPlayerResponse), new System.Type[] { typeof(int) });
        UnityAction<int> del = System.Delegate.CreateDelegate(typeof(UnityAction<int>), dM, targetInfo) as UnityAction<int>;
        backButton.GetComponent<Button>().onClick = new Button.ButtonClickedEvent();
        UnityEventTools.AddIntPersistentListener(backButton.GetComponent<Button>().onClick, del, 2);
    }

    public void CreatePlayerOption4Button()
    {
        var NEB = dialogueData.dialogueOptionButton;
        Button backButton = Instantiate(NEB, new Vector3(960, 270, 0), Quaternion.identity, dialogueUIHolder.transform);
        backButton.name = "PlayerOption4";
        backButton.GetComponentInChildren<TextMeshProUGUI>().font = dialogueData.nameFont;
        backButton.GetComponentInChildren<TextMeshProUGUI>().name = "PlayerOption4Text";
        DialogueManager dM = FindObjectOfType<DialogueManager>();
        var targetInfo = UnityEvent.GetValidMethodInfo(dM, nameof(DialogueManager.SubmitPlayerResponse), new System.Type[] { typeof(int) });
        UnityAction<int> del = System.Delegate.CreateDelegate(typeof(UnityAction<int>), dM, targetInfo) as UnityAction<int>;
        backButton.GetComponent<Button>().onClick = new Button.ButtonClickedEvent();
        UnityEventTools.AddIntPersistentListener(backButton.GetComponent<Button>().onClick, del, 3);
    }
#endif

    // this gathers all the necessary pieces for the scriptable objects to use
    public void GatherDialogueBoxData()
    {
        dialogueData.dialogueBox = Resources.Load<Image>("UIAssets/DialogueBoxImage");
        dialogueData.nameText = Resources.Load<TextMeshProUGUI>("UIAssets/NPCNameText(TMP)");
        dialogueData.dialogueText = Resources.Load<TextMeshProUGUI>("UIAssets/DialogueText(TMP)");
        dialogueData.backButton = Resources.Load<Button>("UIAssets/BackandExitButton(TMP)");
        dialogueData.nameFont = Resources.Load<TMP_FontAsset>("UIAssets/LiberationSans SDF");
        dialogueData.dialogueFont = Resources.Load<TMP_FontAsset>("UIAssets/LiberationSans SDF");
        dialogueData.interactImage = Resources.Load<Image>("UIAssets/InteractWithPlayer");
        dialogueData.dialogueOptionButton = Resources.Load<Button>("UIAssets/PlayerOption(TMP)");
    }
}
