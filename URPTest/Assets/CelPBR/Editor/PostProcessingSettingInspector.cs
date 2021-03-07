using System;
using System.Collections.Generic;
using CelPBR.Runtime.PostProcessing;
using UnityEngine;
using UnityEditor;
using UnityEditor.Graphs;
using UnityEditor.Rendering;

namespace CelPBR.Editor
{
    [CustomEditor(typeof(PostProcessingConfig))]
    public class PostProcessingConfigInspector : UnityEditor.Editor//, ISerializationCallbackReceiver
    {
        #region constant
        private const string addString = "Add";
        private const string removeString = "Remove";
        private const string enableString = "Enable";
        private const string disableString = "Disable";
        #endregion

        #region fields
        // [SerializeField]
        // private List<PostProcessingType> foldoutStateKeyList = new List<PostProcessingType>();
        // [SerializeField]
        // private List<bool> foldoutStateValueList = new List<bool>();
        // private Dictionary<PostProcessingType, bool> foldoutStateDict;
        
        private PostProcessingConfig postProcessingConfig;
        private UnityEditor.Editor screenSpaceReflectionEditor;
        private new PostProcessingConfig taraget;
        private Dictionary<PostProcessingType, UnityEditor.Editor> unityEditorDict;
        #endregion

        #region unity methods
        // private void Awake()
        // {
        //     Debug.Log("Awake");
        //     // foldoutStateDict = new Dictionary<PostProcessingType, bool>();
        // }

        private void OnEnable()
        {
            postProcessingConfig = target as PostProcessingConfig;
            // Undo.RecordObject(postProcessingConfig.gameObject, "Post Processing Config");
            unityEditorDict = new Dictionary<PostProcessingType, UnityEditor.Editor>();
            unityEditorDict.Add(PostProcessingType.ScreenSpaceRelfection, screenSpaceReflectionEditor);
        }

        private void OnDisable()
        {
            // Undo.ClearUndo(postProcessingConfig.gameObject);
        }

        // private void OnDestroy()
        // {
        //     Debug.Log("Destroy");
        // }
        #endregion
        
        // #region interface implementations
        // public void OnBeforeSerialize()
        // {
        //     foldoutStateKeyList.Clear();
        //     foldoutStateValueList.Clear();
        //     
        //     foreach (var pair in foldoutStateDict)
        //     {
        //         foldoutStateKeyList.Add(pair.Key);
        //         foldoutStateValueList.Add(pair.Value);
        //     }
        // }
        //
        // public void OnAfterDeserialize()
        // {
        //     foldoutStateDict.Clear();
        //     
        //     for (int i = 0; i < foldoutStateKeyList.Count; ++i)
        //     {
        //         foldoutStateDict[foldoutStateKeyList[i]] = foldoutStateValueList[i];
        //     }
        // }
        // #endregion
        
        #region methods
        public override void OnInspectorGUI()
        {
            EditorGUILayout.BeginVertical();
            base.OnInspectorGUI();
            DrawSpace(2);
            // DrawScreenSpaceReflecton();      
            DrawExistPostProcessing();
            
            if (GUILayout.Button(EditorGUIUtility.TrTextContent("Add Post Porcessing"), EditorStyles.miniButton))
            {
                OnAddPostProcessingButtonClicked();
            }

            if (GUILayout.Button(EditorGUIUtility.TrTextContent("Remove Post Processing"), EditorStyles.miniButton))
            {
                OnRemovePostProcessingButtonClicked();
            }
            
            EditorGUILayout.EndVertical();
        }

        private void AddPostProcessing(PostProcessingType type)
        {
            PostProcessingSetting postProcessingSetting;
            postProcessingConfig.AddPostProcessing(PostProcessingType.ScreenSpaceRelfection, out  postProcessingSetting);
        }

        private void RemovePostProcessing(PostProcessingType type)
        {
            PostProcessingSetting postProcessingSetting;
            postProcessingConfig.RemovePostProcessing(PostProcessingType.ScreenSpaceRelfection);
        }
        
