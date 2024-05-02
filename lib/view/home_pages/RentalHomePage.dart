import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../data/repository/IAdRepository.dart';
import '../../data/viewmodel/AdViewModel.dart';
import '../../data/viewmodel/AdViewModelFactory.dart';
import '../../model/Rental.dart';
import '../../model/UserModel.dart';
import '../../util/ServiceLocator.dart';

class RentalHomePage extends StatefulWidget {
  final UserModel currentUser;

  const RentalHomePage({Key? key, required this.currentUser}) : super(key: key);

  @override
  State<RentalHomePage> createState() => _RentalHomePageState();
}

class _RentalHomePageState extends State<RentalHomePage> {
  late IAdRepository adRepository;
  late AdViewModel adViewModel;
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<Rental> _rentals = [];
  int index = 0;

  @override
  void initState() {
    super.initState();
    adRepository = ServiceLocator().getAdRepository();
    adViewModel = AdViewModelFactory(adRepository).create();
    _loadMoreData(index);
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _loadMoreData(int index) async {
    setState(() {
      _isLoading = true;
    });
    List<Rental> additionalData = await adViewModel.getRentalsInRadius(
        widget.currentUser.latitude, widget.currentUser.longitude, 30, index);
    setState(() {
      _rentals.addAll(additionalData);
      _isLoading = false;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreData(_rentals.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GridView.builder(
            shrinkWrap: true, // Imposta shrinkWrap a true per consentire al GridView di adattarsi al suo contenuto
            physics: NeverScrollableScrollPhysics(), // Disabilita lo scroll all'interno del GridView
            itemCount: _rentals.length + (_isLoading ? 1 : 0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8.0,
              crossAxisSpacing: 8.0,
            ),
            itemBuilder: (BuildContext context, int index) {
              if (index < _rentals.length) {
                return _buildRentalItem(_rentals[index]);
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ],
      ),
    );
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildRentalItem(Rental rental) {
    return Container(
        padding: const EdgeInsets.all( 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.network(
                rental.imageUrl, // URL dell'immagine remota
                fit: BoxFit.cover, // Adatta l'immagine all'interno del container
              ),
            ),
            ListTile(
              onTap: () {
                // Aggiungere qui la logica da eseguire quando viene toccato il ListTile
              },
              title: Text(rental.title),
              subtitle: Text("€" + rental.dailyCost),
            ),
          ],
        ),
      );
  }
}
/*
Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inserire qui l'immagine
          Image.network(
            rental.imageUrl, // URL dell'immagine
            width: 100, // Larghezza dell'immagine
            height: 100, // Altezza dell'immagine
            fit: BoxFit.cover, // Modalità di adattamento dell'immagine
          ),
          Text(
            rental.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            rental.description,
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.red),
              SizedBox(width: 4),
            ],
          ),
        ],
      ),
    );
 */

