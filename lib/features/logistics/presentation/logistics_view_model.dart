import '../../../core/viewmodels/page_view_model.dart';

class LogisticsViewModel extends PageViewModel {
  LogisticsViewModel() {
    loadLogistics();
  }

  Future<void> loadLogistics() async {
    setLoading(
      title: 'Loading logistics',
      message: 'Fetching routes and delivery statuses.',
    );

    await Future.delayed(const Duration(seconds: 2));

    setContent();
  }
}