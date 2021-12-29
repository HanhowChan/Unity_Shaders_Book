using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MEdgeDetection : MPostEffectsBase
{
    public Shader edgeDetectShader;
    private Material edgeDetectMaterial = null;
    public Material Mmaterial
    {
        get
        {
            edgeDetectMaterial = CheckShaderAndCreateMaterial(edgeDetectShader, edgeDetectMaterial);
            return edgeDetectMaterial;
        }
    }

    [Range(0.0f, 1.0f)]
    public float edgesOnly = 0.0f;
    public Color edgeColor = Color.black;
    public Color backgroudColor = Color.white;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(Mmaterial != null)
        {
            Mmaterial.SetFloat("_EdgeOnly", edgesOnly);
            Mmaterial.SetColor("_EdgeColor", edgeColor);
            Mmaterial.SetColor("_BackgroudColor", backgroudColor);
            Graphics.Blit(source, destination, Mmaterial);
        }
        else
        {
            Graphics.Blit(source, destination);
        }
    }

}
