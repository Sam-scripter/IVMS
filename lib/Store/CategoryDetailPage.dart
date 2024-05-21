import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryDetailPage extends StatefulWidget {
  final String categoryName;
  final String categoryId;

  const CategoryDetailPage(
      {super.key, required this.categoryId, required this.categoryName});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  Future<void> deleteProduct(String productId) async {
    DocumentReference productRef = FirebaseFirestore.instance
        .collection('Store')
        .doc(widget.categoryId)
        .collection('Products')
        .doc(productId);

    DocumentSnapshot productSnapshot = await productRef.get();
    if (productSnapshot.exists) {
      int currentNumberOfProducts = productSnapshot['Number'];

      if (currentNumberOfProducts > 1) {
        // Reduce the number of products by 1
        await productRef.update({
          'Number': currentNumberOfProducts - 1,
        });
      } else {
        // Delete the entire product when it reaches zero
        await productRef.delete();
      }
    }
  }

  Future<void> addProduct(String productId) async {
    DocumentReference productRef = FirebaseFirestore.instance
        .collection('Store')
        .doc(widget.categoryId)
        .collection('Products')
        .doc(productId);

    DocumentSnapshot productSnapshot = await productRef.get();
    if (productSnapshot.exists) {
      int currentNumberOfProducts = productSnapshot['Number'];

      // Add the number of products by 1
      await productRef.update({
        'Number': currentNumberOfProducts + 1,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.categoryName),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.lightBlueAccent,
          onPressed: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) => SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: AddProduct(categoryName: widget.categoryId),
                ),
              ),
            );
          },
          child: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        body: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('Store')
                    .doc(widget.categoryId)
                    .collection('Products')
                    .orderBy('timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    List<Widget> categoryNameWidgets = [];
                    for (var product in snapshot.data!.docs) {
                      var value = product.data() as Map<String, dynamic>;
                      String productId = product.id;
                      String productName = value['Product Name'];
                      int numberOfProducts = value['Number'];

                      categoryNameWidgets.add(Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  productName,
                                  style: GoogleFonts.lato(fontSize: 20),
                                ),
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: IconButton(
                                      onPressed: () => addProduct(productId),
                                      icon: const Icon(Icons.add),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    numberOfProducts.toString(),
                                    style: GoogleFonts.lato(fontSize: 17),
                                  ),
                                  SizedBox(width: 10),
                                  SizedBox(
                                    width: 40,
                                    child: IconButton(
                                      onPressed: () => deleteProduct(productId),
                                      icon: Icon(Icons.delete),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )));
                    }
                    return SingleChildScrollView(
                      child: Column(
                        children: categoryNameWidgets,
                      ),
                    );
                  } else {
                    return const Center(
                      child: Text('No products Found'),
                    );
                  }
                })
          ],
        ));
  }
}

class AddProduct extends StatefulWidget {
  final String categoryName;
  const AddProduct({super.key, required this.categoryName});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController productTitleController = TextEditingController();
  TextEditingController numberOfProductsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // String newProductTitle = "";
    // int numberOfProducts = 0;
    return Form(
      key: _formKey,
      child: Container(
        color: Color(0xFF0A0D22),
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
                    'Add Product',
                    style: GoogleFonts.lato(textStyle: TextStyle(fontSize: 20)),
                  )),
                  TextFormField(
                    autofocus: true,
                    decoration: InputDecoration(hintText: 'name of product'),
                    controller: productTitleController,
                    keyboardType: TextInputType.text,
                    textAlign: TextAlign.center,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a valid product title';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: numberOfProductsController,
                    decoration:
                        const InputDecoration(hintText: 'number of items'),
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the number of items for the product';
                      }
                      return null;
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      print(numberOfProductsController.text);
                      if (_formKey.currentState!.validate()) {
                        int numberOfProducts =
                            int.parse(numberOfProductsController.text.trim());
                        FirebaseFirestore.instance
                            .collection('Store')
                            .doc(widget.categoryName)
                            .collection('Products')
                            .add({
                          'Product Name': productTitleController.text.trim(),
                          'Number': numberOfProducts,
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
                                  'Please enter a valid product name.'),
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
                      'Add Product',
                      style:
                          GoogleFonts.lato(textStyle: TextStyle(fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
