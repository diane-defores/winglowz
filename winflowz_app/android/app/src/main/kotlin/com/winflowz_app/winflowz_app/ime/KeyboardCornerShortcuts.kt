package com.winflowz_app.winflowz_app.ime

import org.json.JSONArray
import org.json.JSONObject

enum class KeyboardCornerSlot(val wireName: String) {
    Up("up"),
    Right("right"),
    Down("down"),
    Left("left"),
    TopLeft("topLeft"),
    TopRight("topRight"),
    BottomLeft("bottomLeft"),
    BottomRight("bottomRight"),
    ;

    companion object {
        fun fromWireName(raw: String?): KeyboardCornerSlot? {
            return values().firstOrNull { it.wireName.equals(raw, ignoreCase = true) || it.name.equals(raw, ignoreCase = true) }
        }

        fun fromSelection(selection: GestureSelection): KeyboardCornerSlot? {
            return when (selection) {
                GestureSelection.Up -> Up
                GestureSelection.Right -> Right
                GestureSelection.Down -> Down
                GestureSelection.Left -> Left
                GestureSelection.TopLeft -> TopLeft
                GestureSelection.TopRight -> TopRight
                GestureSelection.BottomLeft -> BottomLeft
                GestureSelection.BottomRight -> BottomRight
                GestureSelection.PrimaryTap,
                GestureSelection.Canceled,
                -> null
            }
        }

        val directionalSlots: List<KeyboardCornerSlot> = listOf(Up, Right, Down, Left)
        val cornerSlots: List<KeyboardCornerSlot> = listOf(TopLeft, TopRight, BottomLeft, BottomRight)
    }
}

typealias KeyboardGestureSlot = KeyboardCornerSlot

data class KeyboardCornerShortcut(
    val keyId: String,
    val slot: KeyboardCornerSlot,
    val expression: String,
    val label: String? = null,
    val sensitive: Boolean = false,
    val disabled: Boolean = false,
    val layoutProfiles: Set<KeyboardLayoutProfile>? = null,
) {
    fun parsedValue(): KeyboardKeyValue {
        return KeyboardKeyValueParser.parse(expression)
    }

    fun resolvedLabel(value: KeyboardKeyValue = parsedValue()): String {
        return label?.trim()?.takeIf { it.isNotEmpty() } ?: value.renderLabel()
    }

    fun toMap(): Map<String, Any?> {
        return mapOf(
            "keyId" to keyId,
            "slot" to slot.wireName,
            "expression" to expression,
            "label" to label,
            "sensitive" to sensitive,
            "disabled" to disabled,
        )
    }

    fun toJson(): JSONObject {
        return JSONObject()
            .put("keyId", keyId)
            .put("slot", slot.wireName)
            .put("expression", expression)
            .put("label", label)
            .put("sensitive", sensitive)
            .put("disabled", disabled)
    }

    companion object {
        fun fromMap(map: Map<*, *>): KeyboardCornerShortcut {
            val keyId = (map["keyId"] as? String).orEmpty().trim()
            val slot = KeyboardCornerSlot.fromWireName(map["slot"] as? String)
                ?: throw KeyboardCornerConfigException("Unknown corner slot '${map["slot"]}'")
            val expression = (map["expression"] as? String).orEmpty().trim()
            val label = (map["label"] as? String)?.trim()?.takeIf { it.isNotEmpty() }
            val sensitive = map["sensitive"] as? Boolean ?: false
            val disabled = map["disabled"] as? Boolean ?: false
            return KeyboardCornerShortcut(
                keyId = keyId,
                slot = slot,
                expression = expression,
                label = label,
                sensitive = sensitive,
                disabled = disabled,
            ).validated()
        }

        fun fromJson(json: JSONObject): KeyboardCornerShortcut {
            return fromMap(
                mapOf(
                    "keyId" to json.optString("keyId"),
                    "slot" to json.optString("slot"),
                    "expression" to json.optString("expression"),
                    "label" to json.optString("label").takeIf { it.isNotBlank() },
                    "sensitive" to json.optBoolean("sensitive", false),
                    "disabled" to json.optBoolean("disabled", false),
                ),
            )
        }
    }
}

