// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/GlowShader" {

    Properties {
        _Color ("Color", Color) = (1,0.6,0,1)
        _GlowColor("Glow Color", Color) = (1,1,0,1)
        _Strength("Glow Strength", Range(5.0, 1.0)) = 2.0
        _GlowRange("Glow Range", Range(0.1,1)) = 0.6
        // _MainTex ("Albedo (RGB)", 2D) = "white" {}
        // _Glossiness ("Smoothness", Range(0,1)) = 0.5
        // _Metallic ("Metallic", Range(0,1)) = 0.0
    }

    SubShader {
           
        Pass {
            Tags 
            { 
            	"LightMode"="ForwardBase" 
            	"Queue"="Transparent" 
            	"RenderType"="Transparent"
            }
            // Cull Front
            ZWrite Off
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _Color;
            float4 _GlowColor;
            float _Strength;
            float _GlowRange;

            struct a2v {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct v2f {
                float4 position : SV_POSITION;
                float4 col : COLOR;
                float3 normalDir : NORMAL ;
                float3 viewDir : VECTOR ;
            };

            v2f vert(a2v a) {
                v2f o;
                float4x4 modelMatrix = unity_ObjectToWorld;
                float4x4 modelMatrixInverse = unity_WorldToObject;
                float3 normalDirection = normalize(mul(a.normal, modelMatrixInverse)).xyz;
                float3 viewDirection = normalize(_WorldSpaceCameraPos - mul(modelMatrix, a.vertex).xyz);
                float4 pos = a.vertex + (a.normal * _GlowRange);
                o.position = UnityObjectToClipPos(pos);
                o.normalDir = normalize(normalDirection);
                o.viewDir = normalize(viewDirection);
               
                return o;
            }

            float4 frag(v2f i) : COLOR {
            	float strength = abs(dot(i.viewDir, i.normalDir));
                float opacity = pow(strength, _Strength);
                float4 col = float4(_GlowColor.xyz, opacity);
//                return  cross(_Color,  col);
				return col;
            }

            ENDCG
        }

    }
    FallBack "Diffuse"
}