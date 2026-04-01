import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:calories_app/shared/state/auth_providers.dart';

/// Guard xac thuc quyen truy cap cho khu vuc Admin.
///
/// Tra ve `true` chi khi user da dang nhap va co role admin.
/// Mac dinh `false` trong moi truong hop con lai (fail-safe deny).
final adminGuardProvider = StreamProvider<bool>((ref) async* {
  try {
    // Theo doi auth state.
    final authAsync = ref.watch(authStateProvider);
    
    yield* authAsync.when(
      data: (user) {
        if (user == null) {
          return Stream.value(false);
        }
        
        // Theo doi profile de kiem tra role.
        final profileAsync = ref.watch(currentProfileProvider(user.uid));
        
        return profileAsync.when(
          data: (profile) {
            if (profile == null) {
              return Stream.value(false);
            }
            return Stream.value(profile.isAdmin);
          },
          loading: () => Stream.value(false), // Tam thoi deny khi dang tai.
          error: (_, __) => Stream.value(false), // Deny neu co loi.
        );
      },
      loading: () => Stream.value(false), // Deny khi auth chua san sang.
      error: (_, __) => Stream.value(false), // Deny neu auth gap loi.
    );
  } catch (e) {
    // Bat ky exception nao deu deny (fail-safe).
    yield false;
  }
});