data class KeyboardCornerAssignment(
    val slot: KeyboardGestureSlot,
    val value: KeyboardKeyValue,
    val label: String,
    val sensitive: Boolean = false,
)

data class KeyboardCornerAssignments(
    val up: KeyboardCornerAssignment? = null,
    val right: KeyboardCornerAssignment? = null,
    val down: KeyboardCornerAssignment? = null,
    val left: KeyboardCornerAssignment? = null,
    val topLeft: KeyboardCornerAssignment? = null,
    val topRight: KeyboardCornerAssignment? = null,
    val bottomLeft: KeyboardCornerAssignment? = null,
    val bottomRight: KeyboardCornerAssignment? = null,
) {
    fun isEmpty(): Boolean =
        up == null &&
            right == null &&
            down == null &&
            left == null &&
            topLeft == null &&
            topRight == null &&
            bottomLeft == null &&
            bottomRight == null

    fun forSelection(selection: GestureSelection): KeyboardCornerAssignment? {
        val slot = KeyboardCornerSlot.fromSelection(selection) ?: return null
        return forSlot(slot)
    }

    fun forSlot(slot: KeyboardGestureSlot): KeyboardCornerAssignment? {
        return when (slot) {
            KeyboardCornerSlot.Up -> up
            KeyboardCornerSlot.Right -> right
            KeyboardCornerSlot.Down -> down
            KeyboardCornerSlot.Left -> left
            KeyboardCornerSlot.TopLeft -> topLeft
            KeyboardCornerSlot.TopRight -> topRight
            KeyboardCornerSlot.BottomLeft -> bottomLeft
            KeyboardCornerSlot.BottomRight -> bottomRight
        }
    }

    companion object {
        val Empty = KeyboardCornerAssignments()

        fun from(assignments: List<KeyboardCornerAssignment>): KeyboardCornerAssignments {
            var up: KeyboardCornerAssignment? = null
            var right: KeyboardCornerAssignment? = null
            var down: KeyboardCornerAssignment? = null
            var left: KeyboardCornerAssignment? = null
            var topLeft: KeyboardCornerAssignment? = null
            var topRight: KeyboardCornerAssignment? = null
            var bottomLeft: KeyboardCornerAssignment? = null
            var bottomRight: KeyboardCornerAssignment? = null
            assignments.forEach { assignment ->
                when (assignment.slot) {
                    KeyboardCornerSlot.Up -> up = assignment
                    KeyboardCornerSlot.Right -> right = assignment
                    KeyboardCornerSlot.Down -> down = assignment
                    KeyboardCornerSlot.Left -> left = assignment
                    KeyboardCornerSlot.TopLeft -> topLeft = assignment
                    KeyboardCornerSlot.TopRight -> topRight = assignment
                    KeyboardCornerSlot.BottomLeft -> bottomLeft = assignment
                    KeyboardCornerSlot.BottomRight -> bottomRight = assignment
                }
            }
            return KeyboardCornerAssignments(
                up = up,
                right = right,
                down = down,
                left = left,
                topLeft = topLeft,
                topRight = topRight,
                bottomLeft = bottomLeft,
                bottomRight = bottomRight,
            )
        }
    }
}

data class KeyboardCornerPreset(
    val id: String,
    val name: String,
    val shortcuts: List<KeyboardCornerShortcut>,
) {
    fun toMap(): Map<String, Any?> {
        return mapOf(
            "id" to id,
            "name" to name,
        )
    }
}

