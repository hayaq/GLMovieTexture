using UnityEngine;
using System.Collections;

public class Behaviour3 : MonoBehaviour {
	public Renderer _renderer;
	GLMovieTextureObject _mto;
	
	void Start(){
		LoadMovieTexture("Movie.m4v");
	}
	
	void OnDestroy(){
		if( _mto != null ){
			Destroy(_mto);
		}
	}
	
	void OnGUI(){
		if( _mto == null ){ return; }
		int bw = Screen.width/3;
		int bh = bw/2;
		int by = Screen.height-bh;
		bool isPlaying = _mto.IsPlaying();
		if( GUI.Button(new Rect(0,by,bw,bh),isPlaying? "Pause" : "Play") ){
			if( isPlaying ){ _mto.Pause(); }
			else{ _mto.Play(); }
		}else if( GUI.Button(new Rect(bw,by,bw,bh),"Rewind") ){
			_mto.Rewind();
		}
	}
	
	void LoadMovieTexture(string moviePath){
		if( _renderer==null || moviePath == null ){ return; }
		if( _mto != null ){
			Destroy(_mto);
			_mto = null;	
		}
		
		Texture2D texture = new Texture2D(1,1,TextureFormat.ARGB32, false);
		_mto = ScriptableObject.CreateInstance<GLMovieTextureObject>();
		_mto.Load(texture,moviePath);
		_mto.SetLoop(true);
				
		_renderer.material.mainTexture = texture;
	}
	
}
