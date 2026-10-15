#ifndef LUME_SHORTCUT_H
#define LUME_SHORTCUT_H
#include <stdbool.h>
// macOS can strip the Fn flag from a Space key event. Keep the physical
// Fn state observed in flagsChanged until its matching release arrives.
static inline bool lumeShouldLatch(bool enabled, bool fnHeld, bool eventHasFn) {
    return enabled && (fnHeld || eventHasFn);
}
#endif