data class KeyboardCornerConfig(
    val presetId: String = KeyboardCornerPresets.FRENCH_ACCENTS,
    val overrides: List<KeyboardCornerShortcut> = emptyList(),
) {
    fun withPreset(presetId: String): KeyboardCornerConfig {
        KeyboardCornerPresets.requirePreset(presetId)
        return copy(presetId = presetId)
    }

    fun validated(): KeyboardCornerConfig {
        KeyboardCornerPresets.requirePreset(presetId)
        if (overrides.size > MAX_OVERRIDES) {
            throw KeyboardCornerConfigException("Corner shortcut config is limited to $MAX_OVERRIDES overrides")
        }
        overrides.forEach { it.validated() }
        return this
    }

    fun toJson(): JSONObject {
        val array = JSONArray()
        overrides.forEach { shortcut -> array.put(shortcut.toJson()) }
        return JSONObject()
            .put("version", VERSION)
            .put("presetId", presetId)
            .put("overrides", array)
    }

    fun toMap(includePresets: Boolean = false): Map<String, Any?> {
        val map =
            mutableMapOf<String, Any?>(
                "version" to VERSION,
                "presetId" to presetId,
                "overrides" to overrides.map { it.toMap() },
            )
        if (includePresets) {
            map["availablePresets"] = KeyboardCornerPresets.all.map { it.toMap() }
        }
        return map
    }

    companion object {
        const val VERSION = 1
        const val MAX_OVERRIDES = 160
        const val MAX_EXPRESSION_LENGTH = 160
        const val MAX_LABEL_LENGTH = 18
        const val MAX_KEY_ID_LENGTH = 64

        fun fromMap(map: Map<*, *>): KeyboardCornerConfig {
            val presetId = (map["presetId"] as? String)?.trim().orEmpty().ifEmpty {
                KeyboardCornerPresets.FRENCH_ACCENTS
            }
            val overrides =
                (map["overrides"] as? List<*>)
                    .orEmpty()
                    .mapNotNull { item -> item as? Map<*, *> }
                    .map { KeyboardCornerShortcut.fromMap(it) }
            return KeyboardCornerConfig(
                presetId = presetId,
                overrides = overrides,
            ).validated()
        }

        fun fromJson(raw: String?): KeyboardCornerConfig {
            if (raw.isNullOrBlank() || raw.length > KeyboardStateStore.MAX_CORNER_CONFIG_JSON_LENGTH) {
                return KeyboardCornerConfig()
            }
            return runCatching {
                val json = JSONObject(raw)
                val presetId = json.optString("presetId", KeyboardCornerPresets.FRENCH_ACCENTS)
                val overridesArray = json.optJSONArray("overrides") ?: JSONArray()
                val overrides =
                    buildList {
                        for (index in 0 until overridesArray.length()) {
                            val item = overridesArray.optJSONObject(index) ?: continue
                            val shortcut = runCatching { KeyboardCornerShortcut.fromJson(item) }.getOrNull()
                            if (shortcut != null) {
                                add(shortcut)
                            }
                        }
                    }
                KeyboardCornerConfig(presetId = presetId, overrides = overrides).validated()
            }.getOrDefault(KeyboardCornerConfig())
        }
    }
}

class KeyboardCornerConfigException(message: String) : IllegalArgumentException(message)

object KeyboardCornerPresets {
    const val FRENCH_ACCENTS = "french_accents"
    const val PUNCTUATION = "punctuation_corners"
    const val FRENCH_PUNCTUATION = "french_accents_punctuation"
    const val DEVELOPER_SYMBOLS = "developer_symbols"
    const val NONE = "none"

    val all: List<KeyboardCornerPreset> =
        listOf(
            KeyboardCornerPreset(FRENCH_ACCENTS, "Smart French", smartFrenchShortcuts()),
            KeyboardCornerPreset(PUNCTUATION, "Punctuation + navigation", punctuationShortcuts()),
            KeyboardCornerPreset(FRENCH_PUNCTUATION, "French accents + punctuation", frenchAccentShortcuts() + punctuationShortcuts()),
            KeyboardCornerPreset(DEVELOPER_SYMBOLS, "Developer symbols", developerShortcuts()),
            KeyboardCornerPreset(NONE, "No gestures", emptyList()),
        )

