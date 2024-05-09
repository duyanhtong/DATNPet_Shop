import 'package:flutter/material.dart';
import 'package:shop_app/components/product_card.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/models/product.model.dart';
import 'package:shop_app/screens/home/components/search_field.dart';
import '../details/details_screen.dart';
import 'package:shop_app/services/api.dart';

class ProductsScreen extends StatefulWidget {
  final String? searchQuery;
  final int? categoryId;

  const ProductsScreen({Key? key, this.searchQuery, this.categoryId})
      : super(key: key);

  static String routeName = "/products";

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<ProductModel> products = [];
  int currentPage = 1;
  bool isFetching = false;
  final ScrollController _scrollController = ScrollController();
  String? _searchQuery;
  int? _categoryId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeSettings = ModalRoute.of(context)?.settings;
    if (routeSettings != null) {
      final args = routeSettings.arguments as Map<String, dynamic>?;
      if (args != null) {
        final searchQueryArg = args['searchQuery'] as String?;
        final categoryIdArg = args['categoryId'] as int?;
        if (_searchQuery != searchQueryArg || _categoryId != categoryIdArg) {
          setState(() {
            _searchQuery = searchQueryArg;
            _categoryId = categoryIdArg;
            products.clear();
            currentPage = 1;
          });

          fetchProducts();
        }
      }
    }
    if (_searchQuery == null && _categoryId == null) {
      fetchProducts();
    }
  }

  void fetchProducts() async {
    if (!isFetching) {
      setState(() {
        isFetching = true;
      });

      final newProducts = await Api.getAllProduct(
        searchQuery: _searchQuery,
        categoryId: _categoryId,
        page: currentPage,
      );

      setState(() {
        products.addAll(newProducts);
        currentPage++;
        isFetching = false;
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      fetchProducts();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Danh sách sản phẩm",
          style: TextStyle(color: kPrimaryColor, fontSize: 16.0),
        ),
        centerTitle: false,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: const SearchField(),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: products.isEmpty && !isFetching
              ? const Center(child: Text("Không có dữ liệu sản phẩm"))
              : GridView.builder(
                  controller: _scrollController,
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 200,
                    childAspectRatio: 0.7,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) => ProductCard(
                    product: products[index],
                    onPress: () => Navigator.pushNamed(
                      context,
                      DetailsScreen.routeName,
                      arguments:
                          ProductDetailsArguments(product: products[index]),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
