import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/screens/seller_details.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:active_ecommerce_flutter/ui_elements/shop_square_card.dart';
import 'package:active_ecommerce_flutter/ui_elements/brand_square_card.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:active_ecommerce_flutter/repositories/category_repository.dart';
import 'package:active_ecommerce_flutter/repositories/brand_repository.dart';
import 'package:active_ecommerce_flutter/repositories/shop_repository.dart';
import 'package:active_ecommerce_flutter/helpers/reg_ex_inpur_formatter.dart';
import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class WhichFilter {
  String option_key;
  String name;

  WhichFilter(this.option_key, this.name);

  static List<WhichFilter> getWhichFilterList() {
    return <WhichFilter>[
      WhichFilter('product', 'Product'),
      WhichFilter('sellers', 'Sellers'),
      WhichFilter('brands', 'Brands'),
    ];
  }
}

class Filter extends StatefulWidget {
  Filter({
    Key key,
    this.selected_filter = "product",
  }) : super(key: key);

  final String selected_filter;

  @override
  _FilterState createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  final _amountValidator = RegExInputFormatter.withRegex(
      '^\$|^(0|([1-9][0-9]{0,}))(\\.[0-9]{0,})?\$');

  ScrollController _productScrollController = ScrollController();
  ScrollController _brandScrollController = ScrollController();
  ScrollController _shopScrollController = ScrollController();
  List searchresult = [];
  List searchresult1 = [];
  bool issearch = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ScrollController _scrollController;
  WhichFilter _selectedFilter;
  String _givenSelectedFilterOptionKey; // may be it can come from another page
  var _selectedSort = "";
  List<WhichFilter> _which_filter_list = WhichFilter.getWhichFilterList();
  List<DropdownMenuItem<WhichFilter>> _dropdownWhichFilterItems;
  List<dynamic> _selectedCategories = [];
  List<dynamic> _selectedBrands = [];
  final List<String> testing = [
    'Baby Foods',
    'Confectionery',
  ];
  final List<String> hotSearch = [
    'Foods Chain',
    'Confectionery',
    'home',
    'iphone assemblies'
  ];

  final TextEditingController _searchController = new TextEditingController();
  final TextEditingController _minPriceController = new TextEditingController();
  final TextEditingController _maxPriceController = new TextEditingController();

  //--------------------
  List<dynamic> _filterBrandList = List();
  bool _filteredBrandsCalled = false;
  List<dynamic> _filterCategoryList = List();
  bool _filteredCategoriesCalled = false;

  //----------------------------------------
  String _searchKey = "";

  List<dynamic> _productList = [];
  bool _isProductInitial = true;
  int _productPage = 1;
  int _totalProductData = 0;
  bool _showProductLoadingContainer = false;

  List<dynamic> _brandList = [];
  bool _isBrandInitial = true;
  int _brandPage = 1;
  int _totalBrandData = 0;
  bool _showBrandLoadingContainer = false;

  List<dynamic> _shopList = [];
  bool _isShopInitial = true;
  int _shopPage = 1;
  int _totalShopData = 0;
  bool _showShopLoadingContainer = false;

  int listor = 0;

  get color => null;

  //----------------------------------------

  fetchFilteredBrands() async {
    var filteredBrandResponse = await BrandRepository().getFilterPageBrands();
    _filterBrandList.addAll(filteredBrandResponse.brands);
    _filteredBrandsCalled = true;
    setState(() {});
  }

  fetchFilteredCategories() async {
    var filteredCategoriesResponse =
        await CategoryRepository().getFilterPageCategories();
    _filterCategoryList.addAll(filteredCategoriesResponse.categories);
    _filteredCategoriesCalled = true;
    setState(() {});
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _productScrollController.dispose();
    _brandScrollController.dispose();
    _shopScrollController.dispose();
    super.dispose();
  }

