import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:llamadart/llamadart.dart';
import 'package:path_provider/path_provider.dart';
import '../config/app_config.dart';

/// 🧠 Available On-Device SLM Tiers hosted on Hugging Face Hub CDN
enum OnDeviceModelTier {
  compact(
    id: 'compact_q4_k_m',
    displayName: 'Compact Brain (Q4_K_M • 249 MB)',
    fileName: AppConfig.compactModelFileName,
    sha256: AppConfig.compactModelSha256,
    expectedBytes: AppConfig.compactModelSizeBytes,
  ),
  pro(
    id: 'pro_q8_0',
    displayName: 'High-Precision Brain (Q8_0 • 286 MB)',
    fileName: AppConfig.proModelFileName,
    sha256: AppConfig.proModelSha256,
    expectedBytes: AppConfig.proModelSizeBytes,
  );

  const OnDeviceModelTier({
    required this.id,
    required this.displayName,
    required this.fileName,
    required this.sha256,
    required this.expectedBytes,
  });

  final String id;
  final String displayName;
  final String fileName;
  final String sha256;
  final int expectedBytes;

  double get sizeMb => expectedBytes / (1024 * 1024);
}

/// 📊 Lifecycle states of the On-Device SLM Engine
enum OnDeviceModelState {
  notDownloaded,
  downloading,
  loading,
  ready,
  error,
}

/// 📦 ModelManagerService: Manages downloading, SHA-256 verification, caching,
/// and `LlamaEngine` initialization for the fine-tuned Gemma 3 270M `.gguf` brain.
class ModelManagerService extends ChangeNotifier {
  ModelManagerService._internal();
  static final ModelManagerService instance = ModelManagerService._internal();

  OnDeviceModelTier _selectedTier = OnDeviceModelTier.compact;
  OnDeviceModelState _state = OnDeviceModelState.notDownloaded;
  double _downloadProgress = 0.0;
  int _receivedBytes = 0;
  int _totalBytes = AppConfig.compactModelSizeBytes;
  String? _errorMessage;
  String? _loadedModelPath;

  LlamaEngine? _engine;
  ModelDownloadCancelToken? _cancelToken;

  /// Optional test hook allowing deterministic <1ms unit/widget tests without loading native FFI
  @visibleForTesting
  Future<String> Function(String prompt)? debugPromptGenerator;

  OnDeviceModelTier get selectedTier => _selectedTier;
  OnDeviceModelState get state => _state;
  double get downloadProgress => _downloadProgress;
  int get receivedBytes => _receivedBytes;
  int get totalBytes => _totalBytes;
  String? get errorMessage => _errorMessage;
  String? get loadedModelPath => _loadedModelPath;

  /// True when the on-device SLM is loaded in memory (or test generator is active)
  bool get isModelReady =>
      _state == OnDeviceModelState.ready &&
      (_engine != null || debugPromptGenerator != null);

  LlamaEngine? get engine => _engine;

  /// Selects the desired model tier (`compact` 249 MB or `pro` 286 MB)
  void selectTier(OnDeviceModelTier tier) {
    if (_selectedTier == tier) return;
    if (_state == OnDeviceModelState.downloading ||
        _state == OnDeviceModelState.loading) {
      return;
    }
    _selectedTier = tier;
    _totalBytes = tier.expectedBytes;
    notifyListeners();
  }

  /// Resolves the app-private directory where `.gguf` models are cached
  Future<Directory> getModelsDirectory() async {
    final supportDir = await getApplicationSupportDirectory();
    final modelsDir = Directory('${supportDir.path}/models');
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return modelsDir;
  }

  /// Checks if the selected tier's `.gguf` file is already cached on disk,
  /// and if so, loads it into `LlamaEngine` automatically.
  Future<void> checkAndAutoLoadCachedModel() async {
    if (isModelReady ||
        _state == OnDeviceModelState.downloading ||
        _state == OnDeviceModelState.loading) {
      return;
    }
    try {
      final modelsDir = await getModelsDirectory();
      final directFile = File('${modelsDir.path}/${_selectedTier.fileName}');
      if (await directFile.exists() &&
          await directFile.length() == _selectedTier.expectedBytes) {
        await loadFromLocalPath(directFile.path);
      }
    } catch (_) {
      // Ignore if path_provider is unavailable in unit test environment
    }
  }

