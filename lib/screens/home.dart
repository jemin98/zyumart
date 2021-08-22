import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:active_ecommerce_flutter/screens/filter.dart';
import 'package:active_ecommerce_flutter/screens/flash_deal_list.dart';
import 'package:active_ecommerce_flutter/screens/todays_deal_products.dart';
import 'package:active_ecommerce_flutter/screens/top_selling_products.dart';
import 'package:active_ecommerce_flutter/screens/category_products.dart';
import 'package:active_ecommerce_flutter/screens/category_list.dart';
import 'package:active_ecommerce_flutter/screens/profile.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:active_ecommerce_flutter/repositories/sliders_repository.dart';
import 'package:active_ecommerce_flutter/repositories/category_repository.dart';
import 'package:active_ecommerce_flutter/repositories/product_repository.dart';
import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:shimmer/shimmer.dart';
import 'package:active_ecommerce_flutter/screens/cart.dart';
import 'package:active_ecommerce_flutter/custom/toast_component.dart';
import 'package:toast/toast.dart';
import 'package:active_ecommerce_flutter/ui_elements/product_card.dart';
import 'package:active_ecommerce_flutter/helpers/shimmer_helper.dart';
import 'package:lazy_load_scrollview/lazy_load_scrollview.dart';
import 'package:scaling_header/scaling_header.dart';
import 'package:active_ecommerce_flutter/helpers/shared_value_helper.dart';

