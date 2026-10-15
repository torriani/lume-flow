const path=require('node:path');const {spawn}=require('node:child_process');
class Sounds{
 constructor(root,enabled=()=>true,launch=spawn,theme=()=>'classic'){this.theme=theme;this.root=root;this.enabled=enabled;this.launch=launch;this.session=null;}
 play(kind){if(!this.enabled()||!['start','stop'].includes(kind))return;const child=this.launch('/usr/bin/afplay',[path.join(this.root,'ui','sounds',(['soft','pop','glass'].includes(this.theme())?this.theme()+'-':'')+kind+'.wav')],{stdio:'ignore'});child.on('error',()=>{});child.unref();}
 start(id){if(this.session===id)return;this.session=id;this.play('start');}
 stop(id){if(this.session!==id)return;this.session=null;this.play('stop');}
 cancel(id){if(this.session===id)this.session=null;}
}
module.exports={Sounds};
