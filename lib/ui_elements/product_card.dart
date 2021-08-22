import 'package:active_ecommerce_flutter/my_theme.dart';
import 'package:flutter/material.dart';
import 'package:active_ecommerce_flutter/screens/product_details.dart';
import 'package:active_ecommerce_flutter/app_config.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductCard extends StatefulWidget {
  int id;
  String image;
  String name;
  String price;
  int listor;
  int rating;

  ProductCard(
      {Key key,
      this.id,
      this.image,
      this.name,
      this.price,
      this.listor,
      this.rating})
      : super(key: key);

  @override
  _ProductCardState createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override
  void initState() {
    // TODO: implement initState
    /*print(widget.rating);*/
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print((MediaQuery.of(context).size.width - 48) / 2);
    return (widget.listor == 1)
        ? InkWell(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ProductDetails(
                  id: widget.id,
                );
              }));
            },
            child: Container(
              //clipBehavior: Clip.antiAliasWithSaveLayer,
              /*shape: RoundedRectangleBorder(
          side: new BorderSide(color: MyTheme.light_grey, width: 1.0),
          borderRadius: BorderRadius.circular(16.0),
        ),*/
              /* elevation: 0.0,*/
              child: Column(
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            //height: 158,
                            height: MediaQuery.of(context).size.height * 0.23
                            /*(( MediaQuery.of(context).size.width - 28 ) / 2)*/,
                            child: ClipRRect(
                                /* clipBehavior: Clip.hardEdge,
                        borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16), bottom: Radius.zero),*/
                                child: FadeInImage.assetNetwork(
                              placeholder: 'assets/placeholder.png',
                              image: AppConfig.BASE_PATH + widget.image,
                              fit: BoxFit.scaleDown,
                            ))),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          height: 150,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                                child: Text(
                                  widget.name,
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: MyTheme.font_grey,
                                      fontSize: 14,
                                      height: 1.6,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
                                child: Text(
                                  widget.price,
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: MyTheme.accent_color,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: RatingBar(
                                  itemSize: 18.0,
                                  ignoreGestures: true,
                                  initialRating:
                                      double.parse(widget.rating.toString()),
                                  direction: Axis.horizontal,
                                  allowHalfRating: false,
                                  itemCount: 5,
                                  ratingWidget: RatingWidget(
                                    full: Icon(FontAwesome.star,
                                        color: Colors.amber),
                                    empty: Icon(FontAwesome.star,
                                        color:
                                            Color.fromRGBO(224, 224, 225, 1)),
                                  ),
                                  itemPadding: EdgeInsets.only(right: 1.0),
                                  onRatingUpdate: (rating) {
                                    //print(rating);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                  SizedBox(
                    height: 2,
                  )
                ],
              ),
            ),
          )
        : InkWell(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ProductDetails(
                  id: widget.id,
                );
              }));
            },
            child: Container(
                color: Colors.white,
                // width: double.infinity,
                width: MediaQuery.of(context).size.width * 0.48,
                height: MediaQuery.of(context).size.height * 0.37,
                // height: (( MediaQuery.of(context).size.width - 28 ) / 2) + 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                        /* clipBehavior: Clip.hardEdge,
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(16), bottom: Radius.zero),*/
                        child: FadeInImage.assetNetwork(
                      placeholder: 'assets/placeholder.png',
                      image: AppConfig.BASE_PATH + widget.image,
                      fit: BoxFit.cover,
                    )),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: Text(
                        widget.name,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                            color: MyTheme.font_grey,
                            fontSize: 14,
                            height: 1.6,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: Text(
                        widget.price,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                            color: MyTheme.accent_color,
                            fontSize: 14,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: RatingBar(
                        itemSize: 18.0,
                        ignoreGestures: true,
                        initialRating: double.parse(widget.rating.toString()),
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        ratingWidget: RatingWidget(
                          full: Icon(FontAwesome.star, color: Colors.amber),
                          empty: Icon(FontAwesome.star,
                              color: Color.fromRGBO(224, 224, 225, 1)),
                        ),
                        itemPadding: EdgeInsets.only(right: 1.0),
                        onRatingUpdate: (rating) {
                          //print(rating);
                        },
                      ),
                    ),
                  ],
                )),
          );
  }
}
