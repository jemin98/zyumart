import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'filter.dart';


class Searchhistory extends StatefulWidget {

  @override
  _SearchhistoryState createState() => _SearchhistoryState();
}

class _SearchhistoryState extends State<Searchhistory> {
  @override
  Widget build(BuildContext context) {
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
    return Scaffold(
      body:
      Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top:55.0),
            child: Container(
              color: Colors.grey[50],
              child: Padding(
                padding: const EdgeInsets.only(left:8.0),
                child: Row(
                  children: [
                    GestureDetector(onTap: (){
                      Navigator.pop(context);
                    },child: Icon(Icons.arrow_back)),
                    SizedBox(width: MediaQuery.of(context).size.width * 0.05,),
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
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20, right: 8.0, left: 15),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.8,
              width: MediaQuery.of(context).size.width,
              color: Colors.grey[50],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  /*SizedBox(
                              height: MediaQuery.of(context).size.height * 0.01,
                            ),*/
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
                      itemBuilder: (BuildContext context, int index) {
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
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top:8.0),
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
                      itemBuilder: (BuildContext context, int index) {
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
          ),
        ],
      ),




    );
  }
}
