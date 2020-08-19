// Dear developers
// Feel free to make pull requests!
// https://github.com/sh1mc/GamingRGB
// - sh1mc
Shader "Custom/GamingRGB"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [MaterialToggle] _Decol ("Decolor", Float ) = 1
        _Red ("Red", Range(0, 1)) = 1
        _Green ("Green", Range(0, 1)) = 1
        _Blue ("Blue", Range(0, 1)) = 1
        _Cycle ("Cycle", Range(0.03, 0.5)) = 0.1
        _Scale ("Scale", Range(0.5, 3)) = 1
        _RGBIntensity ("RGB_Intensity", Range(0, 1)) = 1
        _TexIntensity ("Texture_Intensity", Range(0, 1)) = 1
        _FreqR ("Freq_R", Range(0.3, 3)) = 1
        _FreqG ("Freq_G", Range(0.3, 3)) = 1
        _FreqB ("Freq_B", Range(0.3, 3)) = 1
        _Cutoff("Cutoff", Range(0, 1)) = 0.5
    }
    SubShader
    {
        Tags {
            "Queue" = "AlphaTest"
            "RenderType" = "TransparentCutoff"
            }
        LOD 100

        Pass
        {
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Decol;
            float _Red;
            float _Green;
            float _Blue;
            float _Cycle;
            float _Scale;
            float _RGBIntensity;
            float _TexIntensity;
            float _FreqR;
            float _FreqG;
            float _FreqB;
            float _Cutoff;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {   
                float PI = 3.14159265;
                float xy = (i.uv.x + i.uv.y) * _Scale;
                fixed3 gaming_col = fixed3(
                _Red * (sin(_FreqR * (_Time.y + xy) / _Cycle) + 1) / 2,
                _Green * (sin(_FreqG * (_Time.y + xy) / _Cycle + PI * 2 / 3) + 1) / 2,
                _Blue * (sin(_FreqB * (_Time.y + xy) / _Cycle + PI * 4 / 3) + 1) / 2
                );
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed ave = (col.x + col.y + col.z) / 3;
                fixed4 o = clamp(
                fixed4(
                    col.x * (1 - _Decol) + ave * _Decol,
                    col.y * (1 - _Decol) + ave * _Decol,
                    col.z * (1 - _Decol) + ave * _Decol,
                     1) * _TexIntensity +
                (fixed4(gaming_col * _RGBIntensity, 1)),
                0, 1);
                clip(col.a - _Cutoff);
                return o;
            }
            ENDCG
        }
    }
}