import 'package:flutter/foundation.dart';
import '../domain/repositories/voice_repository.dart';
import '../domain/entities/recognized_food.dart';

class VoiceService {
  final VoiceRepository _repository;

  VoiceService(this._repository);

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

