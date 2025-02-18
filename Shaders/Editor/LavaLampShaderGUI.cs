﻿﻿﻿﻿using System;
using UnityEngine;
using UnityEngine.Rendering;

namespace UnityEditor
{
    internal class LavaLampShaderGUI : ShaderGUI
    {
        private const int cMaxSubregions = 16;
        private const int cHighestUvChannel = 7;

        private static bool sGlassFoldout = true;
        private static bool sMeshDataFoldout = true;
        private static bool sVolumeDataFoldout = true;
        private static bool sLavaSharedPropertiesFoldout = true;
        private static bool sLavaSubregionsOverallFoldout = true;
        private static bool sAdvancedOptionsFoldout = true;
        private static bool sAudioLinkOptionsFoldout = false;
        private static bool[] sSubregionFoldouts = { true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true };

        bool mFirstTimeApply = true;

        //Property Helper Structs

        private struct Properties
        {
            public MaterialProperty reflectiveness;
            public MaterialProperty roughnessMap;
            public MaterialProperty minPerceptualRoughness;
            public MaterialProperty maxPerceptualRoughness;
            public MaterialProperty normalMap;
            public MaterialProperty normalStrength;
            public MaterialProperty tintMap;
            public MaterialProperty tint;
            public MaterialProperty tintHueShift; //custom
            public MaterialProperty tintBrightness; //custom
            public MaterialProperty matcapMap; //custom
            public MaterialProperty matcapAlpha; //custom
            public MaterialProperty matcapColorize; //custom
            public MaterialProperty matcapHueShift; //custom
            public MaterialProperty rimColor; //custom
            public MaterialProperty rimHue; //custom
            public MaterialProperty rimIntensity; //custom
            public MaterialProperty rimPower; //custom
            public MaterialProperty customReflectionProbe;
            public MaterialProperty useCustomReflectionProbe;
            public MaterialProperty refractiveIndex;
            public MaterialProperty blurFactor; //custom
            public MaterialProperty backgroundColor;
            public MaterialProperty backgroundCubemap;
            public MaterialProperty useBackgroundCubemap;

            public MaterialProperty lavaPadding;
            public MaterialProperty lavaSmoothingFactor;
            public MaterialProperty lavaVerticalSeparation;
            public MaterialProperty lavaSkipChance;
            public MaterialProperty lavaMinSize;
            public MaterialProperty lavaMaxSize;
            public MaterialProperty lavaSizeDistribution;
            public MaterialProperty lavaMinSpeed;
            public MaterialProperty lavaMaxSpeed;
            public MaterialProperty lavaMinDriftSpeed;
            public MaterialProperty lavaMaxDriftSpeed;
            public MaterialProperty lavaReflectiveness;
            public MaterialProperty lavaPerceptualRoughness;
            public MaterialProperty lavaSoftDepthSize;
            public MaterialProperty lavaTouchingSideBlendSize;

            public MaterialProperty bindDataMode;
            public MaterialProperty bindPositionsSlot;
            public MaterialProperty bindNormalsSlot;
            public MaterialProperty bindTangentsSlot;
            public MaterialProperty worldRecale;

            public MaterialProperty sdfTexture;
            public MaterialProperty sdfPixelSize;
            public MaterialProperty sdfLowerCorner;
            public MaterialProperty sdfSize;
            public MaterialProperty minThickness;

            public MaterialProperty lavaSubregionCount;
            public MaterialProperty cullMode;
            public MaterialProperty depthOffset;
            public MaterialProperty maxSpecularHighlightBrightness;
            public MaterialProperty toggleLighting;
            public MaterialProperty toggleTransparency;
            public MaterialProperty toggleDepthIntersection;
            public MaterialProperty writeDepth;
            

            public MaterialProperty lavaReactiveColorRed;
            public MaterialProperty lavaReactiveColorGreen;
            public MaterialProperty lavaReactiveColorBlue;
            public MaterialProperty lavaLampEnableAudioLinkScale;
            public MaterialProperty lavaLampEnableAudioLinkScroll;
            public MaterialProperty lavaLampEnableAudioLinkColor;
            public MaterialProperty lavaLampEnableAudioLink;
            public MaterialProperty lavaLampResizeTargetChannel;
            public MaterialProperty lavaLampScrollTargetChannel;
            public MaterialProperty lavaLampReactiveResizeModifier;
            public MaterialProperty lavaLampScrollAdjustment;
            public MaterialProperty lavaLampColorTargetChannel;

