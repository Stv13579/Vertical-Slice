using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BossSpawn : MonoBehaviour
{

    public bool triggered = false;

    [SerializeField]
    Transform spawnPosition;

    [SerializeField]
    GameObject boss;

    public bool bossDead = false;

    [SerializeField]
    GameObject hubPortal;

    [SerializeField]
    GameObject bridge, bossRing;

    // audio manager
    AudioManager audioManager;
    bool fadeOutAmbientAudio = false;
    bool fadeOutBattleAudio = false;
    void Start()
    {
        audioManager = FindObjectOfType<AudioManager>();
    }

    void Update()
    {
        // will be working on this in alpha was a late implementation 
        // fades out the audio for the ambient sound
        if (fadeOutAmbientAudio == true)
        {
            audioManager.sounds[0].audioSource.volume -= 0.01f * Time.deltaTime;
        }
        // starts the boss music and sets back the volume of the ambient sound
        if (audioManager.sounds[0].audioSource.volume <= 0 && fadeOutBattleAudio == false)
        {
            audioManager.Stop("Ambient Sound");
            audioManager.Play("Boss Music");
            fadeOutAmbientAudio = false;
            audioManager.sounds[0].audioSource.volume = 0.1f;
        }
        // fades out the audio for the boss music
        if (fadeOutBattleAudio == true)
        {
            audioManager.sounds[34].audioSource.volume -= 0.01f * Time.deltaTime;
        }
        // starts the ambient sound again and sets the volume back for the boss music
        if (audioManager.sounds[34].audioSource.volume <= 0 && fadeOutAmbientAudio == false)
        {
            audioManager.Stop("Boss Music");
            audioManager.Play("Ambient Sound");
            fadeOutBattleAudio = false;
            audioManager.sounds[34].audioSource.volume = 0.1f;
        }
        if (!triggered)
        {
            return;
        }
        if(bossDead)
        {
            hubPortal.SetActive(true);
            bridge.SetActive(true);
            bossRing.SetActive(false);
            // if the boss dies set this to true
            fadeOutBattleAudio = true;
        }
    }

    public void StartFight()
    {
        if(triggered)
        {
            return;
        }
        triggered = true;

        bridge.SetActive(false);
        bossRing.SetActive(true);

        Instantiate(boss, spawnPosition.position, Quaternion.identity);
        // when the boss spawns set this to true
        fadeOutAmbientAudio = true;
    }

}
