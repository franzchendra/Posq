// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors_in_immutables, must_be_immutable, prefer_generic_function_type_aliases, non_constant_identifier_names, prefer_const_constructors, avoid_print, unused_import, unused_local_variable

import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:flutter/material.dart';
import 'package:posq/appsmobile.dart';
import 'package:posq/classui/buttonclass.dart';
import 'package:posq/retailmodul/clasretailmainmobile.dart';
import 'package:posq/setting/condiment/maincondiment.dart';
import 'package:posq/setting/customer/classcustomersmobile.dart';
import 'package:posq/setting/classselectoutletmobile.dart';
import 'package:posq/databasehandler.dart';
import 'package:posq/model.dart';
import 'package:posq/setting/product_master/mainmenuproduct.dart';
import 'package:posq/setting/product_master/productmain.dart';
import 'package:posq/setting/profilemain.dart';
import 'package:posq/userinfo.dart';
import 'package:uuid/uuid.dart';
import 'package:posq/classui/api.dart';

typedef void StringCallback(Outlet val);

///callbackstring//

class MenuMain extends StatefulWidget {
  final StringCallback callback;
  late Outlet? outletinfo;
  late final String pscd;

  MenuMain(
      {Key? key,
      required this.outletinfo,
      required this.callback,
      required this.pscd})
      : super(key: key);

  @override
  State<MenuMain> createState() => _MenuMainState();
}

class _MenuMainState extends State<MenuMain> {
  String? trno = '';
  bool selected = false;

  deleteDatabase() async {
    print('oke');
  }

  @override
  void initState() {
    super.initState();
    print(widget.pscd);
    checkTrno();
  }

