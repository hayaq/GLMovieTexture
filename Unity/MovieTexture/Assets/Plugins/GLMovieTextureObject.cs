using UnityEngine;
using System.Collections;
using System.Runtime.InteropServices;

public class GLMovieTextureObject : ScriptableObject 
{
	ulong instanceId;
	
	public bool Load(Texture2D texture){
#if UNITY_IPHONE && UNITY_EDITOR
		Debug.Log("IPHONE EDITOR");
#elif UNITY_IPHONE
		Debug.Log("IPHONE DEVICE");
#endif
		instanceId = _Load(texture.name,(uint)texture.GetNativeTextureID());
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
	
	void OnEnable(){
		//Debug.Log("GLMovieTextureObject.OnEnable");
	}
	
	void OnDisable(){
		//Debug.Log("GLMovieTextureObject.OnDisable");
	}

	void OnDestroy(){
		//Debug.Log("GLMovieTextureObject.OnDestroy");
		Unload();
	}

#if (UNITY_IPHONE && !UNITY_EDITOR)
	[DllImport ("__Internal")] private static extern ulong _Load(string name,uint textureId);
	[DllImport ("__Internal")] private static extern void  _Unload(ulong instanceId);
	[DllImport ("__Internal")] private static extern void  _Play(ulong instanceId);
	[DllImport ("__Internal")] private static extern void  _Pause(ulong instanceId);
	[DllImport ("__Internal")] private static extern float _CurrentTime(ulong instanceId);
	[DllImport ("__Internal")] private static extern void  _SetCurrentTime(ulong instanceId,float t);
	[DllImport ("__Internal")] private static extern bool  _Loop(ulong instanceId);
	[DllImport ("__Internal")] private static extern void  _SetLoop(ulong instanceId,bool loop);
#else
	private static ulong _Load(string name,uint textureId){ return 0; }
	private static void  _Unload(ulong instanceId){}
	private static void  _Play(ulong instanceId){}
	private static void  _Pause(ulong instanceId){}
	private static float _CurrentTime(ulong instanceId){ return 0.0f; }
	private static void  _SetCurrentTime(ulong instanceId,float t){}
	private static bool  _Loop(ulong instanceId){ return false; }
	private static void  _SetLoop(ulong instanceId,bool loop){}
#endif
}

	