  init() {
    _givenSelectedFilterOptionKey = widget.selected_filter;

    _dropdownWhichFilterItems =
        buildDropdownWhichFilterItems(_which_filter_list);
    _selectedFilter = _dropdownWhichFilterItems[0].value;

    for (int x = 0; x < _dropdownWhichFilterItems.length; x++) {
      if (_dropdownWhichFilterItems[x].value.option_key ==
          _givenSelectedFilterOptionKey) {
        _selectedFilter = _dropdownWhichFilterItems[x].value;
      }
    }

    fetchFilteredCategories();
    fetchFilteredBrands();

    if (_selectedFilter.option_key == "sellers") {
      fetchShopData();
    } else if (_selectedFilter.option_key == "brands") {
      fetchBrandData();
    } else {
      fetchProductData();
    }

    //set scroll listeners

    _productScrollController.addListener(() {
      if (_productScrollController.position.pixels ==
          _productScrollController.position.maxScrollExtent) {
        setState(() {
          _productPage++;
        });
        _showProductLoadingContainer = true;
        fetchProductData();
      }
    });

    _brandScrollController.addListener(() {
      if (_brandScrollController.position.pixels ==
          _brandScrollController.position.maxScrollExtent) {
        setState(() {
          _brandPage++;
        });
        _showBrandLoadingContainer = true;
        fetchBrandData();
      }
    });

    _shopScrollController.addListener(() {
      if (_shopScrollController.position.pixels ==
          _shopScrollController.position.maxScrollExtent) {
        setState(() {
          _shopPage++;
        });
        _showShopLoadingContainer = true;
        fetchShopData();
      }
    });
  }

  fetchProductData() async {
    //print("sc:"+_selectedCategories.join(",").toString());
    //print("sb:"+_selectedBrands.join(",").toString());
    var productResponse = await ProductRepository().getFilteredProducts(
        page: _productPage,
        name: _searchKey,
        sort_key: _selectedSort,
        brands: _selectedBrands.join(",").toString(),
        categories: _selectedCategories.join(",").toString(),
        max: _maxPriceController.text.toString(),
        min: _minPriceController.text.toString());

    _productList.addAll(productResponse.products);
    _isProductInitial = false;
    _totalProductData = productResponse.meta.total;
    _showProductLoadingContainer = false;
    setState(() {
      print("000000000000000000000000000000000000000000");
      print(_productList);
    });
  }

  resetProductList() {
    _productList.clear();
    _isProductInitial = true;
    _totalProductData = 0;
    _productPage = 1;
    _showProductLoadingContainer = false;
    setState(() {});
  }

  fetchBrandData() async {
    var brandResponse =
        await BrandRepository().getBrands(page: _brandPage, name: _searchKey);
    _brandList.addAll(brandResponse.brands);
    _isBrandInitial = false;
    _totalBrandData = brandResponse.meta.total;
    _showBrandLoadingContainer = false;
    setState(() {});
  }

