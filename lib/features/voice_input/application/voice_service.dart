import 'package:flutter/foundation.dart';
import '../domain/repositories/voice_repository.dart';
import '../domain/entities/recognized_food.dart';

/// Application service cho luong phan tich transcript bang giong noi.
///
/// Lop nay giu trach nhiem validate input va uy quyen parse cho repository.
class VoiceService {
  final VoiceRepository _repository;

  VoiceService(this._repository);

  /// Chuyen transcript thanh du lieu mon an da nhan dien.
  Future<RecognizedFood> processTranscript(String transcript) async {
    if (transcript.trim().isEmpty) {
      throw Exception('Transcript cannot be empty');
    }

    try {
      debugPrint('[VoiceService] 🔵 Processing transcript: $transcript');
      
      final recognizedFood = await _repository.parseTranscript(transcript);
      
      debugPrint('[VoiceService] ✅ Processed food: $recognizedFood');
      
      
      return recognizedFood;
    } catch (e, stackTrace) {
      debugPrint('[VoiceService] ❌ Error processing transcript: $e');
      debugPrint('[VoiceService] Stack trace: $stackTrace');
      rethrow;
    }
  }
}

