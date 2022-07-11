// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_typing_uninitialized_variables, unnecessary_this, avoid_print, unnecessary_brace_in_string_interps

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posq/classui/classtextfield.dart';
import 'package:posq/databasehandler.dart';
import 'package:posq/model.dart';
import 'package:posq/retailmodul/classdetailtrnomobile.dart';

class Listtransaction extends StatefulWidget {
  final String? pscd;
  final Outlet outletinfo;

  const Listtransaction({
    Key? key,
    this.pscd,
    required this.outletinfo,
  }) : super(key: key);

  @override
  State<Listtransaction> createState() => _ListtransactionState();
}

class _ListtransactionState extends State<Listtransaction> {
  late DatabaseHandler handler;
  var now = DateTime.now();
  var formatter = DateFormat('yyyy-MM-dd');
  var formattedDate;
  int? pending;
  String? query = '';
  final TextEditingController search = TextEditingController();
  @override
  void initState() {
    super.initState();
    this.handler = DatabaseHandler();
    formattedDate = formatter.format(now);
    // checkPending();
  }

  // checkPending() {
  //   handler.checkPendingTransaction().then((value) {
  //     setState(() {
  //       pending = value;
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Riwayat Transaksi'),
        actions: [],
      ),
      body: Column(
        children: [
          TextFieldMobile2(
            hint: 'Search',
            suffixIcon: Icon(
              Icons.search,
            ),
            controller: search,
            onChanged: (value) {
              setState(() {
                query = value;
              });
            },
            typekeyboard: TextInputType.text,
          ),
          FutureBuilder(
              future: this.handler.retriveListHeader(query!),
              builder: (context, AsyncSnapshot<List<IafjrnhdClass>> snapshot) {
                var x = snapshot.data ?? [];
                if (x.isNotEmpty) {
                  return Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        width: MediaQuery.of(context).size.width * 1,
                        child: ListView.builder(
                            itemCount: x.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {},
                                child: DetailTrno(
                                  datatransaksi: IafjrnhdClass(
                                    pymtmthd: x[index].pymtmthd,
                                    totalamt: x[index].ftotamt,
                                    trdt: x[index].trdt,
                                  ),
                                  trno: x[index].trno,
                                  outletinfo: widget.outletinfo,
                                  pscd: widget.pscd.toString(),
                                ),
                              );
                            }),
                      )
                    ],
                  );
                }
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Text('Nothing here')],
                  ),
                );
              }),
        ],
      ),
    );
  }
}
