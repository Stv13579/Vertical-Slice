using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class EndLevel : MonoBehaviour
{
    [SerializeField]
    int sceneToLoad;
    public ItemList items;

    private void OnTriggerEnter(Collider other)
    {
        if (SceneManager.GetActiveScene() == SceneManager.GetSceneByBuildIndex(1))
        {
            foreach(ItemEntry item in items.itemList)
            {
                item.alreadyAdded = false;
            }
        }
        SceneManager.LoadScene(sceneToLoad);

    }
}
