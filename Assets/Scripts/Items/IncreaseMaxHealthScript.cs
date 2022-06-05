using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IncreaseMaxHealthScript : Item
{
    public override void AddEffect(PlayerClass player)
    {
        base.AddEffect(player);
        IncreaseMaxHealth(player);
    }
    public void IncreaseMaxHealth(PlayerClass player)
    {
        player.maxHealth += 25.0f;
        player.ChangeHealth(25.0f);
    }
}
