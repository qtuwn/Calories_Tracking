import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/voice_repository.dart';
import '../../data/implementations/voice_repository_impl.dart';
import '../../application/voice_service.dart';
import '../../application/voice_meal_service.dart';
import '../../../../shared/state/food_providers.dart';

/// Provider cho VoiceRepository implementation.
final voiceRepositoryProvider = Provider<VoiceRepository>((ref) {
  return VoiceRepositoryImpl();
});

/// Provider cho [VoiceService].
///
/// Service nay dieu phoi giua presentation va repository cho luong parse transcript.
final voiceServiceProvider = Provider<VoiceService>((ref) {
  final repository = ref.read(voiceRepositoryProvider);
  return VoiceService(repository);
});

/// Provider cho [VoiceMealService].
///
/// Service nay tim goi y mon an dua tren transcript giong noi.
final voiceMealServiceProvider = Provider<VoiceMealService>((ref) {
  final foodRepository = ref.read(foodRepositoryProvider);
  return VoiceMealService(foodRepository);
});

