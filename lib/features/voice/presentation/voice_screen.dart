import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/platform/android_overlay_bridge.dart';
import '../../../core/platform/platform_capabilities.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/confirm_action_dialog.dart';
import '../../../core/widgets/local_mode_notice.dart';
import '../application/transcription_store.dart';
import '../application/transcription_store_provider.dart';
import '../domain/transcription_draft.dart';

class VoiceScreen extends ConsumerStatefulWidget {
  const VoiceScreen({super.key});

  @override
  ConsumerState<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends ConsumerState<VoiceScreen> {
  final _rawController = TextEditingController();
  final _cleanedController = TextEditingController();
  final _languageController = TextEditingController(text: 'en');
  final _durationController = TextEditingController(text: '0');
  String _source = 'advanced';
  bool _busy = false;
  bool _overlayBusy = false;
  AndroidOverlayStatus? _overlayStatus;
  String? _message;
  List<TranscriptionRecord> _items = const [];

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_load);
    Future<void>.microtask(_loadOverlayStatus);
  }

  @override
  void dispose() {
    _rawController.dispose();
    _cleanedController.dispose();
    _languageController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _busy = true);
    try {
      final store = ref.read(transcriptionStoreProvider);
      final rows = await store.list();
      if (mounted) {
        setState(() {
          _items = rows;
          _message = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Erreur chargement transcriptions: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _loadOverlayStatus() async {
    if (!PlatformCapabilities.overlaySupported) {
      return;
    }
    try {
      final status = await AndroidOverlayBridge.getStatus();
      if (!mounted) {
        return;
      }
      setState(() => _overlayStatus = status);
    } on AndroidOverlayBridgeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () =>
            _message = 'Overlay status error (${error.code}): ${error.message}',
      );
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _message = 'Overlay status error: $error');
    }
  }

  Future<void> _startOverlay() async {
    setState(() => _overlayBusy = true);
    try {
      final status = await AndroidOverlayBridge.startRecording();
      if (!mounted) {
        return;
      }
      setState(() {
        _overlayStatus = status;
        _message = 'Overlay started from Voice.';
      });
    } on AndroidOverlayBridgeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () =>
            _message = 'Overlay start failed (${error.code}): ${error.message}',
      );
    } finally {
      if (mounted) {
        setState(() => _overlayBusy = false);
      }
    }
  }

  Future<void> _stopOverlay() async {
    setState(() => _overlayBusy = true);
    try {
      final status = await AndroidOverlayBridge.stopRecording();
      if (!mounted) {
        return;
      }
      setState(() {
        _overlayStatus = status;
        _message = 'Overlay stopped from Voice.';
      });
    } on AndroidOverlayBridgeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () =>
            _message = 'Overlay stop failed (${error.code}): ${error.message}',
      );
    } finally {
      if (mounted) {
        setState(() => _overlayBusy = false);
      }
    }
  }

  Future<void> _cancelOverlay() async {
    setState(() => _overlayBusy = true);
    try {
      final status = await AndroidOverlayBridge.cancelRecording();
      if (!mounted) {
        return;
      }
      setState(() {
        _overlayStatus = status;
        _message = 'Overlay canceled from Voice.';
      });
    } on AndroidOverlayBridgeException catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () => _message =
            'Overlay cancel failed (${error.code}): ${error.message}',
      );
    } finally {
      if (mounted) {
        setState(() => _overlayBusy = false);
      }
    }
  }

  Future<void> _add() async {
    final duration = int.tryParse(_durationController.text.trim()) ?? 0;
    final draft = TranscriptionDraft(
      rawText: _rawController.text,
      cleanedText: _cleanedController.text,
      language: _languageController.text.trim().isEmpty
          ? 'en'
          : _languageController.text.trim(),
      source: _source,
      durationMs: duration,
    );
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final store = ref.read(transcriptionStoreProvider);
      await store.insert(draft);
      _rawController.clear();
      _cleanedController.clear();
      _durationController.text = '0';
      await _load();
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Insertion impossible: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _delete(String id) async {
    final confirmed = await showConfirmActionDialog(
      context: context,
      title: 'Delete transcription?',
      message:
          'This removes the transcription from the current history. This action cannot be undone from this screen.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!mounted || !confirmed) {
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final store = ref.read(transcriptionStoreProvider);
      await store.softDelete(id);
      await _load();
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Suppression impossible: $error');
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _quickEdit(TranscriptionRecord item) async {
    final controller = TextEditingController(text: item.cleanedText);
    final updated = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit cleaned text'),
          content: TextField(
            controller: controller,
            minLines: 2,
            maxLines: 6,
            decoration: const InputDecoration(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (updated == null) {
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final store = ref.read(transcriptionStoreProvider);
      await store.updateCleanedText(id: item.id, cleanedText: updated);
      await _load();
    } catch (error) {
      if (mounted) {
        setState(() => _message = 'Mise à jour impossible: $error');
      }
    } finally {
      controller.dispose();
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final overlayStatus = _overlayStatus;
    return ListView(
      padding: AppInsets.screen,
      children: [
        const LocalModeNotice(surface: 'Voice'),
        const LocalModeNoticeGap(),
        if (PlatformCapabilities.overlaySupported)
          Card(
            child: Padding(
              padding: AppInsets.compactCard,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Android Overlay Controls',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  AppGaps.x2,
                  Text(
                    'enabled=${overlayStatus?.enabled ?? false} | '
                    'running=${overlayStatus?.running ?? false} | '
                    'delivery=${overlayStatus?.deliveryMode.name ?? 'clipboardOnly'}',
                  ),
                  if (overlayStatus?.accessibilityPermissionGranted == false)
                    const Padding(
                      padding: AppInsets.stack,
                      child: Text(
                        'Accessibility is disabled: delivery falls back to clipboard only.',
                      ),
                    ),
                  AppGaps.x3,
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _overlayBusy ? null : _startOverlay,
                          child: const Text('Start overlay'),
                        ),
                      ),
                      AppGaps.horizontalX2,
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _overlayBusy ? null : _stopOverlay,
                          child: const Text('Stop'),
                        ),
                      ),
                      AppGaps.horizontalX2,
                      Expanded(
                        child: TextButton(
                          onPressed: _overlayBusy ? null : _cancelOverlay,
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        if (PlatformCapabilities.overlaySupported) AppGaps.x2,
        TextField(
          controller: _rawController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Raw text'),
        ),
        AppGaps.x2,
        TextField(
          controller: _cleanedController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(labelText: 'Cleaned text'),
        ),
        AppGaps.x2,
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _languageController,
                decoration: const InputDecoration(labelText: 'Language'),
              ),
            ),
            AppGaps.horizontalX2,
            Expanded(
              child: TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Duration (ms)'),
              ),
            ),
          ],
        ),
        AppGaps.x2,
        DropdownButtonFormField<String>(
          initialValue: _source,
          items: const [
            DropdownMenuItem(value: 'free', child: Text('free')),
            DropdownMenuItem(value: 'advanced', child: Text('advanced')),
            DropdownMenuItem(value: 'overlay', child: Text('overlay')),
            DropdownMenuItem(value: 'keyboard', child: Text('keyboard')),
          ],
          onChanged: _busy
              ? null
              : (value) => setState(() => _source = value ?? 'advanced'),
          decoration: const InputDecoration(labelText: 'Source'),
        ),
        AppGaps.x2,
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: _busy ? null : _add,
                icon: const Icon(Icons.add),
                label: const Text('Add transcription'),
              ),
            ),
            AppGaps.horizontalX2,
            OutlinedButton(
              onPressed: _busy ? null : _load,
              child: const Text('Refresh'),
            ),
          ],
        ),
        if (_busy)
          const Padding(
            padding: AppInsets.progress,
            child: LinearProgressIndicator(),
          ),
        if (_message != null)
          Padding(padding: AppInsets.message, child: Text(_message!)),
        AppGaps.x4,
        Text('Transcriptions', style: Theme.of(context).textTheme.titleSmall),
        AppGaps.x2,
        if (_items.isEmpty)
          const Card(child: ListTile(title: Text('No transcription yet.'))),
        for (final item in _items)
          Card(
            child: ListTile(
              title: Text(item.cleanedText),
              subtitle: Text(
                'raw: ${item.rawText}\n'
                'lang: ${item.language} | source: ${item.source} | '
                'duration: ${item.durationMs}ms',
              ),
              isThreeLine: true,
              trailing: Wrap(
                spacing: AppIconMetrics.listActionSpacing,
                children: [
                  IconButton(
                    tooltip: 'Edit cleaned',
                    onPressed: _busy ? null : () => _quickEdit(item),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: _busy ? null : () => _delete(item.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
