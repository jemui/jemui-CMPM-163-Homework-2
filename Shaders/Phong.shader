
//Adapted from Example 5.3 in The CG Tutorial by Fernando & Kilgard
Shader "CM163/Phong"
{
    Properties
    {   
        _Color ("Color", Color) = (1, 1, 1, 1) //The color of our object
        _Outline("Outline", Range(0.01, 0.05)) = 0.01
        _EmmisiveColor("Emmisive Color", Color) = (1, 1, 1, 1)
        _Emissiveness("Emmissiveness", Range(0,10)) = 0
        _Shininess ("Shininess", Float) = 10 //Shininess
        _SpecColor ("Specular Color", Color) = (1, 1, 1, 1) //Specular highlights color
        _MainTex ("Texture", 2D) = "white" {}

        // Toon Shader
		_AmbientColor("Ambient Color", Color) = (0.4, 0.4, 0.4, 1)

		[HDR]
		_SpecularColor("Specular Color", Color) = (0.9, 0.9, 0.9, 1)
		_Glossiness("Glossiness", Float) = 32
		_RimColor("Rim Color", Color) = (1, 1, 1, 1)
		_RimAmount("Rim Amount", Range(0,1)) = 0.716
		_RimThreshold("Rim Threshold", Range(0, 1)) = 0.1
    }
    
    SubShader
    {

        // Toon Shader
	    Pass
		{
			Tags
			{
				"LightMode" = "ForwardBase"
				"PassFlags" = "OnlyDirectional"
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			struct appdata
			{
				float4 vertex : POSITION;				
				float4 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 worldNormal : NORMAL;
				float3 viewDir : TEXCOORD1;
				float2 uv : TEXCOORD0;
				SHADOW_COORDS(2)
			};

			sampler2D _MainTex;

			float4 _MainTex_ST;
			float4 _AmbientColor;
			float4 _SpecularColor;
			float4 _RimColor;

			float _Glossiness;
			float _RimAmount;
			float _RimThreshold;
			float _Outline;

			v2f vert (appdata v)
			{
				v2f o;
                
                // Outline
                v.vertex += float4(v.normal, 1.0) * _Outline;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = WorldSpaceViewDir(v.vertex);
			    //	TRANSFER_SHADOW(o)

				return o;
			}
			
			float4 _Color;

			float4 frag (v2f i) : SV_Target
			{
				float4 sample = tex2D(_MainTex, i.uv);
				float3 normal = normalize(i.worldNormal);
				float NdotL = dot(_WorldSpaceLightPos0, normal);

				// Shadow macro that returns a value between 0 (no shadow) and 1 (shadow)
		    	//	float shadow = SHADOW_ATTENUATION(1); 

				// Divide lighting into 2 bands: light and dark. Also eliminate jaggedness
                float lightIntensity = smoothstep(0, 0.01, NdotL);// * shadow);

				// _LightColor0 is the color of the main directional light
				float4 light = lightIntensity * _LightColor0;
		
				// Calculate specular reflection
				float3 viewDir = normalize(i.viewDir);

				float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
				float NdotH = dot(normal, halfVector);

				float SpecularIntensity = pow(NdotH * lightIntensity, _Glossiness * _Glossiness);

				// Toonify reflection
				float SpecularIntensitySmooth = smoothstep(0.005, 0.01, SpecularIntensity);
				float4 specular = SpecularIntensitySmooth * _SpecularColor;

				// Rim lighting
				float4 rimDot = 1 - dot(viewDir, normal);

				// Appear on illuminated surfaces
				float rimIntensity = rimDot * pow(NdotL, _RimThreshold);
				rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
				

				return _Color * sample * (_AmbientColor + light + specular + rimIntensity);
			}
			ENDCG
		}

        Pass 
        {
            Tags 
            { "LightMode" = "ForwardAdd" } //Important! In Unity, point lights are calculated in the the ForwardAdd pass
            Blend One One //Turn on additive blending if you have more than one point light
            ZWrite off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            
            float _Outline;
           
            uniform float4 _LightColor0; //From UnityCG
            uniform float4 _Color; 
            uniform float4 _SpecColor;
            uniform float _Shininess;
    
            uniform float4 _EmmisiveColor;
            uniform float _Emissiveness;   
            sampler _MainTex;       
          
            struct appdata
            {
                    float4 vertex : POSITION;
                    float3 normal : NORMAL;
                    float2 uv: TEXCOORD0;
            };

            struct v2f
            {
                    float4 vertex : SV_POSITION;
                    float3 normal : NORMAL;       
                    float3 vertexInWorldCoords : TEXCOORD1;
                    float2 uv: TEXCOORD0;
            };

 
           v2f vert(appdata v)
           { 
                v2f o;
                
                // Outline
                v.vertex += float4(v.normal, 1.0) * _Outline;
                
                o.vertexInWorldCoords = mul(unity_ObjectToWorld, v.vertex); //Vertex position in WORLD coords
                o.normal = v.normal; //Normal 
                o.uv = v.uv;
                o.vertex = UnityObjectToClipPos(v.vertex); 
                
            
                return o;
           }

           fixed4 frag(v2f i) : SV_Target
           {
                
                float3 P = i.vertexInWorldCoords.xyz;
                float3 N = normalize(i.normal);
                float3 V = normalize(_WorldSpaceCameraPos - P);
                float3 L = normalize(_WorldSpaceLightPos0.xyz - P);
                float3 H = normalize(L + V);
                
                float3 Kd = _Color.rgb; //Color of object
                float3 Ka = UNITY_LIGHTMODEL_AMBIENT.rgb; //Ambient light
                //float3 Ka = float3(0,0,0); //UNITY_LIGHTMODEL_AMBIENT.rgb; //Ambient light
                float3 Ks = _SpecColor.rgb; //Color of specular highlighting
                float3 Kl = _LightColor0.rgb; //Color of light
                
                
                //AMBIENT LIGHT 
                float3 ambient = Ka;
                
               
                //DIFFUSE LIGHT
                float diffuseVal = max(dot(N, L), 0);
                float3 diffuse = Kd * Kl * diffuseVal;
                
                
                //SPECULAR LIGHT
                float specularVal = pow(max(dot(N,H), 0), _Shininess);
                
                if (diffuseVal <= 0) {
                    specularVal = 0;
                }
                
                float3 specular = Ks * Kl * specularVal;
                
                float4 texColor = tex2D(_MainTex, i.uv);
                //FINAL COLOR OF FRAGMENT
              
                return float4(_EmmisiveColor * _Emissiveness + ambient+ diffuse + specular, 1.0) * texColor;
 
            }
            ENDCG
        }
        //UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
