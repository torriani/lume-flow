#ifndef LUME_PASTE_TARGET_H
#define LUME_PASTE_TARGET_H
#include <stdbool.h>
// Unknown AX fields may fall back only to the same known window and app.
static inline bool lumeTargetMatches(bool sameApp, bool sameWindow, bool hasTarget, bool hasCurrent, bool sameField) {
 return sameApp && sameWindow && (!(hasTarget && hasCurrent) || sameField);
}
#endif
