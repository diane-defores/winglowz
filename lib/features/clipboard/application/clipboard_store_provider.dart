import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/supabase/clipboard_repository.dart';
import '../../../data/supabase/supabase_client_provider.dart';
import 'clipboard_history_api.dart';
import 'keyboard_clipboard_event_importer.dart';
import '../data/in_memory_clipboard_history_store.dart';
import '../domain/clipboard_store.dart';

final localClipboardHistoryStoreProvider =
    Provider<InMemoryClipboardHistoryStore>(
      (ref) => InMemoryClipboardHistoryStore(),
    );

final clipboardStoreProvider = Provider<ClipboardHistoryStore>((ref) {
  final client = ref.watch(supabaseClientProvider);
  if (client == null) {
    return ref.watch(localClipboardHistoryStoreProvider);
  }
  return SupabaseClipboardStore(client);
});

final clipboardHistoryApiProvider = Provider<ClipboardHistoryApi>((ref) {
  final store = ref.watch(clipboardStoreProvider);
  return ClipboardHistoryApi(store);
});

final keyboardClipboardEventImporterProvider =
    Provider<KeyboardClipboardEventImporter>((ref) {
      final api = ref.watch(clipboardHistoryApiProvider);
      return KeyboardClipboardEventImporter(api);
    });
