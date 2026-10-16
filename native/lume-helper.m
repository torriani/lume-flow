#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import "lume-shortcut.h"
#import "lume-paste-target.h"
static CFMachPortRef tap; static BOOL down=NO, enabled=NO, swallowSpace=NO; static BOOL lastSpace=NO, reconcileFn=NO; static AXUIElementRef targetElement=NULL; static pid_t targetPID=0; static AXUIElementRef targetWindow=NULL; static NSString *targetSession=nil;
static void emit(NSDictionary *v){ NSData *d=[NSJSONSerialization dataWithJSONObject:v options:0 error:nil]; @synchronized(NSProcessInfo.processInfo){fwrite(d.bytes,1,d.length,stdout);fputc('\n',stdout);fflush(stdout);} }
static AXUIElementRef attribute(pid_t pid, CFStringRef name){
 AXUIElementRef a=AXUIElementCreateApplication(pid); AXUIElementSetMessagingTimeout(a,0.5);
 AXUIElementSetAttributeValue(a,CFSTR("AXManualAccessibility"),kCFBooleanTrue);
 CFTypeRef value=NULL; AXUIElementCopyAttributeValue(a,name,&value); CFRelease(a);
 if(value && CFGetTypeID(value)!=AXUIElementGetTypeID()){CFRelease(value);return NULL;}
 return (AXUIElementRef)value;
}
static AXUIElementRef focused(pid_t pid){return attribute(pid,kAXFocusedUIElementAttribute);}
static void arm(NSString *ident){targetPID=NSWorkspace.sharedWorkspace.frontmostApplication.processIdentifier;
 if(targetElement)CFRelease(targetElement);if(targetWindow)CFRelease(targetWindow);
 targetElement=focused(targetPID);targetWindow=attribute(targetPID,kAXFocusedWindowAttribute);targetSession=ident;
}
static NSDictionary *frontInfo(NSString *event){NSRunningApplication *a=NSWorkspace.sharedWorkspace.frontmostApplication;
 return @{@"event":event,@"pid":@(a.processIdentifier),@"appName":a.localizedName?:@"",@"bundleId":a.bundleIdentifier?:@""};}
