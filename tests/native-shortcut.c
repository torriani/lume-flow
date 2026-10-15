#include <assert.h>
#include "../native/lume-shortcut.h"
int main(void){
 assert(lumeShouldLatch(true,true,false)); // Fn stripped from Space event
 assert(lumeShouldLatch(true,true,true));
 assert(lumeShouldLatch(true,false,true));
 assert(!lumeShouldLatch(true,false,false)); // ordinary Space
 assert(!lumeShouldLatch(false,true,true)); // disabled shortcut
 return 0;
}