            public LavaSubregionProperties[] subregions;

            public Properties(MaterialProperty[] props)
            {
                reflectiveness = FindProperty("_Reflectiveness", props);
                roughnessMap = FindProperty("_RoughnessMap", props);
                minPerceptualRoughness = FindProperty("_MinPerceptualRoughness", props);
                maxPerceptualRoughness = FindProperty("_MaxPerceptualRoughness", props);
                normalMap = FindProperty("_NormalMap", props);
                normalStrength = FindProperty("_NormalStrength", props);
                tintMap = FindProperty("_TintMap", props);
                tint = FindProperty("_Tint", props);
                tintHueShift = FindProperty("_TintHueShift", props); //custom
                tintBrightness = FindProperty("_TintBrightness", props); //custom
                matcapMap = FindProperty("_MatCapMap", props); //custom
                matcapAlpha = FindProperty("_MatCapAlpha", props); //custom
                matcapColorize = FindProperty("_MatCapColorize", props); //custom
                matcapHueShift = FindProperty("_MatCapHueShift", props); //custom
                rimColor = FindProperty("_RimColor", props); //custom
                rimHue = FindProperty("_RimHue", props); //custom
                rimIntensity = FindProperty("_RimIntensity", props); //custom
                rimPower = FindProperty("_RimPower", props); //custom
                customReflectionProbe = FindProperty("_CustomReflectionProbe", props);
                useCustomReflectionProbe = FindProperty("_UseCustomReflectionProbe", props);
                refractiveIndex = FindProperty("_RefractiveIndex", props);
                blurFactor = FindProperty("_BlurFactor", props); //custom
                backgroundColor = FindProperty("_BackgroundColor", props);
                backgroundCubemap = FindProperty("_BackgroundCubemap", props); ;
                useBackgroundCubemap = FindProperty("_UseBackgroundCubemap", props); ;

                lavaPadding = FindProperty("_LavaPadding", props);
                lavaSmoothingFactor = FindProperty("_LavaSmoothingFactor", props);
                lavaVerticalSeparation = FindProperty("_LavaVerticalSeparation", props);
                lavaSkipChance = FindProperty("_LavaSkipChance", props);
                lavaMinSize = FindProperty("_LavaMinSize", props);
                lavaMaxSize = FindProperty("_LavaMaxSize", props);
                lavaSizeDistribution = FindProperty("_LavaSizeDistribution", props);
                lavaMinSpeed = FindProperty("_LavaMinSpeed", props);
                lavaMaxSpeed = FindProperty("_LavaMaxSpeed", props);
                lavaMinDriftSpeed = FindProperty("_LavaMinDriftSpeed", props);
                lavaMaxDriftSpeed = FindProperty("_LavaMaxDriftSpeed", props);
                lavaReflectiveness = FindProperty("_LavaReflectiveness", props);
                lavaPerceptualRoughness = FindProperty("_LavaPerceptualRoughness", props);
                lavaSoftDepthSize = FindProperty("_LavaSoftDepthSize", props);
                lavaTouchingSideBlendSize = FindProperty("_LavaTouchingSideBlendSize", props);

                bindDataMode = FindProperty("_BindDataMode", props);
                bindPositionsSlot = FindProperty("_BindPositionsSlot", props);
                bindNormalsSlot = FindProperty("_BindNormalsSlot", props);
                bindTangentsSlot = FindProperty("_BindTangentsSlot", props);
                worldRecale = FindProperty("_WorldRecale", props);

                sdfTexture = FindProperty("_SDFTexture", props);
                sdfPixelSize = FindProperty("_SDFPixelSize", props);
                sdfLowerCorner = FindProperty("_SDFLowerCorner", props);
                sdfSize = FindProperty("_SDFSize", props);
                minThickness = FindProperty("_MinThickness", props);

                lavaSubregionCount = FindProperty("_LavaSubregionCount", props);
                cullMode = FindProperty("_CullMode", props);
                depthOffset = FindProperty("_DepthOffset", props);
                maxSpecularHighlightBrightness = FindProperty("_MaxSpecularHighlightBrightness", props);
                toggleLighting = FindProperty("_Lighting_Toggle", props);
                toggleTransparency = FindProperty("_Transparency_Toggle", props);
                toggleDepthIntersection = FindProperty("_DepthIntersection_Toggle", props);
                writeDepth = FindProperty("_WriteDepth_Toggle", props);
                

                lavaReactiveColorRed = FindProperty("_LavaReactiveColorOffsetRed", props);
                lavaReactiveColorGreen = FindProperty("_LavaReactiveColorOffsetGreen", props);
                lavaReactiveColorBlue = FindProperty("_LavaReactiveColorOffsetBlue", props);
                lavaLampEnableAudioLinkScale = FindProperty("_LavaLampEnableAudioLinkResize_Toggle", props);
                lavaLampEnableAudioLinkScroll = FindProperty("_LavaLampEnableAudioLinkScroll_Toggle", props);
                lavaLampEnableAudioLinkColor = FindProperty("_LavaLampEnableAudioLinkColor_Toggle", props);
                lavaLampEnableAudioLink = FindProperty("_LavaLampEnableAudioLink_Toggle", props);
                lavaLampResizeTargetChannel = FindProperty("_LavaLampResizeTargetChannel", props);
                lavaLampScrollTargetChannel = FindProperty("_LavaLampScrollTargetChannel", props);
                lavaLampReactiveResizeModifier = FindProperty("_LavaLampReactiveResizeModifier", props);
                lavaLampScrollAdjustment = FindProperty("_LavaLampScrollAdjustment", props);
                lavaLampColorTargetChannel = FindProperty("_LavaLampColorTargetChannel", props);

                subregions = new LavaSubregionProperties[cMaxSubregions];

                for (int i = 0; i < subregions.Length; i++)
                {
                    subregions[i].FindProperties(props, i);
                }
            }
        }

