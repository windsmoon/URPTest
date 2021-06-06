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
        public static Action<Vector2> OnMove;
        #endregion

        #region fields
        private Vector2 moveDirection;
        #endregion

        #region unity methods
        private void Update()
        {
            if (OnMove != null)
            {
                OnMove(moveDirection);
            }         
        }
        #endregion
        
        #region methods
        public void Move(InputAction.CallbackContext context)
        {
            moveDirection = context.ReadValue<Vector2>();
        }
        #endregion
    }
}
  