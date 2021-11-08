using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraFollow : MonoBehaviour {

    public Transform target;
    public float distanceH = 1f;
    public float distanceV = 1.5f;
    public float smoothSpeed = 100f; //平滑参数

    public float cameraMoveSpeed = 100f;
	public float cameraRotSpeed = 135f;
	public float maxRotX = 90f;	//相机最大pitch角
	public float minRotX = -20f;    //相机最小pitch角
	public float maxDistanceH = 6.5f;		//相机距主角最大距离
	public float minDistanceH = 0.6f;		//相机距主角最小距离
	bool isRotateCamera = false;

	private float trans_z = 0f;

	private float eulerAngles_x;
	private float eulerAngles_y;

	// Use this for initialization
	void Start () {
		Vector3 eulerAngles = this.transform.eulerAngles;       //当前物体的欧拉角
		this.eulerAngles_x = eulerAngles.x;
		this.eulerAngles_y = eulerAngles.y;
	}
	
	void FixedUpdate()
    {
		if(!target)
        {
			Debug.Log("target is null-->CameraFollow.FixedUpdate()");
			return;
        }
		if (Input.GetMouseButton(2))        //重置视角
		{
            this.eulerAngles_x = target.transform.eulerAngles.x;
            this.eulerAngles_y = target.transform.eulerAngles.y;
            this.trans_z = 0;
        }
		else
        {
			this.eulerAngles_x -= (Input.GetAxis("Mouse Y") * this.cameraRotSpeed) * Time.deltaTime;	//鼠标的Y轴变化量是绕pitch轴(x轴)进行旋转
			this.eulerAngles_y += (Input.GetAxis("Mouse X") * this.cameraRotSpeed) * Time.deltaTime;    //鼠标的X轴变化量是绕yaw轴(y轴)进行旋转
			this.trans_z -= (Input.GetAxis("Mouse ScrollWheel") * this.cameraMoveSpeed * 2) * Time.deltaTime;
        }
		this.eulerAngles_x = Mathf.Min(Mathf.Max(this.minRotX, this.eulerAngles_x), this.maxRotX);  //限制俯仰角范围
		Quaternion quaternion = Quaternion.Euler(this.eulerAngles_x, this.eulerAngles_y, (float)0);
		this.transform.rotation = quaternion;
    }

	// Update is called once per frame
	void Update () {
		
	}

	void LateUpdate()
    {
		if (!target)
		{
			Debug.Log("target is null-->CameraFollow.LateUpdate()");
			return;
		}
		Vector3 nextpos;
		float distanceC = distanceH + this.trans_z;	//相机和主角的距离
		distanceC = Mathf.Min(Mathf.Max(this.minDistanceH, distanceC), this.maxDistanceH);  //限制相机和主角的距离的范围
		nextpos = this.transform.forward * -1 * distanceC + Vector3.up * distanceV + target.position;
        this.transform.position = Vector3.Lerp(this.transform.position, nextpos, smoothSpeed * Time.deltaTime); //平滑插值
    }
}
