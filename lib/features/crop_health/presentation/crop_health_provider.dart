import 'package:flutter/material.dart';
import 'package:verdi/features/crop_health/data/crop_health_models.dart';
import 'package:verdi/features/crop_health/data/mock_crop_health_repository.dart';

class CropHealthProvider extends ChangeNotifier {
  final MockCropHealthRepository repository;

  CropHealthProvider({required this.repository}) {
    loadSnapshot();
  }

  CropHealthSnapshot? snapshot;
  bool isLoading = true;
  String? error;

  Future<void> loadSnapshot() async {
    try {
      isLoading = true;
      error = null;
      notifyListeners();

      await Future<void>.delayed(const Duration(milliseconds: 300));
      snapshot = repository.fetchSnapshot();
    } catch (e) {
      error = 'Unable to load crop health data.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
