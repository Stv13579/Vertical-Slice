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
    int leftElementIndex = 0;
    int rightElementIndex = 0;

    private void Update()
    {
        //Starts the process of activating the element held in the left hand
        if(Input.GetKeyDown(KeyCode.Mouse0))  
        {
            primaryElements[leftElementIndex].ActivateElement();
        }
        if(Input.GetKeyDown(KeyCode.Mouse1))
        {
            catalystElements[rightElementIndex].ActivateElement();
        }

        if(Input.GetKeyUp(KeyCode.Q))
        {
            leftElementIndex++;
            if(leftElementIndex >= primaryElements.Count)
            {
                leftElementIndex = 0;
            }
        }
        if(Input.GetKeyUp(KeyCode.E))
        {
            rightElementIndex++;
            if (rightElementIndex >= catalystElements.Count)
            {
                rightElementIndex = 0;
            }
        }


    }
}
