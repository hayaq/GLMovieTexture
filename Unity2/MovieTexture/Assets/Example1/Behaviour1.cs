using UnityEngine;
using System.Collections;

public class Behaviour1 : MonoBehaviour {
	void Update () {
		this.transform.localRotation = Quaternion.AngleAxis(20.0f*Time.time,Vector3.up);	
	}
}
