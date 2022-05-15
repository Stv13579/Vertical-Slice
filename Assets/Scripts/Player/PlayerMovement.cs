using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    private PlayerLook lookScript;
    private CharacterController cController;

    [Header("General Movement Values")]
    [SerializeField]
    private float moveSpeed = 12.0f;
    [SerializeField]
    private float gravity = 30.0f;
    [SerializeField]
    private float jumpSpeed = 15.0f;
    [SerializeField]
    private float airStrafeSpeed = 1.0f;
    private float acceleration = 10.0f;
    private AnimationCurve frictionCurve = AnimationCurve.Linear(0, 0.1f, 1, 1);
    [SerializeField]
    private float coyoteTime = 0.75f;
    private float currentCoyoteTime;

    [Header("Character velocity")]
    private Vector3 velocity;
    private Vector3 StoredJumpVelo;

    [Header("Checks")]
    private bool isGrounded = false;

    [Header("Head Bobbing")]
    private float headBobTimer = 0.0f;
    private float headBobFrequency = 1.0f;
    private float headBobAmplitude = 0.1f;
    // the default position of the head
    private float headBobNeutral = 1.0f;
    private float headBobMinSpeed = 0.1f;
    private float headBobBlendSpeed = 4.0f;
    [SerializeField] private AnimationCurve headBobBlendCurve = AnimationCurve.EaseInOut(0.0f, 0.0f, 1.0f, 1.0f);
    private float headBobMultiplier = 0.0f;
    private Vector3 oldPos;
    private Vector3 newPos;

    // Start is called before the first frame update
    void Start()
    {
        lookScript = this.gameObject.GetComponent<PlayerLook>();
        cController = this.gameObject.GetComponent<CharacterController>();
    }

    // Update is called once per frame
    void Update()
    {
        PlayerMoving();
    }

    private void PlayerMoving()
    {
        // reads players input 
        float x = Input.GetAxisRaw("Horizontal");
        float z = Input.GetAxisRaw("Vertical");

        Jumping();
        HeadBobbing();
        if(this.gameObject.GetComponent<LaserBeamElement>().usingLaserBeam == true)
        {
            moveSpeed = 6.0f;
        }
        else
        {
            moveSpeed = 12.0f;
        }
        // converting the players input into a vector 3 and timings it by the players look direction
        Vector3 inputMove = new Vector3(x, 0.0f, z);
        Vector3 realMove = Quaternion.Euler(0.0f, lookScript.GetSpin(), 0.0f) * inputMove;
        realMove.Normalize();

        // friction
        // we store the y velocity
        float cacheY = velocity.y;
        // set the y velocity to be 0
        velocity.y = 0;
        // movement for the player
        velocity += realMove * acceleration * Time.deltaTime;
        // friction for the players x and z axis
        velocity -= velocity.normalized * acceleration * frictionCurve.Evaluate(velocity.magnitude) * Time.deltaTime;
        // we give back the y velocity
        velocity.y = cacheY;

        // multiplies velocity by desired movespeed
        float planarSpeed = moveSpeed;
        velocity.x = realMove.x * planarSpeed;
        velocity.z = realMove.z * planarSpeed;

        // gravity on the player
        velocity.y -= gravity * Time.deltaTime;
        // getting the position before the player moves (headbobbing)
        oldPos = transform.position;
        // moving the player on screen
        cController.Move(velocity * Time.deltaTime);
        // getting the position after the player moves (headbobbing)
        newPos = transform.position;

        // collision when touching the roof
        if((cController.collisionFlags & CollisionFlags.Above) != 0)
        {
            velocity.y = -1.0f;
        }

        CoyoteTime();
    }

    private void Jumping()
    {
        // checks if player is on the ground and if player has press space
        if (Input.GetKeyDown(KeyCode.Space) && isGrounded)
        {
            velocity.y = jumpSpeed;
            isGrounded = false;
        }
    }

    private void CoyoteTime()
    {
        // collision detection for player
        if((cController.collisionFlags & CollisionFlags.Below) != 0)
        {
            isGrounded = true;
            StoredJumpVelo = velocity;
            velocity.y = -1.0f;
            currentCoyoteTime = coyoteTime;
        }
        // coyoteTime
        if (currentCoyoteTime > 0)
        {
            currentCoyoteTime -= Time.deltaTime;
        }
        else if (currentCoyoteTime < 0)
        {
            isGrounded = false;
            currentCoyoteTime = coyoteTime;
        }
    }

    private void HeadBobbing()
    {
        // getting the difference between the oldpos and newpos
        Vector3 frameMove = newPos - oldPos;
        Vector2 planarFrameMove = new Vector2(frameMove.x, frameMove.z);
        headBobTimer += planarFrameMove.magnitude;

        // to get how much the head moves per frame
        Vector2 planarFrameVelocity = planarFrameMove;
        planarFrameVelocity.x /= Time.deltaTime;
        planarFrameVelocity.y /= Time.deltaTime;

        // for blending back to the neutral position of the head
        if (isGrounded && planarFrameVelocity.magnitude > headBobMinSpeed)
        {
            if (headBobMultiplier <= 0.0f)
            {
                headBobMultiplier = 1.0f;
            }
            else
            {
                headBobMultiplier += headBobBlendSpeed * Time.deltaTime;
                headBobMultiplier = Mathf.Min(1.0f, headBobMultiplier);
            }
        }
        else
        {
            headBobMultiplier -= headBobBlendSpeed * Time.deltaTime;
            headBobMultiplier = Mathf.Max(0.0f, headBobMultiplier);

            if (headBobMultiplier <= 0.0f)
            {
                headBobTimer = 0.0f;
            }
        }

        // movement for the head bobbing
        Vector3 localPos = lookScript.GetCamera().transform.localPosition;
        float headBobMove = (Mathf.Cos(headBobTimer * headBobFrequency) - 1.0f) * headBobAmplitude;
        localPos.y = headBobNeutral + (headBobMove * headBobBlendCurve.Evaluate(headBobMultiplier));
        lookScript.GetCamera().transform.localPosition = localPos;
    }

}

