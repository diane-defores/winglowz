package com.winflowz_app.winflowz_app.ime.actions

import com.winflowz_app.winflowz_app.ime.KeyboardRowSpec

class KeyboardActionRenderer {
    fun renderRows(snapshot: KeyboardActionRenderSnapshot): List<KeyboardRowSpec> {
        val rows = mutableListOf<KeyboardRowSpec>()
        rows.add(renderRow(snapshot.mainRow))
        snapshot.attachedRows.forEach { row -> rows.add(renderRow(row)) }
        return rows
    }

    private fun renderRow(row: KeyboardActionRowSpec): KeyboardRowSpec {
        return KeyboardRowSpec(
            rowId = row.rowId,
            keys =
                row.items.map { item ->
                    if (row.actionSurface) {
                        item.copy(actionSurface = true)
                    } else {
                        item
                    }
                },
            horizontalScrollable = row.visiblePageKeyCount != null || row.pagedHorizontal,
            pagedHorizontalScrollable = row.pagedHorizontal,
            visiblePageKeyCount = row.visiblePageKeyCount,
        )
    }
}