        private struct LavaSubregionProperties
        {
            public MaterialProperty lavaScale;
            public MaterialProperty lavaHueShift;
            public MaterialProperty lavaTopReservoirHeight;
            public MaterialProperty lavaBottomReservoirHeight;
            public MaterialProperty lavaCoreColor;
            public MaterialProperty lavaEdgeColor;
            public MaterialProperty lavaColorThicknessScale;
            public MaterialProperty lavaWaterHazeColor;
            public MaterialProperty lavaWaterHazeStrength;
            public MaterialProperty lavaWaterTintColor;
            public MaterialProperty lavaWaterTintStrength;
            public MaterialProperty lavaTopLightColor;
            public MaterialProperty lavaTopLightHeight;
            public MaterialProperty lavaBottomLightColor;
            public MaterialProperty lavaBottomLightHeight;
            public MaterialProperty lavaLightFalloff;
            public MaterialProperty lavaFlowDirection;

            public void FindProperties(MaterialProperty[] props, int index)
            {
                lavaScale = FindProperty("_LavaScale" + index, props);
                lavaHueShift = FindProperty("_LavaHueShift" + index, props);
                lavaTopReservoirHeight = FindProperty("_LavaTopReservoirHeight" + index, props);
                lavaBottomReservoirHeight = FindProperty("_LavaBottomReservoirHeight" + index, props);
                lavaCoreColor = FindProperty("_LavaCoreColor" + index, props);
                lavaEdgeColor = FindProperty("_LavaEdgeColor" + index, props);
                lavaColorThicknessScale = FindProperty("_LavaColorThicknessScale" + index, props);
                lavaWaterHazeColor = FindProperty("_LavaWaterHazeColor" + index, props);
                lavaWaterHazeStrength = FindProperty("_LavaWaterHazeStrength" + index, props);
                lavaWaterTintColor = FindProperty("_LavaWaterTintColor" + index, props);
                lavaWaterTintStrength = FindProperty("_LavaWaterTintStrength" + index, props);
                lavaTopLightColor = FindProperty("_LavaTopLightColor" + index, props);
                lavaTopLightHeight = FindProperty("_LavaTopLightHeight" + index, props);
                lavaBottomLightColor = FindProperty("_LavaBottomLightColor" + index, props);
                lavaBottomLightHeight = FindProperty("_LavaBottomLightHeight" + index, props);
                lavaLightFalloff = FindProperty("_LavaLightFalloff" + index, props);
                lavaFlowDirection = FindProperty("_LavaFlowDirection" + index, props);
            }
        };