class Home extends StatefulWidget {
  Home({Key key, this.title, this.show_back_button = false}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  bool show_back_button;

  @override
  _HomeState createState() => _HomeState();
}
int _current_slider = 0;

class _HomeState extends State<Home> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _featuredProductScrollController;
  List<dynamic> _productList = [];
  AnimationController pirated_logo_controller;
  Animation pirated_logo_animation;
  bool isLoadingHorizontal = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
    // In initState()
    if (AppConfig.purchase_code == "") {
      initPiratedAnimation();
    }
  }

  fetchData() async {
    var productResponse = await ProductRepository().getAllProducts();
    _productList.addAll(productResponse.products);
    setState(() {
      print(_productList);
    });
  }

  initPiratedAnimation() {
    pirated_logo_controller = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));
    pirated_logo_animation = Tween(begin: 40.0, end: 60.0).animate(
        CurvedAnimation(
            curve: Curves.bounceOut, parent: pirated_logo_controller));

    pirated_logo_controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        pirated_logo_controller.repeat();
      }
    });

    pirated_logo_controller.forward();
  }

  /*@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    pirated_logo_controller?.dispose();
  }*/

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    //print(MediaQuery.of(context).viewPadding.top);

    return RefreshIndicator(
      color: MyTheme.accent_color,
      backgroundColor: Colors.white,
      onRefresh: _onRefresh,
      displacement: 0,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.grey[50],
        // appBar: buildAppBar(statusBarHeight, context),
        // extendBodyBehindAppBar: true,
        // drawer: MainDrawer(),
        body: CustomScrollView(
          slivers: <Widget>[
            SliverPersistentHeader(
              delegate: MySliverAppBar(expandedHeight: 200),
              pinned: true,
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                AppConfig.purchase_code == ""
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(
                          8.0,
                          16.0,
                          8.0,
                          0.0,
                        ),
                        child: Container(
                          height: 200,
                          color: Colors.black,
                          child: Stack(
                            children: [
                              Positioned(
                                  left: 20,
                                  top: 0,
                                  child: AnimatedBuilder(
                                      animation: pirated_logo_animation,
                                      builder: (context, child) {
                                        return Image.asset(
                                          "assets/pirated_square.png",
                                          height: pirated_logo_animation.value,
                                          color: Colors.white,
                                        );
                                      })),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 24.0, left: 24, right: 24),
                                  child: Text(
                                    "This is a pirated app. Do not use this. It may have security issues.",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
                /* Container(
                        height: 300,
                        child: Image.network(
                            "https://imgaz.staticbg.com/banggood/os/202108/20210816035909_700.jpg",fit: BoxFit.fill,),
                      ),*/
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    8.0,
                    16.0,
                    8.0,
                    0.0,
                  ),
                  child: buildHomeMenuRow(context),
                ),
              ]),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16.0,
                    16.0,
                    8.0,
                    0.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Featured Categories",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16.0,
                  16.0,
                  0.0,
                  0.0,
                ),
                child: SizedBox(
                  height: 154,
                  child: buildHomeFeaturedCategories(context),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16.0,
                    16.0,
                    8.0,
                    0.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Featured Products",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          4.0,
                          16.0,
                          8.0,
                          0.0,
                        ),
                        child: Column(
                          children: [
                            buildHomeFeaturedProducts(context),
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 16.0, top: 16, bottom: 12),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  "Top Selling Products",
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            LazyLoadScrollView(
                              isLoading: isLoadingHorizontal,
                              onEndOfPage: () => loadMore(),
                              child: GridView.builder(
                                // 2
                                //addAutomaticKeepAlives: true,
                                itemCount: _productList.length,

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
                                      image:
                                          _productList[index].thumbnail_image,
                                      name: _productList[index].name,
                                      price: _productList[index].base_price,
                                      rating: _productList[index].rating,
                                      // strocked: _productList[index].stroked_price.toString(),
                                    ),
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 80,
                )
              ]),
            ),
          ],
        ),
      ),
    );
  }

  buildHomeFeaturedProducts(context) {
    return FutureBuilder(
        future: ProductRepository().getFeaturedProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            /*print("product error");
            print(snapshot.error.toString());*/
            return Container();
          } else if (snapshot.hasData) {
            //snapshot.hasData
            var featuredProductResponse = snapshot.data;
            return GridView.builder(
              // 2
              //addAutomaticKeepAlives: true,
              itemCount: featuredProductResponse.products.length,
              controller: _featuredProductScrollController,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.618),
              padding: EdgeInsets.all(8),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                // 3
                return ProductCard(
                  id: featuredProductResponse.products[index].id,
                  image:
                      featuredProductResponse.products[index].thumbnail_image,
                  name: featuredProductResponse.products[index].name,
                  price: featuredProductResponse.products[index].base_price,
                  rating: featuredProductResponse.products[index].rating,
                );
              },
            );
          } else {
            return ShimmerHelper().buildProductGridShimmer(
                scontroller: _featuredProductScrollController);
          }
        });
  }

  buildHomeFeaturedCategories(context) {
    return FutureBuilder(
        future: CategoryRepository().getFeturedCategories(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            //snapshot.hasError
            /*print("Home slider error");
            print(snapshot.error.toString());*/
            return Container();
          } else if (snapshot.hasData) {
            //snapshot.hasData
            var featuredCategoryResponse = snapshot.data;
            return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: featuredCategoryResponse.categories.length,
                itemExtent: 120,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      /*onTap: () {
                        if (featuredCategoryResponse
                                .categories[index].number_of_children >
                            0) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return CategoryList(
                              parent_category_name: featuredCategoryResponse
                                  .categories[index].name,
                            );
                          }));
                        } else {
                          ToastComponent.showDialog(
                              "No sub categories available", context,
                              gravity: Toast.CENTER,
                              duration: Toast.LENGTH_LONG);
                        }
                      },*/
                      onTap: () {
                        print("000000000000000000000000000000000000000000");
                        print(featuredCategoryResponse.categories[index].id);
                        print(featuredCategoryResponse.categories[index].name);

                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return CategoryProducts(
                            category_id:
                                featuredCategoryResponse.categories[index].id,
                            category_name:
                                featuredCategoryResponse.categories[index].name,
                          );
                        }));
                      },
                      child: Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        shape: RoundedRectangleBorder(
                          side: new BorderSide(
                              color: MyTheme.light_grey, width: 1.0),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        elevation: 0.0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                //width: 100,
                                height: 100,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(16),
                                        bottom: Radius.zero),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: 'assets/placeholder.png',
                                      image: AppConfig.BASE_PATH +
                                          featuredCategoryResponse
                                              .categories[index].banner,
                                      fit: BoxFit.cover,
                                    ))),
                            Padding(
                              padding: EdgeInsets.fromLTRB(8, 8, 8, 4),
                              child: Container(
                                height: 32,
                                child: Text(
                                  featuredCategoryResponse
                                      .categories[index].name,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      fontSize: 11, color: MyTheme.font_grey),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                });
          } else {
            return Row(
              children: [
                Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ShimmerHelper().buildBasicShimmer(
                        height: 120.0,
                        width: (MediaQuery.of(context).size.width - 32) / 3)),
                Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ShimmerHelper().buildBasicShimmer(
                        height: 120.0,
                        width: (MediaQuery.of(context).size.width - 32) / 3)),
                Padding(
                    padding: const EdgeInsets.only(right: 0.0),
                    child: ShimmerHelper().buildBasicShimmer(
                        height: 120.0,
                        width: (MediaQuery.of(context).size.width - 32) / 3)),
              ],
            );
          }
        });
  }

  buildHomeMenuRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return CategoryList(
                is_top_category: true,
              );
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/top_categories.png"),
                    )),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    "Top Categories",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color.fromRGBO(132, 132, 132, 1),
                        fontWeight: FontWeight.w300),
                  ),
                )
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return Filter(
                selected_filter: "brands",
              );
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/brands.png"),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text("Brands",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return TopSellingProducts();
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/top_sellers.png"),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text("Top Sellers",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return TodaysDealProducts();
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/todays_deal.png"),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text("Todays Deal",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return FlashDealList();
            }));
          },
          child: Container(
            height: 100,
            width: MediaQuery.of(context).size.width / 5 - 4,
            child: Column(
              children: [
                Container(
                    height: 57,
                    width: 57,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: MyTheme.light_grey, width: 1)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Image.asset("assets/flash_deal.png"),
                    )),
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text("Flash Deal",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Color.fromRGBO(132, 132, 132, 1),
                            fontWeight: FontWeight.w300))),
              ],
            ),
          ),
        )
      ],
    );
  }



  AppBar buildAppBar(double statusBarHeight, BuildContext context) {
    return AppBar(
      leading: Icon(Icons.supervised_user_circle),
      title: Container(
        child: Padding(
            padding: const EdgeInsets.only(top: 14.0, bottom: 14, right: 12),
            // when notification bell will be shown , the right padding will cease to exist.
            child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Filter();
                  }));
                },
                child: buildHomeSearchBox(context))),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0.0,
      titleSpacing: 0,
      actions: <Widget>[
        Icon(Icons.shopping_cart),
        Container(
          width: 10,
        )
      ],
    );
  }

  buildHomeSearchBox(BuildContext context) {
    return Card(
      color: Colors.grey[200],
      child: Container(
        height: MediaQuery.of(context).size.height * 0.045,
        width: MediaQuery.of(context).size.width * 0.8,
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.search,
                size: 20,
              ),
              SizedBox(
                width: 10,
              ),
              Text("Search"),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    print("yes refresh worked................");
    buildHomeFeaturedProducts(context);
    buildHomeFeaturedCategories(context);
    buildHomeMenuRow(context);
    print("yes refresh worked................");

  }

  loadMore() {
    setState(() {
      isLoadingHorizontal = true;
    });
  }
}

