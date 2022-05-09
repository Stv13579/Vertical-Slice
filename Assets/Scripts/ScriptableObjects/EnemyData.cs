using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyData : ScriptableObject
{
    public float maxHealth;
    public float currentHealth;
    public float damageAmount;
    public float moveSpeed;

    //The amount of flat damage any instance of incoming damage is reduced by
    public float damageThreshold;

    //The amount of percentage damage any instance of incoming damage is reduced by
    public float damageResistance = 1;

    public bool dead = false;

    public float maxHopDistance;
    public float currentHopDistance;

    public AnimationCurve slimeHopHeight;



}
