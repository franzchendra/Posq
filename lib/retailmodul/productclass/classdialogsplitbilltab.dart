import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:posq/classui/api.dart';
import 'package:posq/classui/classformat.dart';
import 'package:posq/classui/payment/paymenttablet/dialogclasspayment.dart';
import 'package:posq/model.dart';

class DialogSplitTab extends StatefulWidget {
  final String trno;
  final String pscd;
  final String trdt;
  final num balance;
  final String? outletname;
  final Outlet? outletinfo;
  final List<IafjrndtClass> datatrans;
  final bool fromsaved;

  const DialogSplitTab({
    Key? key,
    required this.trno,
    required this.outletinfo,
    required this.pscd,
    required this.trdt,
    required this.balance,
    this.outletname,
    required this.datatrans,
    required this.fromsaved,
  }) : super(key: key);

  @override
  State<DialogSplitTab> createState() => _DialogSplitTabStateState();
}

class _DialogSplitTabStateState extends State<DialogSplitTab> {
  final GlobalKey<FormState> _formKeys = GlobalKey<FormState>();

  List<bool> checkedValues = [];
  final List<IafjrndtClass> selected = [];
  var now = DateTime.now();
  var formatter = DateFormat('yyyy-MM-dd');
  var formattedDate;
  num totalSlsNett = 0;

  @override
  void initState() {
    checkedValues = List.filled(widget.datatrans.length, false);
    super.initState();
    formattedDate = formatter.format(now);
  }

  getSum(List<IafjrndtClass> selected) {
    totalSlsNett = selected.fold(
        0, (previousValue, isi) => previousValue + isi.totalaftdisc!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        title: Row(
          children: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.arrow_back_ios_new)),
            Text('Split bill'),
            Spacer(),
            Text(
              CurrencyFormat.convertToIdr(totalSlsNett, 0),
            ),
          ],
        ),
        content: Column(
          children: [
            Row(
              children: [
                SizedBox(width: MediaQuery.of(context).size.width*0.015,),
                Text('Item yg akan di split',style: TextStyle(fontWeight: FontWeight.bold),),
              ],
            ),
                   SizedBox(height: MediaQuery.of(context).size.height*0.015,),
            Form(
                key: _formKeys,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.48,
                  width: MediaQuery.of(context).size.width * 0.6,
                  child: ListView.builder(
                    itemCount: widget.datatrans.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Column(
                        children: [
                          CheckboxListTile(
                            dense: true,
                            subtitle: Row(
                              children: [
                                Text(widget.datatrans[index].qty.toString()),
                                Text('X  '),
                                Text(
                                  CurrencyFormat.convertToIdr(
                                      widget.datatrans[index].totalaftdisc, 0),
                                ),
                              ],
                            ),
                            title: Text(widget.datatrans[index].itemdesc!),
                            value: checkedValues[index],
                            onChanged: (newValue) {
                              setState(() {
                                checkedValues[index] = newValue!;
                              });
                              if (checkedValues[index] == true) {
                                selected.add(widget.datatrans[index]);
                                print(selected);
                                getSum(selected);
                              } else {
                                selected.removeWhere((element) =>
                                    element == widget.datatrans[index]);
                                print(selected);
                                getSum(selected);
                              }
                            },
                          ),
                          Divider(
                            height: MediaQuery.of(context).size.height * 0.01,
                          )
                        ],
                      );
                    },
                  ),
                )),
          ],
        ),
        actions: <Widget>[
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // <-- Radius
                  ),
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white // Background color
                  ),
              onPressed: () async {},
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.1,
                child: Text(
                  'Print',
                  style: TextStyle(color: Colors.orange),
                ),
              )),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5), // <-- Radius
                  ),
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.orange // Background color
                  ),
              onPressed: () async {
                final result = await showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) => DialogPaymentTab(
                          fromsplit: true,
                          fromsaved: widget.fromsaved,
                          datatrans: selected,
                          outletinfo: widget.outletinfo,
                          balance: totalSlsNett,
                          pscd: widget.outletinfo!.outletcd,
                          trdt: formattedDate,
                          trno: widget.trno.toString(),
                          outletname: widget.outletinfo!.outletname,
                        )).then((_) {
                  setState(() {});
                });
              },
              child: Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width * 0.1,
                child: Text(
                  'Split',
                  style: TextStyle(color: Colors.white),
                ),
              ))
        ],
      );
    });
  }
}