const {contextBridge,ipcRenderer}=require('electron');
contextBridge.exposeInMainWorld('lume',{
 call:(op,data)=>ipcRenderer.invoke('lume:call',op,data),
 onState:fn=>{ipcRenderer.on('lume:state',(_e,d)=>fn(d));},
 onCapture:fn=>{ipcRenderer.on('lume:capture',(_e,d)=>fn(d));},
 audio:(id,pcm,rms,seq)=>ipcRenderer.send('lume:audio',{id,pcm,rms,seq}),
 captureEvent:(kind,id,detail)=>ipcRenderer.send('lume:capture-event',{kind,id,detail})
});
