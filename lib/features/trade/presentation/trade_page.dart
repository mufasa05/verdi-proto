import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verdi/core/widgets/state_view.dart';
import 'package:verdi/core/widgets/verdi_page_scaffold.dart';
import 'trade_view_model.dart';

class TradePage extends StatelessWidget {
  const TradePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TradeViewModel(),
      child: Consumer<TradeViewModel>(
        builder: (context, vm, _) {
          return VerdiPageScaffold(
            title: 'Trade',
            subtitle: 'Contracts, deals, and transaction activity.',
            child: StateView(
              state: vm.state,
              title: vm.title,
              message: vm.message,
              child: ListView(
                children: const [
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.handshake_outlined),
                      title: Text('Open Offer'),
                      subtitle: Text('Buyer interested in 50 bags of maize'),
                    ),
                  ),
                  SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.receipt_long_outlined),
                      title: Text('Pending Contract'),
                      subtitle: Text('Needs approval from supplier'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}