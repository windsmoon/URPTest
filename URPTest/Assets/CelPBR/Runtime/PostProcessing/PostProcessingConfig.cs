using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SocialPlatforms;

namespace CelPBR.Runtime.PostProcessing
{
    [ExecuteInEditMode]
    [RequireComponent(typeof(Camera))]
    [DisallowMultipleComponent]
    public class PostProcessingConfig : MonoBehaviour, ISerializationCallbackReceiver
    {
        #region fields
        [HideInInspector, SerializeField] 
        private List<int> postProcessingSettingDictKeyList = new List<int>();
        [HideInInspector, SerializeField]
        private List<PostProcessingSetting> postProcessingSettingDictValueList = new List<PostProcessingSetting>();
        
        private Dictionary<int, PostProcessingSetting> postProcessingSettingDict = new Dictionary<int, PostProcessingSetting>();
        // private static Dictionary<Type, PostProcessingType> postProcessingTypeDict;
        private static Dictionary<int, Type> postProcessingSettingTypeDict;
        #endregion

        #region constructors
        static PostProcessingConfig()
        {
            postProcessingSettingTypeDict = new Dictionary<int, Type>();
            postProcessingSettingTypeDict.Add((int)PostProcessingType.ScreenSpaceRelfection, typeof(ScreenSpaceReflectionSetting));
            // postProcessingTypeDict = new Dictionary<Type, PostProcessingType>();
            // postProcessingTypeDict.Add(typeof(ScreenSpaceReflectionSetting), PostProcessingType.ScreenSpaceRelfection);
        }
        #endregion
        
        #region unity methods
        private void Awake()
        {
            foreach (var pair in postProcessingSettingDict)
            {
                pair.Value.hideFlags = HideFlags.HideInInspector;
            }
        }
        #endregion

        #region interface implementations
        public void OnBeforeSerialize()
        {
            postProcessingSettingDictKeyList.Clear();
            postProcessingSettingDictValueList.Clear();
            
            foreach (var pair in postProcessingSettingDict)
            {
                postProcessingSettingDictKeyList.Add(pair.Key);
                postProcessingSettingDictValueList.Add(pair.Value);
            }
        }

        public void OnAfterDeserialize()
        {
            postProcessingSettingDict.Clear();
            
            for (int i = 0; i < postProcessingSettingDictKeyList.Count; ++i)
            {
                postProcessingSettingDict[postProcessingSettingDictKeyList[i]] = postProcessingSettingDictValueList[i];
            }
        }
        #endregion

        #region methods
        public PostProcessingSetting AddPostProcessing(PostProcessingType type)
        {
            int typeInt = (int) type;
            PostProcessingSetting postProcessingSetting;
            
            if (postProcessingSettingDict.TryGetValue(typeInt, out postProcessingSetting))
            {
                return postProcessingSetting;
            }

            Type classType = GetPostProcessingSettingType(typeInt);
            postProcessingSetting = gameObject.AddComponent(classType) as PostProcessingSetting;
            postProcessingSetting.hideFlags = HideFlags.HideInInspector;
            return postProcessingSetting;
        }

        public bool RemovePostProcessing(PostProcessingType type)
        {
            int typeInt = (int) type;
            PostProcessingSetting postProcessingSetting = GetPostProcessingSetting(typeInt);

            if (postProcessingSetting == null)
            {
                return false;
            }

#if UNITY_EDITOR
            UnityEngine.Object.DestroyImmediate(postProcessingSetting, true);
#else
            UnityEngine.Object.Destroy(postProcessingSetting);
#endif

            postProcessingSettingDict.Remove(typeInt);
            return true;
        }

         public bool EnablePostProcessing(PostProcessingType type)
         {
             int typeInt = (int) type;
             PostProcessingSetting postProcessingSetting = GetPostProcessingSetting(typeInt);

             if (postProcessingSetting == null)
             {
                 return false;
             }

             if (postProcessingSetting.enabled)
             {
                 return false;
             }

             postProcessingSetting.enabled = true;
             return true;
         }

         public bool DisablePostProcessing(PostProcessingType type)
         {
             int typeInt = (int) type;
             PostProcessingSetting postProcessingSetting = GetPostProcessingSetting(typeInt);

             if (postProcessingSetting == null)
             {
                 return false;
             }

             if (postProcessingSetting.enabled == false)
             {
                 return false;
             }

             postProcessingSetting.enabled = false;
             return true;
         }

         public PostProcessingSetting GetPoseProcessingSetting(PostProcessingType type)
         {
             int typeInt = (int) type;
             PostProcessingSetting postProcessingSetting = GetPostProcessingSetting(typeInt);
             return postProcessingSetting;
         }

         private bool HasAdded(PostProcessingType type)
         {
             int typeInt = (int) type;
             PostProcessingSetting postProcessingSetting = GetPostProcessingSetting(typeInt);
             return postProcessingSetting != null;
         }
         
         private bool IsEnabled(PostProcessingType type)
         {
             int typeInt = (int) type;
             PostProcessingSetting postProcessingSetting = GetPostProcessingSetting(typeInt);

             if (postProcessingSetting == null)
             {
                 return false;
             }

             return postProcessingSetting.enabled;
         }

        private PostProcessingSetting GetPostProcessingSetting(int typeInt)
        {
            PostProcessingSetting postProcessingSetting;
            postProcessingSettingDict.TryGetValue(typeInt, out postProcessingSetting);
            return postProcessingSetting;
        }
        
        
        // private static PostProcessingType GetPostProcessingType<T>() where T : PostProcessingSetting
        // {
        //     return postProcessingTypeDict[typeof(T)];
        // }

        // protected methtod, dont need try get
        private static Type GetPostProcessingSettingType(int typeInt)
        {
            return postProcessingSettingTypeDict[typeInt];
        }
        #endregion
    }
}