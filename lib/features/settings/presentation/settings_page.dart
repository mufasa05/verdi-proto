import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:verdi/core/widgets/state_view.dart';
import 'package:verdi/core/widgets/verdi_page_scaffold.dart';
import 'settings_view_model.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: Consumer<SettingsViewModel>(
        builder: (context, vm, _) {
          return VerdiPageScaffold(
            title: 'Settings',
            subtitle: 'Preferences, account, and app configuration.',
            child: StateView(
              state: vm.state,
              title: vm.title,
              message: vm.message,
              child: ListView(
                children: const [
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.person_outline),
                      title: Text('Profile'),
                      subtitle: Text('Update account information'),
                    ),
                  ),
                  SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.notifications_none_outlined),
                      title: Text('Notifications'),
                      subtitle: Text('Manage alerts and reminders'),
                    ),
                  ),
                  SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: Icon(Icons.language_outlined),
                      title: Text('Language'),
                      subtitle: Text('Select preferred language'),
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