static void locate(NSString *ident){pid_t pid=NSWorkspace.sharedWorkspace.frontmostApplication.processIdentifier;
 AXUIElementRef w=attribute(pid,kAXFocusedWindowAttribute);CFTypeRef pos=NULL,size=NULL;CGPoint p;CGSize z;
 if(w && AXUIElementCopyAttributeValue(w,kAXPositionAttribute,&pos)==kAXErrorSuccess && AXUIElementCopyAttributeValue(w,kAXSizeAttribute,&size)==kAXErrorSuccess && CFGetTypeID(pos)==AXValueGetTypeID() && CFGetTypeID(size)==AXValueGetTypeID() && AXValueGetValue(pos,kAXValueCGPointType,&p) && AXValueGetValue(size,kAXValueCGSizeType,&z))emit(@{@"event":@"overlay-target",@"id":ident,@"bounds":@{@"x":@(p.x),@"y":@(p.y),@"width":@(z.width),@"height":@(z.height)}});
 if(pos)CFRelease(pos);if(size)CFRelease(size);if(w)CFRelease(w);
}
static CGEventRef callback(CGEventTapProxy proxy,CGEventType type,CGEventRef ev,void *ctx){
 if(type==kCGEventTapDisabledByTimeout||type==kCGEventTapDisabledByUserInput){reconcileFn=YES;emit(@{@"event":@"tap-recovered"});CGEventTapEnable(tap,true);return ev;}
 if(type==kCGEventFlagsChanged && CGEventGetIntegerValueField(ev,kCGKeyboardEventKeycode)==63){BOOL now=(CGEventGetFlags(ev)&kCGEventFlagMaskSecondaryFn)!=0;if(now!=down){down=now;dispatch_async(dispatch_get_main_queue(),^{emit(frontInfo(now?@"fn-down":@"fn-up"));});}}
 if(type==kCGEventKeyUp && CGEventGetIntegerValueField(ev,kCGKeyboardEventKeycode)==49 && swallowSpace){swallowSpace=NO;return NULL;}
 if(type==kCGEventKeyDown && CGEventGetIntegerValueField(ev,kCGKeyboardEventKeycode)==49 && lumeShouldLatch(enabled,down,(CGEventGetFlags(ev)&kCGEventFlagMaskSecondaryFn)!=0)){swallowSpace=YES;if(!CGEventGetIntegerValueField(ev,kCGKeyboardEventAutorepeat))dispatch_async(dispatch_get_main_queue(),^{emit(@{@"event":@"fn-space"});});return NULL;}
 if(type==kCGEventKeyDown && CGEventGetIntegerValueField(ev,kCGKeyboardEventKeycode)==53)emit(@{@"event":@"cancel",@"reason":@"escape"});return ev;
}
static void pollShortcut(void){
 BOOL space=CGEventSourceKeyState(kCGEventSourceStateHIDSystemState,49);
 BOOL physicalFn=(CGEventSourceFlagsState(kCGEventSourceStateHIDSystemState)&kCGEventFlagMaskSecondaryFn)!=0;
 if(reconcileFn && down && !physicalFn){down=NO;emit(frontInfo(@"fn-up"));}
 reconcileFn=NO;
 BOOL fn=down || physicalFn;
 if(enabled && fn && space && !lastSpace)emit(@{@"event":@"fn-space"});
 lastSpace=space;
}
static void status(void){emit(@{@"event":@"status",@"accessibility":@(AXIsProcessTrusted()),@"fn":@(tap!=NULL),@"pid":@(NSWorkspace.sharedWorkspace.frontmostApplication.processIdentifier)});}
static void connectTap(void){if(!tap) {tap=CGEventTapCreate(kCGHIDEventTap,kCGHeadInsertEventTap,kCGEventTapOptionDefault,CGEventMaskBit(kCGEventFlagsChanged)|CGEventMaskBit(kCGEventKeyDown)|CGEventMaskBit(kCGEventKeyUp),callback,NULL);if(tap){CFRunLoopSourceRef s=CFMachPortCreateRunLoopSource(NULL,tap,0);CFRunLoopAddSource(CFRunLoopGetMain(),s,kCFRunLoopCommonModes);CFRelease(s);CGEventTapEnable(tap,true);}}status();}
static void command(NSDictionary *c){NSString *op=c[@"op"];if([op isEqual:@"shortcuts"]){enabled=[c[@"enabled"] boolValue];return;}if([op isEqual:@"status"]){connectTap();return;}if([op isEqual:@"locate"]){locate(c[@"id"]?:@"");return;}if([op isEqual:@"arm"]){arm(c[@"id"]?:@"");NSMutableDictionary *info=[frontInfo(@"armed") mutableCopy];info[@"id"]=targetSession;info[@"pid"]=@(targetPID);emit(info);return;}
 if([op isEqual:@"paste"]){NSString *ident=c[@"id"]?:@"",*text=c[@"text"];pid_t expected=[c[@"pid"] intValue];AXUIElementRef current=focused(expected),window=attribute(expected,kAXFocusedWindowAttribute);
 BOOL sameApp=expected==targetPID&&NSWorkspace.sharedWorkspace.frontmostApplication.processIdentifier==expected;
 BOOL sameWindow=window&&targetWindow&&CFEqual(window,targetWindow);
 BOOL same=lumeTargetMatches(sameApp,sameWindow,targetElement!=NULL,current!=NULL,current&&targetElement&&CFEqual(current,targetElement));
 if(current)CFRelease(current);if(window)CFRelease(window);
 NSString *reason=nil;if(!AXIsProcessTrusted())reason=@"Permissão de Acessibilidade ausente";
 else if(![ident isEqual:targetSession])reason=@"Destino de outra sessão; texto salvo no histórico.";
 else if(!sameApp)reason=@"O aplicativo de destino mudou. Texto salvo no histórico.";
 else if(!sameWindow)reason=@"Janela de destino indisponível ou alterada. Texto salvo no histórico.";
 else if(!same)reason=@"O campo de destino mudou. Texto salvo no histórico.";
 else if(![text isKindOfClass:NSString.class]||text.length>100000)reason=@"Texto inválido";
 if(reason){emit(@{@"event":@"paste-result",@"id":ident,@"ok":@NO,@"reason":reason});return;}
 NSPasteboard *pb=NSPasteboard.generalPasteboard;NSMutableArray *saved=[NSMutableArray new];for(NSPasteboardItem *item in pb.pasteboardItems){NSPasteboardItem *copy=[NSPasteboardItem new];for(NSString *t in item.types){NSData *d=[item dataForType:t];if(d)[copy setData:d forType:t];}[saved addObject:copy];}
 [pb clearContents];[pb setString:text forType:NSPasteboardTypeString];NSInteger count=pb.changeCount;
 CGEventRef press=CGEventCreateKeyboardEvent(NULL,9,true),release=CGEventCreateKeyboardEvent(NULL,9,false);CGEventSetFlags(press,kCGEventFlagMaskCommand);CGEventSetFlags(release,kCGEventFlagMaskCommand);CGEventPost(kCGHIDEventTap,press);CGEventPost(kCGHIDEventTap,release);CFRelease(press);CFRelease(release);
 emit(@{@"event":@"paste-result",@"id":ident,@"ok":@YES,@"reason":@"Comando de colagem enviado; recebimento pelo aplicativo não verificado"});
 dispatch_after(dispatch_time(DISPATCH_TIME_NOW,700*NSEC_PER_MSEC),dispatch_get_main_queue(),^{if(pb.changeCount==count){[pb clearContents];[pb writeObjects:saved];}});
 }
}
int main(int argc,char **argv){@autoreleasepool{[NSApplication sharedApplication];[NSApp setActivationPolicy:NSApplicationActivationPolicyProhibited];if(argc>1 && !strcmp(argv[1],"--status")){status();return 0;}connectTap();
 [NSTimer scheduledTimerWithTimeInterval:0.01 repeats:YES block:^(NSTimer *timer){pollShortcut();}];
 dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED,0),^{char *line=NULL;size_t cap=0;while(getline(&line,&cap,stdin)>0){NSData *d=[[NSString stringWithUTF8String:line] dataUsingEncoding:NSUTF8StringEncoding];NSDictionary *c=[NSJSONSerialization JSONObjectWithData:d options:0 error:nil];if([c isKindOfClass:NSDictionary.class])dispatch_async(dispatch_get_main_queue(),^{command(c);});}free(line);dispatch_async(dispatch_get_main_queue(),^{[NSApp terminate:nil];});});[NSApp run];}return 0;}