class MySliverAppBar extends SliverPersistentHeaderDelegate {
  final double expandedHeight;

  MySliverAppBar({@required this.expandedHeight});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      fit: StackFit.expand,
      overflow: Overflow.visible,
      children: [
        Opacity(
          opacity: (1 - shrinkOffset / expandedHeight),
          // child: buildHomeCarouselSlider(),
          child: Container(color: Colors.orange,),
        ),
        Opacity(
          opacity: (shrinkOffset / expandedHeight),
          child: Container(
            color: Colors.black,
            // height: MediaQuery.of(context).size.height * 0.01,
            width: MediaQuery.of(context).size.width,
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.015,
          // left: 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: Opacity(
                opacity: 1,
                /*shrinkOffset / expandedHeight,*/
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1.01,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return Profile();
                                },
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.account_circle, size: 34,color: Colors.white,),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return Filter();
                                },
                              ),
                            );
                          },
                          child: Card(
                            elevation: 0,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: Colors.black, width: 1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.055,
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8,),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.search,
                                      size: 20,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text("Search"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Cart(
                                        has_bottomnav: false,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Icon(Icons.shopping_cart, size: 34,color: Colors.white,)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.015,

          // left: 2,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Center(
              child: Opacity(
                opacity: 1 - shrinkOffset / expandedHeight,
                /*shrinkOffset / expandedHeight,*/
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Container(
                    width: MediaQuery.of(context).size.width * 1.01,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return Profile();
                                },
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.account_circle, size: 34,color: Colors.white,),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return Filter();
                                },
                              ),
                            );
                          },
                          child: Card(
                            elevation: 0,
                            color: Colors.white,
                            child: Container(
                              height: MediaQuery.of(context).size.height * 0.050,
                              width: MediaQuery.of(context).size.width * 0.75,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0, right: 8,),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.search,
                                      size: 20,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text("Search"),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return Cart(
                                        has_bottomnav: false,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Icon(Icons.shopping_cart, size: 34,color: Colors.white,)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  double get maxExtent => expandedHeight;

  @override
  double get minExtent => kToolbarHeight + 40;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;


}
class buildHomeCarouselSlider extends StatefulWidget {

  @override
  _buildHomeCarouselSliderState createState() => _buildHomeCarouselSliderState();
}

class _buildHomeCarouselSliderState extends State<buildHomeCarouselSlider> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: SlidersRepository().getSliders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            /*print("Home slider error");
            print(snapshot.error.toString());*/
            return Container();
          } else if (snapshot.hasData) {
            var sliderResponse = snapshot.data;
            var carouselImageList = [];
            sliderResponse.sliders.forEach((slider) {
              carouselImageList.add(slider.photo);
            });
            return CarouselSlider(
              options: CarouselOptions(
                  aspectRatio: 1.5,
                  viewportFraction: 1.5,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 5),
                  autoPlayAnimationDuration: Duration(milliseconds: 1000),
                  autoPlayCurve: Curves.easeInCubic,
                  enlargeCenterPage: true,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current_slider = index;
                    });
                  }),
              items: carouselImageList.map((i) {
                return Builder(
                  builder: (BuildContext context) {
                    return Stack(
                      children: <Widget>[
                        Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 5.0),
                            child: ClipRRect(
                                borderRadius:
                                BorderRadius.all(Radius.circular(8)),
                                child: FadeInImage.assetNetwork(
                                  placeholder:
                                  'assets/placeholder_rectangle.png',
                                  image: AppConfig.BASE_PATH + i,
                                  fit: BoxFit.fill,
                                ))),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: carouselImageList.map((url) {
                              int index = carouselImageList.indexOf(url);
                              return Container(
                                width: 7.0,
                                height: 7.0,
                                margin: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 4.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _current_slider == index
                                      ? MyTheme.white
                                      : Color.fromRGBO(112, 112, 112, .3),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }).toList(),
            );
          } else {
            return Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: Shimmer.fromColors(
                baseColor: MyTheme.shimmer_base,
                highlightColor: MyTheme.shimmer_highlighted,
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.white,
                ),
              ),
            );
          }
        });
  }
}
