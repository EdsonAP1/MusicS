import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application_1/data/database/hive_service.dart';

/// Manages favorite songs — stores song IDs in Hive
class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({}) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    state = HiveService.favorites.values.toSet();
  }

  bool isFavorite(String songId) => state.contains(songId);

  void toggleFavorite(String songId) {
    final newState = Set<String>.from(state);
    if (newState.contains(songId)) {
      newState.remove(songId);
      HiveService.favorites.delete(songId);
    } else {
      newState.add(songId);
      HiveService.favorites.put(songId, songId);
    }
    state = newState;
  }

  void addFavorite(String songId) {
    if (!state.contains(songId)) {
      state = {...state, songId};
      HiveService.favorites.put(songId, songId);
    }
  }

  void removeFavorite(String songId) {
    if (state.contains(songId)) {
      state = Set.from(state)..remove(songId);
      HiveService.favorites.delete(songId);
    }
  }
}

/// Global favorites provider
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>(
        (ref) => FavoritesNotifier());