        //Editor Functions

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
        {
            Material material = materialEditor.target as Material;

            //be sure that the keywords and passes are set correcly when we open this material
            if (mFirstTimeApply)
            {
                SetKeywordsAndPasses(material);
                mFirstTimeApply = false;
            }

            //MaterialProperties can be animated so we do not cache them but fetch them every event to ensure animated values are updated correctly
            Properties properties = new Properties(props);

            int subregionCount = material.GetInt("_LavaSubregionCount");
            bool isTransparent = material.renderQueue > (int)RenderQueue.GeometryLast;

            //draw the inspector and check if anything changed
            if (DrawShaderInspector(materialEditor, properties, subregionCount, isTransparent))
            {
                //set the correct keywords and passes for each material we are editing
                foreach (var obj in properties.reflectiveness.targets)
                {
                    SetKeywordsAndPasses((Material)obj);
                }
            }
        }

        public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
        {
            base.AssignNewShaderToMaterial(material, oldShader, newShader);

            //make sure keywords and passes are set correctly when this shader first gets selected
            SetKeywordsAndPasses(material);
        }

        public override void OnClosed(Material material)
        {
            //make sure the passes we might have disabled are re-enabled before switching shaders
            material.SetShaderPassEnabled("Always", true);
            material.SetShaderPassEnabled("ForwardAdd", true);

            base.OnClosed(material);
        }

        //Helper Functions

