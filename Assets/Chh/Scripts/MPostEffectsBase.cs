using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class MPostEffectsBase : MonoBehaviour
{
    //Call when start
    [System.Obsolete]
    protected void CheckResources()
    {
        bool isSupported = CheckSupport();
        if (isSupported == false)
        {
            NotSupported();
        }
    }

    //Called in CheckResources to check support on this platform
    [System.Obsolete]
    protected bool CheckSupport()
    {
        if (SystemInfo.supportsImageEffects == false || SystemInfo.supportsRenderTextures == false)
        {
            Debug.LogWarning("This platform does not support image effects or render textures.");
            return false;
        }
        return true;
    }

    //Called when the platform doesn't support this effect
    protected void NotSupported()
    {
        enabled = false;
    }

    //Called when need to create the material used by this effect
    protected Material CheckShaderAndCreateMaterial(Shader shader, Material material)
    {
        if(shader == null)
        {
            return null;
        }
        if(shader.isSupported && material && material.shader == shader)
        {
            return material;
        }
        if(!shader.isSupported)
        {
            return null;
        }
        else
        {
            material = new Material(shader)
            {
                hideFlags = HideFlags.DontSave
            };
            if (material)
            {
                return material;
            }
            else
            {
                return null;
            }
        }
    }

    // Start is called before the first frame update
    [System.Obsolete]
    void Start()
    {
        CheckResources();
    }

}
