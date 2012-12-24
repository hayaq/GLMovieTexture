using UnityEngine;
using System.Collections;

public class MyBehaviour : MonoBehaviour {
	
	void Update () {
		this.transform.localRotation = Quaternion.AngleAxis(20.0f*Time.time,Vector3.up);	
	}
	
	//void OnGUI(){
	//	if( GUI.Button(new Rect( 0, Screen.height-50, 100, 50 ), "Delete") ){
	//		Destroy(this.gameObject);
	//	}
	//}
}