        private bool DrawShaderInspector(MaterialEditor materialEditor, Properties properties, int subregionCount, bool isTransparent)
        {
            //matches unity default inspector
            EditorGUIUtility.labelWidth = 0.0f;
            EditorGUIUtility.fieldWidth = 64.0f;

            EditorGUI.BeginChangeCheck();

            //Glass Properties
            sGlassFoldout = EditorGUILayout.Foldout(sGlassFoldout, "Glass", true, EditorStyles.foldoutHeader);

            if(sGlassFoldout)
            {
                materialEditor.ShaderProperty(properties.reflectiveness, "Reflectiveness");

                if (properties.roughnessMap.textureValue == null)
                {
                    //if the roughness texture isn't set, just display the min roughness slider as a way to directly control the roughness
                    materialEditor.TexturePropertySingleLine(new GUIContent("Roughness"), properties.roughnessMap, properties.minPerceptualRoughness);
                    EditorGUI.indentLevel++;
                    materialEditor.TextureScaleOffsetProperty(properties.roughnessMap);
                    EditorGUI.indentLevel--;
                }
                else
                {
                    //if the texture is set, display both the min and max sliders
                    materialEditor.TexturePropertySingleLine(new GUIContent("Roughness"), properties.roughnessMap);
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(properties.minPerceptualRoughness, "Min");
                    materialEditor.ShaderProperty(properties.maxPerceptualRoughness, "Max");
                    materialEditor.TextureScaleOffsetProperty(properties.roughnessMap);
                    EditorGUI.indentLevel--;
                }

                materialEditor.TexturePropertySingleLine(new GUIContent("Normals"), properties.normalMap, properties.normalStrength);
                EditorGUI.indentLevel++;
                materialEditor.TextureScaleOffsetProperty(properties.normalMap);
                EditorGUI.indentLevel--;

                
                materialEditor.TexturePropertySingleLine(new GUIContent("MatCap"), properties.matcapMap, properties.matcapAlpha);
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(properties.matcapHueShift, "MatCap HueShift");
                materialEditor.ShaderProperty(properties.matcapColorize, "MatCap Colorize");
                EditorGUI.indentLevel--;

                materialEditor.TexturePropertySingleLine(new GUIContent("Tint"), properties.tintMap, properties.tint);
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(properties.tintHueShift, "Global HueShift");
                materialEditor.ShaderProperty(properties.tintBrightness, "Global Brightness");
                materialEditor.TextureScaleOffsetProperty(properties.tintMap);
                EditorGUI.indentLevel--;

                
                //custom ext
                materialEditor.ShaderProperty(properties.rimColor, "RimLight");
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(properties.rimHue, "Rim HueShift");
                materialEditor.ShaderProperty(properties.rimIntensity, "Rim Intensity");
                materialEditor.ShaderProperty(properties.rimPower, "Rim Power");
                EditorGUI.indentLevel--;
                

                materialEditor.TexturePropertySingleLine(new GUIContent("Reflection Probe Override"), properties.customReflectionProbe, properties.useCustomReflectionProbe);
                materialEditor.ShaderProperty(properties.refractiveIndex, "Refractive Index");
                materialEditor.ShaderProperty(properties.blurFactor, "Blur Factor");
                materialEditor.ShaderProperty(properties.backgroundColor, "Background Color");
                materialEditor.TexturePropertySingleLine(new GUIContent("Background Cubemap"), properties.backgroundCubemap, properties.useBackgroundCubemap);
            }

            EditorGUILayout.Space(12);

            //Lava Shared Properties
            sLavaSharedPropertiesFoldout = EditorGUILayout.Foldout(sLavaSharedPropertiesFoldout, "Lava Shared Properties", true, EditorStyles.foldoutHeader);

            if(sLavaSharedPropertiesFoldout)
            {
                materialEditor.ShaderProperty(properties.lavaPadding, "Padding");
                materialEditor.ShaderProperty(properties.lavaSmoothingFactor, "Smoothing");
                materialEditor.ShaderProperty(properties.lavaVerticalSeparation, "Vertical Spacing");
                materialEditor.ShaderProperty(properties.lavaSkipChance, "Invisible Blob Chance");

                GUILayout.Label("Size");
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(properties.lavaMinSize, "Min");
                materialEditor.ShaderProperty(properties.lavaMaxSize, "Max");
                materialEditor.ShaderProperty(properties.lavaSizeDistribution, "Distribution");
                EditorGUI.indentLevel--;

                GUILayout.Label("Speed");
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(properties.lavaMinSpeed, "Min");
                materialEditor.ShaderProperty(properties.lavaMaxSpeed, "Max");
                EditorGUI.indentLevel--;

                GUILayout.Label("Drift Speed");
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(properties.lavaMinDriftSpeed, "Min");
                materialEditor.ShaderProperty(properties.lavaMaxDriftSpeed, "Max");
                EditorGUI.indentLevel--;

                GUILayout.Label("Rendering");
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(properties.lavaReflectiveness, "Reflectiveness");
                materialEditor.ShaderProperty(properties.lavaPerceptualRoughness, "Roughness");
                materialEditor.ShaderProperty(properties.lavaSoftDepthSize, "Soft Depth Intersection Size");
                materialEditor.ShaderProperty(properties.lavaTouchingSideBlendSize, "Touching Side Blend Size");
                EditorGUI.indentLevel--;
            }

            EditorGUILayout.Space(12);

            //Lava Subregion Properties
            sLavaSubregionsOverallFoldout = EditorGUILayout.Foldout(sLavaSubregionsOverallFoldout, "Lava Subregions", true, EditorStyles.foldoutHeader);

            if (sLavaSubregionsOverallFoldout)
            {
                materialEditor.ShaderProperty(properties.lavaSubregionCount, "");

                //display the properties for every active subregion
                for (int i = 0; i < properties.subregions.Length && i < subregionCount; i++)
                {
                    EditorGUILayout.Space(); //add some space between each of the subregions

                    //enclose each subregion in a foldout
                    sSubregionFoldouts[i] = EditorGUILayout.Foldout(sSubregionFoldouts[i], "Subregion " + i, true);

                    if (sSubregionFoldouts[i])
                    {
                        //draw a background box with a slight dark tint
                        Rect background = EditorGUILayout.BeginVertical();
                        background.xMin -= 12.0f; //give the text some breathing room
                        EditorGUI.DrawRect(background, new Color(0.0f, 0.0f, 0.0f, 0.15f));

                        EditorGUILayout.Space();

                        materialEditor.ShaderProperty(properties.subregions[i].lavaScale, "Scale");
                        materialEditor.ShaderProperty(properties.subregions[i].lavaHueShift, "Hue Shift");

                        GUILayout.Label("Lava Reservoirs");
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(properties.subregions[i].lavaTopReservoirHeight, "Top Height");
                        materialEditor.ShaderProperty(properties.subregions[i].lavaBottomReservoirHeight, "Bottom Height");
                        EditorGUI.indentLevel--;

                        GUILayout.Label("Lava Color");
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(properties.subregions[i].lavaCoreColor, "Core Color");
                        materialEditor.ShaderProperty(properties.subregions[i].lavaEdgeColor, "Edge Color");
                        materialEditor.ShaderProperty(properties.subregions[i].lavaColorThicknessScale, "Transition Thickness Scale");
                        EditorGUI.indentLevel--;

                        GUILayout.Label("Water Haze");
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(properties.subregions[i].lavaWaterHazeColor, "Color");
                        materialEditor.ShaderProperty(properties.subregions[i].lavaWaterHazeStrength, "Density");
                        EditorGUI.indentLevel--;

                        GUILayout.Label("Water Tint");
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(properties.subregions[i].lavaWaterTintColor, "Color");
                        materialEditor.ShaderProperty(properties.subregions[i].lavaWaterTintStrength, "Strength");
                        EditorGUI.indentLevel--;

                        GUILayout.Label("Lights");
                        EditorGUI.indentLevel++;

                        EditorGUILayout.PrefixLabel("Top Light"); //need to use prefix label because normal lables don't indent
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(properties.subregions[i].lavaTopLightColor, "Color");
                        materialEditor.ShaderProperty(properties.subregions[i].lavaTopLightHeight, "Height");
                        EditorGUI.indentLevel--;

                        EditorGUILayout.PrefixLabel("Bottom Light");
                        EditorGUI.indentLevel++;
                        materialEditor.ShaderProperty(properties.subregions[i].lavaBottomLightColor, "Color");
                        materialEditor.ShaderProperty(properties.subregions[i].lavaBottomLightHeight, "Height");
                        EditorGUI.indentLevel--;

                        materialEditor.ShaderProperty(properties.subregions[i].lavaLightFalloff, "Light Falloff Scale");
                        EditorGUI.indentLevel--;

                        materialEditor.ShaderProperty(properties.subregions[i].lavaFlowDirection, "Flow Direction");

                        EditorGUILayout.EndVertical();
                    }
                }
            }

            EditorGUILayout.Space(12);

            //Mesh Data Properties
            sMeshDataFoldout = EditorGUILayout.Foldout(sMeshDataFoldout, "Mesh Data", true, EditorStyles.foldoutHeader);

            if (sMeshDataFoldout)
            {
                materialEditor.ShaderProperty(properties.bindDataMode, "Use Mesh Bind Data");

                //if bind data is not disabled
                if (properties.bindDataMode.floatValue != 0.0f)
                {
                    EditorGUI.indentLevel++;
                    materialEditor.ShaderProperty(properties.bindPositionsSlot, "Bind Positions UV Channel");
                    materialEditor.ShaderProperty(properties.bindNormalsSlot, "Bind Normals UV Channel");
                    materialEditor.ShaderProperty(properties.bindTangentsSlot, "Bind Tangents UV Channel");
                    EditorGUI.indentLevel--;

                    //display an error if any of the bind data uv channels overlap
                    if (properties.bindPositionsSlot.floatValue == properties.bindNormalsSlot.floatValue ||
                        properties.bindPositionsSlot.floatValue == properties.bindTangentsSlot.floatValue ||
                        properties.bindNormalsSlot.floatValue == properties.bindTangentsSlot.floatValue)
                    {
                        EditorGUILayout.HelpBox("Bind data UV channels should not overlap!", MessageType.Error);
                    }
                }

                materialEditor.ShaderProperty(properties.worldRecale, "World Rescale");
            }

            EditorGUILayout.Space(12);

            //Volume Data Properties
            sVolumeDataFoldout = EditorGUILayout.Foldout(sVolumeDataFoldout, "Volume Data", true, EditorStyles.foldoutHeader);

            if (sVolumeDataFoldout)
            {
                materialEditor.ShaderProperty(properties.sdfTexture, "SDF Texture");
                materialEditor.ShaderProperty(properties.sdfPixelSize, "SDF Pixel Size");
                materialEditor.ShaderProperty(properties.sdfLowerCorner, "SDF Lower Corner");
                materialEditor.ShaderProperty(properties.sdfSize, "SDF Size");
                materialEditor.ShaderProperty(properties.minThickness, "Min Thickness");
            }

            EditorGUILayout.Space(12);

            //Advanced Properties
            sAdvancedOptionsFoldout = EditorGUILayout.Foldout(sAdvancedOptionsFoldout, "Advanced Options", true, EditorStyles.foldoutHeader);

            if (sAdvancedOptionsFoldout)
            {
                materialEditor.RenderQueueField();
                materialEditor.ShaderProperty(properties.cullMode, "Culling Mode");
                materialEditor.ShaderProperty(properties.depthOffset, "Depth Offset");
                materialEditor.ShaderProperty(properties.maxSpecularHighlightBrightness, "Max Specular Highlight Brightness");

                materialEditor.ShaderProperty(properties.toggleLighting, "Surface Lighting");

                //these settings are only relevant when the material is transparent
                if (isTransparent)
                {
                    materialEditor.ShaderProperty(properties.toggleTransparency, "Transparent Background");

                    //depth intersection isn't used if the material isn't transparent
                    if (properties.toggleTransparency.floatValue != 0.0f)
                    {
                        materialEditor.ShaderProperty(properties.toggleDepthIntersection, "Lava Depth Intersection");
                    }

                    materialEditor.ShaderProperty(properties.writeDepth, "Write Depth");
                }


                
                materialEditor.EnableInstancingField();
                materialEditor.DoubleSidedGIField();
            }

            //Audiolink Options
            sAudioLinkOptionsFoldout = EditorGUILayout.Foldout(sAudioLinkOptionsFoldout, "Audiolink Options", true, EditorStyles.foldoutHeader);

            if (sAudioLinkOptionsFoldout)
            {

                materialEditor.ShaderProperty(properties.lavaLampEnableAudioLink, "Enable Audio Link");
                materialEditor.ShaderProperty(properties.lavaLampEnableAudioLinkColor, "Enable Audio Link Color");
                materialEditor.ShaderProperty(properties.lavaLampEnableAudioLinkScroll, "Enable Audio Link Scroll Modification");
                materialEditor.ShaderProperty(properties.lavaLampEnableAudioLinkScale, "Enable Audio Link Resizing");

                materialEditor.ShaderProperty(properties.lavaLampColorTargetChannel, "Target Channel For Lava Lamp Color");
                materialEditor.ShaderProperty(properties.lavaReactiveColorRed, "Reactive Lava Color Offset Red");
                materialEditor.ShaderProperty(properties.lavaReactiveColorGreen, "Reactive Lava Color Offset Green");
                materialEditor.ShaderProperty(properties.lavaReactiveColorBlue, "Reactive Lava Color Offset Blue");

                materialEditor.ShaderProperty(properties.lavaLampResizeTargetChannel, "Target Channel For Lava Lamp Resize");
                materialEditor.ShaderProperty(properties.lavaLampReactiveResizeModifier, "Lava Lamp Resize Multiplier");
                materialEditor.ShaderProperty(properties.lavaLampScrollTargetChannel, "Target Channel For Lava Lamp Scroll");
                materialEditor.ShaderProperty(properties.lavaLampScrollAdjustment, "Lava Lamp Scroll Adjustment");
            }

            return EditorGUI.EndChangeCheck(); //return if anything was changed
        }

