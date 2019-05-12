using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RenderEffectBloom : MonoBehaviour
{
    private int max = 0;
    public Shader BloomShader;
    [Range(0, 50)]
    public int BloomFactor;
    private Material screenMat;

    Material ScreenMat
    {
        get
        {
            if (screenMat == null)
            {
                screenMat = new Material(BloomShader);
                screenMat.hideFlags = HideFlags.HideAndDontSave;
            }
            return screenMat;
        }
    }

    void Start()
    {
        if (!SystemInfo.supportsImageEffects)
        {
            enabled = false;
            return;
        }

        if (!BloomShader && !BloomShader.isSupported)
        {
            enabled = false;
        }
       
    }

    // sourceTexture displays 
    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        if (BloomShader != null)
        {
            // Create two temp rendertextures to hold bright pass and blur pass result
            RenderTexture brightPass = RenderTexture.GetTemporary(sourceTexture.width, sourceTexture.height);
            RenderTexture blurPass = RenderTexture.GetTemporary(sourceTexture.width, sourceTexture.height);

            // Blit using bloom shader pass 0 for bright pass ( Graphics.Blit(SOURCE, DESTINATION, MATERIAL, PASS INDEX);)
            Graphics.Blit(sourceTexture, brightPass, ScreenMat, 0);

            // Set _Steps to BloomFactor in the shader
            ScreenMat.SetFloat("_Steps", BloomFactor);

            // Blit using bloom shader pass 1 for blur pass ( Graphics.Blit(SOURCE, DESTINATION, MATERIAL, PASS INDEX);)
            Graphics.Blit(brightPass, blurPass, ScreenMat, 1);

            // Set sourceTexture to _BaseTex in the shader
            ScreenMat.SetTexture("_BaseTex", sourceTexture);

            // Blit using bloom shader pass 2 for combine pass ( Graphics.Blit(SOURCE, DESTINATION, MATERIAL, PASS INDEX);)
            Graphics.Blit(blurPass, destTexture, ScreenMat, 2);

            // Release both temp rendertextures
            RenderTexture.ReleaseTemporary(brightPass);
            RenderTexture.ReleaseTemporary(blurPass); 
        }
        else
        {
            Graphics.Blit(sourceTexture, destTexture);
        }
    }

    // Update is called once per frame
    void Update()
    {
        // Animate bloom factor
        if(BloomFactor != 50 && max == 0) 
            BloomFactor++;
        else if(BloomFactor >= 50) 
            max = 1;

        if(BloomFactor != 0 && max == 1)
            BloomFactor--;
        else if(BloomFactor == 0)
            max = 0;

        Debug.Log(BloomFactor);
    }

    void OnDisable()
    {
        if (screenMat)
        {
            DestroyImmediate(screenMat);
        }
    }
}
