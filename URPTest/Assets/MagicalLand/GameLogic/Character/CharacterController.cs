using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using MagicalLand.GameLogic.Input;

namespace MagicalLand.Character
{
    public class CharacterController
    {
        #region fields
        private float walkSpeed;
        private float runSpeed;
        private Transform transform;
        #endregion

        #region constructors
        public CharacterController(Transform transform)
        {
            this.transform = transform;
            InputManager.OnMove += OnMove;
        }
        #endregion

        #region methods
        public void Destroy()
        {
            InputManager.OnMove -= OnMove;
        }
        
        private void OnMove(Vector2 direction)
        {
            MoveSpeedConfigTemp moveSpeedConfigTemp = transform.GetComponent<MoveSpeedConfigTemp>();
            walkSpeed = moveSpeedConfigTemp.walkSpeed;
            walkSpeed = moveSpeedConfigTemp.runSpeed;
            Vector3 delta = new Vector3(direction.x, 0, direction.y);
            delta = delta.normalized;
            delta *= walkSpeed;
            delta *= Time.deltaTime;
            transform.Translate(delta, Space.World);
        }
        #endregion
    }
}
