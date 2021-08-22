import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';

class CategoryProducts extends StatefulWidget {
  CategoryProducts({Key key, this.category_name, this.category_id})
      : super(key: key);
  final String category_name;
  final int category_id;

  @override
  _CategoryProductsState createState() => _CategoryProductsState();
}

class _CategoryProductsState extends State<CategoryProducts> {
  int listor = 0;
  List searchresult = [];
  List searchresult1 = [];

  ScrollController _scrollController = ScrollController();
  ScrollController _xcrollController = ScrollController();
  TextEditingController _searchController = TextEditingController();

  List<dynamic> _productList = [];
  bool _isInitial = true;
  int _page = 1;
  String _searchKey = "";
  int _totalData = 0;
  bool _showLoadingContainer = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    fetchData();

    _xcrollController.addListener(() {
      //print("position: " + _xcrollController.position.pixels.toString());
      //print("max: " + _xcrollController.position.maxScrollExtent.toString());

      if (_xcrollController.position.pixels ==
          _xcrollController.position.maxScrollExtent) {
        setState(() {
          _page++;
        });
        _showLoadingContainer = true;
        fetchData();
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    _xcrollController.dispose();
    super.dispose();
  }

  fetchData() async {
    var productResponse = await ProductRepository().getCategoryProducts(
        id: widget.category_id, page: _page, name: _searchKey);
    _productList.addAll(productResponse.products);
    _isInitial = false;
    _totalData = productResponse.meta.total;
    _showLoadingContainer = false;
    setState(() {});
  }

  reset() {
    _productList.clear();
    _isInitial = true;
    _totalData = 0;
    _page = 1;
    _showLoadingContainer = false;
    setState(() {});
  }

  Future<void> _onRefresh() async {
    reset();
    fetchData();
  }
  void searchOperation(String searchText) {
    searchresult.clear();
    if (searchText != "") {
      for (int i = 0; i < _productList.length; i++) {
        String data1 = _productList[i].name;
        if (_productList[i]
            .name
            .toLowerCase()
            .contains(searchText.toLowerCase())) {
          setState(() {
            searchresult.add(_productList[i]);
            print("012012012012012012012");
            print(searchresult);
          });
        }
      }
    }
  }


  void searchOperation1(String searchText) {
    searchresult.clear();
    searchresult1.clear();
    if (searchText != "") {
      for (int i = 0; i < _productList.length; i++) {
        String data1 = _productList[i].name;
        if (_productList[i]
            .name
            .toLowerCase()
            .contains(searchText.toLowerCase())) {
          setState(() {
            searchresult1.add(_productList[i]);
            print("012012012012012012012");
            print(searchresult1);
          });
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: buildAppBar(context),
        body: ListView(
          children: [
            if (searchresult.length == 0)
              Container()
            else
              Container(
                child: ListView.builder(
                  itemCount: searchresult.length,
                  controller: _scrollController,
                  // padding: EdgeInsets.all(16),
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    // 3
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _searchController.text = searchresult[index].name;
                          searchOperation1(searchresult[index].name);
                          searchresult.clear;
                        });
                      },
                      child: Column(
                        children: [
                          Padding(
                            padding:
                            const EdgeInsets.only(left: 15.0, bottom: 15),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                searchresult[index].name,
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                color: Colors.white,
              ),
            buildProductList(),
            Align(
                alignment: Alignment.bottomCenter,
                child: buildLoadingContainer())
          ],
        ));
  }

  Container buildLoadingContainer() {
    return Container(
      height: _showLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalData == _productList.length
            ? "No More Products"
            : "Loading More Products ..."),
      ),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      toolbarHeight: 75,
      /*bottom: PreferredSize(
          child: Container(
            color: MyTheme.textfield_grey,
            height: 1.0,
          ),
          preferredSize: Size.fromHeight(4.0)),*/
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: Container(
          width: 250,
          child: Padding(
              padding: MediaQuery.of(context).viewPadding.top >
                  30 //MediaQuery.of(context).viewPadding.top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
                  ? const EdgeInsets.symmetric(vertical: 36.0, horizontal: 0.0)
                  : const EdgeInsets.symmetric(vertical: 14.0, horizontal: 0.0),
              child: TextField(
                controller: _searchController,
                onTap: () {},
                onChanged: searchOperation,
                //autofocus: true,

                onSubmitted: (txt) {
                  _searchKey = txt;
                  setState(() {});

                },
                decoration: InputDecoration(
                    hintText: "Search here ?",
                    hintStyle: TextStyle(
                        fontSize: 12.0, color: MyTheme.textfield_grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyTheme.white, width: 0.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: MyTheme.white, width: 0.0),
                    ),
                    contentPadding: EdgeInsets.all(0.0)),
              )),),
      elevation: 0.0,
      titleSpacing: 0,
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0.0),
          child: IconButton(
            icon: Icon(Icons.search, color: MyTheme.dark_grey),
            onPressed: () {
              _searchKey = _searchController.text.toString();
              reset();
              fetchData();
            },
          ),
        ),
        IconButton(
            icon: Icon(Icons.list_outlined),
            onPressed: () {
              setState(() {
                if (listor == 0) {
                  listor = 1;
                } else {
                  listor = 0;
                }
              });
            })
      ],
    );
  }

  buildProductList() {
    if (_isInitial && _productList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildProductGridShimmer(scontroller: _scrollController));
    } else if (_productList.length > 0) {
      return RefreshIndicator(
        color: MyTheme.accent_color,
        backgroundColor: Colors.white,
        displacement: 0,
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
            controller: _xcrollController,
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            child:
            (searchresult1.length == 0) ?
            (listor == 1)
                ? ListView.builder(
                    itemCount: _productList.length,
                    controller: _scrollController,

                    // padding: EdgeInsets.all(16),
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      // 3
                      return Column(
                        children: [
                          ProductCard(
                            id: _productList[index].id,
                            image: _productList[index].thumbnail_image,
                            name: _productList[index].name,
                            price: _productList[index].base_price,
                            rating: _productList[index].rating,
                            listor: listor,
                          ),
                          Divider(),
                        ],
                      );
                    },
                  )
                : Container(
                    color: Color(0xffF1F3F6),
                    child: GridView.builder(
                      // 2
                      //addAutomaticKeepAlives: true,
                      itemCount: _productList.length,
                      controller: _scrollController,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 2,
                          mainAxisSpacing: 2,
                          childAspectRatio: 0.620),
                      // padding: EdgeInsets.all(16),
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        // 3
                        return Container(
                          color: Color(0xffF1F3F6),
                          child: ProductCard(
                            id: _productList[index].id,
                            image: _productList[index].thumbnail_image,
                            name: _productList[index].name,
                            price: _productList[index].base_price,
                            rating: _productList[index].rating,
                          ),
                        );
                      },
                    ),
                  ) : (listor == 1)
                ? ListView.builder(
              itemCount: searchresult1.length,
              controller: _scrollController,

              // padding: EdgeInsets.all(16),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                // 3
                return Column(
                  children: [
                    ProductCard(
                      id: searchresult1[index].id,
                      image: searchresult1[index].thumbnail_image,
                      name: searchresult1[index].name,
                      price: searchresult1[index].base_price,
                      rating: searchresult1[index].rating,
                      listor: listor,
                    ),
                    Divider(),
                  ],
                );
              },
            )
                : Container(
              color: Color(0xffF1F3F6),
              child: GridView.builder(
                // 2
                //addAutomaticKeepAlives: true,
                itemCount: searchresult1.length,
                controller: _scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                    childAspectRatio: 0.620),
                // padding: EdgeInsets.all(16),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  // 3
                  return Container(
                    color: Color(0xffF1F3F6),
                    child: ProductCard(
                      id: searchresult1[index].id,
                      image: searchresult1[index].thumbnail_image,
                      name: searchresult1[index].name,
                      price: searchresult1[index].base_price,
                      rating: searchresult1[index].rating,
                    ),
                  );
                },
              ),
            )
            // GridView.builder(
            //   // 2
            //   //addAutomaticKeepAlives: true,
            //   itemCount: _productList.length,
            //   controller: _scrollController,
            //   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //       crossAxisCount: 2,
            //       crossAxisSpacing: 10,
            //       mainAxisSpacing: 10,
            //       childAspectRatio: 0.618),
            //   padding: EdgeInsets.all(16),
            //   //physics: NeverScrollableScrollPhysics(),
            //   shrinkWrap: true,
            //   itemBuilder: (context, index) {
            //     // 3
            //     return Flexible(
            //       child: ProductCard(
            //         id: _productList[index].id,
            //         image: _productList[index].thumbnail_image,
            //         name: _productList[index].name,
            //         price: _productList[index].base_price,
            //       ),
            //     );
            //   },
            // ),
            ),
      );
    } else if (_totalData == 0) {
      return Center(child: Text("No data is available"));
    } else {
      return Container(); // should never be happening
    }
  }
}
