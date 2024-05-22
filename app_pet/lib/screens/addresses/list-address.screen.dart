import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop_app/components/custom_dialog.dart';

import 'package:shop_app/constants.dart';
import 'package:shop_app/models/Address.model.dart';
import 'package:shop_app/screens/addresses/components/add_address_dialog.dart';

import 'package:shop_app/screens/addresses/components/address_card.dart';
import 'package:shop_app/screens/addresses/components/detail_address_dialog.dart';

import 'package:shop_app/services/api.dart';

class ListAddressScreen extends StatefulWidget {
  static String routeName = "/list_address";
  const ListAddressScreen({Key? key}) : super(key: key);

  @override
  _ListAddressScreenState createState() => _ListAddressScreenState();
}

class _ListAddressScreenState extends State<ListAddressScreen> {
  late Future<List<AddressModel>> _futureAddresses;
  bool _loading = false;
  List<AddressModel> _addresses = [];
  ScrollController _scrollController = ScrollController();
  int _currentPage = 1;

  int? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
    _futureAddresses = fetchAddresses(_currentPage).then((addresses) {
      final activeAddresses =
          addresses.where((address) => address.isActive).toList();
      if (activeAddresses.isNotEmpty) {
        _selectedAddressId = activeAddresses.first.id;
      }
      return addresses;
    });
    _scrollController.addListener(_scrollListener);
  }

  Future<void> _loadAddresses() async {
    if (!_loading) {
      setState(() => _loading = true);
      try {
        final newAddresses = await Api.getListAddress(page: _currentPage);
        setState(() {
          _addresses.addAll(newAddresses);
          _loading = false;
        });
      } catch (error) {
        debugPrint('Failed to load more addresses: $error');
        setState(() => _loading = false);
      }
    }
  }

  void _refreshAddresses() async {
    setState(() {
      _loading = true;
    });

    try {
      int pageSize = 10 * _currentPage;
      final newAddresses = await Api.getListAddress(items_per_page: pageSize);
      setState(() {
        _addresses.clear();
        _addresses.addAll(newAddresses);
        _loading = false;
      });
    } catch (error) {
      debugPrint('Failed to refresh addresses: $error');
      setState(() {
        _loading = false;
      });
    }
  }

  void _updateSelectedAddress(int? selectedId) async {
    if (selectedId != null) {
      setState(() => _loading = true);
      final result = await Api.updateDefaultAddress(selectedId);
      // ignore: use_build_context_synchronously
      showCustomDialog(context, "Địa chỉ", result);
      _refreshAddresses();
    }
  }

  Future<List<AddressModel>> fetchAddresses(int page) async {
    try {
      final addresses = await Api.getListAddress(page: page);
      return addresses;
    } catch (error) {
      debugPrint('Failed to load addresses: $error');
      return [];
    }
  }

  void _showAddAddressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddAddressDialog(
          onAddressAdded: (addressData) {
            _refreshAddresses();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _currentPage++;
      _loadAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Danh sách địa chỉ',
          style: TextStyle(color: kPrimaryColor, fontSize: 16.0),
        ),
      ),
      body: _loading && _addresses.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollController,
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                return Dismissible(
                  key: Key(_addresses[index].id.toString()),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) async {
                    final result =
                        await Api.removeAddress(_addresses[index].id);
                    if (result == "OK") {
                      setState(() {
                        _addresses.removeAt(index);
                      });
                      await _loadAddresses();
                      _refreshAddresses();
                    } else {
                      // ignore: use_build_context_synchronously
                      showCustomDialog(context, "Địa chỉ", result);
                      await _loadAddresses();
                      _refreshAddresses();
                    }
                  },
                  background: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE6E6),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      children: [
                        const Spacer(),
                        SvgPicture.asset("assets/icons/Trash.svg"),
                      ],
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AddressDetailsDialog(
                              address: _addresses[index]);
                        },
                      ).then((_) {
                        _refreshAddresses();
                      });
                    },
                    child: AddressCart(
                      address: _addresses[index],
                      isSelected: _addresses[index].id == _selectedAddressId,
                      onSelected: () {
                        setState(() {
                          _selectedAddressId = _addresses[index].id;
                        });
                      },
                      onUpdate: _updateSelectedAddress,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddAddressDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
