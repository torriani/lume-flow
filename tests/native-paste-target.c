#include <assert.h>
#include "../native/lume-paste-target.h"
int main(void){
 assert(lumeTargetMatches(1,1,1,1,1));
 assert(!lumeTargetMatches(0,1,1,1,1));
 assert(!lumeTargetMatches(1,0,1,1,1));
 assert(!lumeTargetMatches(1,1,1,1,0));
 assert(lumeTargetMatches(1,1,0,1,0));
 assert(lumeTargetMatches(1,1,1,0,0));
 assert(!lumeTargetMatches(1,0,0,0,0));
 return 0;
}
