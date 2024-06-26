import 'package:flutter/cupertino.dart';

import '../../model/Exchange.dart';

abstract class BaseExchangeDataSource{
  late final Function (Exchange exchange) onLoadFinished;
  late final Function (List<Exchange> exchanges) loadAllExchange;


  Future<String?> loadExchange(Exchange exchange);
  Future<String> uploadImage(String imagePath);
  Future<void> loadFromFirebaseToLocal(String userId);
  Future<Exchange?> getExchange(String idToken);
  Future<List<Exchange>> getAllExchanges();
  Future<List<Exchange>> getAllUserExchanges(String userId);
  Future<List<Exchange>> getExchangesInRadius(double latUser, double longUser, double radiusKm, int startIndex);
  Future<List<Exchange>> searchItems(double latUser, double longUser, String query);
  Future<List<Exchange>> getExchangesByIdTokens(List idTokens);
  Future<void> removeExchange(String idToken);

  void setCallback(Function (Exchange exchange) onLoadFinished, Function (List<Exchange> exchanges) loadAllExchange){
    this.loadAllExchange=loadAllExchange;
    this.onLoadFinished=onLoadFinished;
  }
}
