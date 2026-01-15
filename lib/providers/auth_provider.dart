import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../types.dart';
import '../services/storage_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final storageService = ref.watch(storageServiceProvider);
  return AuthNotifier(storageService);
});

class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;

  AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final StorageService _storageService;

  AuthNotifier(this._storageService) : super(AuthState()) {
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final token = _storageService.getToken();
      final user = _storageService.getUser();

      if (token != null && token.isNotEmpty) {
        state = state.copyWith(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          user: null,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> login(String token, User user) async {
    state = state.copyWith(isLoading: true);
    try {
      await _storageService.saveToken(token);
      await _storageService.saveUser(user);

      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateUser(User user) async {
    try {
      await _storageService.saveUser(user);
      state = state.copyWith(user: user);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
    state = AuthState(isAuthenticated: false);
  }
}
