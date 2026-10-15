#import <Cocoa/Cocoa.h>
#import <ApplicationServices/ApplicationServices.h>
#import "lume-shortcut.h"
static CFMachPortRef tap; static BOOL down=NO, enabled=NO, swallowSpace=NO; static BOOL lastSpace=NO; static AXUIElementRef targetElement=NULL; static pid_t targetPID=0;
static void emit(NSDictionary *v){ NSData *d=[NSJSONSerialization dataWithJSONObject:v options:0 error:nil]; @synchronized(NSProcessInfo.processInfo){fwrite(d.bytes,1,d.length,stdout);fputc('\n',stdout);fflush(stdout);} }
static AXUIElementRef focused(pid_t pid){AXUIElementRef a=AXUIElementCreateApplication(pid); CFTypeRef e=NULL; AXUIElementCopyAttributeValue(a,kAXFocusedUIElementAttribute,&e);CFRelease(a);return (AXUIElementRef)e;}
static void arm(void){targetPID=NSWorkspace.sharedWorkspace.frontmostApplication.processIdentifier;if(targetElement)CFRelease(targetElement);targetElement=focused(targetPID);}
static CGEventRef callback(CGEventTapProxy proxy,CGEventType type,CGEventRef ev,void *ctx){
 if(type==kCGEventTapDisabledByTimeout||type==kCGEventTapDisabledByUserInput){down=NO;emit(@{@"event":@"cancel"});CGEventTapEnable(tap,true);return ev;}
 if(type==kCGEventFlagsChanged && CGEventGetIntegerValueField(ev,kCGKeyboardEventKeycode)==63){BOOL now=(CGEventGetFlags(ev)&kCGEventFlagMaskSecondaryFn)!=0;if(now!=down){down=now;arm();emit(@{@"event":now?@"fn-down":@"fn-up",@"pid":@(targetPID),@"appName":NSWorkspace.sharedWorkspace.frontmostApplication.localizedName?:@"",@"bundleId":NSWorkspace.sharedWorkspace.frontmostApplication.bundleIdentifier?:@""});}}
 if(type==kCGEventKeyUp && CGEventGetIntegerValueField(ev,kCGKeyboardEventKeycode)==49 && swallowSpace){swallowSpace=NO;return NULL;}
 if(type==kCGEventKeyDown && CGEventGetIntegerValueField(ev,kCGKeyboardEventKeycode)==49 && lumeShouldLatch(enabled,down,(CGEventGetFlags(ev)&kCGEventFlagMaskSecondaryFn)!=0)){swallowSpace=YES;if(!CGEventGetIntegerValueField(ev,kCGKeyboardEventAutorepeat))emit(@{@"event":@"fn-space"});return NULL;}
 if(type==kCGEventKeyDown && CGEventGetIntegerValueField(ev,kCGKeyboardEventKeycode)==53)emit(@{@"event":@"cancel"});return ev;
}
static void pollShortcut(void){
 BOOL space=CGEventSourceKeyState(kCGEventSourceStateHIDSystemState,49);
 BOOL fn=down || ((CGEventSourceFlagsState(kCGEventSourceStateHIDSystemState)&kCGEventFlagMaskSecondaryFn)!=0);
 if(enabled && fn && space && !lastSpace)emit(@{@"event":@"fn-space"});
 lastSpace=space;
}
static void status(void){emit(@{@"event":@"status",@"accessibility":@(AXIsProcessTrusted()),@"fn":@(tap!=NULL),@"pid":@(NSWorkspace.sharedWorkspace.frontmostApplication.processIdentifier)});}
static void connectTap(void){if(!tap) {tap=CGEventTapCreate(kCGHIDEventTap,kCGHeadInsertEventTap,kCGEventTapOptionDefault,CGEventMaskBit(kCGEventFlagsChanged)|CGEventMaskBit(kCGEventKeyDown)|CGEventMaskBit(kCGEventKeyUp),callback,NULL);if(tap){CFRunLoopSourceRef s=CFMachPortCreateRunLoopSource(NULL,tap,0);CFRunLoopAddSource(CFRunLoopGetMain(),s,kCFRunLoopCommonModes);CFRelease(s);CGEventTapEnable(tap,true);}}status();}
static void command(NSDictionary *c){NSString *op=c[@"op"];if([op isEqual:@"shortcuts"]){enabled=[c[@"enabled"] boolValue];return;}if([op isEqual:@"status"]){connectTap();return;}if([op isEqual:@"arm"]){arm();emit(@{@"event":@"armed",@"pid":@(targetPID),@"appName":NSWorkspace.sharedWorkspace.frontmostApplication.localizedName?:@"",@"bundleId":NSWorkspace.sharedWorkspace.frontmostApplication.bundleIdentifier?:@""});return;}
 if([op isEqual:@"paste"]){NSString *ident=c[@"id"]?:@"",*text=c[@"text"];pid_t expected=[c[@"pid"] intValue];AXUIElementRef current=focused(expected);BOOL same=current&&targetElement&&CFEqual(current,targetElement);if(current)CFRelease(current);
 NSString *reason=nil;if(!AXIsProcessTrusted())reason=@"Permissão de Acessibilidade ausente";else if(expected!=targetPID||NSWorkspace.sharedWorkspace.frontmostApplication.processIdentifier!=expected||!same)reason=@"O campo de destino mudou. Texto salvo no histórico.";else if(![text isKindOfClass:NSString.class]||text.length>100000)reason=@"Texto inválido";
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
