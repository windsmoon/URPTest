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
        private bool isRun;
        #endregion

        #region unity methods
        private void Update()
        {
            if (OnMove != null)
            {
                OnMove(moveDirection, isRun);
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

        public void HandleRun(InputAction.CallbackContext context)
        {
            if (context.performed)
            {
                isRun = true;
            }

            else if (context.canceled)
            {
                isRun = false;
            }
        }
        public void HandleRotateView(InputAction.CallbackContext context)
        {
            rotateViewDelta = context.ReadValue<Vector2>();
        }
        #endregion
    }
}
  