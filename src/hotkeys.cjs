// One recording gesture: hold Fn, or latch with Fn+Space and finish with Fn.
class Hotkeys {
 constructor(){this.reset();}
 reset(){this.active=false;this.locked=false;}
 handle(event){if(event==='fn-down'){if(this.active&&this.locked){this.reset();return 'stop';}if(!this.active){this.active=true;return 'start';}}
 if(event==='fn-space'&&this.active){this.locked=true;return 'lock';}
 if(event==='fn-up'&&this.active&&!this.locked){this.reset();return 'stop';}
 return null;}
}
module.exports={Hotkeys};
