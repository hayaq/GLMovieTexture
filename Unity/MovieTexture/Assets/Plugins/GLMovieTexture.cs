using UnityEngine;
using System.Collections;

public class GLMovieTexture : MonoBehaviour 
{
	public Texture2D targetTexture;
	public bool autoPlay;
	public bool loop;
	GLMovieTextureObject mto;
	
	void Start(){
		if( targetTexture == null ){
			if( this.renderer!=null && this.renderer.materials!=null ){
				foreach( Material m in this.renderer.materials ){
					if( m.mainTexture!=null && m.mainTexture.GetType()==typeof(Texture2D) ){
						targetTexture = (Texture2D)m.mainTexture;
						break;
					}
				}
			}
		}
		if( targetTexture==null ){
			return;
		}
		mto = ScriptableObject.CreateInstance<GLMovieTextureObject>();
		mto.Load(targetTexture);
		mto.SetLoop(loop);
		if( autoPlay ){
			mto.Play();
		}
	}
	
	void OnDestroy(){
		Destroy(mto);
	}
	
	public void Play(){
		if( mto==null ){ return; }
		mto.Play();
	}
	
	public void Pause(){
		if( mto==null ){ return; }
		mto.Pause();
	}
	
	public void Rewind(){
		if( mto==null ){ return; }
		mto.Rewind();
	}
	
	public float CurrentTime(){
		if( mto==null ){ return 0.0f; }
		return mto.CurrentTime();
	}
	
	public void SetCurrentTime(float t){
		if( mto==null ){ return; }
		mto.SetCurrentTime(t);
	}
	
	public void SetLoop(bool _loop){
		loop = _loop;
		if( mto==null ){ return; }
		mto.SetLoop(_loop);
	}
	
	public bool Loop(){
		if( mto==null ){ return false; }
		return mto.Loop();
	}
	
}
