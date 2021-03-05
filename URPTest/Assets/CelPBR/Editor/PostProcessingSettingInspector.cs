using CelPBR.Runtime.PostProcessing;
using UnityEngine;
using UnityEditor;

namespace CelPBR.Editor
{
    [CustomEditor(typeof(PostProcessingConfig))]
    public class PostProcessingConfigInspector : UnityEditor.Editor
    {
        #region constant
        private const string addString = "Add";
        private const string removeString = "Remove";
        private const string enableString = "Enable";
        private const string disableString = "Disable";
        #endregion

        #region fields
        private PostProcessingConfig postProcessingConfig;
        private UnityEditor.Editor screenSpaceReflectionEditor;
        #endregion

        #region methods
        public override void OnInspectorGUI()
        {
            postProcessingConfig = target as PostProcessingConfig;
            EditorGUILayout.BeginVertical();
            base.OnInspectorGUI();
            DrawSpace(2);
            DrawScreenSpaceReflecton();            
            EditorGUILayout.EndVertical();
        }

        private void DrawScreenSpaceReflecton()
        {
            EditorGUILayout.BeginVertical();
            DrawHeader(PostProcessingType.ScreenSpaceRelfection);
            DrawContent(PostProcessingType.ScreenSpaceRelfection, null, ref screenSpaceReflectionEditor);
            EditorGUILayout.EndVertical();
        }
        
        private void DrawHeader(PostProcessingType type, string label)
        {
            // EditorGUILayout.BeginHorizontal();
            // EditorGUILayout.LabelField(label);
            //
            // if (state == PostProcessingConfig.State.Removed)
            // {
            //     if (GUILayout.Button(addString))
            //     {
            //         OnAddButtonClick(type);
            //     }
            // }
            //
            // else
            // {
            //     PostProcessingBase postProcessingBase = postProcessingConfig.GetPostProcessing(type);
            //
            //     if (postProcessingBase.enabled == false)
            //     {
            //         GUILayout.Label("the monobehaviour is disable");        
            //     }
            //     
            //     if (state == PostProcessingConfig.State.Enable)
            //     {
            //         if (GUILayout.Button(disableString))
            //         {
            //             OnDisableButtonClick(type);
            //         }
            //     }
            //
            //     else
            //     {
            //         if (GUILayout.Button(enableString))
            //         {
            //             OnEnableButtonClick(type);
            //         }
            //     }
            //
            //     if (GUILayout.Button(removeString))
            //     {
            //         OnRemoveButtonClick(type);
            //     }
            // }
            //
            // EditorGUILayout.EndHorizontal();
        }

        private void DrawHeader(PostProcessingType type)
        {
            DrawHeader(type, type.ToString());
        }

        private void DrawContent(PostProcessingType type, System.Type editorType, ref UnityEditor.Editor editor)
        {
            PostProcessingSetting postProcessingSetting = postProcessingConfig.GetPoseProcessingSetting(type);

            if (postProcessingSetting == null)
            {
                return;
            }

            if (postProcessingSetting.enabled == false)
            {
                return;
            }

            if (editor == null)
            {
                UnityEditor.Editor.CreateCachedEditor(postProcessingSetting, editorType, ref editor);
            }

            if (editor.target == null)
            {
                UnityEditor.Editor.CreateCachedEditor(postProcessingSetting, editorType, ref editor);
            }

            EditorGUILayout.BeginVertical();
            EditorGUI.indentLevel += 2;
            editor.OnInspectorGUI();
            EditorGUI.indentLevel -= 2;
            EditorGUILayout.EndVertical();
        }

        private void OnAddButtonClick(PostProcessingType type)
        {
            postProcessingConfig.AddPostProcessing(type);

            if (Application.isPlaying == false)
            {
                UnityEditor.SceneManagement.EditorSceneManager.MarkAllScenesDirty();
                PrefabUtility.RecordPrefabInstancePropertyModifications(postProcessingConfig);
            }
        }

        private void OnRemoveButtonClick(PostProcessingType type)
        {
            postProcessingConfig.RemovePostProcessing(type);

            if (Application.isPlaying == false)
            {
                UnityEditor.SceneManagement.EditorSceneManager.MarkAllScenesDirty();
                PrefabUtility.RecordPrefabInstancePropertyModifications(postProcessingConfig);
            }
        }

        private void OnEnableButtonClick(PostProcessingType type)
        {
            postProcessingConfig.EnablePostProcessing(type);

            if (Application.isPlaying == false)
            {
                UnityEditor.SceneManagement.EditorSceneManager.MarkAllScenesDirty();
                PrefabUtility.RecordPrefabInstancePropertyModifications(postProcessingConfig);
                EditorApplication.QueuePlayerLoopUpdate();
            }
        }

        private void OnDisableButtonClick(PostProcessingType type)
        {
            postProcessingConfig.DisablePostProcessing(type);

            if (Application.isPlaying == false)
            {
                UnityEditor.SceneManagement.EditorSceneManager.MarkAllScenesDirty();
                PrefabUtility.RecordPrefabInstancePropertyModifications(postProcessingConfig);
                EditorApplication.QueuePlayerLoopUpdate();
            }
        }

        private void DrawSpace(int spaceCount)
        {
            for (int i = 0; i < spaceCount; ++i)
            {
                EditorGUILayout.Space();
            }
        }
        #endregion
    }
}
