using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColorLerp : MonoBehaviour
{
    #region fields
    [SerializeField]
    private float time = 0.2f;

    private float timer = 0;
    private Color targetColor = Color.black;
    private Color startColor = Color.black;
    
    private Material material;
    #endregion
    
    // Start is called before the first frame update
    void Start()
    {
        targetColor = Random.ColorHSV();
        material = GetComponent<MeshRenderer>().sharedMaterial;
    }

    // Update is called once per frame
    void Update()
    {
        timer += Time.deltaTime;
        
        if (timer > time)
        {
            timer = 0;
            startColor = targetColor;
            targetColor = Random.ColorHSV();
        }
        
        Color currentColor = Color.Lerp(startColor, targetColor, timer / time);
        material.SetColor("_EmissionColor", currentColor);
        material.SetColor("_KKHighlightData", new Vector4(-0.31f, Random.Range(-1, 1), 256, 0));
    }
}
