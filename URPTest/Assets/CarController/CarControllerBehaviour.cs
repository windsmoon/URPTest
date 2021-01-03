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
        private float mass = 400f;
        [SerializeField]
        private float force = 4000;
        [SerializeField]
        private float frictionCoefficient = 0.6f;
        [SerializeField]
        private float maxSpeedKM_H = 150;
        [SerializeField] 
        private Camera camera;
        // [SerializeField]
        // private float speed = 15;
        [SerializeField]
        private float rotateSpeed = 45f;
        [SerializeField]
        private float cameraMoveTime = 1;
        private Vector3 cameraTargetPos;
        [SerializeField]
        private Vector3 currentSpeed;
        [SerializeField]
        private float maxSpeed;
        [SerializeField]
        private float pressureForce = 0;
        [SerializeField]
        private float frictionForce;
        #endregion
        
        #region unity methods

        private void Awake()
        {
            pressureForce = mass * 9.8f;
            float tempFrictionForce = frictionCoefficient * pressureForce;
            frictionForce = tempFrictionForce;
            maxSpeed = maxSpeedKM_H * 1000 / 3600;
        }

        private void Update()
        {
            Vector3 accelerate;
            
            if (Input.GetKey(KeyCode.W))
            {
                accelerate = force * transform.forward;
            }

            else
            {
                accelerate = Vector3.zero;
            }

            Vector3 speedDirection = Vector3.Magnitude(currentSpeed) != 0 ? currentSpeed.normalized : Vector3.zero;
            accelerate = (accelerate - frictionForce * speedDirection) / mass;
            currentSpeed += accelerate * Time.deltaTime;

            if (Vector3.Magnitude(currentSpeed) > maxSpeed)
            {
                currentSpeed = currentSpeed.normalized * maxSpeed;
            }

            if (currentSpeed.x < 0)
            {
                currentSpeed.x = 0;
            }
            
            if (currentSpeed.y < 0)
            {
                currentSpeed.y = 0;
            }
            
            if (currentSpeed.z < 0)
            {
                currentSpeed.z = 0;
            }
            
            // if (currentSpeed > maxSpeed)
            // {
            //     currentSpeed = maxSpeed;
            // }
            //
            // else if (currentSpeed < 0)
            // {
            //     currentSpeed = 0;
            // }

            transform.position = transform.position + currentSpeed * Time.deltaTime;
            // transform.Translate(currentSpeed * Time.deltaTime, Space.World);

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
            cameraTargetPos = transform.position + new Vector3(0, 2, 2 * backward.z);
            Vector3 posOffset = cameraTargetPos - camera.transform.position;
            Vector3 currentCameraSpeed = posOffset / cameraMoveTime;
            camera.transform.position = camera.transform.position + currentCameraSpeed * Time.deltaTime; 
            camera.transform.LookAt(transform, Vector3.up);
        }
        #endregion
    } 
}

