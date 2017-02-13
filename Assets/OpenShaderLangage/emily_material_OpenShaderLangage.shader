Shader "DigitalEmily2_OSL_____emily_material_OpenShaderLangage" {
	Properties{
		_Color("Color", Color) = (1,1,1,1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
	_Glossiness("Smoothness", Range(0,1)) = 0.5
		_Metallic("Metallic", Range(0,1)) = 0.0
		/////////DigitalEmily2_OSL
		DigitalEmily2_OSL__specularUnlitNormTexture____00_specular_unlit_exr("OSL__specularUnlitNormTexture____00_specular_unlit.exr (RGB)", 2D) = "white" {}
	DigitalEmily2_OSL__singleScatterTexture____00_single_scatter_exr("OSL__singleScatterTexture____00_single_scatter (RGB)", 2D) = "white" {}
	DigitalEmily2_OSL__sdiffuseUnlitTexture____00_diffuse_unlit_exr("OSL__sdiffuseUnlitTexture____00 (RGB)", 2D) = "white" {}
	DigitalEmily2_OSL__scatterRadius___("OSL__scatterRadius_0.5", Range(0,1)) = 0.5
		DigitalEmily2_OSL__scatterColor("OSL____Color", Color) = (0.482, 0.169, 0.109)
		DigitalEmily2_OSL__ior("OSL____ior", Range(0,2)) = 1.33
		DigitalEmily2_OSL__phaseFunction("OSL___phaseFunction", Range(0,1)) = 0.8
		/////////DigitalEmily2_OSL
	}
		/////////DigitalEmily2_OSL/////////////////////////////////////////////////////////////////////////////////
		float phongExponent(float glossiness) {
		return (1 / pow(1 - glossiness, 3.5) - 1);
	}

	surface emily_material
	(
		string specularUnlitNormTexture = "00_specular_unlit.exr",
		string singleScatterTexture = "00_single_scatter.exr",
		string diffuseUnlitTexture = "00_diffuse_unlit.exr",
		float scatterRadius = 0.5,
		color scatterColor = color(0.482, 0.169, 0.109),
		float ior = 1.33,
		float phaseFunction = 0.8
	)
	{
		color diffuseUnlit = texture(diffuseUnlitTexture, u, v);
		color singleScatter = texture(singleScatterTexture, u, v);
		color specularUnlit = texture(specularUnlitNormTexture, u, v);

		// Single scattering is approximated with a diffuse closure
		color diffuseAmount = singleScatter;

		// Multiple scattering reduced with the single scattering amount
		color sssAmount = (color(1, 1, 1) - singleScatter)*diffuseUnlit;

		// We have two Phong specular lobes with equal strength, so each is half as bright
		color specularAmount = specularUnlit*0.5;

		// Fresnel coefficient; this should really be glossy Fresnel that takes into
		// account the specular roughness, but for the moment we are just using the
		// perfect mirror Fresnel.
		float fresnelCoeff, refractionStrength;
		vector reflectDir, refractDir;
		fresnel(I, N, ior, fresnelCoeff, refractionStrength, reflectDir, refractDir);

		specularAmount *= fresnelCoeff;

		// Compute the final result.
		Ci =
			specularAmount*phong(N, phongExponent(0.55)) +
			specularAmount*phong(N, phongExponent(0.75)) +
			diffuseAmount*diffuse(N) +
			subsurface(ior, phaseFunction, scatterColor*scatterRadius, sssAmount);
	}

	/////////DigitalEmily2_OSL//////////////////////////////////////////////////////////////////////////////////////////////
	SubShader{
		Tags{ "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
#pragma surface surf Standard fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
#pragma target 3.0
		sampler2D _MainTex;
	sampler2D DigitalEmily2_OSL__specularUnlitNormTexture____00_specular_unlit_exr;
	sampler2D DigitalEmily2_OSL__singleScatterTexture____00_single_scatter_exr;
	sampler2D DigitalEmily2_OSL__sdiffuseUnlitTexture____00_diffuse_unlit_exr;


	struct Input {
		float2 uv_MainTex;
		////////////////////////////////////
		float scatterRadius = 0.5,
			float3 scatterColor = color(0.482, 0.169, 0.109),
			float ior = 1.33,
			float phaseFunction = 0.8
			///////////////////////////////
	};

	half _Glossiness;
	half _Metallic;
	fixed4 _Color;
	////////////////////////////////////
	float DigitalEmily2_OSL__scatterRadius___
		float3 DigitalEmily2_OSL__scatterColor
		float DigitalEmily2_OSL__ior = 1.33,
		float DigitalEmily2_OSL__phaseFunction = 0.8
		///////////////////////////////


		void surf(Input IN, inout SurfaceOutputStandard o) {
		// Albedo comes from a texture tinted by color
		fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
		o.Albedo = c.rgb;
		// Metallic and smoothness come from slider variables
		o.Metallic = _Metallic;
		o.Smoothness = _Glossiness;
		o.Alpha = c.a;
	}
	ENDCG
	}
		FallBack "Diffuse"
}
