import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:nisave/state/login_state.dart';
import 'package:nisave/state/register_state.dart';
import 'package:nisave/services/api_service.dart'; // Assuming ApiService also uses ChangeNotifier or similar

class ProviderManager {
  static List<SingleChildWidget> getProviders() {
    return [
      ChangeNotifierProvider(create: (_) => LoginState()),
      ChangeNotifierProvider(create: (_) => RegisterState()),
      Provider(create: (_) => ApiService()), // This is just an example if ApiService needs no ChangeNotifier
      // Add more providers here
    ];
  }
}
