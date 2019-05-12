Shader "Custom/Outline"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Outline("Outline",float) = 1.01
    }
    SubShader
    {
        Pass 
        {
            ZWrite off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"


            float _Outline;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
            };
           struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v) 
            {
                v2f o;
                v.vertex += float4(v.normal, 1.0) * _Outline;
                //v.vertex += float4(v.normal, 1.0) * _Outline;
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                return o;
            }

            float4 frag (v2f i) : SV_Target 
            {
                return float4(0,0,0,1);
            }
            ENDCG
        }

        Pass 
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v) 
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target 
            {
                return float4(1,1,1,1);
            }

            ENDCG
        }
    }
}
