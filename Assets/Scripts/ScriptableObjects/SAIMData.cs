﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "SAIM Data")]
public class SAIMData : ScriptableObject
{

    [SerializeField]
    public List<GameObject> enemyTypes;

    public GameObject player;

    //The amount of spawns available for the entire room in the entire duration.
    [SerializeField]
    public int totalSpawns;


    //How long into the room spawning can still occur. After this time is reached, there will be no more spawning.
    [SerializeField]
    public float spawnDuration;

    //The set difficulty.
    public int difficulty;

    //Based off of the set difficulty, will change dynamically as the player plays.
    public int adjustedDifficulty;


    //The total amount of time the spawn timer has to reach before there is another legal spawn event.
    //Adjusted by player performance and difficulty.
    public float totalSpawnTimer;

    //The max amount to spawn in each spawn event
    public int spawnMax;

    //If there are less enemies than this number, can spawn.
    public int enemyMinimum;
}
