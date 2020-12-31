using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CarController
{
    public class CarControllerBehaviour : MonoBehaviour
    {
        #region fields
        [SerializeField] 
        private Camera camera;
        [SerializeField]
        private float speed = 15;
        [SerializeField]
        private float rotateSpeed = 45f;
        [SerializeField]
        private float cameraMoveTime = 1;
        private Vector3 cameraTargetPos;
        #endregion
        
        #region unity methods
        private void Update()
        {
            if (Input.GetKey(KeyCode.W))
            {
                transform.Translate(Vector3.forward * speed * Time.deltaTime, Space.Self);
            }

            if (Input.GetKey(KeyCode.A))
            {
                transform.Rotate(Vector3.up, -rotateSpeed * Time.deltaTime, Space.Self);
            }
            
            else if (Input.GetKey(KeyCode.D))
            {
                transform.Rotate(Vector3.up, rotateSpeed * Time.deltaTime, Space.Self);
            }
            
        }

        private void LateUpdate()
        {
            Vector3 backward = -transform.forward;
            cameraTargetPos = transform.position + new Vector3(0, 6, 10 * backward.z);
            Vector3 posOffset = cameraTargetPos - camera.transform.position;
            Vector3 currentCameraSpeed = posOffset / cameraMoveTime;
            camera.transform.position = camera.transform.position + currentCameraSpeed * Time.deltaTime; 
            camera.transform.LookAt(transform, Vector3.up);
        }
        #endregion
    } 
}