    fun preset(id: String): KeyboardCornerPreset {
        return all.firstOrNull { it.id == id } ?: all.first { it.id == FRENCH_ACCENTS }
    }

    fun requirePreset(id: String) {
        if (all.none { it.id == id }) {
            throw KeyboardCornerConfigException("Unknown corner preset '$id'")
        }
    }

    private fun smartFrenchShortcuts(): List<KeyboardCornerShortcut> {
        return frenchAccentShortcuts() + punctuationShortcuts()
    }

    private fun frenchAccentShortcuts(): List<KeyboardCornerShortcut> {
        return listOf(
            shortcut("letter-a", KeyboardCornerSlot.TopLeft, "à"),
            shortcut("letter-a", KeyboardCornerSlot.TopRight, "â"),
            shortcut("letter-e", KeyboardCornerSlot.TopLeft, "é"),
            shortcut("letter-e", KeyboardCornerSlot.TopRight, "è"),
            shortcut("letter-e", KeyboardCornerSlot.BottomLeft, "ê"),
            shortcut("letter-e", KeyboardCornerSlot.BottomRight, "ë"),
            shortcut("letter-i", KeyboardCornerSlot.TopLeft, "î"),
            shortcut("letter-i", KeyboardCornerSlot.TopRight, "ï"),
            shortcut("letter-o", KeyboardCornerSlot.TopLeft, "ô"),
            shortcut("letter-o", KeyboardCornerSlot.TopRight, "œ"),
            shortcut("letter-u", KeyboardCornerSlot.TopLeft, "ù"),
            shortcut("letter-u", KeyboardCornerSlot.TopRight, "û"),
            shortcut("letter-u", KeyboardCornerSlot.BottomLeft, "ü"),
            shortcut("letter-c", KeyboardCornerSlot.TopLeft, "ç"),
        )
    }

    private fun punctuationShortcuts(): List<KeyboardCornerShortcut> {
        return listOf(
            shortcut("letter-r", KeyboardCornerSlot.Up, "1"),
            shortcut("letter-t", KeyboardCornerSlot.Up, "2"),
            shortcut("letter-y", KeyboardCornerSlot.Up, "3"),
            shortcut("letter-f", KeyboardCornerSlot.Up, "4"),
            shortcut("letter-g", KeyboardCornerSlot.Up, "5"),
            shortcut("letter-h", KeyboardCornerSlot.Up, "6"),
            shortcut("letter-x", KeyboardCornerSlot.Up, "7"),
            shortcut("letter-c", KeyboardCornerSlot.Up, "8"),
            shortcut("letter-v", KeyboardCornerSlot.Up, "9"),
            shortcut("letter-b", KeyboardCornerSlot.Up, "0"),
            shortcut(
                "letter-w",
                KeyboardCornerSlot.Up,
                "action:NavigateLineUp",
                label = "↑",
                layoutProfiles = setOf(KeyboardLayoutProfile.QWERTY),
            ),
            shortcut(
                "letter-w",
                KeyboardCornerSlot.Down,
                "action:NavigateLineDown",
                label = "↓",
                layoutProfiles = setOf(KeyboardLayoutProfile.QWERTY),
            ),
            shortcut(
                "letter-z",
                KeyboardCornerSlot.Up,
                "action:NavigateLineUp",
                label = "↑",
                layoutProfiles = setOf(KeyboardLayoutProfile.AZERTY),
            ),
            shortcut(
                "letter-z",
                KeyboardCornerSlot.Down,
                "action:NavigateLineDown",
                label = "↓",
                layoutProfiles = setOf(KeyboardLayoutProfile.AZERTY),
            ),
            shortcut("letter-s", KeyboardCornerSlot.Left, "action:NavigateCharLeft", label = "←"),
            shortcut("letter-s", KeyboardCornerSlot.Right, "action:NavigateCharRight", label = "→"),
            shortcut("letter-n", KeyboardCornerSlot.TopLeft, "-"),
            shortcut("letter-n", KeyboardCornerSlot.TopRight, "_"),
            shortcut("letter-j", KeyboardCornerSlot.TopLeft, ","),
            shortcut("letter-j", KeyboardCornerSlot.TopRight, "."),
            shortcut("letter-j", KeyboardCornerSlot.BottomLeft, "?"),
            shortcut("letter-j", KeyboardCornerSlot.BottomRight, "!"),
            shortcut("letter-k", KeyboardCornerSlot.TopLeft, "'\\''", label = "'"),
            shortcut("letter-k", KeyboardCornerSlot.TopRight, "\""),
            shortcut("letter-k", KeyboardCornerSlot.BottomLeft, "("),
            shortcut("letter-k", KeyboardCornerSlot.BottomRight, ")"),
            shortcut("letter-l", KeyboardCornerSlot.TopLeft, ":"),
            shortcut("letter-l", KeyboardCornerSlot.TopRight, ";"),
            shortcut("letter-l", KeyboardCornerSlot.BottomLeft, "\$"),
            shortcut("letter-l", KeyboardCornerSlot.BottomRight, "€"),
        )
    }

