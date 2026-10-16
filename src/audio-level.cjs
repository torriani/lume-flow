// Normalize only the recognition copy. The original WAV is never modified.
function preparePCM(pcm){
 let peak=0,sum=0;const count=pcm.length/2;
 for(let i=0;i<pcm.length;i+=2){const v=pcm.readInt16LE(i);peak=Math.max(peak,Math.abs(v));sum+=v*v;}
 if(!count||!peak)return pcm;
 const rms=Math.sqrt(sum/count)/32768;
 const gain=Math.min(24,0.04/rms,29490/peak);
 if(gain<=1)return pcm;
 const result=Buffer.alloc(pcm.length);
 for(let i=0;i<pcm.length;i+=2)result.writeInt16LE(Math.round(pcm.readInt16LE(i)*gain),i);
 return result;
}
module.exports={preparePCM};
