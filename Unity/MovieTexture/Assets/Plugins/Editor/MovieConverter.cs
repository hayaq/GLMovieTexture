using UnityEngine;
using UnityEditor;
using System.Collections;

public class MovieConverter : Editor {

	[MenuItem("Assets/Convert EmbededPNG")]
	public static void ConvertEmbededPNG(){
		if( !ValidateConvertEmbededPNG() ){
			return;
		}
		string execPath = Application.dataPath + "/Plugins/Editor/pngmovie";
		string path = AssetDatabase.GetAssetPath(Selection.activeObject);
		path = Application.dataPath+path.Substring(6);
		System.Diagnostics.Process process = new System.Diagnostics.Process();
		process.StartInfo.FileName = execPath;
		process.StartInfo.Arguments = path + " -o "+path+".png";
		process.StartInfo.CreateNoWindow = false;
		process.Start();
		process.WaitForExit();
		if( process.ExitCode==0 ){
			System.IO.File.Delete(path);
			AssetDatabase.Refresh();
		}
	}
	
	[MenuItem("Assets/Convert EmbededPNG",true)]
	public static bool ValidateConvertEmbededPNG(){
		if( Selection.activeObject == null ){ return false; }
		string path = AssetDatabase.GetAssetPath(Selection.activeObject);
		if( path.EndsWith(".mov") || path.EndsWith(".m4v") || path.EndsWith(".mp4") || path.EndsWith(".webm") ){
			return true;	
		}
		return false;
	}
	
}