    private fun developerShortcuts(): List<KeyboardCornerShortcut> {
        return listOf(
            shortcut("letter-f", KeyboardCornerSlot.TopLeft, "/"),
            shortcut("letter-f", KeyboardCornerSlot.TopRight, "\\"),
            shortcut("letter-f", KeyboardCornerSlot.BottomLeft, "|"),
            shortcut("letter-f", KeyboardCornerSlot.BottomRight, "~"),
            shortcut("letter-g", KeyboardCornerSlot.TopLeft, "{"),
            shortcut("letter-g", KeyboardCornerSlot.TopRight, "}"),
            shortcut("letter-g", KeyboardCornerSlot.BottomLeft, "["),
            shortcut("letter-g", KeyboardCornerSlot.BottomRight, "]"),
            shortcut("letter-h", KeyboardCornerSlot.TopLeft, "<"),
            shortcut("letter-h", KeyboardCornerSlot.TopRight, ">"),
            shortcut("letter-h", KeyboardCornerSlot.BottomLeft, "="),
            shortcut("letter-h", KeyboardCornerSlot.BottomRight, "_"),
        )
    }

    private fun shortcut(
        keyId: String,
        slot: KeyboardCornerSlot,
        expression: String,
        label: String? = null,
        sensitive: Boolean = false,
        layoutProfiles: Set<KeyboardLayoutProfile>? = null,
    ): KeyboardCornerShortcut {
        return KeyboardCornerShortcut(
            keyId = keyId,
            slot = slot,
            expression = expression,
            label = label,
            sensitive = sensitive,
            layoutProfiles = layoutProfiles,
        )
    }
}

object KeyboardCornerShortcutResolver {
    private val sensitiveActions =
        setOf(
            KeyboardKeyAction.CopySelection,
            KeyboardKeyAction.CutSelection,
            KeyboardKeyAction.PasteClipboard,
            KeyboardKeyAction.PastePlainClipboard,
            KeyboardKeyAction.InsertClipboardEntry,
            KeyboardKeyAction.ShowClipboardPins,
            KeyboardKeyAction.InsertSnippetOne,
            KeyboardKeyAction.ToggleSnippetsPanel,
            KeyboardKeyAction.Voice,
        )

