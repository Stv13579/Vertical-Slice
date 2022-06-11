using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class EndLevel : MonoBehaviour
{
    [SerializeField]
    int sceneToLoad;
    [SerializeField]
    GameObject loadingScreen;

    private void OnTriggerEnter(Collider other)
    {
        GameObject screen = Instantiate(loadingScreen);
        StartCoroutine(screen.GetComponent<LoadingScreen>().LoadScene(sceneToLoad));
    }
}
