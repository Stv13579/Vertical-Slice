using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(DialogueScript))]
[CanEditMultipleObjects]
public class DialogueToolEditor : Editor
{
    DialogueScript _target;

    private void OnEnable()
    {
        _target = (DialogueScript)target;
    }
    public override void OnInspectorGUI()
    {
        DrawMain();
    }

    void DrawMain()
    {
        GUILayout.Label("Dialogue Tool");

        base.OnInspectorGUI();
        GUILayout.Label("Create Canvas");
        if (GUILayout.Button("Create"))
        {
            _target.CreateCanvas();
        }
        GUILayout.Label("Create Dialogue Box");
        if (GUILayout.Button("Create"))
        {
            _target.CreateDialogueBox();
        }
        GUILayout.Label("Create Text");
        if (GUILayout.Button("Create Name Text"))
        {
            _target.CreateNameText();
        }
        if (GUILayout.Button("Create Dialogue Text"))
        {
            _target.CreateDialogueText();
        }
        if (GUILayout.Button("Create Back/Exit Button"))
        {
            _target.CreateNextExitButton();
        }
        if (GUILayout.Button("Create Player Dialogue Option 1"))
        {
            _target.CreatePlayerOption1Button();
        }
        if (GUILayout.Button("Create Player Dialogue Option 2"))
        {
            _target.CreatePlayerOption2Button();
        }
        if (GUILayout.Button("Create Player Dialogue Option 3"))
        {
            _target.CreatePlayerOption3Button();
        }
        if (GUILayout.Button("Create Player Dialogue Option 4"))
        {
            _target.CreatePlayerOption4Button();
        }
        if (GUILayout.Button("Gather Dialogue Data"))
        {
            _target.GatherDialogueBoxData();
        }
    }
}
