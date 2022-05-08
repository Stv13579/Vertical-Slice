using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Shooting : MonoBehaviour
{

    [SerializeField] 
    List<BaseElementClass> primaryElements;
    [SerializeField] 
    List<BaseElementClass> catalystElements;
    [SerializeField] 
    List<BaseElementClass> comboElements;
    [SerializeField]
    BaseElementClass rightElement;
    [SerializeField]
    BaseElementClass leftElement;
    [SerializeField]
    BaseElementClass comboElement;

    private void Update()
    {
        //Starts the process of activating the element held in the left hand
        if(Input.GetKeyDown(KeyCode.Mouse0))  
        {
            leftElement.ActivateElement();
        }

        if(Input.GetKeyUp(KeyCode.Q))
        {

        }
        if(Input.GetKeyUp(KeyCode.E))
        {

        }


    }
}
