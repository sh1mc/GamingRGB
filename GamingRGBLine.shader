// Dear developers
// Feel free to make pull requests!
// https://github.com/sh1mc/GamingRGB
// - sh1mc
Shader "Custom/GamingRGBLine"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [MaterialToggle] _Decol ("Decolorization", Float ) = 1
        _TextureIntensity ("TextureIntensity", Range(0, 1)) = 1
        _Thick1 ("Thick1", Range(0.0002, 0.005)) = 0.00284
        _Space1 ("Space1", Range(0.0005, 0.02)) = 0.00851
        _Speed1 ("Speed1", Range(0.1, 5)) = 2
        _Freq1 ("Freq1", Range(0.8, 10)) = 5
        _Thick2 ("Thick2", Range(0.0002, 0.005)) = 0.0002
        _Space2 ("Space2", Range(0.0005, 0.02)) = 0.0011
        _Speed2 ("Speed2", Range(0.5, 5)) = 0.5
        _Freq2 ("Freq2", Range(0.8, 10)) = 4.91
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
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            sampler2D _MainTex_ST;
            float _Decol;
            float _TextureIntensity;
            float _Thick1;
            float _Space1;
            float _Speed1;
            float _Freq1;
            float _Thick2;
            float _Space2;
            float _Speed2;
            float _Freq2;
            float _Cutoff;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            float f1(float x, float t) {
                return (sin(_Freq1 * x + t * _Speed1) + 1) / 2;
            }
            float f2(float x, float t) {
                return (cos(_Freq2 * x + t * _Speed2) + 1) / 2;
            }

            fixed4 frag (v2f i) : SV_Target
            {   
                float PI = 3.1415926535;
                float PI1 = 2 * PI / 3, PI2 = 4 * PI / 3;
                fixed r = 0, g = 0, b = 0;
                float y1 = f1(i.uv.x, _Time.y);
                float y2 = f2(i.uv.x, _Time.y);
                fixed d = 0;
                d += step(abs((y1 % 1.0) - i.uv.y) % _Space1, _Thick1);
                d += step(abs((y2 % 1.0) - i.uv.y) % _Space2, _Thick2);
                float theta = 2 * PI * (abs((y1 % 1.0) - i.uv.y) + abs((y2 % 1.0) - i.uv.y));
                    r += d * (sin(theta) + 1) / 2;
                    g += d * (sin(theta + PI1) + 1) / 2;
                    b += d * (sin(theta + PI2) + 1) / 2;
                fixed4 texcol = tex2D(_MainTex, i.uv);
                fixed ave_de = _Decol * (texcol.x + texcol.y + texcol.z) / 3;
                fixed4 col = fixed4(
                    texcol.x * (1 - _Decol) + ave_de,
                    texcol.y * (1 - _Decol) + ave_de,
                    texcol.z * (1 - _Decol) + ave_de,
                1);
                fixed4 o = clamp(fixed4(r, g, b, 1), 0, 1) + col * _TextureIntensity;
                clip(texcol.a - _Cutoff);
                return o;
            }
            ENDCG
        }
    }
}