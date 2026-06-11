import 'package:flutter/material.dart';

enum CustomActionButtonType {
  textSnippet,
  keyboardExpression,
  desktopKeySequence,
}

enum CustomActionButtonIcon {
  spark,
  window,
  bolt,
  terminal,
  clipboard,
  cursor,
  wand,
  layers,
}

extension CustomActionButtonIconPresentation on CustomActionButtonIcon {
  IconData get iconData {
    return switch (this) {
      CustomActionButtonIcon.spark => Icons.auto_awesome_outlined,
      CustomActionButtonIcon.window => Icons.web_asset_outlined,
      CustomActionButtonIcon.bolt => Icons.bolt_outlined,
      CustomActionButtonIcon.terminal => Icons.terminal_outlined,
      CustomActionButtonIcon.clipboard => Icons.content_paste_outlined,
      CustomActionButtonIcon.cursor => Icons.ads_click_outlined,
      CustomActionButtonIcon.wand => Icons.auto_fix_high_outlined,
      CustomActionButtonIcon.layers => Icons.layers_outlined,
    };
  }

  String get label {
    return switch (this) {
      CustomActionButtonIcon.spark => 'Étincelle',
      CustomActionButtonIcon.window => 'Fenêtre',
      CustomActionButtonIcon.bolt => 'Éclair',
      CustomActionButtonIcon.terminal => 'Commande',
      CustomActionButtonIcon.clipboard => 'Papiers',
      CustomActionButtonIcon.cursor => 'Curseur',
      CustomActionButtonIcon.wand => 'Action',
      CustomActionButtonIcon.layers => 'Pile',
    };
  }
}

class CustomActionButtonAction {
  const CustomActionButtonAction({required this.type, required this.value});

  final CustomActionButtonType type;
  final String value;

  String get trimmedValue => value.trim();

  Map<String, Object?> toMap() {
    return {'type': type.name, 'value': trimmedValue};
  }

  factory CustomActionButtonAction.fromMap(Map<Object?, Object?> map) {
    final rawType = map['type'] as String? ?? '';
    return CustomActionButtonAction(
      type: CustomActionButtonType.values.firstWhere(
        (item) => item.name == rawType,
        orElse: () => CustomActionButtonType.textSnippet,
      ),
      value: map['value'] as String? ?? '',
    );
  }
}

class CustomActionButtonRecord {
  const CustomActionButtonRecord({
    required this.id,
    required this.title,
    required this.icon,
    required this.action,
    required this.createdAt,
  });

  final String id;
  final String title;
  final CustomActionButtonIcon icon;
  final CustomActionButtonAction action;
  final DateTime createdAt;
}

enum DesktopKeyModifier { ctrl, alt, shift, meta }

class DesktopKeyStroke {
  const DesktopKeyStroke({required this.key, required this.modifiers});

  final String key;
  final List<DesktopKeyModifier> modifiers;

  Map<String, Object?> toMap() {
    return {
      'key': key,
      'modifiers': modifiers.map((item) => item.name).toList(growable: false),
    };
  }
}

class DesktopKeySequence {
  const DesktopKeySequence._(this.steps);

  final List<DesktopKeyStroke> steps;

  static const _namedKeys = <String, String>{
    'tab': 'Tab',
    'enter': 'Enter',
    'return': 'Enter',
    'space': 'Space',
    'esc': 'Escape',
    'escape': 'Escape',
    'left': 'Left',
    'right': 'Right',
    'up': 'Up',
    'down': 'Down',
    'backspace': 'Backspace',
    'delete': 'Delete',
  };

  factory DesktopKeySequence.parse(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty) {
      throw const FormatException('La séquence clavier est vide.');
    }
    final steps = normalized
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .map(_parseStep)
        .toList(growable: false);
    if (steps.isEmpty) {
      throw const FormatException('Aucune étape clavier valide.');
    }
    return DesktopKeySequence._(steps);
  }

  static DesktopKeyStroke _parseStep(String rawStep) {
    final tokens = rawStep
        .split('+')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
    if (tokens.isEmpty) {
      throw FormatException('Étape clavier vide: "$rawStep".');
    }
    final modifiers = <DesktopKeyModifier>[];
    String? key;
    for (final token in tokens) {
      final lower = token.toLowerCase();
      final modifier = switch (lower) {
        'ctrl' || 'control' => DesktopKeyModifier.ctrl,
        'alt' || 'option' => DesktopKeyModifier.alt,
        'shift' => DesktopKeyModifier.shift,
        'meta' || 'cmd' || 'command' || 'win' => DesktopKeyModifier.meta,
        _ => null,
      };
      if (modifier != null) {
        if (!modifiers.contains(modifier)) {
          modifiers.add(modifier);
        }
        continue;
      }
      if (key != null) {
        throw FormatException(
          'Une étape ne peut contenir qu’une seule touche principale: "$rawStep".',
        );
      }
      key = _normalizeKeyToken(token);
    }
    if (key == null) {
      throw FormatException(
        'Aucune touche principale détectée dans "$rawStep".',
      );
    }
    return DesktopKeyStroke(key: key, modifiers: modifiers);
  }

  static String _normalizeKeyToken(String token) {
    final lower = token.toLowerCase();
    final named = _namedKeys[lower];
    if (named != null) {
      return named;
    }
    if (token.length == 1) {
      final upper = token.toUpperCase();
      final code = upper.codeUnitAt(0);
      final isLetter = code >= 65 && code <= 90;
      final isDigit = code >= 48 && code <= 57;
      if (isLetter || isDigit) {
        return upper;
      }
    }
    throw FormatException('Touche non supportée: "$token".');
  }
}
