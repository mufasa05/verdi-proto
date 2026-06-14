import '../../../core/viewmodels/page_view_model.dart';

class MarketplaceViewModel extends PageViewModel {
  MarketplaceViewModel() {
    loadMarketplace();
  }

  Future<void> loadMarketplace() async {
    setLoading(
      title: 'Loading marketplace',
      message: 'Fetching listings and pricing data.',
    );

    await Future.delayed(const Duration(seconds: 2));

    setEmpty(
      title: 'No marketplace data yet',
      message: 'Listings will appear here once they are available.',
    );
  }
}