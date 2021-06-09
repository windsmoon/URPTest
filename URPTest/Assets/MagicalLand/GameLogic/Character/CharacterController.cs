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
        private bool isSprintInput;
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
        
        private void OnMove(Vector2 input, bool isSprintInput)
        {
            this.moveInput = input;
            this.isSprintInput = isSprintInput;
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
                
                Vector2 diffSpeed = moveInput * Time.deltaTime * accelerate;

                if (diffSpeed.x * currentSpeed.x < 0)
                {
                    diffSpeed.x *= 3;
                }

                if (diffSpeed.y * currentSpeed.y < 0)
                {
                    diffSpeed.y *= 3;
                }

                currentSpeed += diffSpeed;

                if (currentSpeed.magnitude > runSpeed)
                {
                    currentSpeed = currentSpeed * runSpeed / currentSpeed.magnitude;
                }
            }

            else
            {
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

            animator.SetBool("IsSPrint", isSprintInput && moveInput.y > 0 && moveInput.x == 0);
            animator.SetFloat("SpeedX", this.currentSpeed.x);
            animator.SetFloat("SpeedY", this.currentSpeed.y);
        }
        #endregion
    }
}
