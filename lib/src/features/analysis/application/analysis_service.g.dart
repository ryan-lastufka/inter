// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(analysisService)
const analysisServiceProvider = AnalysisServiceProvider._();

final class AnalysisServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<AnalysisService>,
          AnalysisService,
          FutureOr<AnalysisService>
        >
    with $FutureModifier<AnalysisService>, $FutureProvider<AnalysisService> {
  const AnalysisServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analysisServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analysisServiceHash();

  @$internal
  @override
  $FutureProviderElement<AnalysisService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AnalysisService> create(Ref ref) {
    return analysisService(ref);
  }
}

String _$analysisServiceHash() => r'5d45089c835eb5463b70b9fbf6bbf3828ab0af66';
