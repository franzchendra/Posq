// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posq/classui/buttonclass.dart';
import 'package:posq/classui/dialogclass.dart';
import 'package:posq/classui/midtrans.dart';
import 'package:posq/databasehandler.dart';
import 'package:posq/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

PaymentGate? paymentapi;

class PaymentMobileCreditCard extends StatefulWidget {
  final String trno;
  final String pscd;
  late num? result;
  final num balance;
  final String? outletname;
  final Outlet? outletinfo;
  final bool? discbyamount;
  final List<IafjrndtClass> datatrans;
  late bool zerobill;
  final Function callback;

  PaymentMobileCreditCard({
    Key? key,
    required this.trno,
    required this.pscd,
    required this.balance,
    this.outletname,
    this.outletinfo,
    this.discbyamount,
    required this.datatrans,
    this.result,
    required this.zerobill,
    required this.callback
  }) : super(key: key);

  @override
  State<PaymentMobileCreditCard> createState() =>
      _PaymentMobileCreditCardState();
}

class _PaymentMobileCreditCardState extends State<PaymentMobileCreditCard> {
  late DatabaseHandler handler;
  var formattedDate;
  var now = DateTime.now();
  var formatter = DateFormat('yyyy-MM-dd');
  bool paymentsuccess = false;
  String compcd = '';
  String compdesc = '';
  String virtualaccount = '';
  String bank = '';
  String bill_key = '';
  String biller_code = '';
  String transactionstatus = '';
  num totalamount = 0;
  String email = 'mithmass2@gmail.com';
  String phone = '+6282221769478';
  String guestname = 'None';
  List<Midtransitem> listitem = [];

  @override
  void initState() {
    super.initState();
    handler = DatabaseHandler();
    handler.initializeDB();
    formattedDate = formatter.format(now);
    paymentapi = PaymentGate();
    print(widget.result);
    List.generate(
        widget.datatrans.length,
        (index) => listitem.add(Midtransitem(
            id: '${widget.datatrans[index].itemcd}'.replaceAll(' ', ''),
            price: num.parse(
                '${widget.datatrans[index].nettamt! / widget.datatrans[index].qty!}'),
            quantity: int.parse('${widget.datatrans[index].qty}'),
            name: '${widget.datatrans[index].trdesc}')));
    print(listitem);
    checkSF();
  }

