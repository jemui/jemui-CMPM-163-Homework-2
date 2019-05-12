Shader "Roystan/Toon"
{
	Properties
	{
		_Color("Color", Color) = (0.5, 0.65, 1, 1)
		_MainTex("Main Texture", 2D) = "white" {}	
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
			#pragma multi_complie_fwdbase
			
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
			
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldNormal = UnityObjectToWorldNormal(v.normal);
				o.viewDir = WorldSpaceViewDir(v.vertex);
				TRANSFER_SHADOW(o)

				return o;
			}
			
			float4 _Color;

			float4 frag (v2f i) : SV_Target
			{
				float4 sample = tex2D(_MainTex, i.uv);
				float3 normal = normalize(i.worldNormal);
				float NdotL = dot(_WorldSpaceLightPos0, normal);

				// Shadow macro that returns a value between 0 (no shadow) and 1 (shadow)
				float shadow = SHADOW_ATTENUATION(1); 

				// Divide lighting into 2 bands: light and dark. Also eliminate jaggedness
				float lightIntensity = smoothstep(0, 0.01, NdotL * shadow);

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
		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
	}
}