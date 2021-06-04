using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace MagicalLand.GameLogic
{
    public class InputManager : MonoBehaviour
    {
        #region fields
        public Action<Vector2> OnMove;
        #endregion
    
        #region unity methods
        private void Update()
        {
        }
        #endregion

        #region methods
        public void Move(InputAction.CallbackContext context)
        {
            if (OnMove != null)
            {
                Vector2 direction = context.ReadValue<Vector2>();
                OnMove(direction);
            }
        }
        #endregion
    }
}
  