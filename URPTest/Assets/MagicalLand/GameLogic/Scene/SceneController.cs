using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace MagicalLand.GameLogic.Scene
{
    public class SceneController
    {
        #region fields
        protected int id;
        protected UnityEngine.SceneManagement.Scene scene;
        protected GameObject rootGameObject;
        protected Transform rootTransform;
        #endregion

        #region properties
        public int ID
        {
            get => id;
        }

        public string Name
        {
            get => scene.name;
        }
        #endregion

        #region constructors
        public SceneController(int id, UnityEngine.SceneManagement.Scene scene)
        {
            this.id = id;
            this.scene = scene;
            GameObject[] rootGameObjects = scene.GetRootGameObjects();

            if (rootGameObjects.Length == 0 || rootGameObjects.Length > 1)
            {
                Debug.LogWarning("No RootGameObject"); // todo
                return;
            }

            rootGameObject = rootGameObjects[0];
            rootTransform = rootGameObject.transform;
        }
        #endregion

        #region methods
        // todo
        public Camera GetMainCamera()
        {
            return Camera.main;
        }
        #endregion
    }
}
