using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class StartGameController : MonoBehaviour
{
    AudioManager audioManager;
    public void Start()
    {
        audioManager = FindObjectOfType<AudioManager>();
    }
    public void StartGame()
    {
        audioManager.Stop("Menu and Pause");
        audioManager.Play("Menu and Pause");
        SceneManager.LoadScene(1);
    }
}
