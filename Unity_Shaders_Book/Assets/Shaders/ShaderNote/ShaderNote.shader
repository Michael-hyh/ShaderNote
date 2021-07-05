// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

/*
 //渲染流水线阶段
Application Stage(应用阶段)/Geometry Stage（几何阶段）/Rasterizer State（光栅化阶段）

//一些专业名词解释
{
	Normalized Device Coordinates/NDC ,归一化的设备坐标，把顶点坐标从模型空间转换到齐次裁剪空间再做透视除法
	Macro 宏
	Albedo 反射率
}

//着色器类型
Vertex Shader/Fragment Shader/Surface Shader（表面着色器）/Fixed Function Shader（固定函数着色器）

//Unity Shader 结构
Properties
{
	_Int("Int",Int) = 2
	_Float("Float",Float) = 1.5
	_Range("Range',Range(0.0,5.0)) = 3.0
	_Color("Color",Color) = (1,1,1,1)
	_Vecotr("Vector",Vecotr) = (1,1,1,1)
	_2D("2D",2D) = ""{}
	_Cube("Cube",Cube) = "white"{}
	_3D("3D",3D) = "black"{}
}
//SubShader中的标签设置类型
Tags 
{
	"Queue" = "Transparent"
	"RenderType" = "Opaque"
}
Tags {"DisableBatching" = "True"}
Tags {"ForceNoShadowCasting" = "True"}
Tags {"IngoreProjector" = "True"}
Tags {"CanUseSpriteAtlas" = "True"}
Tags {"Preview" = "Plane"}

//Pass中的标签设置类型
Tags {"LightMode" = "ForwardBase"}
Tags {"RequireOptions" = "SoftVegetation"}

//状态设置SubShader和Pass一样
Cull Off

//定义Pass的名称
Name "MyPassName"

//使用已经存在的Pass,名称要大写,这是因为Unity Shader 内部会将Pass的名称toUpper
UsePass "MyShader/MYPASSNAME"

//备用Shader
FallBack "Name" Off

//Unity 使用的坐标系类型
模型空间和世界空间为左手坐标系,观察空间为右手坐标系

//Unity 中的纹理
{
	纹理导入时的Warp Mode：Repeat 和 Clamp
	Repeat：纹理坐标超过1将会取小数部分进行采样
	Clamp：纹理坐标大于1截取到1，小于0截取到0

	纹理名_ST（scale和translation）来声明某个纹理的属性，在面板上显示为Tiling（平铺属性）和Offset（偏移属性）
	tiling：缩放倍数，其值大于1时表示缩小，小于1时表示放大
	offset：坐标偏移，一般取0~1之间（左下角为(0,0),右上角为(1,1)），描点将对应物体上的某一点，开始将物体覆盖

	纹理类型：普通纹理（Texture）、法线纹理（Normal Map,法线纹理存储了模型顶点在切线空间下的法线方向）
}

//需要了解的数学知识
{
	点积（dot product,也叫内积inner product）两种计算公式及其几何含义
	叉积（cross product,也叫外积outer product）yz,zx,xy
	
	Square Matrix（方块矩阵） ,Diagonal Matrix（对角矩阵） ,Identity Matrix（单位矩阵）,Transposed Matrix（转置矩阵）,Inverse Matrix(逆矩阵)
	Orthogonal(正交矩阵，和其转置矩阵相乘为单位矩阵，即其转置矩阵和逆矩阵相同)
	
	Determinant(行列式),
	
	Model Space(模型空间),World Space（世界空间）,View Space/Camera Space（观察空间）,Clip Space（（齐次）裁剪空间）,Screen Space(屏幕空间)
	Viewport Space(视口空间，屏幕空间坐标除以屏幕分辨率，将屏幕坐标归一化),Tangent Space(模型顶点的切线空间)
	一个模型顶点所包含的信息：顶点坐标（coordinate）,纹理坐标（texture coordinate）,法线（normal）,切线（tangent）,副法线（binormal）

	矩阵填充方式：Unity Shader 或者说CG是行优先，Unity Matrix4X4列优先

	用原变换矩阵的逆转置矩阵来变换法线,参数的位置决定是按行矩阵还是列矩阵进行乘法,通常在变换顶点时都会使用右乘的方式按列矩阵进行乘法（若已知逆转置矩阵,通常也会进行左乘）,
	但在变换法线时通常进行左乘,这样可以省去转置的操作（只需要知道原变换矩阵的逆矩阵即可）,这是因为有如下等式
	mul(M,v) = mul(v,transpose(M))
	mul(v,M) = mul(transpose(M),v)
}

//CG/HLSL
{
	语义（Semantics）POSITION（模型空间的顶点坐标）,NORMAL,TANGENT,TEXCOORDn（纹理坐标）,COLORn(顶点颜色),VPOS(HLSL,屏幕坐标),WPOS(CG,屏幕坐标)
	系统数值语义（system_value semantics）SV_POSITION(裁剪空间的顶点坐标),SV_Target（告诉渲染器，把用户的输出存储到一个渲染目标）
	基本数据类型：float,int,half,fixed,bool,sampler*,string,struct

	//CG常用函数
	{
		saturate(param),把参数截取到【0,1】的范围内
		cross(a,b),返回向量的叉积
		dot(a,b),返回向量的点积
		mul(A,B),矩阵乘法
		pow(x,y),幂运算
		reflect(i,n),i是入射方向,n是法线计算反射方向
	}
}

//Lighting Model(光照模型)
{
	
	用光照模型计算着色的时候需要知道的变量：光源方向、视角方向、材质的高光反射颜色/漫反射颜色、光源颜色、表面法线,
	其中光源方向和视角方向均是顶点到光源和摄像机的矢量

	环境光(Ambient)	
	自发光（Emissive）
	高光反射（Specular）
	漫反射(Diffuse)

	漫反射计算公式（Lambert光照模型）： cross (C_light,M_diffuse) * max(0,dot(n,I)), C_light入射光线的颜色和强度,M_diffuse材质的漫反射颜色, n是表面法线,I是指向光源的单位矢量
	需要防止点积结果为负值,在实际计算中会用CG的 saturate 函数

	漫反射计算公式（Half-Lambert光照模型）： cross (C_light,M_diffuse) * (  α * dot(n,I) + β),大多数情况下α和β均为0.5

	高光反射计算公式（Phong光照模型）： cross (C_light,M_specular) * pow(max(0,dot(v,r)),M_gloss)
	C_light入射光线的颜色和强度,M_specular材质的高光反射颜色,v是视角方向,r是反射方向.可有 reflect(i,n)计算得到
	M_gloss是材质的光泽度,用于控制高光区域的大小,M_gloss越大,亮点越小

	高光反射计算公式（Blinn-Phong光照模型): cross (C_light,M_specular) * pow(max(0,dot(n,h)),M_gloss)
	C_light入射光线的颜色和强度,M_specular材质的高光反射颜色,n是表面法线,h是对v（视角方向）和i（光源方向）相加再归一化后得到的参数
	M_gloss同上
}

//Unity Shader 常用内置变量及函数,这些都可以在*.cginc的文件中找到,
//用到时需要用#include *.cginc指令把这些文件包含进来
{
	//内置变换矩阵
	{
		UNITY_MATRIX_MVP,用于将顶点/方向矢量从模型空间到裁剪空间的变换矩阵
		UNITY_MATRIX_MV,用于将顶点/方向矢量从模型空间到观察空间的变换矩阵
		UNITY_MATRIX_IT_MV,UNITY_MATRIX_MV 的逆转置矩阵,用于将法线从从模型空间变换到观察空间,也可用于得到 UNITY_MATRIX_MV 的逆矩阵
		_Object2World,模型空间到世界空的变换矩阵
		_World2Object,世界空间到模型空间的变换矩阵
	}

	//摄像机和屏幕参数
	{
		_WorldSpaceCameraPos,该摄像机在世界空间中的位置
		_ScreenParams,
	}

	//其他
	{
		_LightColor0,访问该pass处理的光源颜色及强度
		_WorldSpaceLightPos0,光源方向
		UNITY_LIGHTMODEL_AMBIENT,环境光,在计算光照的最后要加上环境光的影响
	}

	//帮助函数
	{
		float3 WorldSpaceViewDir(float4 v),输入模型空间的顶点位置,返回世界空间中从该点到摄像机的观察方向
		float3 UnityWorldSpaceViewDir(float4 v),输入世界空间的顶点位置,返回世界空间中从该点到摄像机的观察方向
		float3 ObjSpaceViewDir(float4 v),
		float3 WorldSpaceLightDir(float4 v),仅用于前向渲染中,输入模型空间的顶点位置,返回世界空间中从该点到光源的光照方向,未被归一化
		float3 UnityWorldSpaceLightDir(float4 v),仅用于前向渲染中,输入世界空间的顶点位置,返回世界空间中从该点到光源的光照方向,未被归一化
		float3 ObjSpaceLightDir(float4 v),

		float3 UnityObjectToWorldNormal(float3 normal),把法线从模型空间转换到世界空间中
		float3 UnityObjectToWorldDir(float3 dir),把方向矢量从模型空间转换到世界空间中
		float3 UnityWorldToObjectDir(float3 dir),把方向矢量从世界空间转换到模型空间中
	}

}
//颜色的灰度计算公式
对于彩色转灰度的计算公式：Gray = R*0.299 + G*0.587 + B*0.114
                          








*/

