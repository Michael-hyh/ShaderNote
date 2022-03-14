using System.Collections.Generic;
using UnityEngine;
 
 
public class EffectClip : MonoBehaviour {
    public RectTransform m_rectTrans;//遮挡容器，即ScrollView
    Transform m_canvas;//UI的根,Canvas
    float m_halfWidth, m_halfHeight, m_canvasScale;
    
    public void Clip(Transform canvas, RectTransform rectTrans){
        m_canvas = canvas;
        m_rectTrans = rectTrans;
        CalculateClip();
    }

    public void Clip(RectTransform rectTrans){
        m_canvas = null;
        m_rectTrans = rectTrans;
        CalculateClip();
    }

    void CalculateClip(){
        m_canvasScale = 1;
        if (m_canvas)
        {
            m_canvasScale = m_canvas.localScale.x;
        }
        m_halfWidth = m_rectTrans.sizeDelta.x * 0.5f * m_canvasScale;
        m_halfHeight = m_rectTrans.sizeDelta.y * 0.5f * m_canvasScale;
        Vector4 area = CalculateArea(m_rectTrans.position);
        Debug.Log(area.ToString());
        var particleSystems = GetComponentsInChildren<ParticleSystem>();
        for(int i = 0, j = particleSystems.Length; i < j ; i++) {
            var ps = particleSystems[i];
            var mat = ps.GetComponent<Renderer>().material;
            mat.SetVector("_Area", area);
        }
 
        var renders = GetComponentsInChildren<MeshRenderer>();
        for(int i = 0, j = renders.Length; i < j; i++) {
            var ps = renders[i];
            var mat_list = ps.materials;
            int mat_length = mat_list.Length;
            for (int k = 0; k < mat_length; k++)
            {
                var mat = mat_list[k];
                mat.SetVector("_Area", area);
            }
        }
    }

    //计算容器在世界坐标的Vector4，x   z为左右边界的值，yw为下上边界值
    Vector4 CalculateArea(Vector3 position) {
        return new Vector4() {
            x = position.x - m_halfWidth,
            y = position.y - m_halfHeight,
            z = position.x + m_halfWidth,
            w = position.y + m_halfHeight
        };
    }

    private void Update()
    {
        if (m_rectTrans)
        {
            CalculateClip();
        }
    }
}
