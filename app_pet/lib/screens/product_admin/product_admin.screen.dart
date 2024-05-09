import 'package:flutter/material.dart';
import 'package:shop_app/components/product_card.dart';
import 'package:shop_app/constants.dart';
import 'package:shop_app/screens/product_admin/components/add_product.screen.dart';
import 'package:shop_app/screens/product_detail_admin/product_detail_admin.screen.dart';
import 'package:shop_app/services/api.dart';
import 'package:shop_app/models/product.model.dart';

class ProductManagementScreen extends StatefulWidget {
  static String routeName = "/product_admin";

  // const ProductManagementScreen({super.key});

  @override
  _ProductManagementScreenState createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
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

  void _refreshData() {
    setState(() {
      products.clear();
      currentPage = 1;
      isFetching = false;
    });
    fetchProducts();
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
            isFetching = false;
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
        // Thêm dữ liệu mới mà không trùng lặp
        for (var newProduct in newProducts) {
          if (!products.any((product) => product.id == newProduct.id)) {
            products.add(newProduct);
          }
        }
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: isFetching && products.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : products.isEmpty
                  ? const Center(child: Text("Không có dữ liệu sản phẩm"))
                  : GridView.builder(
                      controller: _scrollController,
                      itemCount: products.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 0.7,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 16,
                      ),
                      itemBuilder: (context, index) => ProductCard(
                        product: products[index],
                        isAdmin: true,
                        onPress: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsAdminScreen(
                                  product: products[index]),
                            ),
                          ).then((_) =>
                              _refreshData()), // Cập nhật lại dữ liệu khi quay trở lại
                        },
                      ),
                    ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, AddProductScreen.routeName);
        },
        child: Icon(Icons.add),
        backgroundColor: kPrimaryColor,
      ),
    );
  }
}
