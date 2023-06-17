import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:posq/classui/api.dart';
import 'package:posq/classui/buttonclass.dart';
import 'package:posq/classui/classtextfield.dart';
import 'package:posq/classui/dialogclass.dart';
import 'package:posq/image.dart';
import 'package:posq/model.dart';
import 'package:posq/setting/classtabcreateproductmobile.dart';
import 'package:posq/userinfo.dart';

class BuatPaketTab extends StatefulWidget {
  const BuatPaketTab({Key? key}) : super(key: key);

  @override
  State<BuatPaketTab> createState() => _BuatPaketTabState();

  static _BuatPaketTabState? of(BuildContext context) =>
      context.findAncestorStateOfType<_BuatPaketTabState>();
}

class _BuatPaketTabState extends State<BuatPaketTab> {
  final TextEditingController _namepaket = TextEditingController();
  final TextEditingController _harga = TextEditingController();
  final TextEditingController _notepaket = TextEditingController();
  final TextEditingController _pilihan =
      TextEditingController(text: 'pilih menu');
  List<Package> package = [];
  List<TextEditingController> qtycontroller = [];
  String prodcd = '';
  num code = 0;
  bool detailon = false;
  String? pathimage;

  set string(String? value) {
    setState(() {
      pathimage = value;
    });
    print("ini value $value");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Buat Paket'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 0, 173, 150),
        foregroundColor: Colors.white,
        splashColor: Colors.yellow,
        hoverColor: Colors.red,
        onPressed: () async {
          EasyLoading.show(status: 'loading...');
          await ClassApi.createPackageMenu(dbname, package);
          await ClassApi.insertProduct(
              Item(
                  outletcode: pscd,
                  sku: '',
                  trackstock: 0,
                  costamt: 0,
                  slsfl: 1,
                  modifiers: 0,
                  slsamt: int.parse(_harga.text),
                  slsnett: int.parse(_harga.text),
                  revenuecoa: 'REVENUE',
                  taxcoa: 'TAX',
                  svchgcoa: 'SERVICE',
                  costcoa: 'COST',
                  ctg: 'PAKET',
                  stock: 0,
                  pricelist: [],
                  packageflag: 1,
                  multiprice: 0,
                  itemcode: prodcd,
                  description: _namepaket.text,
                  itemdesc: _namepaket.text,
                  pathimage: pathimage),
              dbname);
          EasyLoading.dismiss();
          Navigator.of(context).pop();
        },
        child: Icon(Icons.save),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    'Nama Paket',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                  ),
                  Text(
                    'harga',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.12,
                  child: TextFieldMobile2(
                    hint: 'Nama Paket',
                    controller: _namepaket,
                    typekeyboard: TextInputType.text,
                    onChanged: (value) {
                      code = Random().nextInt(100) + 1;
                      prodcd =
                          code.toString() + _namepaket.text.substring(1, 4);
                      print(prodcd);
                    },
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  height: MediaQuery.of(context).size.height * 0.12,
                  child: TextFieldMobile2(
                    hint: 'Harga',
                    controller: _harga,
                    typekeyboard: TextInputType.text,
                    onChanged: (value) {},
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Container(
                  color: Colors.grey,
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: ImageFromGalleryEx(
                    ImageSourceType.gallery,
                    savingimage: pathimage,
                    fromedit: false,
                    frompaket: false,
                    imagepath: pathimage,
                    fromtemplateprint: false,
                    frompakettab: true,
                    height: MediaQuery.of(context).size.height * 0.2,
                    width: MediaQuery.of(context).size.width * 0.2,
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.4,
                  child: TextFieldMobileButton(
                      hint: 'Pilih menu',
                      controller: _pilihan,
                      typekeyboard: TextInputType.none,
                      onChanged: (value) {},
                      ontap: () async {
                        package = await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return DialogSetPackage(
                                // imagepath: pathimage!,
                                controllerpackage: _namepaket,
                                note: _notepaket.text,
                                packagecode: prodcd,
                              );
                            });
                        setState(() {});
                      }),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Text(
                    'Detail Paket',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: ListView.builder(
                  itemCount: package.length,
                  itemBuilder: (context, index) {
                    qtycontroller.add(TextEditingController(text: '1'));
                    return ListTile(
                      title: Text(package[index].itemdesc),
                      trailing: Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: Row(
                          children: [
                            IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  package[index].qty <= 0
                                      ? package[index].qty
                                      : package[index].qty--;
                                  qtycontroller[index].text =
                                      package[index].qty.toString();
                                  setState(() {});
                                  print(package);
                                },
                                icon: Icon(Icons.remove)),
                            Container(
                              width:
                                  MediaQuery.of(context).size.height * 0.1,
                              child: TextFieldMobile2(
                                hint: 'Nama package',
                                controller: qtycontroller[index],
                                typekeyboard: TextInputType.text,
                                onChanged: (value) {
                                  package[index].qty =
                                      int.parse(qtycontroller[index].text);
                                },
                              ),
                            ),
                            IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  package[index].qty++;
                                  qtycontroller[index].text =
                                      package[index].qty.toString();
                                  setState(() {});
                                  print(package);
                                },
                                icon: Icon(Icons.add)),
                          ],
                        ),
                      ),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }
}
