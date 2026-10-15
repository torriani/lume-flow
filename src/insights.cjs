const CATEGORIES={ai_prompt:'Prompts de IA',personal_message:'Mensagens pessoais',work_message:'Mensagens de trabalho',document:'Documentos',email:'E-mails',other:'Outras tarefas'};
function words(t){return (String(t||'').match(/[\p{L}\p{N}]+(?:['’-][\p{L}\p{N}]+)*/gu)||[]).length;}
function classify(app='',text='',hint=''){
 const a=app.toLowerCase(),t=text.toLowerCase();
 if(/codex|claude|cursor|chatgpt|windsurf|copilot|visual studio code|vscode/.test(a))return {category:'ai_prompt',source:'aplicativo'};
 const mapped={work:'work_message',personal:'personal_message',email:'email',document:'document',ai:'ai_prompt'}[hint];if(mapped)return {category:mapped,source:'preferência importada'};
 if(/outlook|mail|spark|gmail/.test(a))return {category:'email',source:'aplicativo'};
 if(/slack|teams/.test(a))return {category:'work_message',source:'aplicativo'};
 if(/whatsapp|telegram|messages|mensagens/.test(a))return {category:'personal_message',source:'aplicativo'};
 if(/pages|word|notion|obsidian/.test(a))return {category:'document',source:'aplicativo'};
 if(/\b(implemente|refatore|crie um|gere um|analise|corrija o código|escreva um prompt)\b/u.test(t))return {category:'ai_prompt',source:'regra de texto'};
 return {category:'other',source:'sem contexto suficiente'};
}
function ordinal(date){return Math.floor(Date.UTC(date.getFullYear(),date.getMonth(),date.getDate())/86400000);}
function summarize(rows,{days=30,source='all',category='all',now=new Date()}={}){
 const today=ordinal(now);const valid=rows.filter(r=>Number.isFinite(new Date(r.created_at).getTime())&&(source==='all'||r.source===source)&&(category==='all'||r.category===category));
 const selected=valid.filter(r=>days===0||(ordinal(new Date(r.created_at))>=today-days+1&&ordinal(new Date(r.created_at))<=today));
 const total=selected.reduce((a,r)=>a+(Number(r.word_count)||0),0);const timed=selected.filter(r=>r.duration_ms>0);const duration=timed.reduce((a,r)=>a+r.duration_ms,0);const timedWords=timed.reduce((a,r)=>a+r.word_count,0);
 const groups=Object.keys(CATEGORIES).map(key=>({key,label:CATEGORIES[key],count:selected.filter(r=>r.category===key).length,words:selected.filter(r=>r.category===key).reduce((a,r)=>a+r.word_count,0)})).sort((a,b)=>b.count-a.count);
 const dates=[...new Set(valid.filter(r=>r.word_count>0).map(r=>ordinal(new Date(r.created_at))))].sort((a,b)=>a-b);let longest=0,run=0,previous=null;for(const d of dates){run=d===previous+1?run+1:1;longest=Math.max(longest,run);previous=d;}const set=new Set(dates);let current=0,day=set.has(today)?today:today-1;while(set.has(day--))current++;
 const byDay=new Map();for(const r of valid){const d=ordinal(new Date(r.created_at));const v=byDay.get(d)||{words:0,count:0};v.words+=r.word_count;v.count++;byDay.set(d,v);}const calendar=[];let start=today-181;start-=new Date(start*86400000).getUTCDay();const streakEnd=set.has(today)?today:today-1;for(let d=start;d<=today;d++){const v=byDay.get(d)||{words:0,count:0};calendar.push({date:new Date(d*86400000).toISOString().slice(0,10),...v,streak:current>0&&d>=streakEnd-current+1&&d<=streakEnd});}
 const recent=valid.filter(r=>ordinal(new Date(r.created_at))>=today-29&&ordinal(new Date(r.created_at))<=today).reduce((a,r)=>a+r.word_count,0);const prior=valid.filter(r=>{const d=ordinal(new Date(r.created_at));return d>=today-59&&d<today-29;}).reduce((a,r)=>a+r.word_count,0);
 return {words:total,count:selected.length,wpm:duration?Math.round(timedWords/(duration/60000)):null,duration_ms:duration,wordsCorrected:selected.reduce((a,r)=>a+(r.words_corrected||0),0),dictionaryFixes:selected.reduce((a,r)=>a+(r.dictionary_fixes||0),0),apps:new Set(selected.map(r=>r.app_name).filter(Boolean)).size,groups,current,longest,calendar,change:prior?Math.round((recent-prior)/prior*100):null,imported:selected.filter(r=>r.source==='wispr').length,first:valid.length?valid.reduce((a,r)=>a<r.created_at?a:r.created_at,valid[0].created_at):null};
}
module.exports={words,classify,summarize,CATEGORIES};
