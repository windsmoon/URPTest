// using UnityEngine;
// using UnityEditor;
//
// namespace PixelNeko.Render.Effect.PostProcessing.Editor
// {
//     [CustomEditor(typeof(PostProcessingConfig))]
//     public class PostProcessingConfigInspector : UnityEditor.Editor
//     {
//         #region constant
//         private const string addString = "Add";
//         private const string removeString = "Remove";
//         private const string enableString = "Enable";
//         private const string disableString = "Disable";
//         #endregion
//
//         #region fields
//         private PostProcessingConfig postProcessingConfig;
//         private UnityEditor.Editor dofEditor;
//         private UnityEditor.Editor blurByStencilEditor;
//         private UnityEditor.Editor gaussianBlurEditor;
//         private UnityEditor.Editor globalFogEditor;
//         private UnityEditor.Editor bloomEditor;
//         private UnityEditor.Editor vignetteEditor;
//         private UnityEditor.Editor chromaticAberrationEditor;
//         private UnityEditor.Editor timeSkillEditor;
//         private UnityEditor.Editor colorAdjustmentEditor;
//         #endregion
//
//         #region methods
//         public override void OnInspectorGUI()
//         {
//             postProcessingConfig = target as PostProcessingConfig;
//             EditorGUILayout.BeginVertical();
//             base.OnInspectorGUI();
//             DrawSpace(2);
//             DrawDOF();
//             DrawSpace(2);
//             DrawBlurByStencil();
//             DrawSpace(2);
//             DrawGaussianBlur();
//             // DrawSpace(2);
//             // DrawGlobalFog();
//             DrawSpace(2);
//             DrawBloom();
//             DrawSpace(2);
//             DrawVignette();
//             DrawSpace(2);
//             DrawChromaticAberration();
//             DrawSpace(2);
//             DrawTimeSkill();
//             DrawColorAdjustment();
//             EditorGUILayout.EndVertical();
//         }
//
//         private void DrawDOF()
//         {
//             EditorGUILayout.BeginVertical();
//             DrawHeader(PostProcessingConfig.Type.DepthOfField);
//             DrawContent(PostProcessingConfig.Type.DepthOfField, null, ref dofEditor);
//             EditorGUILayout.EndVertical();
//         }
//
//         private void DrawBlurByStencil()
//         {
//             EditorGUILayout.BeginVertical();
//             DrawHeader(PostProcessingConfig.Type.BlurByStencil);
//             DrawContent(PostProcessingConfig.Type.BlurByStencil, null, ref blurByStencilEditor);
//             EditorGUILayout.EndVertical();
//         }
//
//         private void DrawGaussianBlur()
//         {
//             EditorGUILayout.BeginVertical();
//             DrawHeader(PostProcessingConfig.Type.GaussianBlur);
//             DrawContent(PostProcessingConfig.Type.GaussianBlur, null, ref gaussianBlurEditor);
//             EditorGUILayout.EndVertical();
//         }
//
//         private void DrawGlobalFog()
//         {
//             EditorGUILayout.BeginVertical();
//             DrawHeader(PostProcessingConfig.Type.GlobalFog);
//             DrawContent(PostProcessingConfig.Type.GlobalFog, typeof(GlobalFogInspector), ref globalFogEditor);
//             EditorGUILayout.EndVertical();
//         }
//
//         private void DrawBloom()
//         {
//             EditorGUILayout.BeginVertical();
//             DrawHeader(PostProcessingConfig.Type.Bloom);
//             DrawContent(PostProcessingConfig.Type.Bloom, null, ref bloomEditor);
//             EditorGUILayout.EndVertical();
//         }
//
//         private void DrawVignette()
//         {
//             EditorGUILayout.BeginVertical();
//             DrawHeader(PostProcessingConfig.Type.Vignette);
//             DrawContent(PostProcessingConfig.Type.Vignette, null, ref vignetteEditor);
//             EditorGUILayout.EndVertical();
//         }
//
//         private void DrawChromaticAberration()
//         {
//             EditorGUILayout.BeginVertical();
//             DrawHeader(PostProcessingConfig.Type.ChromaticAberration);
//             DrawContent(PostProcessingConfig.Type.ChromaticAberration, null, ref chromaticAberrationEditor);
//             EditorGUILayout.EndVertical();
//         }
//
//         private void DrawTimeSkill()
//         {
//             EditorGUILayout.BeginVertical();
//             DrawHeader(PostProcessingConfig.Type.TimeSkill);
//             DrawContent(PostProcessingConfig.Type.TimeSkill, null, ref timeSkillEditor);
//             EditorGUILayout.EndVertical();
//         }
//
//         private void DrawColorAdjustment()
//         {
//             EditorGUILayout.BeginVertical();
//             DrawHeader(PostProcessingConfig.Type.ColorAdjustment);
//             DrawContent(PostProcessingConfig.Type.ColorAdjustment, null, ref colorAdjustmentEditor);
//             EditorGUILayout.EndVertical();
//         }
//         
//         private void DrawHeader(PostProcessingConfig.Type type, string label)
//         {
//             EditorGUILayout.BeginHorizontal();
//             EditorGUILayout.LabelField(label);
//             PostProcessingConfig.State state = postProcessingConfig.GetPostProcessingState(type);
//
//             if (state == PostProcessingConfig.State.Removed)
//             {
//                 if (GUILayout.Button(addString))
//                 {
//                     OnAddButtonClick(type);
//                 }
//             }
//
//             else
//             {
//                 PostProcessingBase postProcessingBase = postProcessingConfig.GetPostProcessing(type);
//
//                 if (postProcessingBase.enabled == false)
//                 {
//                     GUILayout.Label("the monobehaviour is disable");        
//                 }
//                 
//                 if (state == PostProcessingConfig.State.Enable)
//                 {
//                     if (GUILayout.Button(disableString))
//                     {
//                         OnDisableButtonClick(type);
//                     }
//                 }
//
//                 else
//                 {
//                     if (GUILayout.Button(enableString))
//                     {
//                         OnEnableButtonClick(type);
//                     }
//                 }
//
//                 if (GUILayout.Button(removeString))
//                 {
//                     OnRemoveButtonClick(type);
//                 }
//             }
//
//             EditorGUILayout.EndHorizontal();
//         }
//
//         private void DrawHeader(PostProcessingConfig.Type type)
//         {
//             DrawHeader(type, type.ToString());
//         }
//
//         private void DrawContent(PostProcessingConfig.Type type, System.Type editorType, ref UnityEditor.Editor editor)
//         {
//             PostProcessingConfig.State state = postProcessingConfig.GetPostProcessingState(type);
//
//             if (state == PostProcessingConfig.State.Removed || state == PostProcessingConfig.State.Disable)
//             {
//                 return;
//             }
//
//             PostProcessingBase postProcessing = postProcessingConfig.GetPostProcessing(type);
//
//             if (editor == null)
//             {
//                 UnityEditor.Editor.CreateCachedEditor(postProcessing, editorType, ref editor);
//             }
//
//             if (editor.target == null)
//             {
//                 UnityEditor.Editor.CreateCachedEditor(postProcessing, editorType, ref editor);
//             }
//
//             EditorGUILayout.BeginVertical();
//             EditorGUI.indentLevel += 2;
//             editor.OnInspectorGUI();
//             EditorGUI.indentLevel -= 2;
//             EditorGUILayout.EndVertical();
//         }
//
//         private void OnAddButtonClick(PostProcessingConfig.Type type)
//         {
//             postProcessingConfig.AddPostProcessing(type);
//
//             if (Application.isPlaying == false)
//             {
//                 UnityEditor.SceneManagement.EditorSceneManager.MarkAllScenesDirty();
//                 PrefabUtility.RecordPrefabInstancePropertyModifications(postProcessingConfig);
//             }
//         }
//
//         private void OnRemoveButtonClick(PostProcessingConfig.Type type)
//         {
//             postProcessingConfig.RemovePostProcessing(type);
//
//             if (Application.isPlaying == false)
//             {
//                 UnityEditor.SceneManagement.EditorSceneManager.MarkAllScenesDirty();
//                 PrefabUtility.RecordPrefabInstancePropertyModifications(postProcessingConfig);
//             }
//         }
//
//         private void OnEnableButtonClick(PostProcessingConfig.Type type)
//         {
//             postProcessingConfig.EnablePostProcessing(type);
//
//             if (Application.isPlaying == false)
//             {
//                 UnityEditor.SceneManagement.EditorSceneManager.MarkAllScenesDirty();
//                 PrefabUtility.RecordPrefabInstancePropertyModifications(postProcessingConfig);
//                 EditorApplication.QueuePlayerLoopUpdate();
//             }
//         }
//
//         private void OnDisableButtonClick(PostProcessingConfig.Type type)
//         {
//             postProcessingConfig.DisablePostProcessing(type);
//
//             if (Application.isPlaying == false)
//             {
//                 UnityEditor.SceneManagement.EditorSceneManager.MarkAllScenesDirty();
//                 PrefabUtility.RecordPrefabInstancePropertyModifications(postProcessingConfig);
//                 EditorApplication.QueuePlayerLoopUpdate();
//             }
//         }
//
//         private void DrawSpace(int spaceCount)
//         {
//             for (int i = 0; i < spaceCount; ++i)
//             {
//                 EditorGUILayout.Space();
//             }
//         }
//         #endregion
//     }
// }
