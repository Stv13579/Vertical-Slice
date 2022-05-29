using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationEventController : MonoBehaviour
{
    [SerializeField]
    List<BaseElementClass> elements;

    public void Activate(int activateType)
    {
        if (activateType <= elements.Count)
        {
            elements[activateType].ActivateVFX();
            elements[activateType].ElementEffect();
        }
    }

    public void Lifted(int activateType)
    {
        if (activateType <= elements.Count)
        {           
            elements[activateType].LiftEffect();
        }
    }    
}
