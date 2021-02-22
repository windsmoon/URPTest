using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEditor;

namespace Windsmoon.Tools.Editor
{
    public class ImageChannelMixer : EditorWindow
    {
        #region fields
        private Texture2D texture;
        private Texture2D tempTexture;
        private Operation operationR;
        private Operation operationG;
        private Operation operationB;
        private Operation operationA;
        private float thresholdR;
        private float thresholdG;
        private float thresholdB;
        private float thresholdA;
        #endregion

        #region unity methods
        private void OnGUI()
        {
            EditorGUILayout.BeginVertical();
            
            texture = EditorGUILayout.ObjectField("Texture", texture, typeof(Texture2D)) as Texture2D;
            ChannelOperation(Channel.R, ref operationR, ref thresholdR);
            ChannelOperation(Channel.G, ref operationG, ref thresholdG);
            ChannelOperation(Channel.B, ref operationB, ref thresholdB);
            ChannelOperation(Channel.A, ref operationA, ref thresholdA);

            if (GUILayout.Button("Mix"))
            {
                Mix();
            }
            
            EditorGUILayout.EndVertical();
            
        }
        #endregion
        
        #region methods
        private void ChannelOperation(Channel channel, ref Operation operation, ref float threshold)
        {
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField(channel.ToString());
            operation = (Operation)EditorGUILayout.EnumPopup(operation);
            threshold = EditorGUILayout.Slider("Threshold", threshold, 0, 1);
            EditorGUILayout.EndHorizontal();
        }

        private void Mix()
        {
            float[] rColors = Mix(0, operationR, thresholdR);
            float[] gColors = Mix(1, operationG, thresholdG);
            float[] bColors = Mix(2, operationB, thresholdB);
            float[] aColors = Mix(3, operationA, thresholdA);

            Color[] colors = texture.GetPixels();
            Color[] tempColors = new Color[colors.Length];
            tempTexture = UnityEngine.Object.Instantiate<Texture2D>(texture);
            
            for (int i = 0; i < colors.Length; ++i)
            {
                Color tempColor = new Color(rColors[i], gColors[i], bColors[i], aColors[i]);
                tempColors[i] = tempColor;
            }
            
            tempTexture.SetPixels(tempColors);
            tempTexture.Apply();
            
            // todo : can select format and path
            byte[] bytes = tempTexture.EncodeToPNG();
            FileInfo fileInfo = new FileInfo("Assets/" + texture.name + "_" + DateTime.Now.Millisecond + ".png");
            FileStream fs = new FileStream("Assets/" + texture.name + "_" + DateTime.Now.Millisecond + ".png", FileMode.Create);
            fs.Write(bytes, 0, bytes.Length);
            fs.Close();
            AssetDatabase.Refresh();
        }

        private float[] Mix(int channel, Operation operation, float threshold)
        {
            switch (operation)
            {
                case Operation.None:
                    return CopySingleChannel(channel);
                case Operation.CopyR:
                    return CopySingleChannel(0);
                case Operation.CopyG:
                    return CopySingleChannel(1);
                case Operation.CopyB:
                    return CopySingleChannel(2);
                case Operation.CopyA:
                    return CopySingleChannel(3);
                case Operation.SetOne:
                    return SetOne();
                case Operation.SetZero:
                    return SetZero();
                case Operation.InvertR:
                    return InvertSingleChannel(0);
                case Operation.InvertG:
                    return InvertSingleChannel(1);
                case Operation.InvertB:
                    return InvertSingleChannel(2);
                case Operation.InvertA:
                    return InvertSingleChannel(3);
                case Operation.InvertSelf:
                    return InvertSingleChannel(channel);
                case Operation.BinarizationR:
                    return BinarizationSingleChannel(0, threshold);
                case Operation.BinarizationG:
                    return BinarizationSingleChannel(1, threshold);
                case Operation.BinarizationB:
                    return BinarizationSingleChannel(2, threshold);
                case Operation.BinarizationA:
                    return BinarizationSingleChannel(3, threshold);
            }

            return null;
        }

        private float[] CopySingleChannel(int index)
        {
            Color[] colors = texture.GetPixels();
            float[] results = new float[colors.Length];
            
            for (int i = 0; i < colors.Length; ++i)
            {
                results[i] = colors[i][index];
            }

            return results;
        }

        private float[] SetOne()
        {            
            Color[] colors = texture.GetPixels();
            float[] results = new float[colors.Length];
            
            for (int i = 0; i < colors.Length; ++i)
            {
                results[i] = 1;
            }

            return results;
        }
        
        private float[] SetZero()
        {            
            Color[] colors = texture.GetPixels();
            float[] results = new float[colors.Length];
            
            for (int i = 0; i < colors.Length; ++i)
            {
                results[i] = 0;
            }

            return results;
        }
        
        private float[] InvertSingleChannel(int index)
        {
            Color[] colors = texture.GetPixels();
            float[] results = new float[colors.Length];
            
            for (int i = 0; i < colors.Length; ++i)
            {
                results[i] = 1 - colors[i][index];
            }

            return results;
        }

        private float[] BinarizationSingleChannel(int index, float threshold)
        {
            Color[] colors = texture.GetPixels();
            float[] results = new float[colors.Length];
            
            for (int i = 0; i < colors.Length; ++i)
            {
                results[i] = colors[i][index] <= threshold ? 0 : 1;
            }

            return results;
        }
        
        [MenuItem("Windsmoon/Tools/Image Channel Mixer")]
        private static void OpenImageChannelMixer()
        {
            ImageChannelMixer imageChannelMixer = GetWindow<ImageChannelMixer>();
            imageChannelMixer.Show();
        }
        #endregion

        #region enums
        private enum Channel
        {
            R,
            G,
            B,
            A,
        }
        
        private enum Operation
        {
            None,
            CopyR,
            CopyG,
            CopyB,
            CopyA,
            SetOne,
            SetZero,
            InvertSelf,
            InvertR,
            InvertG,
            InvertB,
            InvertA,
            BinarizationR,
            BinarizationG,
            BinarizationB,
            BinarizationA,
        }
        #endregion
    }
}
