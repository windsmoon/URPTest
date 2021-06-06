using System;
using System.Collections;
using System.Collections.Generic;
using MagicalLand.GameLogic.Scene;
using UnityEngine;

namespace MagicalLand.GameLogic
{
    public class Game : MonoBehaviour
    {
        #region delegates
        public static Action OnUpdate;
        public static Action OnLateUpdate;
        #endregion
        
        #region unity methods
        private void Awake()
        {
            DontDestroyOnLoad(gameObject);
            SceneManager.Load();
        }

        private void Update()
        {
            if (OnUpdate != null)
            {
                OnUpdate();
            }

            if (OnLateUpdate != null)
            {
                OnLateUpdate();
            }
        }
        #endregion
    }
}
