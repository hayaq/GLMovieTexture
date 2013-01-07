using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public class GLMovieTextureObject : ScriptableObject 
{
	ulong instanceId;
	
	public bool Load(Texture2D texture,string movieFileName){
		uint textureId = (uint)texture.GetNativeTextureID();
		if( textureId == 0 ){ return false; }
		string dataPath = Application.dataPath;
#if !UNITY_EDITOR && UNITY_STANDALONE_OSX
		dataPath += "/Data";
#endif
		instanceId = _Load(movieFileName,textureId,dataPath);
		return ( instanceId != 0 );
	}
	
	public void Unload(){
		if( instanceId !=0 ){
			_Unload(instanceId);
		}
		instanceId = 0;
	}
	
	public void Play(){ _Play(instanceId); }
	public void Pause(){ _Pause(instanceId); }
	public void Rewind(){ _SetCurrentTime(instanceId,0); }
	public float CurrentTime(){ return _CurrentTime(instanceId); }
	public void SetCurrentTime(float t){ _SetCurrentTime(instanceId,t); }
	public void SetLoop(bool loop){ _SetLoop(instanceId,loop); }
	public bool Loop(){ return _Loop(instanceId); }
	public bool IsPlaying(){ return _IsPlaying(instanceId); }
	
	void OnEnable(){
	}
	
	void OnDisable(){
	}

	void OnDestroy(){
		Unload();
	}
	
#if (UNITY_IPHONE && !UNITY_EDITOR)
	[DllImport ("__Internal")] private static extern ulong _Load(string name,uint textureId,string dataPath);
	[DllImport ("__Internal")] private static extern void  _Unload(ulong instanceId);
	[DllImport ("__Internal")] private static extern void  _Play(ulong instanceId);
	[DllImport ("__Internal")] private static extern void  _Pause(ulong instanceId);
	[DllImport ("__Internal")] private static extern float _CurrentTime(ulong instanceId);
	[DllImport ("__Internal")] private static extern void  _SetCurrentTime(ulong instanceId,float t);
	[DllImport ("__Internal")] private static extern bool  _Loop(ulong instanceId);
	[DllImport ("__Internal")] private static extern void  _SetLoop(ulong instanceId,bool loop);
	[DllImport ("__Internal")] private static extern bool  _IsPlaying(ulong instanceId);
#elif (UNITY_EDITOR||UNITY_STANDALONE_OSX)
	[DllImport ("GLMovieTexture")] private static extern ulong _Load(string name,uint textureId,string dataPath);
	[DllImport ("GLMovieTexture")] private static extern void  _Unload(ulong instanceId);
	[DllImport ("GLMovieTexture")] private static extern void  _Play(ulong instanceId);
	[DllImport ("GLMovieTexture")] private static extern void  _Pause(ulong instanceId);
	[DllImport ("GLMovieTexture")] private static extern float _CurrentTime(ulong instanceId);
	[DllImport ("GLMovieTexture")] private static extern void  _SetCurrentTime(ulong instanceId,float t);
	[DllImport ("GLMovieTexture")] private static extern bool  _Loop(ulong instanceId);
	[DllImport ("GLMovieTexture")] private static extern void  _SetLoop(ulong instanceId,bool loop);
	[DllImport ("GLMovieTexture")] private static extern bool  _IsPlaying(ulong instanceId);
#else
	private static ulong _Load(string name,uint textureId,string dataPath){ return 0; }
	private static void  _Unload(ulong instanceId){}
	private static void  _Play(ulong instanceId){}
	private static void  _Pause(ulong instanceId){}
	private static float _CurrentTime(ulong instanceId){ return 0.0f; }
	private static void  _SetCurrentTime(ulong instanceId,float t){}
	private static bool  _Loop(ulong instanceId){ return false; }
	private static void  _SetLoop(ulong instanceId,bool loop){}
	private static bool  _IsPlaying(ulong instanceId){ return false; }
#endif
}

	

