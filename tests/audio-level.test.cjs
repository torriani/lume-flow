const test=require('node:test'),assert=require('node:assert/strict');
const {preparePCM}=require('../src/audio-level.cjs');
test('voz baixa é amplificada sem alterar o áudio original ou duração',()=>{
 const b=Buffer.alloc(32000);for(let i=0;i<16000;i++)b.writeInt16LE(Math.round(80*Math.sin(i*.2)),i*2);
 const before=Buffer.from(b),out=preparePCM(b);assert.deepEqual(b,before);assert.equal(out.length,b.length);
 assert.ok(Math.abs(out.readInt16LE(20))>Math.abs(b.readInt16LE(20))*10);
});
test('silêncio continua silêncio e picos não saturam',()=>{
 const zero=Buffer.alloc(32000);assert.deepEqual(preparePCM(zero),zero);
 const b=Buffer.alloc(32000);b.writeInt16LE(29000,0);const out=preparePCM(b);
 assert.ok(out.readInt16LE(0)<=29490);assert.ok(out.readInt16LE(0)>=29000);
 b.writeInt16LE(-32768,0);assert.deepEqual(preparePCM(b),b);
});
