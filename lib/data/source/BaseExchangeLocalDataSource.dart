import '../../model/Exchange.dart';

abstract class BaseExchangeLocalDataSource{

  Future<void> loadLocal(Exchange exchange);
  Future<void> loadAll(List<Exchange> exchanges);
  Future<List<Exchange>> getLocal();
  Future<void> updateLocal(Exchange exchange);
  Future<void> deleteLocal(String idToken);
}