        private void OnAddPostProcessingButtonClicked()
        {
            var menu = new GenericMenu();
            menu.AddItem(EditorGUIUtility.TrTextContent("SSR"), false, () => AddPostProcessing(PostProcessingType.ScreenSpaceRelfection));
            menu.ShowAsContext();
        }

        private void OnRemovePostProcessingButtonClicked()
        {
            List<PostProcessingType> existPostProcessingTypeList = new List<PostProcessingType>();
            int count = postProcessingConfig.GetExistPostProcessingTypeList(existPostProcessingTypeList);
            var menu = new GenericMenu();

            for (int i = 0; i < count; ++i)
            {
                PostProcessingType type = existPostProcessingTypeList[i];
                PostProcessingSetting postProcessingSetting;
                postProcessingConfig.GetPostProcessingSetting(type, out postProcessingSetting);
                menu.AddItem(EditorGUIUtility.TrTextContent(postProcessingSetting.PostProcessingName), false, () => RemovePostProcessing(type));
                menu.ShowAsContext();
            }
        }

        private void DrawExistPostProcessing()
        {
            List<PostProcessingType> existPostProcessingTypeList = new List<PostProcessingType>();
            int count = postProcessingConfig.GetExistPostProcessingTypeList(existPostProcessingTypeList);

            for (int i = 0; i < count; ++i)
            {
                PostProcessingType type = existPostProcessingTypeList[i];
                DrawPostProcessing(type);
            }
        }

        private void DrawPostProcessing(PostProcessingType type)
        {
            PostProcessingSetting postProcessingSetting;
            postProcessingConfig.GetPostProcessingSetting(type, out postProcessingSetting);
            EditorGUILayout.BeginVertical();

            // if (foldoutStateDict.TryGetValue(type, out bool foldoutState) == false)
            // {
            //     foldoutStateDict.Add(type, false);
            // }
            
            // foldoutStateDict[type] = CoreEditorUtils.DrawHeaderFoldout(postProcessingSetting.PostProcessingName, state, false);
            bool isEnabled = postProcessingSetting.enabled;
            postProcessingSetting.IsEditorFoldout = DrawHeaderToggle(postProcessingSetting.PostProcessingName, postProcessingSetting.IsEditorFoldout, ref isEnabled, null, null, null, null);
            // foldoutStateDict[type] = foldoutState;
            postProcessingSetting.enabled = isEnabled;
            
            if (postProcessingSetting.IsEditorFoldout)
            {
                UnityEditor.Editor postProcessingEditor = unityEditorDict[type];
                DrawContent(type, null, ref postProcessingEditor);
            }
            
            EditorGUILayout.EndVertical();
        }