  resetBrandList() {
    _brandList.clear();
    _isBrandInitial = true;
    _totalBrandData = 0;
    _brandPage = 1;
    _showBrandLoadingContainer = false;
    setState(() {});
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

  fetchShopData() async {
    var shopResponse =
        await ShopRepository().getShops(page: _shopPage, name: _searchKey);
    _shopList.addAll(shopResponse.shops);
    _isShopInitial = false;
    _totalShopData = shopResponse.meta.total;
    _showShopLoadingContainer = false;
    //print("_shopPage:" + _shopPage.toString());
    //print("_totalShopData:" + _totalShopData.toString());
    setState(() {});
  }

  resetShopList() {
    _shopList.clear();
    _isShopInitial = true;
    _totalShopData = 0;
    _shopPage = 1;
    _showShopLoadingContainer = false;
    setState(() {});
  }

  Future<void> _onProductListRefresh() async {
    resetProductList();
    fetchProductData();
  }

  Future<void> _onBrandListRefresh() async {
    resetBrandList();
    fetchBrandData();
  }

  Future<void> _onShopListRefresh() async {
    resetShopList();
    fetchShopData();
  }

  _applyProductFilter() {
    resetProductList();
    fetchProductData();
  }

  _onSearchSubmit() {
    if (_selectedFilter.option_key == "sellers") {
      resetShopList();
      fetchShopData();
    } else if (_selectedFilter.option_key == "brands") {
      resetBrandList();
      fetchBrandData();
    } else {
      resetProductList();
      fetchProductData();
    }
  }

  _onSortChange() {
    resetProductList();
    fetchProductData();
  }

  _onWhichFilterChange() {
    if (_selectedFilter.option_key == "sellers") {
      resetShopList();
      fetchShopData();
    } else if (_selectedFilter.option_key == "brands") {
      resetBrandList();
      fetchBrandData();
    } else {
      resetProductList();
      fetchProductData();
    }
  }

  List<DropdownMenuItem<WhichFilter>> buildDropdownWhichFilterItems(
      List which_filter_list) {
    List<DropdownMenuItem<WhichFilter>> items = List();
    for (WhichFilter which_filter_item in which_filter_list) {
      items.add(
        DropdownMenuItem(
          value: which_filter_item,
          child: Text(which_filter_item.name),
        ),
      );
    }
    return items;
  }

  Container buildProductLoadingContainer() {
    return Container(
      height: _showProductLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalProductData == _productList.length
            ? "No More Products"
            : "Loading More Products ..."),
      ),
    );
  }

  Container buildBrandLoadingContainer() {
    return Container(
      height: _showBrandLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalBrandData == _brandList.length
            ? "No More Brands"
            : "Loading More Brands ..."),
      ),
    );
  }

  Container buildShopLoadingContainer() {
    return Container(
      height: _showShopLoadingContainer ? 36 : 0,
      width: double.infinity,
      color: Colors.white,
      child: Center(
        child: Text(_totalShopData == _shopList.length
            ? "No More Shops"
            : "Loading More Shops ..."),
      ),
    );
  }

  //--------------------

  @override
  Widget build(BuildContext context) {
    /*print(_appBar.preferredSize.height.toString()+" Appbar height");
    print(kToolbarHeight.toString()+" kToolbarHeight height");
    print(MediaQuery.of(context).padding.top.toString() +" MediaQuery.of(context).padding.top");*/
    return Scaffold(
      bottomNavigationBar: buildBottomAppBar(context),
      endDrawer: buildFilterDrawer(),
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: Stack(overflow: Overflow.visible, children: [
        _selectedFilter.option_key == 'product'
            ? issearch == false ? Container() : buildProductList()
            : (_selectedFilter.option_key == 'brands'
                ? buildBrandList()
                : buildShopList()),
        Positioned(
          top: 0.0,
          left: 0.0,
          right: 0.0,
          child: Container(color: Colors.grey,child: buildAppBar(context)),
        ),
        Align(
            alignment: Alignment.bottomCenter,
            child: _selectedFilter.option_key == 'product'
                ? buildProductLoadingContainer()
                : (_selectedFilter.option_key == 'brands'
                    ? buildBrandLoadingContainer()
                    : buildShopLoadingContainer()))
      ]),
    );
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          new Container(),
        ],
        backgroundColor: Colors.white.withOpacity(0.95),
        centerTitle: false,
        flexibleSpace: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 45.0, 0.0, 0.0),
          child: Column(
            children: [
              Container(child: buildTopAppbar(context)),
              if (issearch == true)
                if (searchresult.length == 0)
                  (_searchController.text == "")
                      ? Padding(
                          padding: const EdgeInsets.only(
                              top: 20, right: 8.0, left: 15),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.8,
                            width: MediaQuery.of(context).size.width,
                            color: Colors.grey[50],
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Search Histroy",
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                    Icon(Icons.delete),
                                  ],
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: StaggeredGridView.countBuilder(
                                    itemCount: testing.length,
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    crossAxisCount: 8,
                                    staggeredTileBuilder: (int index) {
                                      if (testing[index].length < 5) {
                                        return StaggeredTile.count(2, 1);
                                      } else if (testing[index].length < 16) {
                                        return StaggeredTile.count(3, 1);
                                      } else {
                                        return StaggeredTile.count(4, 1);
                                      }
                                    },
                                    mainAxisSpacing: 12.0,
                                    crossAxisSpacing: 10.0,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Card(
                                        color: Colors.grey[100],
                                        child: Center(
                                            child: Text(
                                          testing[index],
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 16),
                                        )),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      "Hot Searches",
                                      style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  child: StaggeredGridView.countBuilder(
                                    itemCount: hotSearch.length,
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    crossAxisCount: 8,
                                    staggeredTileBuilder: (int index) {
                                      if (hotSearch[index].length < 5) {
                                        return StaggeredTile.count(2, 1);
                                      } else if (hotSearch[index].length < 16) {
                                        return StaggeredTile.count(3, 1);
                                      } else {
                                        return StaggeredTile.count(4, 1);
                                      }
                                    },
                                    mainAxisSpacing: 12.0,
                                    crossAxisSpacing: 10.0,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return Card(
                                        color: Colors.grey[100],
                                        child: Center(
                                            child: Text(
                                          hotSearch[index],
                                          style: TextStyle(
                                              color: Colors.grey, fontSize: 16),
                                        )),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Container()
                else
                  Container(
                    height: MediaQuery.of(context).size.height * 0.9,
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
                                padding: const EdgeInsets.only(
                                    left: 15.0, bottom: 15),
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
            ],
          ),
        ));
  }

  Row buildBottomAppBar(BuildContext context) {
    return Row(
      // mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 25.0, // soften the shadow
                spreadRadius: 5.0, //extend the shadow
                offset: Offset(
                  15.0, // Move to right 10  horizontally
                  15.0, // Move to bottom 10 Vertically
                ),
              )
            ],
            color: Colors.white,
            /* border: Border.symmetric(
                  vertical: BorderSide(color: MyTheme.light_grey, width: .5),
                  horizontal: BorderSide(color: MyTheme.light_grey, width: 1))*/
          ),
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          height: 52,
          width: MediaQuery.of(context).size.width * .33,
          child: new DropdownButton<WhichFilter>(
            icon: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Icon(Icons.expand_more, color: Colors.black54),
            ),
            hint: Text(
              "Products",
              style: TextStyle(
                color: Colors.black,
                fontSize: 13,
              ),
            ),
            iconSize: 14,
            underline: SizedBox(),
            value: _selectedFilter,
            items: _dropdownWhichFilterItems,
            onChanged: (WhichFilter selectedFilter) {
              setState(() {
                _selectedFilter = selectedFilter;
              });

              _onWhichFilterChange();
            },
          ),
        ),
        GestureDetector(
          onTap: () {
            _selectedFilter.option_key == "product"
                ? _scaffoldKey.currentState.openEndDrawer()
                : ToastComponent.showDialog(
                    "You can use filters while searching for products.",
                    context,
                    gravity: Toast.CENTER,
                    duration: Toast.LENGTH_LONG);
            ;
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 25.0, // soften the shadow
                  spreadRadius: 5.0, //extend the shadow
                  offset: Offset(
                    50.0, // Move to right 10  horizontally
                    15.0, // Move to bottom 10 Vertically
                  ),
                )
              ],
              /*border: Border.symmetric(
                    vertical: BorderSide(color: MyTheme.light_grey, width: .5),
                    horizontal:
                        BorderSide(color: MyTheme.light_grey, width: 1))*/
            ),
            height: 52,
            width: MediaQuery.of(context).size.width * .33,
            child: Center(
                child: Container(
              width: 55,
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt_outlined,
                    size: 13,
                  ),
                  SizedBox(width: 2),
                  Text(
                    "Filter",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )),
          ),
        ),
        GestureDetector(
          /* onTap: () {
            _selectedFilter.option_key == "product"
                ? showDialog(
                    context: context,
                    builder: (_) =>
                        AlertDialog(
                          contentPadding: EdgeInsets.only(
                              top: 16.0, left: 2.0, right: 2.0, bottom: 2.0),
                          content: StatefulBuilder(builder:
                              (BuildContext context, StateSetter setState) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.only(left: 24.0),
                                    child: Text(
                                      "Sort Products By",
                                    )),
                                RadioListTile(
                                  dense: true,
                                  value: "",
                                  groupValue: _selectedSort,
                                  activeColor: MyTheme.font_grey,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: const Text('Default'),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSort = value;
                                    });
                                    _onSortChange();
                                    Navigator.pop(context);
                                  },
                                ),
                                RadioListTile(
                                  dense: true,
                                  value: "price_high_to_low",
                                  groupValue: _selectedSort,
                                  activeColor: MyTheme.font_grey,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: const Text('Price high to low'),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSort = value;
                                    });
                                    _onSortChange();
                                    Navigator.pop(context);
                                  },
                                ),
                                RadioListTile(
                                  dense: true,
                                  value: "price_low_to_high",
                                  groupValue: _selectedSort,
                                  activeColor: MyTheme.font_grey,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: const Text('Price low to high'),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSort = value;
                                    });
                                    _onSortChange();
                                    Navigator.pop(context);
                                  },
                                ),
                                RadioListTile(
                                  dense: true,
                                  value: "new_arrival",
                                  groupValue: _selectedSort,
                                  activeColor: MyTheme.font_grey,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: const Text('New Arrival'),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSort = value;
                                    });
                                    _onSortChange();
                                    Navigator.pop(context);
                                  },
                                ),
                                RadioListTile(
                                  dense: true,
                                  value: "popularity",
                                  groupValue: _selectedSort,
                                  activeColor: MyTheme.font_grey,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: const Text('Popularity'),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSort = value;
                                    });
                                    _onSortChange();
                                    Navigator.pop(context);
                                  },
                                ),
                                RadioListTile(
                                  dense: true,
                                  value: "top_rated",
                                  groupValue: _selectedSort,
                                  activeColor: MyTheme.font_grey,
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  title: const Text('Top Rated'),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedSort = value;
                                    });
                                    _onSortChange();
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                          }),
                          actions: [
                            FlatButton(
                              child: Text(
                                "CLOSE",
                                style: TextStyle(color: MyTheme.medium_grey),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ))*/
          onTap: () {
            _selectedFilter.option_key == "product"
                ? showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          RadioListTile(
                            dense: true,
                            value: "",
                            groupValue: _selectedSort,
                            activeColor: MyTheme.font_grey,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text('Default'),
                            onChanged: (value) {
                              setState(() {
                                _selectedSort = value;
                              });
                              _onSortChange();
                              Navigator.pop(context);
                            },
                          ),
                          RadioListTile(
                            dense: true,
                            value: "price_high_to_low",
                            groupValue: _selectedSort,
                            activeColor: MyTheme.font_grey,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text('Price high to low'),
                            onChanged: (value) {
                              setState(() {
                                _selectedSort = value;
                              });
                              _onSortChange();
                              Navigator.pop(context);
                            },
                          ),
                          RadioListTile(
                            dense: true,
                            value: "price_low_to_high",
                            groupValue: _selectedSort,
                            activeColor: MyTheme.font_grey,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text('Price low to high'),
                            onChanged: (value) {
                              setState(() {
                                _selectedSort = value;
                              });
                              _onSortChange();
                              Navigator.pop(context);
                            },
                          ),
                          RadioListTile(
                            dense: true,
                            value: "new_arrival",
                            groupValue: _selectedSort,
                            activeColor: MyTheme.font_grey,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text('New Arrival'),
                            onChanged: (value) {
                              setState(() {
                                _selectedSort = value;
                              });
                              _onSortChange();
                              Navigator.pop(context);
                            },
                          ),
                          RadioListTile(
                            dense: true,
                            value: "popularity",
                            groupValue: _selectedSort,
                            activeColor: MyTheme.font_grey,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text('Popularity'),
                            onChanged: (value) {
                              setState(() {
                                _selectedSort = value;
                              });
                              _onSortChange();
                              Navigator.pop(context);
                            },
                          ),
                          RadioListTile(
                            dense: true,
                            value: "top_rated",
                            groupValue: _selectedSort,
                            activeColor: MyTheme.font_grey,
                            controlAffinity: ListTileControlAffinity.leading,
                            title: const Text('Top Rated'),
                            onChanged: (value) {
                              setState(() {
                                _selectedSort = value;
                              });
                              _onSortChange();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      );
                    })
                : ToastComponent.showDialog(
                    "You can use sorting while searching for products.",
                    context,
                    gravity: Toast.CENTER,
                    duration: Toast.LENGTH_LONG);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 25.0, // soften the shadow
                  spreadRadius: 5.0, //extend the shadow
                  offset: Offset(
                    50.0, // Move to right 10  horizontally
                    15.0, // Move to bottom 10 Vertically
                  ),
                )
              ],
              /* border: Border.symmetric(
                    vertical: BorderSide(color: MyTheme.light_grey, width: .5),
                    horizontal:
                        BorderSide(color: MyTheme.light_grey, width: 1))*/
            ),
            height: 52,
            width: MediaQuery.of(context).size.width * .33,
            child: Center(
                child: Container(
              width: 50,
              child: Row(
                children: [
                  Icon(
                    Icons.swap_vert,
                    size: 13,
                  ),
                  SizedBox(width: 2),
                  Text(
                    "Sort",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )),
          ),
        )
      ],
    );
  }

  Row buildTopAppbar(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.arrow_back, color: MyTheme.dark_grey),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.07,
            child: Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.black, width: 1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                      icon: Icon(Icons.search, color: MyTheme.dark_grey,size: 20,),
                      onPressed: () {
                        _searchKey = _searchController.text.toString();
                        setState(() {
                          issearch == false;
                        });
                        _onSearchSubmit();
                      }),
                  Container(
                    // height: MediaQuery.of(context).size.height * 0.050,
                    width: MediaQuery.of(context).size.width * 0.65,
                    child: Padding(
                        /* padding: MediaQuery.of(context).viewPadding.top >
                            30 //MediaQuery.of(context).viewPadding.top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
                        ? const EdgeInsets.symmetric(vertical: 36.0, horizontal: 0.0)
                        : const EdgeInsets.symmetric(vertical: 14.0, horizontal: 0.0),*/
                        padding: const EdgeInsets.only(
                          left: 8.0,
                          right: 8,
                        ),
                        child: TextField(

                          controller: _searchController,
                          onTap: () {
                            setState(() {
                              issearch == true;
                            });
                          },
                          onChanged: searchOperation,
                          //autofocus: true,
                          onSubmitted: (txt) {
                            _searchKey = txt;
                            setState(() {
                              issearch == false;
                            });
                            _onSearchSubmit();
                          },
                          decoration: InputDecoration(
                             /* prefixIcon: IconButton(
                                  icon: Icon(Icons.search, color: MyTheme.dark_grey),
                                  onPressed: () {
                                    _searchKey = _searchController.text.toString();
                                    setState(() {
                                      issearch == false;
                                    });
                                    _onSearchSubmit();
                                  }),*/
                              hintText: "Search",
                              hintStyle: TextStyle(
                                  fontSize: 14.0, color: MyTheme.textfield_grey),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: MyTheme.white, width: 0.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: MyTheme.white, width: 0.0),
                              ),
                              contentPadding: EdgeInsets.all(0.0)),
                        )),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            width: 20,
          )

          /*IconButton(
          icon: Icon(Icons.list_outlined),
          onPressed: () {
            setState(() {
              if (listor == 0) {
                listor = 1;
              } else {
                listor = 0;
              }
            });
          })*/
        ]);
  }

  Drawer buildFilterDrawer() {
    return Drawer(
      child: Container(
        padding: EdgeInsets.only(top: 50),
        child: Column(
          children: [
            Container(
              height: 100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "Price Range",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Container(
                            height: 30,
                            width: 100,
                            child: TextField(
                              controller: _minPriceController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [_amountValidator],
                              decoration: InputDecoration(
                                  hintText: "Minimum",
                                  hintStyle: TextStyle(
                                      fontSize: 12.0,
                                      color: MyTheme.textfield_grey),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 1.0),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(4.0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 2.0),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(4.0),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.all(4.0)),
                            ),
                          ),
                        ),
                        Text(" - "),
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Container(
                            height: 30,
                            width: 100,
                            child: TextField(
                              controller: _maxPriceController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [_amountValidator],
                              decoration: InputDecoration(
                                  hintText: "Maximum",
                                  hintStyle: TextStyle(
                                      fontSize: 12.0,
                                      color: MyTheme.textfield_grey),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 1.0),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(4.0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: MyTheme.textfield_grey,
                                        width: 2.0),
                                    borderRadius: const BorderRadius.all(
                                      const Radius.circular(4.0),
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.all(4.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: CustomScrollView(slivers: [
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        "Categories",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _filterCategoryList.length == 0
                        ? Container(
                            height: 100,
                            child: Center(
                              child: Text(
                                "No categories available",
                                style: TextStyle(color: MyTheme.font_grey),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: buildFilterCategoryList(),
                          ),
                    Padding(
                      padding: const EdgeInsets.only(left: 16.0),
                      child: Text(
                        "Brands",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _filterBrandList.length == 0
                        ? Container(
                            height: 100,
                            child: Center(
                              child: Text(
                                "No brands available",
                                style: TextStyle(color: MyTheme.font_grey),
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: buildFilterBrandsList(),
                          ),
                  ]),
                )
              ]),
            ),
            Container(
              height: 70,
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  FlatButton(
                    color: Colors.grey[300],
                    /*shape: RoundedRectangleBorder(
                      side:
                          new BorderSide(color: MyTheme.light_grey, width: 2.0),
                      borderRadius: BorderRadius.circular(4.0),
                    ),*/
                    child: Container(
                      height: 50,
                      width: 120,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "CLEAR",
                          style: TextStyle(
                            color: Colors.blue[300],
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      _minPriceController.clear();
                      _maxPriceController.clear();
                      setState(() {
                        _selectedCategories.clear();
                        _selectedBrands.clear();
                      });
                    },
                  ),
                  FlatButton(
                    color: MyTheme.accent_color,
                    child: Container(
                      height: 50,
                      width: 120,
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "APPLY",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    onPressed: () {
                      var min = _minPriceController.text.toString();
                      var max = _maxPriceController.text.toString();
                      bool apply = true;
                      if (min != "" && max != "") {
                        if (max.compareTo(min) < 0) {
                          ToastComponent.showDialog(
                              "Min price cannot be larger than max price",
                              context,
                              gravity: Toast.CENTER,
                              duration: Toast.LENGTH_LONG);
                          apply = false;
                        }
                      }

                      if (apply) {
                        _applyProductFilter();
                      }
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListView buildFilterBrandsList() {
    return ListView(
      padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: <Widget>[
        ..._filterBrandList
            .map(
              (brand) => CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                title: Text(brand.name),
                value: _selectedBrands.contains(brand.id),
                onChanged: (bool value) {
                  if (value) {
                    setState(() {
                      _selectedBrands.add(brand.id);
                    });
                  } else {
                    setState(() {
                      _selectedBrands.remove(brand.id);
                    });
                  }
                },
              ),
            )
            .toList()
      ],
    );
  }

  ListView buildFilterCategoryList() {
    return ListView(
      padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: <Widget>[
        ..._filterCategoryList
            .map(
              (category) => CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                title: Text(category.name),
                value: _selectedCategories.contains(category.id),
                onChanged: (bool value) {
                  if (value) {
                    setState(() {
                      _selectedCategories.clear();
                      _selectedCategories.add(category.id);
                    });
                  } else {
                    setState(() {
                      _selectedCategories.remove(category.id);
                    });
                  }
                },
              ),
            )
            .toList()
      ],
    );
  }

  Container buildProductList() {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: buildProductScrollableList(),
          )
        ],
      ),
    );
  }

  buildProductScrollableList() {
    if (_isProductInitial && _productList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildProductGridShimmer(scontroller: _scrollController));
    } else if (_productList.length > 0) {
      return RefreshIndicator(
        color: Colors.white,
        backgroundColor: MyTheme.accent_color,
        onRefresh: _onProductListRefresh,
        child: SingleChildScrollView(
          controller: _productScrollController,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                  height: MediaQuery.of(context).viewPadding.top > 40
                      ? 180
                      : /*135*/ 75
                  //MediaQuery.of(context).viewPadding.top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
                  ),
              (searchresult1.length == 0)
                  ? (listor == 1)
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
                                  // strocked: _productList[index].stroked_price.toString(),
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
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
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
                                  // strocked: _productList[index].stroked_price.toString(),
                                ),
                              );
                            },
                          ),
                        )
                  : (listor == 1)
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
                                  // strocked: searchresult1[index].stroked_price.toString(),
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
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
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
                                  // strocked: searchresult1[index].stroked_price.toString(),
                                ),
                              );
                            },
                          ),
                        )
            ],
          ),
        ),
      );
    } else if (_totalProductData == 0) {
      return Center(child: Text("No product is available"));
    } else {
      return Container(); // should never be happening
    }
  }

  Container buildBrandList() {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: buildBrandScrollableList(),
          )
        ],
      ),
    );
  }

  buildBrandScrollableList() {
    if (_isBrandInitial && _brandList.length == 0) {
      return SingleChildScrollView(
          child: ShimmerHelper()
              .buildSquareGridShimmer(scontroller: _scrollController));
    } else if (_brandList.length > 0) {
      return RefreshIndicator(
        color: Colors.white,
        backgroundColor: MyTheme.accent_color,
        onRefresh: _onBrandListRefresh,
        child: SingleChildScrollView(
          controller: _brandScrollController,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: Column(
            children: [
              SizedBox(
                  height:
                      MediaQuery.of(context).viewPadding.top > 40 ? 180 : 135
                  //MediaQuery.of(context).viewPadding.top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
                  ),
              GridView.builder(
                // 2
                //addAutomaticKeepAlives: true,
                itemCount: _brandList.length,
                controller: _scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1),
                padding: EdgeInsets.all(8),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  // 3
                  return BrandSquareCard(
                    id: _brandList[index].id,
                    image: _brandList[index].logo,
                    name: _brandList[index].name,
                  );
                },
              )
            ],
          ),
        ),
      );
    } else if (_totalBrandData == 0) {
      return Center(child: Text("No brand is available"));
    } else {
      return Container(); // should never be happening
    }
  }

  Container buildShopList() {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: buildShopScrollableList(),
          )
        ],
      ),
    );
  }

  buildShopScrollableList() {
    if (_isShopInitial && _shopList.length == 0) {
      return SingleChildScrollView(
          controller: _scrollController,
          child: ShimmerHelper()
              .buildSquareGridShimmer(scontroller: _scrollController));
    } else if (_shopList.length > 0) {
      return RefreshIndicator(
        color: Colors.white,
        backgroundColor: MyTheme.accent_color,
        onRefresh: _onShopListRefresh,
        child: SingleChildScrollView(
          controller: _shopScrollController,
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: Column(
            children: [
              SizedBox(
                  height:
                      MediaQuery.of(context).viewPadding.top > 40 ? 180 : 135
                  //MediaQuery.of(context).viewPadding.top is the statusbar height, with a notch phone it results almost 50, without a notch it shows 24.0.For safety we have checked if its greater than thirty
                  ),
              GridView.builder(
                // 2
                //addAutomaticKeepAlives: true,
                itemCount: _shopList.length,
                controller: _scrollController,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1),
                padding: EdgeInsets.all(8),
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  // 3
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return SellerDetails();
                      }));
                    },
                    child: ShopSquareCard(
                      id: _shopList[index].id,
                      image: _shopList[index].logo,
                      name: _shopList[index].name,
                    ),
                  );
                },
              )
            ],
          ),
        ),
      );
    } else if (_totalShopData == 0) {
      return Center(child: Text("No shop is available"));
    } else {
      return Container(); // should never be happening
    }
  }
}