    fun resolve(
        key: KeyboardKeySpec,
        config: KeyboardCornerConfig,
        cornerModeEnabled: Boolean,
        specialKeyCornersEnabled: Boolean,
        fieldPolicy: KeyboardFieldPolicy,
        layoutProfile: KeyboardLayoutProfile,
    ): KeyboardCornerAssignments {
        if (!cornerModeEnabled || !allowsCornerGesture(key, specialKeyCornersEnabled)) {
            return KeyboardCornerAssignments.Empty
        }

        val bySlot = linkedMapOf<KeyboardCornerSlot, KeyboardCornerShortcut>()
        KeyboardCornerPresets.preset(config.presetId).shortcuts
            .filter { it.keyId == key.id && it.matchesLayout(layoutProfile) }
            .forEach { bySlot[it.slot] = it }
        config.overrides
            .filter { it.keyId == key.id }
            .forEach {
                if (it.disabled) {
                    bySlot.remove(it.slot)
                } else {
                    bySlot[it.slot] = it
                }
            }

        if (bySlot.isEmpty()) {
            return KeyboardCornerAssignments.Empty
        }

        val assignments =
            bySlot.values.mapNotNull { shortcut ->
                if (shortcut.disabled) {
                    return@mapNotNull null
                }
                val value = runCatching { shortcut.parsedValue() }.getOrNull() ?: return@mapNotNull null
                if (!isAllowedForPolicy(shortcut, value, fieldPolicy)) {
                    return@mapNotNull null
                }
                KeyboardCornerAssignment(
                    slot = shortcut.slot,
                    value = value,
                    label = compactLabel(shortcut.resolvedLabel(value)),
                    sensitive = shortcut.sensitive,
                )
            }
        return KeyboardCornerAssignments.from(assignments)
    }

    private fun allowsCornerGesture(
        key: KeyboardKeySpec,
        specialKeyCornersEnabled: Boolean,
    ): Boolean {
        return (key.action == KeyboardKeyAction.Text && key.id != "space") || specialKeyCornersEnabled
    }

    private fun KeyboardCornerShortcut.matchesLayout(layoutProfile: KeyboardLayoutProfile): Boolean {
        return layoutProfiles?.contains(layoutProfile) ?: true
    }

    private fun isAllowedForPolicy(
        shortcut: KeyboardCornerShortcut,
        value: KeyboardKeyValue,
        fieldPolicy: KeyboardFieldPolicy,
    ): Boolean {
        if (!fieldPolicy.inputAllowed) {
            return false
        }
        if (!fieldPolicy.privateMode) {
            return true
        }
        if (shortcut.sensitive) {
            return false
        }
        if (value.kind == KeyboardKeyValueKind.Action && value.action in sensitiveActions) {
            return false
        }
        if (value.kind == KeyboardKeyValueKind.Macro) {
            return value.macro.all { isAllowedForPolicy(shortcut.copy(sensitive = false), it, fieldPolicy) }
        }
        return true
    }

    private fun compactLabel(label: String): String {
        val normalized = label.replace(Regex("\\s+"), " ").trim()
        return if (normalized.length <= KeyboardCornerConfig.MAX_LABEL_LENGTH) {
            normalized
        } else {
            normalized.take(KeyboardCornerConfig.MAX_LABEL_LENGTH - 1) + "…"
        }
    }
}

private fun KeyboardCornerShortcut.validated(): KeyboardCornerShortcut {
    if (keyId.isBlank()) {
        throw KeyboardCornerConfigException("Corner shortcut keyId is required")
    }
    if (keyId.length > KeyboardCornerConfig.MAX_KEY_ID_LENGTH) {
        throw KeyboardCornerConfigException("Corner shortcut keyId is too long")
    }
    if (disabled) {
        return this
    }
    if (expression.isBlank()) {
        throw KeyboardCornerConfigException("Corner shortcut expression is required")
    }
    if (expression.length > KeyboardCornerConfig.MAX_EXPRESSION_LENGTH) {
        throw KeyboardCornerConfigException("Corner shortcut expression is too long")
    }
    if ((label?.length ?: 0) > KeyboardCornerConfig.MAX_LABEL_LENGTH) {
        throw KeyboardCornerConfigException("Corner shortcut label is too long")
    }
    parsedValue()
    return this
}
