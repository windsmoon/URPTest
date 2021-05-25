using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MagicalLand.CharacterController
{
    public class CharacterMove : MonoBehaviour
    {
        #region fields
        [SerializeField]
        private float walkSpeed;
        [SerializeField]
        private float runSpeed;

        private new Transform transform;
        #endregion

        #region unity methods
        private void Awake()
        {
            transform = gameObject.transform;
        }
        #endregion
    }
}
