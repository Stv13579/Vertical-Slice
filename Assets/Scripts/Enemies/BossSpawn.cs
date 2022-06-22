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

    AudioManager audioManager;
    bool fadeOutAmbientAudio = false;
    bool fadeOutBattleAudio = false;
    void Start()
    {
        audioManager = FindObjectOfType<AudioManager>();
    }

    void Update()
    {
        if (fadeOutAmbientAudio == true)
        {
            audioManager.sounds[0].audioSource.volume -= 0.01f * Time.deltaTime;
        }
        if (audioManager.sounds[0].audioSource.volume <= 0 && fadeOutBattleAudio == false)
        {
            audioManager.Stop("Ambient Sound");
            audioManager.Play("Boss Music");
            fadeOutAmbientAudio = false;
            audioManager.sounds[0].audioSource.volume = 0.1f;
        }
        if (fadeOutBattleAudio == true)
        {
            audioManager.sounds[34].audioSource.volume -= 0.01f * Time.deltaTime;
        }
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
        fadeOutAmbientAudio = true;
    }

}
