using System;
using System.Collections;
using System.Collections.Generic;
using MagicalLand.GameLogic;
using UnityEngine;
using MagicalLand.GameLogic.Input;
using MagicalLand.GameLogic.Scene;
using UnityEngine.Rendering;

namespace MagicalLand.Character
{
    public class CharacterController
    {
        #region fields
        private float runSpeed = 4;
        private float turnSpeed = 10;
        private float fullSpeedTime = 0.7f;
        private float walkTimer = 0f;
        private float accelerate;
        
        private Vector2 currentSpeed;
        private Transform transform;
        private Animator animator;
        private Vector3 targetDirection;
        private Vector2 moveInput;
        private bool isRun;
        #endregion

        #region constructors
        public CharacterController(Transform transform)
        {
            // todo
            this.accelerate = runSpeed / fullSpeedTime;

            this.transform = transform;
            this.animator = transform.GetComponent<Animator>();
            InputManager.OnMove += OnMove;
            Game.OnLateUpdate += OnLateUpdate;
            // InputManager.OnRotateView += OnRotateView;
        }
        
        #endregion

        #region methods
        public void Destroy()
        {
            Game.OnUpdate -= OnLateUpdate;
            InputManager.OnMove -= OnMove;
        }
        
        private void OnMove(Vector2 input, bool isRun)
        {
            this.moveInput = input;
            this.isRun = isRun;
            Camera camera = SceneManager.GetActiveSceneController().GetMainCamera();
            Vector3 forward = camera.transform.TransformDirection(Vector3.forward);
            forward.y = 0;
            Vector3 right = camera.transform.TransformDirection(Vector3.right);
            // targetDirection = input.x * right + input.y * forward;
            targetDirection = forward;
            // transform.Translate(delta, Space.World);
        }

        private void OnLateUpdate()
        {
            if (moveInput != Vector2.zero)
            {
                if (targetDirection.magnitude > 0.1f)
                {
                    Vector3 lookDirection = targetDirection.normalized;
                    Quaternion targetRotation = Quaternion.LookRotation(lookDirection, transform.up);
                    float eulerY = transform.eulerAngles.y;
                    float diferenceRotation = targetRotation.eulerAngles.y - eulerY;

                    if (diferenceRotation < 0 || diferenceRotation > 0)
                    {
                        eulerY = targetRotation.eulerAngles.y;
                    }

                    var euler = new Vector3(0, eulerY, 0);
                    transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.Euler(euler),
                        turnSpeed * Time.deltaTime);
                }

                // walkTimer += Time.deltaTime;

                // if (walkTimer > fullSpeedTime)
                // {
                //     walkTimer = fullSpeedTime;
                // }
                currentSpeed += moveInput * Time.deltaTime * accelerate;

                if (currentSpeed.magnitude > runSpeed)
                {
                    currentSpeed = currentSpeed * runSpeed / currentSpeed.magnitude;
                }
                
                // float speedRatio = walkTimer / fullSpeedTime;
                // this.currentSpeed = moveInput.normalized * speedRatio * runSpeed;
            }

            else
            {
                // walkTimer -= Time.deltaTime;
                //
                // if (walkTimer < 0)
                // {
                //     walkTimer = 0;
                // }
                //
                // float speedRatio = walkTimer / fullSpeedTime;
                // this.currentSpeed = this.currentSpeed.normalized * speedRatio * runSpeed;

                float diffSpeed = Time.deltaTime * accelerate;
                float tempSpeed = currentSpeed.magnitude - diffSpeed;

                if (tempSpeed < 0)
                {
                    currentSpeed = Vector2.zero;
                }

                else
                {
                    currentSpeed = currentSpeed * (tempSpeed / currentSpeed.magnitude);
                }
            }

            // float currentSpeed = Mathf.Lerp(0, runSpeed, walkTimer / fullSpeedTime);
            // currentSpeed = Vector2.Lerp(Vector2.zero, Vector2.one, walkTimer / fullSpeedTime);

            // if (currentSpeed > 0f)
            // {
                // transform.Translate(transform.forward * currentSpeed * Time.deltaTime, Space.World);
            // }
            
            Debug.Log(currentSpeed);

            // if (isRun)
            // {
            //     currentSpeed = runSpeed;
            // }
            
            animator.SetBool("IsRun", isRun);
            // animator.SetFloat("Speed", currentSpeed);
            animator.SetFloat("SpeedX", this.currentSpeed.x);
            animator.SetFloat("SpeedY", this.currentSpeed.y);
        }

        // private void OnRotateView(Vector2 rotateDelta)
        // {
        //     if (rotateDelta.sqrMagnitude < 0.01f)
        //     {
        //         return;
        //     }
        //     
        //     MoveSpeedConfigTemp moveSpeedConfigTemp = transform.GetComponent<MoveSpeedConfigTemp>();
        //     float rotateSpeed = moveSpeedConfigTemp.rotateSpeed;
        //     float scaledRotateSpeed = rotateSpeed * Time.deltaTime;
        //     rotateDelta = rotateDelta * scaledRotateSpeed;
        //     Vector3 rotate;
        //     rotate.y = rotateDelta.x;
        //     rotate.x = rotateDelta.y;
        //     rotate.z = 0;
        //     // thirdPersonFollowTarget.Rotate(rotate, );
        // }
        
        // void FixedUpdate ()
        // {
        //     input.x = Input.GetAxis("Horizontal");
        //     input.y = Input.GetAxis("Vertical");
        //
        //     // set speed to both vertical and horizontal inputs
        //     if (useCharacterForward)
        //         speed = Mathf.Abs(input.x) + input.y;
        //     else
        //         speed = Mathf.Abs(input.x) + Mathf.Abs(input.y);
        //
        //     speed = Mathf.Clamp(speed, 0f, 1f);
        //     speed = Mathf.SmoothDamp(anim.GetFloat("Speed"), speed, ref velocity, 0.1f);
        //     anim.SetFloat("Speed", speed);
        //
        //     if (input.y < 0f && useCharacterForward)
        //         direction = input.y;
        //     else
        //         direction = 0f;
        //
        //     anim.SetFloat("Direction", direction);
        //
        //     // set sprinting
        //     isSprinting = ((Input.GetKey(sprintJoystick) || Input.GetKey(sprintKeyboard)) && input != Vector2.zero && direction >= 0f);
        //     anim.SetBool("isSprinting", isSprinting);
        //
        //     // Update target direction relative to the camera view (or not if the Keep Direction option is checked)
        //     UpdateTargetDirection();
        //     if (input != Vector2.zero && targetDirection.magnitude > 0.1f)
        //     {
        //         Vector3 lookDirection = targetDirection.normalized;
        //         freeRotation = Quaternion.LookRotation(lookDirection, transform.up);
        //         var diferenceRotation = freeRotation.eulerAngles.y - transform.eulerAngles.y;
        //         var eulerY = transform.eulerAngles.y;
        //
        //         if (diferenceRotation < 0 || diferenceRotation > 0) eulerY = freeRotation.eulerAngles.y;
        //         var euler = new Vector3(0, eulerY, 0);
        //
        //         transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.Euler(euler), turnSpeed * turnSpeedMultiplier * Time.deltaTime);
        //     }
        // }

        #endregion
    }
}