  checkSF() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String guestPref = prefs.getString('savecostmrs') ?? "";
    if (guestPref.isNotEmpty) {
      Map<String, dynamic> userMap =
          jsonDecode(guestPref) as Map<String, dynamic>;
      if (userMap != []) {
        setState(() {
          guestname = userMap['guestname'];
          email = userMap['email'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      color: Colors.grey[100],
      height: MediaQuery.of(context).size.height * 0.25,
      width: MediaQuery.of(context).size.width * 0.90,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.05,
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Row(
            children: [
              Container(
                child: Text('Kredit Card',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Container(
            color: Colors.grey[100],
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width * 0.90,
            child: GridView.count(
              physics: NeverScrollableScrollPhysics(),
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 1.6,
              crossAxisCount: 3,
              children: [
                ButtonClassPayment(
                  name: '',
                  iconasset: 'bca.png',
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.2,
                  onpressed: () async {
                    await PaymentGate.bankTransfer(
                            guestname,
                            'bca',
                            phone,
                            email,
                            widget.trno,
                            widget.result.toString(),
                            listitem.toList())
                        .then((value) async {
                      if (value['status_code'] != '406') {
                        List x = value['va_numbers'];
                        print(x.first['va_number']);
                        setState(() {
                          virtualaccount = x.first['va_number'];
                          bank = x.first['bank'];
                          transactionstatus = value['transaction_status'];
                          totalamount = num.parse(value['gross_amount']);
                        });
                        await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return DialogClassBankTransfer(
                        
                                paymenttype: 'Account',
                                virtualaccount: virtualaccount,
                                bank: bank,
                                transactionstatus: transactionstatus,
                                grossmaount: totalamount,
                                compcd: compcd,
                                compdesc: compdesc,
                                result: widget.result,
                                balance: widget.balance,
                                pscd: widget.outletinfo!.outletcd,
                                trno: widget.trno,
                                outletinfo: widget.outletinfo,
                              );
                            });
                        setState(() {
                          compcd = 'BCA VA';
                          compdesc = 'BCA VA';
                        });
                      }
                      Toast.show(
                          "Payment Information already sent to customers email",
                          duration: Toast.lengthLong,
                          gravity: Toast.center);
                    });
                  },
                ),
                ButtonClassPayment(
                  name: '',
                  iconasset: 'bni.png',
                  height: MediaQuery.of(context).size.height * 0.2,
                  width: MediaQuery.of(context).size.width * 0.2,
                  onpressed: () async {
                    setState(() {
                      compcd = 'BNIVA';
                      compdesc = 'BNI VA';
                    });
                    await PaymentGate.bankTransfer(
                            guestname,
                            'bni',
                            phone,
                            email,
                            widget.trno,
                            widget.result.toString(),
                            listitem.toList())
                        .then((value) async {
                      if (value['status_code'] != '406') {
                        if (value != null) {
                          List x = value['va_numbers'];
                          print(x.first['va_number']);
                          setState(() {
                            virtualaccount = x.first['va_number'];
                            bank = x.first['bank'];
                            transactionstatus = value['transaction_status'];
                            totalamount = num.parse(value['gross_amount']);
                          });
                        }
                        await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return DialogClassBankTransfer(
                         
                                paymenttype: 'Account',
                                virtualaccount: virtualaccount,
                                bank: bank,
                                transactionstatus: transactionstatus,
                                grossmaount: totalamount,
                                compcd: compcd,
                                compdesc: compdesc,
                                result: widget.result,
                                balance: widget.balance,
                                pscd: widget.outletinfo!.outletcd,
                                trno: widget.trno,
                                outletinfo: widget.outletinfo,
                              );
                            });
                      }
                      Toast.show(
                          "Payment Information already sent to customers email",
                          duration: Toast.lengthLong,
                          gravity: Toast.center);
                    });
                  },
                ),
                ButtonClassPayment(
                  name: '',
                  iconasset: 'bri.png',
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.1,
                  onpressed: () async {
                    await PaymentGate.bankTransfer(
                            guestname,
                            'bri',
                            phone,
                            email,
                            widget.trno,
                            widget.result.toString(),
                            listitem.toList())
                        .then((value) async {
                      if (value['status_code'] != '406') {
                        List x = value['va_numbers'];
                        print(x.first['va_number']);
                        setState(() {
                          virtualaccount = x.first['va_number'];
                          bank = x.first['bank'];
                          transactionstatus = value['transaction_status'];
                          totalamount = num.parse(value['gross_amount']);
                        });
                        await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return DialogClassBankTransfer(
                        
                                paymenttype: 'Account',
                                virtualaccount: virtualaccount,
                                bank: bank,
                                transactionstatus: transactionstatus,
                                grossmaount: totalamount,
                                compcd: compcd,
                                compdesc: compdesc,
                                result: widget.result,
                                balance: widget.balance,
                                pscd: widget.outletinfo!.outletcd,
                                trno: widget.trno,
                                outletinfo: widget.outletinfo,
                              );
                            });
                        setState(() {
                          compcd = 'BRIVA';
                          compdesc = 'BRI VA';
                        });
                      }
                      Toast.show(
                          "Payment Information already sent to customers email",
                          duration: Toast.lengthLong,
                          gravity: Toast.center);
                    });
                  },
                ),
                ButtonClassPayment(
                  name: '',
                  iconasset: 'mandiri.png',
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.1,
                  onpressed: () async {
                    await PaymentGate.mandiribillers(
                            guestname,
                            phone,
                            email,
                            widget.trno,
                            widget.result.toString(),
                            listitem.toList())
                        .then((value) async {
                      if (value['status_code'] != '406') {
                        print(value['bill_key']);
                        setState(() {
                          bill_key = value['bill_key'];
                          biller_code = value['biller_code'];
                          transactionstatus = value['transaction_status'];
                          totalamount = num.parse(value['gross_amount']);
                        });
                        setState(() {
                          compcd = 'MANDIRIVA';
                          compdesc = 'MANDIRI VA';
                        });
                        await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return DialogClassMandiribiller(
                          
                                paymenttype: 'Account',
                                bill_key: bill_key,
                                biller_code: biller_code,
                                transactionstatus: transactionstatus,
                                grossmaount: totalamount,
                                compcd: compcd,
                                compdesc: compdesc,
                                result: widget.result,
                                balance: widget.balance,
                                pscd: widget.outletinfo!.outletcd,
                                trno: widget.trno,
                                outletinfo: widget.outletinfo,
                              );
                            });
                      }
                      Toast.show(
                          "Payment Information already sent to customers email",
                          duration: Toast.lengthLong,
                          gravity: Toast.center);
                    });
                  },
                ),
                ButtonClassPayment(
                  name: '',
                  iconasset: 'permatabank.png',
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.1,
                  onpressed: () async {
                    await PaymentGate.getvaPermata(
                      guestname,
                      email,
                      phone,
                      widget.trno,
                      listitem.toList(),
                      widget.result.toString(),
                    ).then((value) async {
                      if (value['status_code'] != '406') {
                        print(value);
                        setState(() {
                          virtualaccount = value['permata_va_number'];
                          bank = 'permata bank';
                          transactionstatus = value['transaction_status'];
                          totalamount = num.parse(value['gross_amount']);
                        });
                        await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return DialogClassBankTransfer(
                        
                                paymenttype: 'Account',
                                virtualaccount: virtualaccount,
                                bank: bank,
                                transactionstatus: transactionstatus,
                                grossmaount: totalamount,
                                compcd: compcd,
                                compdesc: compdesc,
                                result: widget.result,
                                balance: widget.balance,
                                pscd: widget.outletinfo!.outletcd,
                                trno: widget.trno,
                                outletinfo: widget.outletinfo,
                              );
                            });
                        setState(() {
                          compcd = 'PERMATAVA';
                          compdesc = 'PERMATA VA';
                        });
                      }
                      Toast.show(
                          "Payment Information already sent to customers email",
                          duration: Toast.lengthLong,
                          gravity: Toast.center);
                    });
                  },
                ),
                ButtonClassPayment2(
                  name: 'Lainnya',
                  height: MediaQuery.of(context).size.height * 0.1,
                  width: MediaQuery.of(context).size.width * 0.1,
                  onpressed: () async {
                    await PaymentGate.getvaPermata(
                      guestname,
                      email,
                      phone,
                      widget.trno,
                      listitem.toList(),
                      widget.result.toString(),
                    ).then((value) async {
                      if (value['status_code'] != '406') {
                        print(value);
                        setState(() {
                          virtualaccount = value['permata_va_number'];
                          bank = 'permata bank';
                          transactionstatus = value['transaction_status'];
                          totalamount = num.parse(value['gross_amount']);
                        });
                        await showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (BuildContext context) {
                              return DialogClassBankTransfer(
                             
                                paymenttype: 'Account',
                                virtualaccount: virtualaccount,
                                bank: bank,
                                transactionstatus: transactionstatus,
                                grossmaount: totalamount,
                                compcd: compcd,
                                compdesc: compdesc,
                                result: widget.result,
                                balance: widget.balance,
                                pscd: widget.outletinfo!.outletcd,
                                trno: widget.trno,
                                outletinfo: widget.outletinfo,
                              );
                            });
                        setState(() {
                          compcd = 'PERMATAVA';
                          compdesc = 'PERMATA VA';
                        });
                      }
                      Toast.show(
                          "Payment Information already sent to customers email",
                          duration: Toast.lengthLong,
                          gravity: Toast.center);
                    });
                  },
                ),
                // Padding(
                //   padding: const EdgeInsets.all(10.0),
                //   child: ButtonClassPayment(
                //     name: '',
                //     iconasset: '',
                //     height: MediaQuery.of(context).size.height * 0.1,
                //     width: MediaQuery.of(context).size.width * 0.1,
                //     onpressed: () {
                //       setState(() {
                //         compcd = 'qris';
                //         compdesc = 'qris';
                //       });
                //     },
                //   ),
                // )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
