import 'package:eco_swap/view/searchPages/Search_Page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path/path.dart';
import '../../data/repository/IAdRepository.dart';
import '../../data/repository/IUserRepository.dart';
import '../../data/viewmodel/AdViewModel.dart';
import '../../data/viewmodel/AdViewModelFactory.dart';
import '../../data/viewmodel/UserViewModel.dart';
import '../../data/viewmodel/UserViewModelFactory.dart';
import '../../model/Exchange.dart';
import '../../model/Rental.dart';
import '../../model/UserModel.dart';
import '../../util/ServiceLocator.dart';

import '../searchPages/ExchangePage.dart';
import '../searchPages/RentalPage.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late IUserRepository userRepository;
  late UserViewModel userViewModel;
  late IAdRepository adRepository;
  late AdViewModel adViewModel;
  late UserModel currentUser;
  int _selectedIndex = 0;
  Color rentalButtonColor = Color(0xFF7BFF81);
  Color exchangeButtonColor = Colors.transparent;
  bool obscurePassword = true;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollControllerRental = ScrollController();
  final ScrollController _scrollControllerExchange = ScrollController();
  bool _isLoadingRental = false;
  List<Rental> _rentals = [];
  List<Exchange> _exchanges = [];
  bool _isLoadingExchange=false;

  @override
  void initState() {
    super.initState();
    userRepository = ServiceLocator().getUserRepository();
    userViewModel = new UserViewModelFactory(userRepository).create();
    adRepository = ServiceLocator().getAdRepository();
    adViewModel = AdViewModelFactory(adRepository).create();
    userViewModel.getUser().then((value) {
      currentUser = value!;
      loadMoreRental(currentUser);
      loadMoreExchange(currentUser);
    });
    _handleLocationPermission().then((bool hasPermission) {
      userViewModel.updatePosition(hasPermission);
    });
    _selectedIndex = 0;
    _scrollControllerRental.addListener(_scrollRentalListener);
    _scrollControllerExchange.addListener(_scrollExchangeListener);
  }

  void _scrollRentalListener() {
    if (_scrollControllerRental.position.pixels ==
        _scrollControllerRental.position.maxScrollExtent) {
      loadMoreRental(currentUser);
    }
  }

  void _scrollExchangeListener() {
    if (_scrollControllerExchange.position.pixels ==
        _scrollControllerExchange.position.maxScrollExtent) {
      loadMoreExchange(currentUser);
    }
  }

  Future<void> loadMoreRental(UserModel user) async {
    setState(() {
      _isLoadingRental = true;
    });
    List<Rental> rentals = await adViewModel.getRentalsInRadius(
        user.latitude, user.longitude, 30, _rentals.length);
    _rentals.addAll(rentals);
    setState(() {
      _isLoadingRental = false;
    });
  }
  Future<void> loadMoreExchange(UserModel user) async{
    setState(() {
      _isLoadingExchange = true;
    });
    List<Exchange> exchanges = await adViewModel.getExchangesInRadius(
        user.latitude, user.longitude, 30, _exchanges.length);
    _exchanges.addAll(exchanges);
    setState(() {
      _isLoadingExchange = false;
    });
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context as BuildContext).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.primary,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 60.0),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.0),
              color: colorScheme.primary,
              border: Border.all( // Imposta il bordo del Container
                color: colorScheme.onPrimary, // Colore del bordo
                width: 1.0, // Spessore del bordo in pixel
              ),
            ),
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    textAlignVertical: TextAlignVertical.center,
                    controller: _searchController,
                    style: TextStyle(
                        color: colorScheme.onPrimary,
                    ),
                    decoration:  InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      prefixIconColor: colorScheme.onPrimary,
                      border: InputBorder.none,
                    ),
                    onEditingComplete: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchPage(
                            search: _searchController.text,
                            currentUser: currentUser,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 0;
                        rentalButtonColor = colorScheme.background;
                        exchangeButtonColor = Colors.transparent;
                      });
                    },
                    child: Text(
                      'Rental',
                      style: TextStyle(color: _selectedIndex == 0 ? Colors.black : colorScheme.onPrimary,),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.resolveWith<Color>(
                              (states) => rentalButtonColor),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      await loadMoreExchange(currentUser);
                      setState(() {
                        _selectedIndex = 1;
                        exchangeButtonColor = colorScheme.background;
                        rentalButtonColor = Colors.transparent;
                      });
                    },
                    child: Text(
                      'Exchange',
                      style: TextStyle(color: _selectedIndex == 1 ? Colors.black : colorScheme.onPrimary,),
                    ),
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.resolveWith<Color>(
                              (states) => exchangeButtonColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: <Widget>[
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    controller: _scrollControllerRental,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: _rentals.length + (_isLoadingRental ? 1 : 0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 2.0,
                      crossAxisSpacing: 2.0,
                      mainAxisExtent: 300,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      if (index < _rentals.length) {
                        return _buildRentalItem(_rentals[index], context);
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                  GridView.builder(
                    padding: EdgeInsets.zero,
                    controller: _scrollControllerExchange,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    itemCount: _exchanges.length + (_isLoadingExchange ? 1 : 0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 2.0,
                      crossAxisSpacing: 2.0,
                      mainAxisExtent: 300,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      if (index < _exchanges.length) {
                        return _buildExchangeItem(_exchanges[index], context);
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }



  Widget _buildRentalItem(Rental rental, BuildContext context) {
    bool isFavorite;
    isFavorite = currentUser.favoriteRentals.contains(rental.idToken);
      return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RentalPage(
              rental: rental,
              currentUser: currentUser,
            ),
          ),
        ).then((value) => setState(() {}));
      },
      child: Container(
        margin: const EdgeInsets.all(5.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: FadeInImage(
                placeholder: AssetImage('assets/image/loading_indicator.gif'),
                image: NetworkImage(rental.imageUrl),
                fit: BoxFit.cover,
                height: 200,
                width: 180,
              ),
            ),
            Stack(
              children: [
                ListTile(
                  title: Text(
                    rental.title,
                    overflow: TextOverflow.ellipsis, // Testo non va a capo
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    "€${rental.dailyCost}",
                    overflow: TextOverflow.ellipsis, // Testo non va a capo
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isFavorite) {
                          currentUser.removeFromFavoriteRentals(rental.idToken);
                          isFavorite=false;
                        } else {
                          currentUser.addToFavoriteRentals(rental.idToken);
                          isFavorite=true;
                        }
                        if(currentUser.favoriteRentals.contains(" ")) {
                          currentUser.removeFromFavoriteRentals(" ");
                          userViewModel.saveFavoriteRentals(currentUser);
                        }else{
                          userViewModel.saveFavoriteRentals(currentUser);
                        }
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8.0), // Personalizza il padding dell'icona
                      child: Icon(
                        Icons.favorite, // Icona del cuore come preferito
                        color: isFavorite ? Colors.red : Colors.grey, // Colore rosso per indicare che è contrassegnato come preferito
                        size: 24.0, // Dimensione dell'icona personalizzata
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExchangeItem(Exchange exchange, BuildContext context) {
    bool isFavorite=true;
    isFavorite = currentUser.favoriteExchange.contains(exchange.idToken);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExchangePage(
              exchange: exchange,
              currentUser: currentUser,
            ),
          ),
        ).then((value) => setState(() {}));
      },
      child: Container(
        margin: const EdgeInsets.all(5.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Column(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: FadeInImage(
                placeholder: AssetImage('assets/image/loading_indicator.gif'), // Immagine di placeholder (un'animazione di caricamento circolare, ad esempio)
                height: 200,
                width: 180,
                image: NetworkImage(exchange.imageUrl), // URL dell'immagine principale
                fit: BoxFit.cover, // Adatta l'immagine all'interno del container
              ),
            ),Stack(
              children: [
                ListTile(
                  onTap: () {
                  },
                  title: Text(
                    exchange.title,
                    overflow: TextOverflow.ellipsis, // Testo non va a capo
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () {
                        if (isFavorite) {
                          currentUser.removeFromFavoriteExchange(exchange.idToken);
                          setState(() {
                            isFavorite=false;
                          });
                        } else {
                          currentUser.addToFavoriteExchange(exchange.idToken);
                          setState(() {
                            isFavorite=true;
                          });
                        }
                        // Cambia il colore dell'icona in base a isFavorite
                        isFavorite ? Colors.red : Colors.grey;
                        if(currentUser.favoriteExchange.contains(" ")) {
                          currentUser.removeFromFavoriteExchange(" ");
                          userViewModel.saveFavoriteExchange(currentUser);
                        }else{
                          userViewModel.saveFavoriteExchange(currentUser);
                        }
                    },
                    child: Padding(
                      padding: EdgeInsets.all(8.0), // Personalizza il padding dell'icona
                      child: Icon(
                        Icons.favorite, // Icona del cuore come preferito
                        color: isFavorite ? Colors.red : Colors.grey,  // Colore rosso per indicare che è contrassegnato come preferito
                        size: 24.0, // Dimensione dell'icona personalizzata
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}