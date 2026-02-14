import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ModelManifest {
  final String id;
  final String version;
  final String modelUrl;
  final String vocabUrl;
  final String modelFileName;
  final String vocabFileName;

  ModelManifest({
    required this.id,
    required this.version,
    required this.modelUrl,
    required this.vocabUrl,
    required this.modelFileName,
    required this.vocabFileName,
  });
}

class ModelDownloadService {
  final Dio _dio = Dio();
  static const String _modelDirName = 'ml_models';
  static const String _versionKeyPrefix = 'ml_model_version_';

  static final ModelManifest transactionParserModel = ModelManifest(
    id: 'transaction_parser',
    version: '1.0.0',
    modelUrl: 'https://github.com/tamatasoft/flowpaisa/releases/download/model/1.tflite',
    vocabUrl: 'https://github.com/tamatasoft/flowpaisa/releases/download/model/vocab.txt',
    modelFileName: 'transaction_parser.tflite',
    vocabFileName: 'vocab.txt',
  );

  Future<String?> getModelPath(ModelManifest manifest) async {
    final directory = await getApplicationDocumentsDirectory();
    final modelFile = File('${directory.path}/$_modelDirName/${manifest.modelFileName}');
    
    if (await modelFile.exists()) {
      final prefs = await SharedPreferences.getInstance();
      final savedVersion = prefs.getString('$_versionKeyPrefix${manifest.id}');
      if (savedVersion == manifest.version) {
        return modelFile.path;
      }
    }
    return null;
  }

  Future<String?> getVocabPath(ModelManifest manifest) async {
    final directory = await getApplicationDocumentsDirectory();
    final vocabFile = File('${directory.path}/$_modelDirName/${manifest.vocabFileName}');
    
    if (await vocabFile.exists()) {
      final prefs = await SharedPreferences.getInstance();
      final savedVersion = prefs.getString('$_versionKeyPrefix${manifest.id}');
      if (savedVersion == manifest.version) {
        return vocabFile.path;
      }
    }
    return null;
  }

  Future<bool> downloadModel(
    ModelManifest manifest, {
    void Function(double progress)? onProgress,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final modelDir = Directory('${directory.path}/$_modelDirName');
      if (!await modelDir.exists()) {
        await modelDir.create(recursive: true);
      }

      final modelSavePath = '${modelDir.path}/${manifest.modelFileName}';
      final vocabSavePath = '${modelDir.path}/${manifest.vocabFileName}';
      
      // Download model
      await _dio.download(
        manifest.modelUrl,
        modelSavePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            // Model is usually much larger, so it takes 90% of the progress
            onProgress((received / total) * 0.9);
          }
        },
      );

      // Download vocab
      await _dio.download(
        manifest.vocabUrl,
        vocabSavePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            // Vocab takes the last 10%
            onProgress(0.9 + (received / total) * 0.1);
          }
        },
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_versionKeyPrefix${manifest.id}', manifest.version);
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error downloading model/vocab: $e');
      }
      return false;
    }
  }

  Future<bool> isModelDownloaded(ModelManifest manifest) async {
    final mPath = await getModelPath(manifest);
    final vPath = await getVocabPath(manifest);
    return mPath != null && vPath != null;
  }
}
