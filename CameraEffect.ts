import { ZepetoScriptBehaviour } from 'ZEPETO.Script'
import *as UnityEngine from 'UnityEngine';

export default class CamearaEffect extends ZepetoScriptBehaviour {

    @SerializeField() private cameraMtrl:UnityEngine.Material;
    Start()
    {
        const cam = this.GetComponent<UnityEngine.Camera>();
        cam.depthTextureMode = UnityEngine.DepthTextureMode.Depth;

    }

    OnRenderImage(_src:UnityEngine.RenderTexture,  _dest:UnityEngine.RenderTexture)
    {
        UnityEngine.Graphics.Blit(  _src, _dest,this.cameraMtrl);

    }
}