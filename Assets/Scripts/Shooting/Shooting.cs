using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class Shooting : MonoBehaviour
{

    [SerializeField] 
    List<BaseElementClass> primaryElements;
    [SerializeField] 
    List<BaseElementClass> catalystElements;

    [Serializable]
    public struct ComboElementList
    {
        public List<BaseElementClass> comboElements;
    }

    [SerializeField] 
    List<ComboElementList> comboElements;
    int leftElementIndex = 0;
    int rightElementIndex = 0;

    bool inComboMode = false;

    private void Update()
    {
        if(Input.GetKey(KeyCode.Escape))
        {
            Application.Quit();
        }

        if(!inComboMode)
        {
            NonComboShooting();
        }
        else
        {
            ComboShooting();
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

        if(Input.GetKeyUp(KeyCode.F))
        {
            inComboMode = !inComboMode;
            //Activate an animation trigger?

        }

    }

    void NonComboShooting()
    {
        //Starts the process of activating the element held in the left hand
        if (Input.GetKeyDown(KeyCode.Mouse0))
        {
            primaryElements[leftElementIndex].ActivateElement();
        }
        if (Input.GetKeyDown(KeyCode.Mouse1))
        {
            catalystElements[rightElementIndex].ActivateElement();
        }

        if (Input.GetKeyUp(KeyCode.Mouse0))
        {
            primaryElements[leftElementIndex].LiftEffect();
        }
        if (Input.GetKeyUp(KeyCode.Mouse1))
        {
            catalystElements[rightElementIndex].LiftEffect();
        }
    }

    void ComboShooting()
    {
        if (Input.GetKeyDown(KeyCode.Mouse0))
        {
            comboElements[leftElementIndex].comboElements[rightElementIndex].ActivateElement();
        }

        if (Input.GetKeyUp(KeyCode.Mouse0))
        {
            comboElements[leftElementIndex].comboElements[rightElementIndex].LiftEffect();
        }
    }

    public Sprite GetPrimaryElement()
    {
        return primaryElements[leftElementIndex].uiSprite;
    }

    public Sprite GetCatalystElement()
    {
        return catalystElements[rightElementIndex].uiSprite;
    }


    public Sprite GetComboElement()
    {
        return (comboElements[leftElementIndex].comboElements[rightElementIndex].uiSprite);
    }
}
