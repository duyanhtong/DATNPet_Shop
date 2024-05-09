import 'package:flutter/material.dart';
import 'package:shop_app/screens/products/products_screen.dart';
import 'package:shop_app/services/api.dart';

import 'section_title.dart';

class SpecialOffers extends StatelessWidget {
  const SpecialOffers({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SectionTitle(
            title: "Đặc biệt dành riêng cho bạn",
            press: () {},
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SpecialOfferCard(
                image: "assets/images/meocungbanner.jpg",
                category: "Mèo cưng",
                search: "mèo",
                //numOfBrands: 18,
                press: () {
                  Navigator.pushNamed(
                    context,
                    ProductsScreen.routeName,
                    arguments: {'searchQuery': "mèo"},
                  );
                },
              ),
              SpecialOfferCard(
                image: "assets/images/cuncungbanner.png",
                category: "Cún Cưng",
                search: "chó",
                //numOfBrands: 24,
                press: () {
                  Navigator.pushNamed(
                    context,
                    ProductsScreen.routeName,
                    arguments: {'searchQuery': "chó"},
                  );
                },
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class SpecialOfferCard extends StatefulWidget {
  const SpecialOfferCard({
    Key? key,
    required this.category,
    required this.image,
    required this.press,
    required this.search,
  }) : super(key: key);

  final String category, image, search;
  final GestureTapCallback press;

  @override
  State<SpecialOfferCard> createState() => _SpecialOfferCardState();
}

class _SpecialOfferCardState extends State<SpecialOfferCard> {
  int numOfBrands = 0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getCount();
  }

  void getCount() async {
    setState(() {
      isLoading = true;
    });

    int count = await Api.getCountProduct(widget.search);

    setState(() {
      numOfBrands = count;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: GestureDetector(
        onTap: widget.press,
        child: SizedBox(
          width: 180,
          height: 100,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              children: [
                Image.asset(
                  widget.image,
                  fit: BoxFit.cover,
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black54,
                        Colors.black38,
                        Colors.black26,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : Text.rich(
                          TextSpan(
                            style: const TextStyle(color: Colors.white),
                            children: [
                              TextSpan(
                                text: "${widget.category}\n",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(text: "${numOfBrands} sản phẩm")
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
