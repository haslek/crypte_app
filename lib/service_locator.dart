import 'utils.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt.instance;
void setUpLocator(){
  locator.registerSingleton<SocketService>(SocketService(),signalsReady: true);
  locator.registerSingleton<User>(User());
}