using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IncreaseFireDamageScript : Item
{
    public override void AddEffect(PlayerClass player)
    {
        base.AddEffect(player);
        player.gameObject.GetComponent<FireElement>().damageMultiplier += 0.1f;
        player.gameObject.GetComponent<LaserBeamElement>().damageMultiplier += 0.1f;
        player.gameObject.GetComponent<AcidCloudElement>().damageMultiplier += 0.1f;
    }
}