  checkTrno() async {
    var transno = await ClassApi.checkTrno();
    trno = widget.outletinfo!.outletcd +
        '-' +
        transno[0]['transnonext'].toString();
    print(trno);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (
      context,
      BoxConstraints constraints,
    ) {
      if (constraints.maxWidth <= 480) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ButtonClassAction(
                splash: selected,
                iconasset: 'cart1.png',
                height: MediaQuery.of(context).size.height * 0.04,
                widht: MediaQuery.of(context).size.width * 0.19,
                onpressed: () {
                  setState(() {
                    selected = !selected;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ClassRetailMainMobile(
                              fromsaved: false,
                              trno: trno,
                              qty: 0,
                              pscd: widget.pscd.toString(),
                              outletinfo: widget.outletinfo!,
                            )),
                  );
                },
                name: 'Transaksi ',
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ButtonClassAction(
                splash: selected,
                iconasset: 'outlet1.png',
                height: MediaQuery.of(context).size.height * 0.04,
                widht: MediaQuery.of(context).size.width * 0.19,
                onpressed: accesslist.contains('selectoutlet') == true
                    ? () async {
                        setState(() {
                          selected = !selected;
                        });
                        final Outlet result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Selectoutletmobile()),
                        );

                        // callbackTitle(result);
                        AppsMobile.of(context)!.string = result;
                        print(result);
                      }
                    : () {
                        Fluttertoast.showToast(
                            msg: "Tidak punya akses outlet",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Color.fromARGB(255, 11, 12, 14),
                            textColor: Colors.white,
                            fontSize: 16.0);
                      },
                name: 'Outlet',
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ButtonClassAction(
                splash: selected,
                iconasset: 'investor.png',
                height: MediaQuery.of(context).size.height * 0.04,
                widht: MediaQuery.of(context).size.width * 0.19,
                onpressed:accesslist.contains('createcostumer') == true? () {
                  selected = !selected;
                  setState(() {});
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ClassListCustomers()),
                  );
                }:(){
                     Fluttertoast.showToast(
                            msg: "Tidak punya akses customer",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Color.fromARGB(255, 11, 12, 14),
                            textColor: Colors.white,
                            fontSize: 16.0);
                },
                name: 'Customer',
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ButtonClassAction(
                splash: selected,
                iconasset: 'settings.png',
                height: MediaQuery.of(context).size.height * 0.04,
                widht: MediaQuery.of(context).size.width * 0.19,
                onpressed: accesslist.contains('setting') == true
                    ? () {
                        selected = !selected;
                        setState(() {});
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MainMenuProduct(
                                    pscd: widget.outletinfo!.outletcd,
                                    outletinfo: widget.outletinfo!,
                                  )),
                        );
                      }
                    : () {
                        Fluttertoast.showToast(
                            msg: "Tidak punya akses kelola",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Color.fromARGB(255, 11, 12, 14),
                            textColor: Colors.white,
                            fontSize: 16.0);
                      },
                name: 'Kelola',
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ButtonClassAction(
                splash: selected,
                iconasset: 'staff.png',
                height: MediaQuery.of(context).size.height * 0.04,
                widht: MediaQuery.of(context).size.width * 0.19,
                onpressed: accesslist.contains('pegawai') == true
                    ? () {
                        selected = !selected;
                        setState(() {});
                      }
                    : () {
                        Fluttertoast.showToast(
                            msg: "Tidak punya akses pegawai",
                            toastLength: Toast.LENGTH_LONG,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 1,
                            backgroundColor: Color.fromARGB(255, 11, 12, 14),
                            textColor: Colors.white,
                            fontSize: 16.0);
                      },
                name: 'Pegawai',
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ButtonClassAction(
                splash: selected,
                iconasset: 'support.png',
                height: MediaQuery.of(context).size.height * 0.04,
                widht: MediaQuery.of(context).size.width * 0.19,
                onpressed: () async {
                  selected = !selected;
                  setState(() {});
                  // handler = DatabaseHandler();
                  // await handler.upgradeDB();
                },
                name: 'Help',
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
            ],
          ),
        );
      } else if (constraints.maxWidth <= 820) {
        // diatas 480P ///
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ButtonClassAction(
                iconasset: 'retail.png',
                height: MediaQuery.of(context).size.height * 0.04,
                widht: MediaQuery.of(context).size.width * 0.095,
                onpressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ClassRetailMainMobile(
                              fromsaved: false,
                              trno: trno,
                              qty: 0,
                              pscd: widget.pscd.toString(),
                              outletinfo: widget.outletinfo!,
                            )),
                  );
                },
                name: 'Transaksi ',
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ButtonClassAction(
                iconasset: 'outlet.png',
                height: MediaQuery.of(context).size.height * 0.04,
                widht: MediaQuery.of(context).size.width * 0.095,
                onpressed: () async {
                  final Outlet result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Selectoutletmobile()),
                  );
                  setState(() {});
                  // callbackTitle(result);
                  AppsMobile.of(context)!.string = result;
                  print(result);
                },
                name: 'Outlet',
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ButtonClassAction(
                iconasset: 'pembeli.png',
                height: MediaQuery.of(context).size.height * 0.04,
                widht: MediaQuery.of(context).size.width * 0.095,
                onpressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ClassListCustomers()),
                  );
                },
                name: 'Customer',
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ButtonClassAction(
                iconasset: 'settings.png',
                height: MediaQuery.of(context).size.height * 0.04,
                widht: MediaQuery.of(context).size.width * 0.095,
                onpressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MainMenuProduct(
                              pscd: widget.outletinfo!.outletcd,
                              outletinfo: widget.outletinfo!,
                            )),
                  );
                },
                name: 'Kelola',
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ButtonClassAction(
                iconasset: 'pegawai.png',
                height: MediaQuery.of(context).size.height * 0.04,
                widht: MediaQuery.of(context).size.width * 0.095,
                onpressed: () {},
                name: 'Pegawai',
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ButtonClassAction(
                iconasset: 'help.png',
                height: MediaQuery.of(context).size.height * 0.04,
                widht: MediaQuery.of(context).size.width * 0.095,
                onpressed: () async {
                  // handler = DatabaseHandler();
                  // await handler.upgradeDB();
                },
                name: 'Help',
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
            ],
          ),
        );
      } else if (constraints.maxWidth >= 1180) {
        //landscape ipad //
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ButtonClassAction(
                iconasset: 'retail.png',
                height: MediaQuery.of(context).size.height * 0.04,
                widht: MediaQuery.of(context).size.width * 0.075,
                onpressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ClassRetailMainMobile(
                              fromsaved: false,
                              trno: trno,
                              qty: 0,
                              pscd: widget.pscd.toString(),
                              outletinfo: widget.outletinfo!,
                            )),
                  );
                },
                name: 'Transaksi ',
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ButtonClassAction(
                iconasset: 'outlet.png',
                height: MediaQuery.of(context).size.height * 0.04,
                widht: MediaQuery.of(context).size.width * 0.075,
                onpressed: () async {
                  final Outlet result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Selectoutletmobile()),
                  );
                  setState(() {});
                  // callbackTitle(result);
                  AppsMobile.of(context)!.string = result;
                  print(result);
                },
                name: 'Outlet',
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ButtonClassAction(
                iconasset: 'pembeli.png',
                height: MediaQuery.of(context).size.height * 0.04,
                widht: MediaQuery.of(context).size.width * 0.075,
                onpressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ClassListCustomers()),
                  );
                },
                name: 'Customer',
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ButtonClassAction(
                iconasset: 'settings.png',
                height: MediaQuery.of(context).size.height * 0.04,
                widht: MediaQuery.of(context).size.width * 0.075,
                onpressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MainMenuProduct(
                              pscd: widget.outletinfo!.outletcd,
                              outletinfo: widget.outletinfo!,
                            )),
                  );
                },
                name: 'Product',
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ButtonClassAction(
                iconasset: 'pegawai.png',
                height: MediaQuery.of(context).size.height * 0.04,
                widht: MediaQuery.of(context).size.width * 0.075,
                onpressed: () {},
                name: 'Pegawai',
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
              ButtonClassAction(
                iconasset: 'help.png',
                height: MediaQuery.of(context).size.height * 0.04,
                widht: MediaQuery.of(context).size.width * 0.075,
                onpressed: () async {
                  // handler = DatabaseHandler();
                  // await handler.upgradeDB();
                },
                name: 'Help',
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                width: MediaQuery.of(context).size.width * 0.05,
              ),
            ],
          ),
        );
      }
      return Container();
    });
  }
}
