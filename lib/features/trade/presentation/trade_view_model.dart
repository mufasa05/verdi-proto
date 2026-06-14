import '../../../core/viewmodels/page_view_model.dart';

class TradeViewModel extends PageViewModel {
  TradeViewModel() {
    loadTrades();
  }

  Future<void> loadTrades() async {
    setLoading(
      title: 'Loading trade data',
      message: 'Retrieving contracts and offers.',
    );

    await Future.delayed(const Duration(seconds: 2));

    setEmpty(
      title: 'No trades yet',
      message: 'Trade activity will show here once contracts are created.',
    );
  }
}