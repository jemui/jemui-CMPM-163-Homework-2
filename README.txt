CMPM 163 S2109
Game Graphics & Real-Time Rendering
Homework 2

Jeanette Mui
jemui@ucsc.edu

Screenshots - https://github.com/jemui/jemui-CMPM-163-Homework-2/tree/master/Screenshots
Part A - https://github.com/jemui/jemui-CMPM-163-Homework-2/blob/master/Part%20A%20Build.zip
Part B - https://cowsgooom.itch.io/cmpm-163-homework-2-part-b?secret=VC4EvY0Ny9rdrHswO98RvCCqqpw

Part A- Tron Filter 
The camera rotates around a sheep. The bloom filter increases and decreases over time
and its outline can be seen. A toon shader is also applied to the sheep. 

Files (3):
RenderEffectBloom.cs
Spinner.cs
Phong.shader

Toon Shader - https://roystan.net/articles/toon-shader.html
Sheep Mesh - https://poly.google.com/view/aWFQcDSaDyo

Part B - Outdoor 3D Scene
The camera rotates like Part A. Snow falls from the sky. 
The water reflects the sky and bottom textured plane below the water.

Properties that control parameters of the scene: 
Ground Size slider - Adjusts the size of the ground and water.
_DisplacementAmt - Shader slider in Inspector that adjusts height

Files: 
CreateMeshSimple.cs
Spinner.cs
Water.cs
HillFromTexture.shader
Toon.shader

Camera rotation - https://www.youtube.com/watch?v=OJkGGuudm38
Skybox - https://assetstore.unity.com/packages/2d/textures-materials/sky/fantasy-skybox-free-18353
		