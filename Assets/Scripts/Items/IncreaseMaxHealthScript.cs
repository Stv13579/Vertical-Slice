using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IncreaseMaxHealthScript : Item
{
    // Start is called before the first frame update
    void Start()
    {
        
    }

    public override void AddEffect(PlayerClass player)
    {
        base.AddEffect(player);
        IncreaseMaxHealth(player);
    }
    public void IncreaseMaxHealth(PlayerClass player)
    {
        player.pData.maxHealth = 125.0f;
        
    }
}
