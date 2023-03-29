import 'dart:math';

import 'package:flutter/material.dart';
import 'package:posq/classui/api.dart';
import 'package:posq/classui/buttonclass.dart';
import 'package:posq/classui/classtextfield.dart';
import 'package:posq/model.dart';
import 'package:posq/userinfo.dart';

class CreateTipeTransaksi extends StatefulWidget {
  final String pscd;
  const CreateTipeTransaksi({Key? key, required this.pscd}) : super(key: key);

  @override
  State<CreateTipeTransaksi> createState() => _CreateTipeTransaksiState();
}

class _CreateTipeTransaksiState extends State<CreateTipeTransaksi> {
  final TextEditingController code = TextEditingController();
  final TextEditingController deskripsi = TextEditingController();
  late List<TextEditingController>? descriptionlist = [];
  late List<TransactionTipe> listtipe = [];
  bool _isloading = false;
  @override
  void initState() {
    super.initState();
  }

  _addWidget() {
    descriptionlist!.add(TextEditingController());
    listtipe.add(TransactionTipe());
  }

  removeWidget(index) {
    setState(() {
      descriptionlist!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Buat Tipe Transaksi'),
        actions: [
          Container(
            child: IconButton(
              onPressed: () {
                descriptionlist = [];
                setState(() {});
              },
              icon: Icon(Icons.delete),
              color: Colors.red,
            ),
          )
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.8,
            child: ListView.builder(
                itemCount: descriptionlist!.length,
                itemBuilder: (context, index) {
                  return Row(children: [
                    Expanded(
                      flex: 5,
                      child: TextFieldMobile2(
                          label: 'Transaksi tipe',
                          controller: descriptionlist![index],
                          typekeyboard: TextInputType.text,
                          onChanged: (value) {
                            var rng = Random();
                            for (var i = 0; i < 10; i++) {
                              // print(rng.nextInt(1000));

                            }
                            listtipe[index].transtype =
                                rng.nextInt(1000).toString();
                            listtipe[index].transdesc =
                                descriptionlist![index].text;
                            print(listtipe);
                          }),
                    ),
                    Expanded(
                        flex: 1,
                        child: IconButton(
                          onPressed: () {
                            removeWidget(index);
                          },
                          icon: Icon(Icons.close),
                          color: Colors.red,
                          iconSize: 17,
                        )),
                  ]);
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                LoadingButton(
                    isLoading: _isloading,
                    color: Colors.pink,
                    textcolor: Colors.white,
                    name: 'Simpan',
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.3,
                    onpressed: _isloading == false
                        ? () async {
                            _isloading = true;
                            await ClassApi.insert_TransactionType(
                                dbname, listtipe);
                            setState(() {});
                            _isloading = false;
                            Navigator.of(context).pop();
                          }
                        : null),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.05,
                ),
                ButtonNoIcon(
                  textcolor: Colors.white,
                  color: Colors.blue,
                  height: MediaQuery.of(context).size.height * 0.05,
                  width: MediaQuery.of(context).size.width * 0.6,
                  name: 'Tambah Tipe',
                  onpressed: () async {
                    _addWidget();
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
