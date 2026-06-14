import '../../../core/viewmodels/page_view_model.dart';

class FinanceViewModel extends PageViewModel {
  FinanceViewModel() {
    loadFinance();
  }

  Future<void> loadFinance() async {
    setLoading(
      title: 'Loading finance',
      message: 'Fetching balances and payment records.',
    );

    await Future.delayed(const Duration(seconds: 2));

    setError(
      title: 'Finance unavailable',
      message: 'We could not connect to the finance service.',
    );
  }
}