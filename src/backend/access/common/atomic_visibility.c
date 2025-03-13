/*-------------------------------------------------------------------------
 *
 * atomic_visibility.c
 *	  Atomic visibility support.
 *
 * Portions Copyright (c) 2024-2025, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 * IDENTIFICATION
 *	  src/backend/access/common/atomic_visibility.c
 *
 * This file provides an atomic visibility feature.
 *
 * Our approach to guarantee atomic visibility is to wait for prepared
 * transactions to finish. However, waiting for all prepared transactions is a
 * time-consuming task and leads to performance bottlenecks. We don't wait for
 * transactions that are not relevant to the query results and speed up atomic
 * visibility. To achieve this goal, we change the architecture of snapshots.
 * In the original snapshot, all transactions including prepared transactions
 * are marked as in progress when GetSnapshotData() is called. With our
 * modification, prepared transactions are treated as finished. Such
 * transactions are stored in the SnapshotData->x2pc[] array. When accessing
 * tuples, if xmin or xmax are in the array, we wait for those transactions to
 * finish. This approach eliminates waiting for transactions that do not
 * affect query results, so we can drastically improve performance.
 *
 *-------------------------------------------------------------------------
 */

#include "postgres.h"

#include "access/atomic_visibility.h"
#include "access/xact.h"
#include "port/pg_lfind.h"
#include "storage/lmgr.h"


/*
 * Returns true if we need to wait for the transaction according to the given
 * snapshot.
 */
static bool
ShouldWaitForTransaction(TransactionId xid, Snapshot snapshot)
{
	/*
	 * Callers of WaitForPreparedXactsInSnapshot must ensure that xid is in
	 * the snapshot.
	 */
	Assert(!TransactionIdPrecedes(xid, snapshot->xmin));
	Assert(!TransactionIdFollowsOrEquals(xid, snapshot->xmax));

	return pg_lfind32(xid, snapshot->x2pc, snapshot->x2pc_cnt);
}

/*
 * Wait for the given transaction.
 */
static void
WaitForTransaction(TransactionId xid)
{
	wlog(LOG, "Waiting XID %u", xid);
	XactLockTableWait(xid, NULL, NULL, XLTW_None);
	wlog(LOG, "Waited XID %u", xid);
}

/*
 * If necessary, wait for xmin and xmax according to the given MVCC snapshot.
 */
void
WaitForPreparedXactsInSnapshot(TransactionId xid, Snapshot snapshot)
{
	Assert(snapshot->snapshot_type == SNAPSHOT_MVCC ||
		   snapshot->snapshot_type == SNAPSHOT_HISTORIC_MVCC);
	if (ShouldWaitForTransaction(xid, snapshot))
		WaitForTransaction(xid);
}
