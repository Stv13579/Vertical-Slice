using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Enemy Data")]
public class EnemyData : ScriptableObject
{
    public float maxHealth;
    public float damageAmount;
    public float moveSpeed;

    //The amount of flat damage any instance of incoming damage is reduced by
    public float damageThreshold;

    //The amount of percentage damage any instance of incoming damage is reduced by
    public float damageResistance = 1;

}
