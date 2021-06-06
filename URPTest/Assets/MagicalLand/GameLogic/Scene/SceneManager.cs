using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace MagicalLand.GameLogic.Scene
{
    public static class SceneManager
    {
        #region fields
        private static Dictionary<int, SceneController> sceneControllerDict;
        #endregion

        #region constructors
        static SceneManager()
        {
            sceneControllerDict = new Dictionary<int, SceneController>();
        }
        #endregion

        #region methods
        //  todo : temp code
        public static void Load()
        {
            UnityEngine.SceneManagement.Scene scene = UnityEngine.SceneManagement.SceneManager.GetActiveScene();
            sceneControllerDict[1] = new MainSceneController(1, scene); 
        }

        public static SceneController GetActiveSceneController()
        {
            return sceneControllerDict[1];
        }
        #endregion
    }
}
