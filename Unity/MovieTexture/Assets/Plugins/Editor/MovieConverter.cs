using UnityEngine;
using UnityEditor;
using System.Collections;

public class MovieConverter : Editor {

	[MenuItem("Assets/Make MovieTexture ref image")]
	public static void ConvertToEmbededPNG(){
		if( !ValidateConvertToEmbededPNG() ){
			return;
		}
		string execPath = Application.dataPath + "/Plugins/Editor/movtoimg";
		string path = AssetDatabase.GetAssetPath(Selection.activeObject);
		path = Application.dataPath+path.Substring(6);
		System.Diagnostics.Process process = new System.Diagnostics.Process();
		process.StartInfo.FileName = execPath;
		process.StartInfo.Arguments = "\""+path + "\" -o \""+path+".jpg\"";
		process.StartInfo.CreateNoWindow = false;
		process.Start();
		process.WaitForExit();
		if( process.ExitCode==0 ){
			AssetDatabase.Refresh();
		}
	}
	
	[MenuItem("Assets/Make MovieTexture ref image",true)]
	public static bool ValidateConvertToEmbededPNG(){
		if( Selection.activeObject == null ){ return false; }
		string path = AssetDatabase.GetAssetPath(Selection.activeObject);
		if( path.EndsWith(".mov") || path.EndsWith(".m4v") || 
			path.EndsWith(".mp4") || path.EndsWith(".webm") ){
			return true;	
		}
		return false;
	}
}