        private static void SetKeywordsAndPasses(Material material)
        {
            //clamp the subregion count to the supported range of subregions
            int subregionCount = Math.Min(Math.Max(1, material.GetInt("_LavaSubregionCount")), cMaxSubregions); 

            //set the appropriate subregion keyword, start at 2 because count 1 is the default value when no keyword is set
            for (int i = 2; i <= cMaxSubregions; i++)
            {
                if (i == subregionCount)
                {
                    material.EnableKeyword("LAVA_LAMP_SUBREGION_COUNT_" + i);
                }
                else
                {
                    material.DisableKeyword("LAVA_LAMP_SUBREGION_COUNT_" + i);
                }
            }

            //set the keywords to control the bind data mode, if there are any conflicting uv channels for bind data force it to be disabled
            int bindDataMode = material.GetInt("_BindDataMode");
            
            if (bindDataMode == 0)
            {
                material.EnableKeyword("LAVA_LAMP_BIND_DATA_DISABLED");

                material.DisableKeyword("LAVA_LAMP_BIND_DATA_ENABLED");
                material.DisableKeyword("LAVA_LAMP_BIND_DATA_AUTO");
            }
            else if(bindDataMode == 1)
            {
                material.EnableKeyword("LAVA_LAMP_BIND_DATA_ENABLED");

                material.DisableKeyword("LAVA_LAMP_BIND_DATA_DISABLED");
                material.DisableKeyword("LAVA_LAMP_BIND_DATA_AUTO");
            }
            else
            {
                material.EnableKeyword("LAVA_LAMP_BIND_DATA_AUTO");

                material.DisableKeyword("LAVA_LAMP_BIND_DATA_DISABLED");
                material.DisableKeyword("LAVA_LAMP_BIND_DATA_ENABLED");
            }

            //clamp the uv slots to the actual range of available uv channels
            int bindPositionsSlot = Math.Min(Math.Max(1, material.GetInt("_BindPositionsSlot")), cHighestUvChannel); 
            int bindNormalsSlot = Math.Min(Math.Max(1, material.GetInt("_BindNormalsSlot")), cHighestUvChannel);
            int bindTangentsSlot = Math.Min(Math.Max(1, material.GetInt("_BindTangentsSlot")), cHighestUvChannel);

            //set the appropriate keywords for the uv slots that each set of bind data will come from
            for (int i = 1; i <= cHighestUvChannel; i++)
            {
                if(i == bindPositionsSlot)
                {
                    material.EnableKeyword("LAVA_LAMP_BIND_POSITIONS_SLOT_" + i);
                }
                else
                {
                    material.DisableKeyword("LAVA_LAMP_BIND_POSITIONS_SLOT_" + i);
                }

                if (i == bindNormalsSlot)
                {
                    material.EnableKeyword("LAVA_LAMP_BIND_NORMALS_SLOT_" + i);
                }
                else
                {
                    material.DisableKeyword("LAVA_LAMP_BIND_NORMALS_SLOT_" + i);
                }

                if (i == bindTangentsSlot)
                {
                    material.EnableKeyword("LAVA_LAMP_BIND_TANGENTS_SLOT_" + i);
                }
                else
                {
                    material.DisableKeyword("LAVA_LAMP_BIND_TANGENTS_SLOT_" + i);
                }
            }

            //toggle surface lighting
            if (material.GetInt("_Lighting_Toggle") == 0)
            {
                material.DisableKeyword("LAVA_LAMP_USE_LIGHTING");
                material.SetShaderPassEnabled("ForwardAdd", false);
            }
            else
            {
                material.EnableKeyword("LAVA_LAMP_USE_LIGHTING");
                material.SetShaderPassEnabled("ForwardAdd", true);
            }

            bool isOpaque = material.renderQueue <= (int)RenderQueue.GeometryLast;

            //always disable transparency when the material is in the opaque queue, otherwise use the toggle
            if (isOpaque || material.GetInt("_Transparency_Toggle") == 0)
            {
                material.DisableKeyword("LAVA_LAMP_USE_TRANSPARENCY");
                material.SetShaderPassEnabled("Always", false); //"Always" is the lightmode of the grab pass
            }
            else
            {
                material.EnableKeyword("LAVA_LAMP_USE_TRANSPARENCY");
                material.SetShaderPassEnabled("Always", true);
            }

            //toggle depth intersection
            if (material.GetInt("_DepthIntersection_Toggle") == 0)
            {
                material.DisableKeyword("LAVA_LAMP_DEPTH_INTERSECTION");
            }
            else
            {
                material.EnableKeyword("LAVA_LAMP_DEPTH_INTERSECTION");
            }

            //always write depth when the material is in the opaque queue, otherwise use the toggle setting
            if (isOpaque)
            {
                material.SetInt("_ZWrite", 1);
            }
            else
            {
                int writeDepth  = material.GetInt("_WriteDepth_Toggle");
                material.SetInt("_ZWrite", writeDepth);
            }
        }
    }
}
