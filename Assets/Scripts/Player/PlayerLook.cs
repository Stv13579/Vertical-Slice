using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerLook : MonoBehaviour
{
    [SerializeField] new private Camera camera;
    // current rotation of camera
    private float spin = 0.0f;
    private float tilt = 0.0f;

    private float targetCameraPos;

    [SerializeField] private Vector2 tiltExtents = new Vector2(-85.0f, 85.0f);
    [SerializeField] private Vector2 spinExtents;
    [SerializeField] private float sensitivity = 2.0f;
    bool cursorLocked = false;

    // getter to get the camera
    public Camera GetCamera() { return camera; }
    // getter to get the spin value
    public float GetSpin() { return spin; }
    // setter to set the spin value
    public void SetSpin(float newSpin) { spin = newSpin; }
    // getter to get the sensitivity value
    public float GetSensitivity() { return sensitivity; }
    // setter to set the sensitivity value
    public void SetSensitivity(float _sensitivity) { sensitivity = _sensitivity; }

    public void LockCursor()
    {
        cursorLocked = !cursorLocked;
        // locks cursor in the middle of screen
        Cursor.lockState = cursorLocked ? CursorLockMode.Locked : CursorLockMode.None;
        // cursor is not visable
        Cursor.visible = !cursorLocked;
    }

    private void HandleEditorInputs()
    {
        if (Input.GetKeyDown(KeyCode.Tab))
        {
            LockCursor();
        }
    }
    private void MoveCamera()
    {
        // if cursor is locked
        if (cursorLocked)
        {
            //getting input for the x and y axis for the mouse
            // using GetAxisRaw so that we are dealing with 0 and 1
            float mouseX = Input.GetAxisRaw("Mouse X");
            float mouseY = Input.GetAxisRaw("Mouse Y");

            // moves the players look when moving the mouse
            spin += mouseX * sensitivity;
            tilt -= mouseY * sensitivity;

            // stops the player from snapping their neck
            tilt = Mathf.Clamp(tilt, tiltExtents.x, tiltExtents.y);

            // rotation on the x axis for the mouse (rotating head to look from side to side)
            // rotation on the y axis for the mouse (rotating head so looking up and down)
            camera.transform.localEulerAngles = new Vector3(tilt, spin, 0);
            camera.transform.localPosition += Quaternion.Euler(0.0f, spin, 0.0f) * new Vector3(targetCameraPos, 0, 0);
        }
    }
    // Start is called before the first frame update
    void Start()
    {
        camera = GameObject.Find("Main Camera").GetComponent<Camera>();
        LockCursor();
    }

    // Update is called once per frame
    void Update()
    {
        MoveCamera();
        HandleEditorInputs();
    }
}
