import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:integrated_vehicle_management_system/Store/CategoryDetailPage.dart';

class StoreHome extends StatefulWidget {
  const StoreHome({super.key});

  // final List<String> categories;
  //
  // const StoreHome({super.key, required this.categories});

  @override
  State<StoreHome> createState() => _StoreHomeState();
}

class _StoreHomeState extends State<StoreHome> {
  Future<List<Map<String, dynamic>>> getAllProducts() async {
    List<Map<String, dynamic>> allProducts = [];

    QuerySnapshot productsSnapshot =
        await FirebaseFirestore.instance.collectionGroup('Products').get();

    for (QueryDocumentSnapshot productDoc in productsSnapshot.docs) {
      Map<String, dynamic> productData =
          productDoc.data() as Map<String, dynamic>;
      allProducts.add(productData);
    }

    return allProducts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Repair Store'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue,
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: const AddCategory(),
              ),
            ),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Categories',
                style:
                    GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              StreamBuilder<List<Tuple2<String, String>>>(
                stream: FirebaseFirestore.instance
                    .collection('Store')
                    .snapshots()
                    .map((snapshot) {
                  return snapshot.docs.map((doc) {
                    var value = doc.data() as Map<String, dynamic>;
                    String categoryName = value['name'] as String ?? '';
                    String categoryId = doc.id;
                    return Tuple2<String, String>(categoryName, categoryId);
                  }).toList();
                }),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator(); // Or any other loading indicator
                  }
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }
                  List<Tuple2<String, String>> categories = snapshot.data ?? [];
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: categories.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return CategoryCard(
                        categoryData: categories[index],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              Text(
                'Featured Products',
                style:
                    GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: getAllProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Text('Loading....'),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No featured products available.');
                  } else {
                    return buildCarousel(snapshot.data!);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCarousel(List<Map<String, dynamic>> products) {
    return CarouselSlider(
      items: products.map((product) {
        String productName = product['Product Name'];
        return Container(
          margin: const EdgeInsets.all(8),
          child: Card(
            color: const Color(0xFF111328),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 4,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(productName),
              ),
            ),
          ),
        );
      }).toList(),
      options: CarouselOptions(
        height: 160,
        enlargeCenterPage: true,
        autoPlay: true,
        aspectRatio: 16 / 9,
        autoPlayCurve: Curves.fastOutSlowIn,
        enableInfiniteScroll: true,
        autoPlayAnimationDuration: const Duration(milliseconds: 800),
        viewportFraction: 0.8,
      ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Tuple2<String, String> categoryData;

  CategoryCard({Key? key, required this.categoryData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String category = categoryData.item1;
    final String categoryId = categoryData.item2;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CategoryDetailPage(
            categoryName: category,
            categoryId: categoryId,
          ),
        ),
      ),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(16.0), // Adjust the value as needed
        ),
        color: const Color(0xFF111328),
        elevation: 6,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(category),
          ),
        ),
      ),
    );
  }
}

class AddCategory extends StatelessWidget {
  const AddCategory({super.key});

  @override
  Widget build(BuildContext context) {
    String newCategoryTitle = "";
    return Container(
      color: const Color(0xFF0A0D22),
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), topRight: Radius.circular(30)),
          color: Color(0xFF1D1E33),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                    child: Text(
                  'Add Category',
                  style: GoogleFonts.lato(
                      textStyle: const TextStyle(fontSize: 20)),
                )),
                TextField(
                  autofocus: true,
                  textAlign: TextAlign.center,
                  onChanged: (value) {
                    newCategoryTitle = value;
                  },
                ),
                ElevatedButton(
                  onPressed: () {
                    if (newCategoryTitle.isNotEmpty) {
                      // Check if the department title is not empty before adding
                      FirebaseFirestore.instance.collection('Store').add({
                        'name': newCategoryTitle,
                        'timestamp': FieldValue.serverTimestamp(),
                      });
                      Navigator.pop(context);
                    } else {
                      // Handle case where the department title is empty
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: const Text(
                                'Please enter a valid category name.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text(
                    'Add Category',
                    style: GoogleFonts.lato(textStyle: TextStyle(fontSize: 18)),
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

class Tuple2<A, B> {
  final A item1;
  final B item2;

  Tuple2(this.item1, this.item2);
}