  /// Downloads the selected `.gguf` model from Hugging Face Hub CDN (with HTTP Range resume
  /// and SHA-256 verification) and initializes `LlamaEngine`.
  Future<bool> downloadAndLoadModel({OnDeviceModelTier? tier}) async {
    if (tier != null) {
      _selectedTier = tier;
    }
    if (_state == OnDeviceModelState.downloading ||
        _state == OnDeviceModelState.loading) {
      return false;
    }

    _state = OnDeviceModelState.downloading;
    _downloadProgress = 0.0;
    _receivedBytes = 0;
    _totalBytes = _selectedTier.expectedBytes;
    _errorMessage = null;
    _cancelToken = ModelDownloadCancelToken();
    notifyListeners();

    try {
      final modelsDir = await getModelsDirectory();
      final source = ModelSource.huggingFace(
        repoId: AppConfig.hfRepoId,
        filePath: _selectedTier.fileName,
      );

      await _engine?.dispose();
      _engine = null;

      final loadedEngine = await LlamaEngine.load(
        LlamaModel(source),
        params: const LlamaCppModelParams(
          contextSize: 1024,
          batchSize: 512,
        ),
        download: ModelLoadOptions(
          cachePolicy: ModelCachePolicy.preferCached,
          cacheDirectory: modelsDir.path,
          sha256: _selectedTier.sha256,
          resume: true,
          maxRetries: 3,
          cancelToken: _cancelToken,
        ),
        onProgress: (progress) {
          _receivedBytes = progress.receivedBytes;
          if (progress.totalBytes != null && progress.totalBytes! > 0) {
            _totalBytes = progress.totalBytes!;
          }
          _downloadProgress = progress.fraction ?? 0.0;
          if (_downloadProgress >= 0.999 &&
              _state == OnDeviceModelState.downloading) {
            _state = OnDeviceModelState.loading;
          }
          notifyListeners();
        },
      );

      _engine = loadedEngine;
      _loadedModelPath = source.fileName;
      _downloadProgress = 1.0;
      _state = OnDeviceModelState.ready;
      notifyListeners();
      return true;
    } catch (e) {
      if (_cancelToken?.isCancelled ?? false) {
        _state = OnDeviceModelState.notDownloaded;
        _errorMessage = null;
      } else {
        _state = OnDeviceModelState.error;
        _errorMessage = e.toString();
      }
      notifyListeners();
      return false;
    } finally {
      _cancelToken = null;
    }
  }

  /// Loads a `.gguf` model directly from an existing local file path into `LlamaEngine`
  Future<bool> loadFromLocalPath(String filePath, {bool verifySha256 = false}) async {
    _state = OnDeviceModelState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _engine?.dispose();
      _engine = null;

      final loadedEngine = await LlamaEngine.load(
        LlamaModel(ModelSource.path(filePath)),
        params: const LlamaCppModelParams(
          contextSize: 1024,
          batchSize: 512,
        ),
        download: ModelLoadOptions(
          sha256: verifySha256 ? _selectedTier.sha256 : null,
        ),
      );

      _engine = loadedEngine;
      _loadedModelPath = filePath;
      _downloadProgress = 1.0;
      _state = OnDeviceModelState.ready;
      notifyListeners();
      return true;
    } catch (e) {
      _state = OnDeviceModelState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Cancels an in-progress Hugging Face download
  void cancelDownload() {
    _cancelToken?.cancel();
  }

  /// Unloads the engine from RAM and optionally deletes cached `.gguf` files
  Future<void> unloadAndDeleteCache({bool deleteDiskFiles = false}) async {
    _cancelToken?.cancel();
    await _engine?.dispose();
    _engine = null;
    _loadedModelPath = null;
    debugPromptGenerator = null;
    _downloadProgress = 0.0;
    _receivedBytes = 0;
    _errorMessage = null;
    _state = OnDeviceModelState.notDownloaded;

    if (deleteDiskFiles) {
      try {
        final modelsDir = await getModelsDirectory();
        if (await modelsDir.exists()) {
          await modelsDir.delete(recursive: true);
        }
      } catch (_) {}
    }
    notifyListeners();
  }

  /// Configures a fast mock/fake generator for unit & widget tests
  @visibleForTesting
  void setDebugGenerator(Future<String> Function(String prompt)? generator) {
    debugPromptGenerator = generator;
    _state = generator != null
        ? OnDeviceModelState.ready
        : OnDeviceModelState.notDownloaded;
    _downloadProgress = generator != null ? 1.0 : 0.0;
    notifyListeners();
  }

  /// Generates a text completion from the loaded `LlamaEngine` (or debug generator in tests)
  Future<String> generateCompletion(
    String prompt, {
    int maxTokens = 150,
    double temp = 0.0,
    double penalty = 1.0,
    List<String> stopSequences = const ['<end_of_turn>'],
  }) async {
    if (debugPromptGenerator != null) {
      return debugPromptGenerator!(prompt);
    }
    final activeEngine = _engine;
    if (activeEngine == null) {
      throw StateError('On-Device LlamaEngine is not loaded.');
    }
    final buffer = StringBuffer();
    await for (final tokenChunk in activeEngine.generate(
      prompt,
      params: GenerationParams(
        maxTokens: maxTokens,
        temp: temp,
        penalty: penalty,
        stopSequences: stopSequences,
      ),
    )) {
      buffer.write(tokenChunk);
    }
    return buffer.toString();
  }
}
