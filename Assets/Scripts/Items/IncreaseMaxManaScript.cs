using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IncreaseMaxManaScript : Item
{
    public override void AddEffect(PlayerClass player)
    {
        base.AddEffect(player);
        IncreaseMaxMana(player);
    }
    public void IncreaseMaxMana(PlayerClass player)
    {
        player.pData.maxMana += 25.0f;

    }
}
