import 'package:boilerplate/models/productModel.dart';
import 'package:boilerplate/widgets/productCard.dart';
import 'package:boilerplate/screens/homescreen/productShimmer.dart';
import 'package:boilerplate/utils/productapi.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<ProductList> futureProducts;

  @override
  void initState() {
    super.initState();
    futureProducts = ApiService.fetchProducts();
  }

  Future<void> _refreshData() async {
    setState(() {
      futureProducts = ApiService.fetchProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: FutureBuilder<ProductList>(
          future: futureProducts,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: ListView.builder(
                  itemCount: 15,
                  itemBuilder: (context, index) {
                    return const ProductCardShimmer();
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.products.length,
                itemBuilder: (context, index) {
                  Product product = snapshot.data!.products[index];
                  return ProductCard(product: product);
                },
              );
            }
          },
        ),
      ),
    );
  }
}
