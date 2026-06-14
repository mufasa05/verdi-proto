import 'package:flutter_riverpod/flutter_riverpod.dart';

enum UserRole { farmer, buyer, driver, admin }

class AppState {
  final UserRole role;
  final int navIndex;

  const AppState({
    required this.role,
    required this.navIndex,
  });

  AppState copyWith({
    UserRole? role,
    int? navIndex,
  }) {
    return AppState(
      role: role ?? this.role,
      navIndex: navIndex ?? this.navIndex,
    );
  }

  static const initial = AppState(
    role: UserRole.farmer,
    navIndex: 0,
  );
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(AppState.initial);

  void setRole(UserRole role) {
    state = state.copyWith(role: role, navIndex: 0);
  }

  void setNavIndex(int index) {
    state = state.copyWith(navIndex: index);
  }
}

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});