/*-------------------------------------------------------------------------
 *
 * atomic_visibility.h
 *	  Atomic visibility support.
 *
 *
 * Portions Copyright (c) 2024-2025, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 * src/include/access/atomic_visibility.h
 *
 *-------------------------------------------------------------------------
 */
#ifndef ATOMIC_VISIBILITY_H
#define ATOMIC_VISIBILITY_H

#include "c.h"
#include "utils/snapshot.h"

extern void WaitForPreparedXactsInSnapshot(TransactionId xid, Snapshot snapshot);

#endif							/* ATOMIC_VISIBILITY_H */
