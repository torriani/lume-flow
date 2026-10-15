const fs = require('node:fs');
function wavHeader(bytes,rate=16000){const b=Buffer.alloc(44);b.write('RIFF');b.writeUInt32LE(bytes+36,4);b.write('WAVEfmt ',8);b.writeUInt32LE(16,16);b.writeUInt16LE(1,20);b.writeUInt16LE(1,22);b.writeUInt32LE(rate,24);b.writeUInt32LE(rate*2,28);b.writeUInt16LE(2,32);b.writeUInt16LE(16,34);b.write('data',36);b.writeUInt32LE(bytes,40);return b;}
class Recording {constructor(file){this.fd=fs.openSync(file,'wx',0o600);this.bytes=0;fs.writeSync(this.fd,wavHeader(0));}append(b){if(this.fd===null)throw Error('Gravação encerrada');fs.writeSync(this.fd,b);this.bytes+=b.length;fs.writeSync(this.fd,wavHeader(this.bytes),0,44,0);}close(){if(this.fd!==null){fs.fsyncSync(this.fd);fs.closeSync(this.fd);this.fd=null;}}}
const escape=s=>s.replace(/[.*+?^${}()|[\]\\]/g,'\\$&');
function correct(text,rules,onChange=()=>{}){const sorted=rules.filter(r=>r.heard&&r.replacement).sort((a,b)=>b.heard.length-a.heard.length);if(!sorted.length)return text;const map=new Map(sorted.map(r=>[r.heard.toLocaleLowerCase('pt-BR'),r.replacement]));const re=new RegExp('(?<![\\p{L}\\p{N}_])(?:'+sorted.map(r=>escape(r.heard)).join('|')+')(?![\\p{L}\\p{N}_])','giu');return text.replace(re,m=>{const replacement=map.get(m.toLocaleLowerCase('pt-BR'))??m;if(replacement!==m)onChange(m,replacement);return replacement;});}
function format(text,rules=[],mode='natural',style='casual',cleanup='none'){
 let t=correct(text.trim(),rules).replace(/\s+/g,' ');
 if(cleanup!=='none')t=t.replace(/\b(?:ahn|humm|ééé)\b[, ]*/giu,'').replace(/\b(\p{L}+)\s+\1\b/giu,'$1');
 if(style==='formal')t=t.replace(/\bpra\b/giu,'para').replace(/\btô\b/giu,'estou').replace(/\btá\b/giu,'está');
 t=t.replace(/\b(?:novo parágrafo|nova linha)\b[,.]?\s*/giu,'\n\n').replace(/\b(?:próximo tópico|novo tópico)\b[,:.]?\s*/giu,'\n• ');
 t=t.replace(/\s+([,.;!?])/g,'$1').replace(/([^\n])[ \t]*\n/g,'$1\n').trim();
 if(mode==='lista')t=t.split(/(?<=[.!?])\s+|\n+/u).filter(Boolean).map(x=>'• '+x.replace(/^•\s*/,'' )).join('\n');
 t=t.replace(/(^|[.!?]\s+|\n(?:• )?)(\p{Ll})/gu,(_,a,b)=>a+b.toLocaleUpperCase('pt-BR'));
 if(t&&!/[.!?:;]$/.test(t)&&style!=='very_casual')t+='.';if(style==='very_casual'&&t.length<180&&!t.includes('\n'))t=t.replace(/\.$/,'');return t;
}
class SessionGate{constructor(){this.current=null;}begin(id){if(this.current)throw Error('Já existe um ditado ativo');this.current={id,state:'starting',cancelled:false,finished:false};return this.current;}matches(id){return this.current?.id===id&&!this.current.cancelled;}finish(id){if(!this.matches(id)||this.current.finished)return false;this.current.finished=true;this.current.state='processing';return true;}cancel(){if(this.current)this.current.cancelled=true;}clear(id){if(this.current?.id===id)this.current=null;}}
module.exports={Recording,wavHeader,correct,format,SessionGate};
