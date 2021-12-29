using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MBrightnessSaturationAndContrast : MPostEffectsBase
{
    public Shader briSatConShader;
    private Material briSatConMaterial;
    public Material Mmaterial
    {
        get
        {
            briSatConMaterial = CheckShaderAndCreateMaterial(briSatConShader, briSatConMaterial);
            return briSatConMaterial;
        }
    }
    [Range(0.0f, 3.0f)]
    public float brightness = 1.0f;
    [Range(0.0f, 3.0f)]
    public float saturation = 1.0f;
    [Range(0.0f, 3.0f)]
    public float contrast = 1.0f;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(Mmaterial != null)
        {
            Mmaterial.SetFloat("_Brightness", brightness);
            Mmaterial.SetFloat("_Saturation", saturation);
            Mmaterial.SetFloat("_Contrast", contrast);
            Graphics.Blit(source, destination, Mmaterial);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
