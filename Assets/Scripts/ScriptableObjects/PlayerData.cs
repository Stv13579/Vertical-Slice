using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu (fileName = "Player Data")]
public class PlayerData : ScriptableObject
{
    public float mana;
    public float health;
    public float maxHealth;
    public float maxMana;
}
