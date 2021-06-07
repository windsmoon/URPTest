﻿using UnityEngine;
using MagicalLand.Character;
using CharacterController = MagicalLand.Character.CharacterController;

namespace MagicalLand.GameLogic.Scene
{
    public class MainSceneController : SceneController
    {
        #region fields
        private Transform playerTransform;
        private CharacterController characterController;
        #endregion

        #region constructors
        public MainSceneController(int id, UnityEngine.SceneManagement.Scene scene) : base(id, scene)
        {
            playerTransform = rootTransform.Find("Reisalin-unity"); 
            this.characterController = new CharacterController(playerTransform);
        }
        #endregion
    }
}