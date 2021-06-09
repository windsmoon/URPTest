using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace MagicalLand.GameLogic.Input
{
    public class InputManager : MonoBehaviour
    {
        #region delegates
        public static Action<Vector2, bool> OnMove;
        public static Action<Vector2> OnRotateView;
        #endregion

        #region fields
        private Vector2 moveDirection;
        private Vector2 rotateViewDelta;
        private bool isSprint;
        #endregion

        #region unity methods
        private void Update()
        {
            if (OnMove != null)
            {
                OnMove(moveDirection, isSprint);
            }

            if (OnRotateView != null)
            {
                OnRotateView(rotateViewDelta);
            }
        }
        #endregion
        
        #region methods
        public void HandleMove(InputAction.CallbackContext context)
        {
            moveDirection = context.ReadValue<Vector2>();
        }

        public void HandleSprint(InputAction.CallbackContext context)
        {
            if (context.performed)
            {
                isSprint = true;
            }

            else if (context.canceled)
            {
                isSprint = false;
            }
        }

        public void HandleViewDistance(InputAction.CallbackContext context)
        {
            float input = context.ReadValue<float>();
            Debug.Log(input);
        }
        public void HandleRotateView(InputAction.CallbackContext context)
        {
            rotateViewDelta = context.ReadValue<Vector2>();
        }
        #endregion
    }
}
  