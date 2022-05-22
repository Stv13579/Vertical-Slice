using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IncreaseMaxHealthScript : Item
{
    public IncreaseMaxHealthScript(GameObject uiWidge) : base(uiWidge)
    {

    }
    // Start is called before the first frame update
    void Start()
    {
        
    }

    public override void AddEffect(PlayerClass player)
    {
        base.AddEffect(player);
    }
    public override void IncreaseMaxHealth(PlayerClass player)
    {
        base.IncreaseMaxHealth(player);
        player.pData.maxHealth = 125.0f;
        
    }
}
