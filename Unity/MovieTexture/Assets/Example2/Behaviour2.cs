using UnityEngine;
using System.Collections;

public class Behaviour2 : MonoBehaviour {
	public Renderer _renderer;
	GLMovieTextureObject _mto;
	
	void OnDestroy(){
		if( _mto != null ){
			Destroy(_mto);
		}
	}
	
	void OnGUI(){
		int bw = Screen.width/3;
		int bh = bw/2;
		int by = Screen.height-bh;
		if( GUI.Button(new Rect(0,by,bw,bh),"Local") ){
			LoadMovieTexture("Movie2.m4v");
		}else if( GUI.Button(new Rect(bw,by,bw,bh),"Streaming") ){
			LoadMovieTexture("http://github.id0.jp/GLMovieTexture/Movie.m4v");
		}else if( GUI.Button(new Rect(2*bw,by,bw,bh),"Delete") ){
			if( _mto != null ){
				Destroy(_mto);
			}
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
		_mto.Play();
		
		_renderer.material.mainTexture = texture;
	}
	
}
