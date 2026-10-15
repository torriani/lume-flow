class PCM extends AudioWorkletProcessor {
 constructor(){super();this.data=[];this.sum=0;this.port.onmessage=e=>{if(e.data==='flush'){this.flush();this.port.postMessage({done:true});}};}
 flush(){if(!this.data.length)return;const pcm=new Int16Array(this.data.length);for(let i=0;i<pcm.length;i++)pcm[i]=Math.round(Math.max(-1,Math.min(1,this.data[i]))*32767);this.port.postMessage({pcm:pcm.buffer,rms:Math.sqrt(this.sum/this.data.length)},[pcm.buffer]);this.data=[];this.sum=0;}
 process(inputs){const x=inputs[0]?.[0];if(x){for(const n of x){this.data.push(n);this.sum+=n*n;}if(this.data.length>=2048)this.flush();}return true;}
}registerProcessor('pcm',PCM);
