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

    public bool ableToShoot = true;

    AudioManager audioManager;

    [SerializeField]
    Transform leftOrbPos;

    [SerializeField]
    Transform rightOrbPos;

    private void Start()
    {
        audioManager = FindObjectOfType<AudioManager>();
    }
    private void Update()
    {
        if(Input.GetKey(KeyCode.Escape))
        {
            Application.Quit();
        }

        if(ableToShoot)
        {
            if (!inComboMode)
            {
                NonComboShooting();
            }
            else
            {
                ComboShooting();
            }
        }


        if(Input.GetKeyUp(KeyCode.Q))
        {
            leftElementIndex++;
            // play audio of switching weapons
            audioManager.Stop("Change Element");
            audioManager.Play("Change Element");
            if(leftElementIndex >= primaryElements.Count)
            {
                leftElementIndex = 0;
            }
            Destroy(leftOrbPos.GetChild(0).gameObject);
            if(leftOrbPos.parent.parent.childCount == 2)
            {
                Destroy(leftOrbPos.parent.parent.GetChild(1).gameObject);
            }
            if(!inComboMode)
            {
                Instantiate(primaryElements[leftElementIndex].handVFX, leftOrbPos);
                if (primaryElements[leftElementIndex].wristVFX)
                {
                    Instantiate(primaryElements[leftElementIndex].wristVFX, leftOrbPos.parent.parent);
                }
            }
            else
            {
                Destroy(rightOrbPos.GetChild(0).gameObject);
                if (rightOrbPos.parent.parent.childCount == 2)
                {
                    Destroy(rightOrbPos.parent.parent.GetChild(1).gameObject);
                }
                Instantiate(comboElements[leftElementIndex].comboElements[rightElementIndex].handVFX, leftOrbPos);
                Instantiate(comboElements[leftElementIndex].comboElements[rightElementIndex].handVFX, rightOrbPos);
                if (comboElements[leftElementIndex].comboElements[rightElementIndex].wristVFX)
                {
                    Instantiate(comboElements[leftElementIndex].comboElements[rightElementIndex].wristVFX, leftOrbPos.parent.parent);
                    Instantiate(comboElements[leftElementIndex].comboElements[rightElementIndex].wristVFX, rightOrbPos.parent.parent);
                }

            }

        }
        if(Input.GetKeyUp(KeyCode.E))
        {
            rightElementIndex++;
            // play audio of switching weapons
            audioManager.Stop("Change Element");
            audioManager.Play("Change Element");
            if (rightElementIndex >= catalystElements.Count)
            {
                rightElementIndex = 0;
            }
            Destroy(rightOrbPos.GetChild(0).gameObject);
            if (rightOrbPos.parent.parent.childCount == 2)
            {
                Destroy(rightOrbPos.parent.parent.GetChild(1).gameObject);
            }
            if(!inComboMode)
            {
                Instantiate(catalystElements[rightElementIndex].handVFX, rightOrbPos);
                if (catalystElements[rightElementIndex].wristVFX)
                {
                    Instantiate(catalystElements[rightElementIndex].wristVFX, rightOrbPos.parent.parent);
                }
            }
            else
            {
                Destroy(leftOrbPos.GetChild(0).gameObject);
                if (leftOrbPos.parent.parent.childCount == 2)
                {
                    Destroy(leftOrbPos.parent.parent.GetChild(1).gameObject);
                }
                Instantiate(comboElements[leftElementIndex].comboElements[rightElementIndex].handVFX, leftOrbPos);
                Instantiate(comboElements[leftElementIndex].comboElements[rightElementIndex].handVFX, rightOrbPos);
                if (comboElements[leftElementIndex].comboElements[rightElementIndex].wristVFX)
                {
                    Instantiate(comboElements[leftElementIndex].comboElements[rightElementIndex].wristVFX, leftOrbPos.parent.parent);
                    Instantiate(comboElements[leftElementIndex].comboElements[rightElementIndex].wristVFX, rightOrbPos.parent.parent);
                }
            }

        }

        if(Input.GetKeyUp(KeyCode.F))
        {
            inComboMode = !inComboMode;
            //Activate an animation trigger?

            Destroy(leftOrbPos.GetChild(0).gameObject);
            if (leftOrbPos.parent.parent.childCount == 2)
            {
                Destroy(leftOrbPos.parent.parent.GetChild(1).gameObject);
            }
            Destroy(rightOrbPos.GetChild(0).gameObject);
            if (rightOrbPos.parent.parent.childCount == 2)
            {
                Destroy(rightOrbPos.parent.parent.GetChild(1).gameObject);
            }
            if(!inComboMode)
            {
                Instantiate(primaryElements[leftElementIndex].handVFX, leftOrbPos);
                if (primaryElements[leftElementIndex].wristVFX)
                {
                    Instantiate(primaryElements[leftElementIndex].wristVFX, leftOrbPos.parent.parent);
                }
                Instantiate(catalystElements[rightElementIndex].handVFX, rightOrbPos);
                if (catalystElements[rightElementIndex].wristVFX)
                {
                    Instantiate(catalystElements[rightElementIndex].wristVFX, rightOrbPos.parent.parent);
                }
            }
            else
            {
                Instantiate(comboElements[leftElementIndex].comboElements[rightElementIndex].handVFX, leftOrbPos);
                Instantiate(comboElements[leftElementIndex].comboElements[rightElementIndex].handVFX, rightOrbPos);
                if (comboElements[leftElementIndex].comboElements[rightElementIndex].wristVFX)
                {
                    Instantiate(comboElements[leftElementIndex].comboElements[rightElementIndex].wristVFX, leftOrbPos.parent.parent);
                    Instantiate(comboElements[leftElementIndex].comboElements[rightElementIndex].wristVFX, rightOrbPos.parent.parent);
                }
            }

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

    public Sprite GetCrosshair()
    {
        if(inComboMode)
        {
            return (comboElements[leftElementIndex].comboElements[rightElementIndex].crosshair);
        }
        else
        {
            return (primaryElements[leftElementIndex].crosshair);
        }
    }

    public Transform GetLeftOrbPos()
    {
        return leftOrbPos;
    }

    public Transform GetRightOrbPos()
    {
        return rightOrbPos;
    }
}
