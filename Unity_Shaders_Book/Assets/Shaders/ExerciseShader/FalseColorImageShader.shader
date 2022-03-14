Shader "Custom/FalseColorImageShader"
{
    Properties{
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader{
        Pass{
            CGPROGRAM
        
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct v2f{
                float4 pos : SV_POSITION;
                fixed4 color : COLOR0;
            };

            v2f vert(appdata_full v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.color = fixed4(v.normal * 0.5 + fixed3(0.5 , 0.5, 0.5), 1.0);

                o.color = fixed4(v.tangent * 0.5 + fixed3(0.5 , 0.5, 0.5), 1.0);

                fixed3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                o.color = fixed4(binormal * 0.5 + fixed3(0.5 , 0.5, 0.5), 1.0);

                o.color = fixed4(v.texcoord.xy, 0.0, 1.0);
            };
            ENDCG
        }
       
    }
    FallBack "Diffuse"
}
