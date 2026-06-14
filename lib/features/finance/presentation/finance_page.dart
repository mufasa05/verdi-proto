import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verdi/core/widgets/state_view.dart';
import 'package:verdi/core/widgets/verdi_page_scaffold.dart';
import 'finance_view_model.dart';

class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FinanceViewModel(),
      child: Consumer<FinanceViewModel>(
        builder: (context, vm, _) {
          return VerdiPageScaffold(
            title: 'Finance',
            subtitle: 'Payments, balances, and financial tracking.',
            child: StateView(
              state: vm.state,
              title: vm.title,
              message: vm.message,
              child: ListView(
                children: const [
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.account_balance_wallet_outlined),
                      title: Text('Wallet Balance'),
                      subtitle: Text('KES 2.4M available'),
                    ),
                  ),
                  SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.payments_outlined),
                      title: Text('Recent Payment'),
                      subtitle: Text('KES 240,000 received today'),
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