        // If this function is called, then this post-processing must exist
        private void DrawContent(PostProcessingType type, System.Type editorType, ref UnityEditor.Editor editor)
        {
            PostProcessingSetting postProcessingSetting;
            postProcessingConfig.GetPostProcessingSetting(type, out postProcessingSetting);

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

        private void DrawSpace(int spaceCount)
        {
            for (int i = 0; i < spaceCount; ++i)
            {
                EditorGUILayout.Space();
            }
        }

        /// <summary>Draw a header toggle like in Volumes</summary>
        /// <param name="title"> The title of the header </param>
        /// <param name="group"> The group of the header </param>
        /// <param name="activeField">The active field</param>
        /// <param name="contextAction">The context action</param>
        /// <param name="hasMoreOptions">Delegate saying if we have MoreOptions</param>
        /// <param name="toggleMoreOptions">Callback called when the MoreOptions is toggled</param>
        /// <param name="documentationURL">Documentation URL</param>
        /// <returns>return the state of the foldout header</returns>
        public static bool DrawHeaderToggle(string title, bool isFoldout, ref bool isEnabled, Action<Vector2> contextAction, Func<bool> hasMoreOptions, Action toggleMoreOptions, string documentationURL)
        {
            var backgroundRect = GUILayoutUtility.GetRect(1f, 17f);

            var labelRect = backgroundRect;
            labelRect.xMin += 32f;
            labelRect.xMax -= 20f + 16 + 5;

            var foldoutRect = backgroundRect;
            foldoutRect.y += 1f;
            foldoutRect.width = 13f;
            foldoutRect.height = 13f;

            var toggleRect = backgroundRect;
            toggleRect.x += 16f;
            toggleRect.y += 2f;
            toggleRect.width = 13f;
            toggleRect.height = 13f;

            // // More options 1/2
            // var moreOptionsRect = new Rect();
            // if (hasMoreOptions != null)
            // {
            //     moreOptionsRect = backgroundRect;
            //
            //     moreOptionsRect.x += moreOptionsRect.width - 16 - 1 - 16 - 5;
            //
            //     if (!string.IsNullOrEmpty(documentationURL))
            //         moreOptionsRect.x -= 16 + 7;
            //
            //     moreOptionsRect.height = 15;
            //     moreOptionsRect.width = 16;
            // }

            // Background rect should be full-width
            backgroundRect.xMin = 0f;
            backgroundRect.width += 4f;

            // Background
            float backgroundTint = EditorGUIUtility.isProSkin ? 0.1f : 1f;
            EditorGUI.DrawRect(backgroundRect, new Color(backgroundTint, backgroundTint, backgroundTint, 0.2f));

            // Title
            using (new EditorGUI.DisabledScope(!isEnabled))
                EditorGUI.LabelField(labelRect, new GUIContent(title), EditorStyles.boldLabel);

            // Foldout
            // group.serializedObject.Update();
            isFoldout = GUI.Toggle(foldoutRect, isFoldout, GUIContent.none, EditorStyles.foldout);
            // group.serializedObject.ApplyModifiedProperties();
            
            // custome 
            

            // Active checkbox
            // activeField.serializedObject.Update();
            isEnabled = GUI.Toggle(toggleRect, isEnabled, GUIContent.none, CoreEditorStyles.smallTickbox);
            // activeField.serializedObject.ApplyModifiedProperties();

            // // More options 2/2
            // if (hasMoreOptions != null)
            // {
            //     bool moreOptions = hasMoreOptions();
            //     bool newMoreOptions = Styles.DrawMoreOptions(moreOptionsRect, moreOptions);
            //     if (moreOptions ^ newMoreOptions)
            //         toggleMoreOptions?.Invoke();
            // }

            // Context menu
            var menuIcon = CoreEditorStyles.paneOptionsIcon;
            var menuRect = new Rect(labelRect.xMax + 3f + 16 + 5 , labelRect.y + 1f, menuIcon.width, menuIcon.height);

            if (contextAction != null)
                GUI.DrawTexture(menuRect, menuIcon);

            // // Documentation button
            // if (!String.IsNullOrEmpty(documentationURL))
            // {
            //     var documentationRect = menuRect;
            //     documentationRect.x -= 16 + 5;
            //     documentationRect.y -= 1;
            //
            //     var documentationTooltip = $"Open Reference for {title.text}.";
            //     var documentationIcon = new GUIContent(EditorGUIUtility.TrIconContent("_Help").image, documentationTooltip);
            //     var documentationStyle = new GUIStyle("IconButton");
            //
            //     if (GUI.Button(documentationRect, documentationIcon, documentationStyle))
            //         System.Diagnostics.Process.Start(documentationURL);
            // }

            // // Handle events
            // var e = Event.current;
            //
            // if (e.type == EventType.MouseDown)
            // {
            //     if (contextAction != null && menuRect.Contains(e.mousePosition))
            //     {
            //         contextAction(new Vector2(menuRect.x, menuRect.yMax));
            //         e.Use();
            //     }
            //     else if (labelRect.Contains(e.mousePosition))
            //     {
            //         if (e.button == 0)
            //             group.isExpanded = !group.isExpanded;
            //         else if (contextAction != null)
            //             contextAction(e.mousePosition);
            //
            //         e.Use();
            //     }
            // }
            //
            // return group.isExpanded;
            return isFoldout;
        }
        #endregion
    }
}
