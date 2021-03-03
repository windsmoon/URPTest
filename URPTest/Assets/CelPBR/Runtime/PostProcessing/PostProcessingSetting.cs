using System;
using System.Collections.Generic;
using UnityEngine;

namespace CelPBR.Runtime.PostProcessing
{
    [System.Serializable]
    [AddComponentMenu("")]
    [RequireComponent(typeof(PostProcessingConfig))]
    public abstract class PostProcessingSetting : MonoBehaviour
    {
        #region fields
        // private static Dictionary<int, Type> postProcessingTypeSettingDict;
        #endregion

        #region constructors
        // static PostProcessingSetting()
        // {
        //     // postProcessingTypeSettingDict = new Dictionary<int, Type>();
        //     // postProcessingTypeSettingDict.Add((int)PostProcessingType.ScreenSpaceRelfection, typeof(ScreenSpaceReflectionSetting));
        //     postProcessingTypeDict = new Dictionary<Type, PostProcessingType>();
        //     postProcessingTypeDict.Add(typeof(ScreenSpaceReflectionSetting), PostProcessingType.ScreenSpaceRelfection);
        // }
        #endregion

        #region methods
        // protected methtod, dont need try get
        // protected static Type GetPostProcessingSettingType(PostProcessingType type)
        // {
            // int typeInt = (int)type;
            // return postProcessingTypeSettingDict[typeInt];
        // }

        // protected methtod, dont need try get
        // public static PostProcessingType GetPostProcessingType<T>() where T : PostProcessingSetting
        // {
        //     return postProcessingTypeDict[typeof(T)];
        // }
        #endregion
    }
}