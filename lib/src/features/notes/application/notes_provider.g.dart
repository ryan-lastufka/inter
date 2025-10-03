// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(notesService)
const notesServiceProvider = NotesServiceProvider._();

final class NotesServiceProvider
    extends $FunctionalProvider<NotesService, NotesService, NotesService>
    with $Provider<NotesService> {
  const NotesServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notesServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notesServiceHash();

  @$internal
  @override
  $ProviderElement<NotesService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  NotesService create(Ref ref) {
    return notesService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotesService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotesService>(value),
    );
  }
}

String _$notesServiceHash() => r'e026c90918a77c8dcdc98d128a8ba3c7ecd882a1';

@ProviderFor(Notes)
const notesProvider = NotesProvider._();

final class NotesProvider
    extends $AsyncNotifierProvider<Notes, List<FolderItem>> {
  const NotesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notesHash();

  @$internal
  @override
  Notes create() => Notes();
}

String _$notesHash() => r'a90686e94a0c7e773d9821ceeae306c0275af22a';

abstract class _$Notes extends $AsyncNotifier<List<FolderItem>> {
  FutureOr<List<FolderItem>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<FolderItem>>, List<FolderItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<FolderItem>>, List<FolderItem>>,
              AsyncValue<List<FolderItem>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(SelectedNoteId)
const selectedNoteIdProvider = SelectedNoteIdProvider._();

final class SelectedNoteIdProvider
    extends $NotifierProvider<SelectedNoteId, String?> {
  const SelectedNoteIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedNoteIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedNoteIdHash();

  @$internal
  @override
  SelectedNoteId create() => SelectedNoteId();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$selectedNoteIdHash() => r'f718ac9b5c4a8b23a8983800542326fb33b2d709';

abstract class _$SelectedNoteId extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(selectedNote)
const selectedNoteProvider = SelectedNoteProvider._();

final class SelectedNoteProvider
    extends
        $FunctionalProvider<
          AsyncValue<NoteItem?>,
          NoteItem?,
          FutureOr<NoteItem?>
        >
    with $FutureModifier<NoteItem?>, $FutureProvider<NoteItem?> {
  const SelectedNoteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedNoteProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedNoteHash();

  @$internal
  @override
  $FutureProviderElement<NoteItem?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<NoteItem?> create(Ref ref) {
    return selectedNote(ref);
  }
}

String _$selectedNoteHash() => r'f83f31fec0ff8a8166e927422b649d922a1aa489';

@ProviderFor(noteAnalysis)
const noteAnalysisProvider = NoteAnalysisProvider._();

final class NoteAnalysisProvider
    extends
        $FunctionalProvider<
          AsyncValue<AnalysisResult?>,
          AnalysisResult?,
          FutureOr<AnalysisResult?>
        >
    with $FutureModifier<AnalysisResult?>, $FutureProvider<AnalysisResult?> {
  const NoteAnalysisProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'noteAnalysisProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$noteAnalysisHash();

  @$internal
  @override
  $FutureProviderElement<AnalysisResult?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AnalysisResult?> create(Ref ref) {
    return noteAnalysis(ref);
  }
}

String _$noteAnalysisHash() => r'02d41dcac97c90046bc7d19dbeac91a938f2d3c7';
