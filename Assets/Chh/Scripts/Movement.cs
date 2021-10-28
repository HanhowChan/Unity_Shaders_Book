using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Movement : MonoBehaviour
{
    public float speed = 0.1f;  //移动速度
    public bool moveable = true;    //是否可以移动

    private GameObject obj;
    // Start is called before the first frame update
    void Start()
    {
        obj = gameObject;
        print("obj is " + gameObject?.name);
    }

    // Update is called once per frame
    void Update()
    {
        if (Input.anyKeyDown)
        {
            float dst = Time.deltaTime * speed;
            //Event t = new Event();
            ////KeyCode key = Event.current.keyCode;
            //switch(Event.current.keyCode)
            //{
            //    case KeyCode.W:
            //        {
            //            obj.transform.position = new Vector3(obj.transform.position.x + dst, obj.transform.position.y, obj.transform.position.z);
            //        }
            //        break;
            //}
        }
    }
}
