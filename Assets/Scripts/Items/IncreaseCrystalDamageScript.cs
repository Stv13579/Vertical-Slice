using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IncreaseCrystalDamageScript : Item
{
    public override void AddEffect(PlayerClass player)
    {
        base.AddEffect(player);
        player.gameObject.GetComponent<CrystalElement>().damageMultiplier += 0.1f;
        player.gameObject.GetComponent<ShardCannonElement>().damageMultiplier += 0.1f;
        player.gameObject.GetComponent<CurseElement>().damageMultiplier += 0.1f;
    }
}
