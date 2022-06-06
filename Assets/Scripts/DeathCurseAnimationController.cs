using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeathCurseAnimationController : MonoBehaviour
{
    public ParticleSystem SplatDamage;
    public void VFXDeathCurseParticleSplat()
    {
        SplatDamage.Play();
    }
}