Shader "Custom/ShaderNote" {
	Properties {
		_Int("Int",Int) = 2
		_Float("Float",Float) = 1.5
		_Range("Range",Range(0.0,1.0)) = 0.0
		_Color("Color",Color) = (1,1,1,1)
		_Vecotr("Vector",Vector) = (1,1,1,1)
		_2D("2D",2D) = ""{}
		_Cube("Cube",Cube) = "white"{}
		_3D("3D",3D) = "black"{}
		[Toggle]_Bool("彩色",Float) = 1 //[MaterialToggle]
	}

	SubShader{

		Pass{
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
				#pragma fragment frag
				#pragma vertex vert

				#include "UnityCG.cginc"

				fixed4 _Color;
				float _Bool;
				float _Range;

				struct a2v {
					//用模型空间的顶点坐标填充vertex变量
	            	float4 vertex : POSITION;
	            	//用模型空间的法线方向填充normal变量
	         		float3 normal : NORMAL;
	         		//用模型的第一套纹理坐标填充texcoord变量
					float4 texcoord : TEXCOORD0;
				};
				
				struct v2f{
					float4 pos : SV_POSITION;
					fixed3 color : COLOR0;
					float4 scrPos : TEXCOORD0;					
				};
				
				v2f vert(a2v v){
					v2f o;
					o.pos =  UnityObjectToClipPos(v.vertex);
					o.color = v.normal * 0.5 + fixed3(0.5,0.5,0.5);
					o.scrPos = ComputeScreenPos(o.pos);
					return o;
				}


				float4 frag(v2f i) : COLOR {
//					return fixed4((i.scrPos.xy/i.scrPos.w),0.0,1.0);
//					return fixed4(i.xy/_ScreenParams.xy,0.0,1.0);//float4 i : VPOS
//					return fixed4(i.color,1.0);
					if(_Bool)
					{
						return float4(i.color * _Color.rgb,_Range);						
					}else
					{
						return float4(_Color.rgb,_Range);			
					}
				}

			ENDCG
		}
	}
	FallBack "Unity Shaders Book/Chapter 5/Simple Shader" 	
}

