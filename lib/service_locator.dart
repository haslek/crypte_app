import 'utils.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;
void setUpLocator(){
  locator.registerSingleton<User>(User(),signalsReady: true);
  locator.registerSingleton<DBService>(DBService(),signalsReady: true);
  locator.registerSingleton<SocketService>(SocketService(),signalsReady: true);
}