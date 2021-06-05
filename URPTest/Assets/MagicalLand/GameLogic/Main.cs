using System;
using System.Collections;
using System.Collections.Generic;
using MagicalLand.GameLogic.Scene;
using UnityEngine;

namespace MagicalLand.GameLogic
{
    public class Main : MonoBehaviour
    {
        #region unity methods
        private void Awake()
        {
            DontDestroyOnLoad(gameObject);
            SceneManager.Load();
        }
        #endregion
    }
}
