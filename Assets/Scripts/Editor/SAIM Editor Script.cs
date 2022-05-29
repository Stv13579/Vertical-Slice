using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

[CustomEditor(typeof(SAIM))]
[CanEditMultipleObjects]
public class SAIMEditorScript : Editor
{
    

    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        SAIM saimInstance = (SAIM)target;


        //serializedObject.Update();

        if (GUILayout.Button("Generate Nodes"))
        {

            saimInstance.DestroyAllNodes();
            saimInstance.CreateAndKillNodes();
            EditorUtility.SetDirty(saimInstance);
        }

        if (GUILayout.Button("Clear Nodes"))
        {

            saimInstance.DestroyAllNodes();
        }


    }

}
