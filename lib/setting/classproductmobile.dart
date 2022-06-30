// ignore_for_file: prefer_const_constructors, unnecessary_this, sized_box_for_whitespace, iterable_contains_unrelated_type, avoid_print, unused_import, avoid_unnecessary_containers, prefer_is_empty

import 'dart:io';
import 'dart:io' show Directory;
import 'package:path/path.dart' show join;
import 'package:posq/classui/classtextfield.dart';
import 'package:posq/model.dart';
import 'package:flutter/material.dart';
import 'package:posq/setting/classcreateproduct.dart';
import 'package:posq/setting/classeditproductmobile.dart';
import 'package:posq/databasehandler.dart';
import 'package:posq/classui/searchwidget.dart';
import 'package:posq/setting/classeditproductv2mob.dart';

class Classproductmobile extends StatefulWidget {
  const Classproductmobile({Key? key}) : super(key: key);

  @override
  State<Classproductmobile> createState() => _ClassproductmobileState();
}

class _ClassproductmobileState extends State<Classproductmobile> {
  final search = TextEditingController();
  String query = '';
  late DatabaseHandler handler;
  bool? hasitem = false;

  @override
  void initState() {
    super.initState();
    this.handler = DatabaseHandler();
    handler.initializeDB(databasename);
    handler.retrieveItems(query).then((value) {
      if (value.length != 0) {
        setState(() {
          hasitem = true;
        });
      } else {
        setState(() {
          hasitem = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          'Product List',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        future: this.handler.retrieveItems(query),
        builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
          var x = snapshot.data ?? [];
          if (x.isNotEmpty) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFieldMobile(
                    hint: 'Example Menu Description',
                    label: 'Search',
                    controller: search,
                    onChanged: (value) async {
                      setState(() {
                        query = value;
                        print(value);
                      });
                    },
                    typekeyboard: TextInputType.text,
                  ),
                ),
                Container(
                  height: MediaQuery.of(context).size.height * 0.75,
                  width: MediaQuery.of(context).size.width * 1,
                  child: ListView.builder(
                    itemCount: x.length,
                    itemBuilder: (BuildContext context, int index) {
                      var _image =
                          File(x[index].pathimage.toString());
                      return Column(
                        children: [
                          Dismissible(
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.symmetric(horizontal: 10.0),
                              child: Icon(Icons.delete_forever),
                            ),
                            key: ValueKey<int>(x[index].id!),
                            onDismissed: (DismissDirection direction) async {
                              await this
                                  .handler
                                  .deleteItem(x[index].id!);
                              setState(() {
                               x.remove(x[index]);
                              });
                            },
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Editproduct(
                                            productcode: x[index],
                                          )),
                                ).then((_) {
                                  setState(() {});
                                });
                              },
                              leading: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 0.5,
                                  ),
                                ),
                                height:
                                    MediaQuery.of(context).size.height * 0.1,
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Image.file(
                                  _image,
                                  errorBuilder: (BuildContext context,
                                      Object exception,
                                      StackTrace? stackTrace) {
                                    return Center(
                                        child: const Text('No Image'));
                                  },
                                  fit: BoxFit.cover,
                                ),
                              ),
                              contentPadding: EdgeInsets.all(8.0),
                              title: Text(x[index].itemdesc!),
                              subtitle: Text(
                                  x[index].slsnett.toString()),
                              trailing: Container(
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: x[index].trackstock==1? Row(
                                  children: [
                                    Text('Stok :'),
                                    Text(
                                        x[index].stock.toString()),
                                  ],
                                ):Container(),
                              ),
                            ),
                          ),
                          Divider(
                            thickness: 1,
                          )
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(child: Text('Tidak ada produk')),
                  Container(
                      child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Createproduct()),
                            ).then((_) {
                              setState(() {});
                            });
                          },
                          child: Text('Buat Produk'))),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const Createproduct()),
          ).then((_) {
            setState(() {});
          });
        },
      ),
    );
  }
}
