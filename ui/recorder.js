let active=null;
async function close(s){s.stream?.getTracks().forEach(t=>t.stop());s.node?.disconnect();await s.context?.close().catch(()=>{});if(active===s)active=null;}
window.lume.onCapture(async d=>{
 if(d.op==='start'){
  if(active)return;const s={id:d.id,seq:0,stop:false,cancel:false};active=s;
  try{if(!d.testPCM)s.stream=await navigator.mediaDevices.getUserMedia({audio:{channelCount:1,sampleRate:16000,echoCancellation:false,noiseSuppression:false,autoGainControl:false}});if(s.cancel){await close(s);return;}
   s.context=new AudioContext({sampleRate:16000});if(s.context.sampleRate!==16000)throw Error('Taxa de áudio incompatível');await s.context.audioWorklet.addModule('audio-worklet.js');if(s.cancel){await close(s);return;}
   s.node=new AudioWorkletNode(s.context,'pcm');if(d.testPCM){const pcm=new Int16Array(new Uint8Array(d.testPCM).buffer);const buffer=s.context.createBuffer(1,pcm.length,16000);const channel=buffer.getChannelData(0);for(let i=0;i<pcm.length;i++)channel[i]=pcm[i]/32768;s.source=s.context.createBufferSource();s.source.buffer=buffer;}else s.source=s.context.createMediaStreamSource(s.stream);s.source.connect(s.node);const mute=s.context.createGain();mute.gain.value=0;s.node.connect(mute).connect(s.context.destination);
   if(s.stream)s.stream.getAudioTracks()[0].onended=()=>{if(!s.stop&&!s.cancel){window.lume.captureEvent('error',s.id,'Microfone desconectado');close(s);}};
   s.node.port.onmessage=async e=>{if(e.data.done){await close(s);if(!s.cancel)window.lume.captureEvent('done',s.id);}else if(!s.cancel)window.lume.audio(s.id,e.data.pcm,e.data.rms,s.seq++);};
   await s.context.resume();if(d.testPCM)s.source.start();if(s.cancel){await close(s);return;}window.lume.captureEvent('ready',s.id);if(s.stop)s.node.port.postMessage('flush');
  }catch(e){await close(s);if(!s.cancel)window.lume.captureEvent('error',s.id,e.message);}
 }else if(active?.id===d.id){const s=active;s.stop=true;if(d.op==='cancel'){s.cancel=true;await close(s);}else if(s.node)s.node.port.postMessage('flush');}
});
