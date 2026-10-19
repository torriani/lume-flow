// Public release discovery only. Never executes downloaded code or changes user data.
const REPO='https://github.com/torriani/lume-flow';
const API='https://api.github.com/repos/torriani/lume-flow/releases?per_page=30';
function version(value){const m=/^v?(\d+)\.(\d+)\.(\d+)(?:-preview\.\d+)?$/.exec(value||'');return m?m.slice(1,4).map(Number):null;}
function newer(a,b){const x=version(a),y=version(b);if(!x||!y)return false;for(let i=0;i<3;i++){if(x[i]!==y[i])return x[i]>y[i];}return false;}
function selectRelease(releases,current,arch){if(!['arm64','x64'].includes(arch)||!Array.isArray(releases))return null;return releases.filter(r=>!r.draft&&version(r.tag_name)&&newer(r.tag_name,current)).sort((a,b)=>newer(a.tag_name,b.tag_name)?-1:1).map(r=>{const v=version(r.tag_name).join('.');const name=`LumeFlow-${v}-mac-${arch}.zip`;const url=`${REPO}/releases/download/${r.tag_name}/${name}`;const asset=r.assets?.find(a=>a.name===name&&a.state==='uploaded'&&a.size>0&&a.browser_download_url===url);return asset?{version:v,url,page:`${REPO}/releases/tag/${r.tag_name}`,experimental:!!r.prerelease}:null;}).find(Boolean)||null;}
function createUpdateChecker({app,dialog,shell,isBusy,notify,fetchImpl=fetch,arch=process.arch}){
 let checking=false,pending=null,timer;
 async function check(manual=false){
  if(checking)return;
  if(isBusy()){if(manual)notify('Encerre o ditado ou aguarde a operação atual para buscar atualizações.');return;}
  checking=true;
  try{
   const response=await fetchImpl(API,{headers:{Accept:'application/vnd.github+json','User-Agent':'LumeFlow-update-check'},signal:AbortSignal.timeout(12000)});
   if(!response.ok)throw Error(`GitHub HTTP ${response.status}`);
   pending=selectRelease(await response.json(),app.getVersion(),arch);
   if(!pending){if(manual)notify(`LumeFlow ${app.getVersion()}: nenhuma versão mais nova disponível para este Mac.`);return;}
   if(isBusy())return; // keep pending until an idle interval
   await offer();
  }catch{if(manual)notify('Não foi possível consultar o GitHub. Verifique a conexão e tente novamente.');}
  finally{checking=false;}
 }
 async function offer(){
  if(!pending||isBusy())return;
  const release=pending;pending=null;
  const result=await dialog.showMessageBox({type:'info',title:'Atualização do LumeFlow',message:`LumeFlow ${release.version} disponível${release.experimental?' — prévia experimental':''}`,detail:`Versão instalada: ${app.getVersion()}. O download corresponde à arquitetura deste aplicativo (${arch}).\n\nEsta prévia não possui certificado Apple Developer: baixe, encerre o LumeFlow e substitua o aplicativo em Aplicativos. Seu histórico será preservado. O macOS poderá pedir novamente as permissões. A instalação ainda não é automática.`,buttons:['Baixar atualização','Agora não'],defaultId:0,cancelId:1,noLink:true});
  if(result.response===0)await shell.openExternal(release.url);
 }
 function start(){if(!app.isPackaged)return;let first=true;timer=setInterval(()=>{if(checking||isBusy())return;if(pending){checking=true;void offer().catch(()=>notify('Não foi possível abrir o download. Use Buscar atualizações no menu.')).finally(()=>{checking=false;});}else if(first){first=false;void check();}},15000);timer.unref?.();}
 function close(){clearInterval(timer);}
 return {check,start,close};
}
module.exports={version,newer,selectRelease,createUpdateChecker};
