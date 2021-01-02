using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CelPBRDebug : MonoBehaviour
{
    #region fields
    [SerializeField]
    [Range(0, 1)]
    private float threshold = 0.5f;
    #endregion

    #region unity methods
    private void Update()
    {
        Shader.SetGlobalFloat("_Threshold", threshold);        
    }
    #endregion
}
