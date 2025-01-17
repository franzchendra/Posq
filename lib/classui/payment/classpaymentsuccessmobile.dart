// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, prefer_const_literals_to_create_immutables, unused_import, avoid_print

import 'dart:convert';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posq/classfungsi/classhitungreward.dart';
import 'package:posq/classui/api.dart';
import 'package:posq/classui/buttonclass.dart';
import 'package:posq/classui/classtextfield.dart';
import 'package:posq/integrasipayment/midtrans.dart';
import 'package:posq/databasehandler.dart';
import 'package:posq/model.dart';
import 'package:posq/retailmodul/clasretailmainmobile.dart';
import 'package:posq/setting/printer/classmainprinter.dart';
import 'package:posq/setting/printer/classprinterbillpayment.dart';
import 'package:posq/userinfo.dart';
import 'package:toast/toast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

PaymentGate? paymentapi;
ClassApi? api;
PrintSmallPayment? printing;

class ClassPaymetSucsessMobile extends StatefulWidget {
  final bool frombanktransfer;
  final String? virtualaccount;
  final String trno;
  final num amount;
  final String paymenttype;
  final String? guestname;
  final String? trdt;
  final String? outletcd;
  final String? outletname;
  final Outlet? outletinfo;
  final bool? cash;
  final List<IafjrndtClass> datatrans;
  final bool fromsaved;
  final bool fromsplit;

  const ClassPaymetSucsessMobile({
    Key? key,
    required this.trno,
    required this.amount,
    required this.paymenttype,
    required this.guestname,
    this.trdt,
    this.outletcd,
    this.outletname,
    required this.outletinfo,
    required this.cash,
    this.virtualaccount,
    required this.frombanktransfer,
    required this.datatrans,
    required this.fromsaved,
    required this.fromsplit,
  }) : super(key: key);

  @override
  State<ClassPaymetSucsessMobile> createState() =>
      _ClassPaymetSucsessMobileState();
}

class _ClassPaymetSucsessMobileState extends State<ClassPaymetSucsessMobile> {
  late DatabaseHandler handler;
  int? trno;
  String? nexttrno;
  String? statustransaction = '';
  final bool pending = true;
  final TextEditingController _telp =
      TextEditingController(text: '82221769478');
  final TextEditingController _email = TextEditingController();
  List<String> string = [];
  List<ItemMail> itememail = [];
  List<String> summary = [];
  List<String> payment = [];
  List<PaymentEmail> paymentemail = [];
  num subtotal = 0;
  num discounts = 0;
  num total = 0;
  num tax = 0;
  num service = 0;
  num grantotal = 0;
  num totalcharge = 0;
  var now = DateTime.now();
  var formatter = DateFormat('yyyy-MM-dd');
  var formattedDate;
  bool loading = false;
  bool emailValid = false;
  List<IafjrndtClass> datacheck = [];
  int? pendings;
  PrintSmallPayment printing = PrintSmallPayment();
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  bool connected = false;
  List<IafjrndtClass>? summarybill;
  List<IafjrnhdClass> data = [];
  String logourl = '';
  String header = '';
  String footer = '';
  var wsUrl;
  WebSocketChannel? channel;

  checkPrinter() async {
    connected = await bluetooth.isConnected.then((value) => value!);
    setState(() {});
    print(connected);
  }

  @override
  void initState() {
    super.initState();
    checkPrinter();
    wsUrl = Uri.parse('ws://digims.online:8080?property=$dbname');
    channel = WebSocketChannel.connect(wsUrl);
    channel!.stream.listen((message) {
      print(message);

      // channel.sink.close(status.goingAway);
    });
    getSumm();
    formattedDate = formatter.format(now);
    generateDataWA();
    removeDiscount();
    api = ClassApi();
    // getSummary();
    getListPayament();
    getPaymentList();
    getTemplatePrinter();
    if (widget.cash == false) {
      PaymentGate.getStatusTransaction(widget.trno).then((value) {
        setState(() {
          statustransaction = value;
        });
      });
    } else {
      setState(() {
        statustransaction = 'Settlement';
      });
    }
  }

  getTemplatePrinter() {
    ClassApi.getTemplatePrinter().then((value) {
      if (value.isNotEmpty) {
        logourl = value[0]['logourl'];
        header = value[0]['header'];
        footer = value[0]['footer'];
      }
      ;
    });
    setState(() {});
  }

  Future<List<IafjrndtClass>> getDetailTrnos() async {
    datacheck = await ClassApi.getTrnoDetail(widget.trno, dbname, '');

    setState(() {});
    return datacheck;
  }

  Stream<String> _getstatus() async* {
    if (widget.cash == false) {
      await PaymentGate.getStatusTransaction(widget.trno).then((value) {
        setState(() {
          statustransaction = value;
        });
      });
    }

    // This loop will run forever because _running is always true
  }

  checkPending() {
    ClassApi.getOutstandingBillTransno(widget.trno, dbname, '').then((value) {
      setState(() {
        pendings = value.length;
      });
    });
  }

  checkTrno() async {
    var transno = await ClassApi.checkTrno();
    nexttrno = widget.outletcd! + '-' + transno[0]['transnonext'].toString();
    print(trno);
  }

  updateTrno() async {
    await ClassApi.updateTrno(dbname);
    await checkTrno();
  }

  generateDataWA() {
    List.generate(widget.datatrans.length, (index) {
      string.add(
          '${widget.datatrans[index].description.toString().padRight(23)}\n   ${widget.datatrans[index].qty.toString().padLeft(40)}X\t   ${widget.datatrans[index].totalaftdisc.toString().padRight(10)}\n');
    });
    List.generate(widget.datatrans.length, (index) {
      itememail.add(ItemMail(
          item: widget.datatrans[index].itemdesc!,
          harga: widget.datatrans[index].totalaftdisc!));
    });
  }

  removeDiscount() {
    string.removeWhere((element) => element.contains('Discount'));
  }

  // getSummary() async {
  //   await handler.summarybill(widget.datatrans.first.transno!).then((value) {
  //     List.generate(value.length, (index) {
  //       summary.add('total'.padRight(16, '  ') +
  //           ':'.padRight(2) +
  //           '${value[index].revenueamt.toString().padLeft(20)}\n' +
  //           'discount'.padRight(14, '  ') +
  //           ':'.padRight(2) +
  //           '${value[index].discamt.toString().padLeft(20)}\n' +
  //           'pajak'.padRight(15, '  ') +
  //           ':'.padRight(2) +
  //           '${value[index].taxamt.toString().padLeft(20)}\n' +
  //           'service'.padRight(15, '  ') +
  //           ':'.padRight(2) +
  //           '${value[index].serviceamt.toString().padLeft(20)}\n' +
  //           'grand total'.padRight(15, '  ') +
  //           ':'.padRight(2) +
  //           '${value[index].totalaftdisc.toString().padLeft(20)}\n');
  //     });
  //   });
  // }

  getSumm() async {
    await ClassApi.getSumTrans(widget.trno, dbname, '').then((value) {
      print('ini summary : $value');
      if (value.isNotEmpty) {
        setState(() {
          summarybill = value;
        });
      } else {}
    });
  }

  getListPayament() {
    handler.retriveListDetailPayment(widget.trno).then((value) {
      setState(() {
        totalcharge = value.first.ftotamt!;
      });
      List.generate(value.length, (index) {
        payment.add(
            '${value[index].compdesc.toString().padRight(15, '  ')}${value[index].ftotamt.toString().padLeft(23, ' ')}\n');
      });

      List.generate(value.length, (index) {
        paymentemail.add(PaymentEmail(
            metode: value[index].trdesc!, jumlah: value[index].ftotamt!));
      });
    });
  }

  getPaymentList() async {
    data = await ClassApi.getDetailPayment(widget.trno, dbname, '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          StreamBuilder(
              stream: _getstatus(),
              builder: (context, AsyncSnapshot<String> snapshot) {
                return Center(
                  child: Container(
                    height: MediaQuery.of(context).size.height * 95,
                    width: MediaQuery.of(context).size.width * 0.90,
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),
                        Text(
                          'Transaksi Berhasil',
                          style: TextStyle(fontSize: 25, color: Colors.green),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.14,
                          width: MediaQuery.of(context).size.height * 0.14,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: AssetImage('assets/check.png'),
                            fit: BoxFit.fill,
                          )),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.05,
                        ),
                        TextFieldMobile2(
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.send,
                            ),
                            iconSize: 20,
                            color: Colors.blue,
                            splashColor: Colors.purple,
                            onPressed: () {
                              // String subtotal = 'subtotal';
                              // String discount = 'Discount';
                              // String taxs = 'Pajak';
                              // String services = 'Service';
                              // String grandtotal = 'Grand Total';
                              FocusManager.instance.primaryFocus?.unfocus();
                              var whatsappUrl =
                                  "whatsapp://send?phone=${"+62" + _telp.text}" +
                                      "&text=" +
                                      '''
Outlet : ${widget.outletname}
Trx    : ${widget.trno}

item
-----------------------------------------          
${string.reduce((value, element) => value + element)}
-----------------------------------------
${summary.reduce((value, element) => value + element)}
-----------------------------------------
${payment.reduce((value, element) => value + element)}
''';
                              try {
                                launch(whatsappUrl);
                              } catch (e) {
                                //To handle error and display error message
                                print('gagal kirim $e');
                              }
                            },
                          ),
                          label: 'Whatsapp',
                          controller: _telp,
                          onChanged: (String value) {},
                          typekeyboard: TextInputType.phone,
                        ),
                        TextFieldMobile2(
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.send,
                            ),
                            iconSize: 20,
                            color: Colors.blue,
                            splashColor: Colors.purple,
                            onPressed: emailValid == true
                                ? () async {
                                    setState(() {
                                      loading = true;
                                    });
                                    await ClassApi.sendMail(
                                            paymentemail,
                                            itememail,
                                            formattedDate,
                                            widget.outletname!,
                                            widget.trno,
                                            totalcharge,
                                            _email.text)
                                        .then((value) {
                                      if (value['hasil'] == 'success') {
                                        setState(() {
                                          loading = false;
                                        });
                                      } else {
                                        setState(() {
                                          loading = false;
                                        });
                                        Toast.show("Failed send email",
                                            duration: Toast.lengthLong,
                                            gravity: Toast.center);
                                      }
                                      print(value['hasil']);
                                      Toast.show(
                                          "${value['hasil']} sending email",
                                          duration: Toast.lengthLong,
                                          gravity: Toast.center);
                                    });
                                  }
                                : null,
                          ),
                          label: 'E-mail',
                          controller: _email,
                          onChanged: (String value) {
                            emailValid = RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(_email.text);
                            print(emailValid);
                          },
                          validator: (value) {
                            emailValid = RegExp(
                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                .hasMatch(_email.text);
                            print(emailValid);
                            if (emailValid) {
                              return 'valid';
                            } else {
                              return 'not valid email';
                            }
                          },
                          typekeyboard: TextInputType.text,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.27,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ButtonNoIcon(
                              textcolor: connected == true
                                  ? Colors.orange
                                  : Colors.red,
                              color: Colors.white,
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.height * 0.18,
                              onpressed:
                                  accesslist.contains('settingprinter') == true
                                      ? () async {
                                          await getSumm();
                                          if (connected == true) {
                                            await printing.prints(
                                                widget.datatrans,
                                                summarybill!,
                                                data,
                                                widget.outletinfo!.outletname!,
                                                header,
                                                footer,
                                                logourl,
                                                widget.outletinfo!);
                                          } else {
                                            await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ClassMainPrinter()));
                                          }
                                        }
                                      : () {
                                          Toast.show(
                                              "Tidak Punya access printer",
                                              duration: Toast.lengthLong,
                                              gravity: Toast.center);
                                        },
                              name: 'Print',
                            ),
                            ButtonNoIcon(
                              textcolor: Colors.white,
                              color: Colors.orange,
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.height * 0.18,
                              onpressed: () async {
                                // if (Pembelian(widget.amount)
                                //         .hitungPoin()
                                //         .toInt() !=
                                //     '0') {
                                //   await ClassApi.updatePointCustomers(
                                //       Pembelian(widget.amount)
                                //           .hitungPoin()
                                //           .toInt(),
                                //       widget.guestname!);
                                // }
                                channel!.sink
                                    .add(json.encode({"property": dbname}));
                                await getDetailTrnos().then((value) async {
                                  print('ini value : $value');
                                  if (value.isEmpty) {
                                    await updateTrno();
                                    await ClassApi.cleartable(
                                        dbname, widget.trno);
                                    Navigator.of(context).pushAndRemoveUntil(
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ClassRetailMainMobile(
                                                  fromsaved: widget.fromsaved,
                                                  pscd: widget.outletcd!,
                                                  trno: nexttrno,
                                                  outletinfo:
                                                      widget.outletinfo!,
                                                  qty: 0,
                                                )),
                                        (Route<dynamic> route) => false);
                                  } else {
                                    if (widget.fromsaved == true) {
                                      await checkTrno();
                                      await ClassApi.cleartable(
                                          dbname, widget.trno);
                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ClassRetailMainMobile(
                                                    fromsaved: false,
                                                    pscd: widget.outletcd!,
                                                    trno: nexttrno,
                                                    outletinfo:
                                                        widget.outletinfo!,
                                                    qty: 0,
                                                  )),
                                          (Route<dynamic> route) => false);
                                    } else if (widget.fromsplit == true) {
                                      for (var x in widget.datatrans) {
                                        if (x.condimenttype == '') {
                                          await ClassApi.updateSplit(
                                              dbname, widget.trno, x.itemseq!);
                                        }
                                      }

                                      await ClassApi.getOutstandingBillTransno(
                                              widget.trno, dbname, '')
                                          .then((valued) async {
                                        print('ini value success:  $valued');
                                        if (valued.isEmpty) {
                                          await updateTrno();
                                          await ClassApi.cleartable(
                                              dbname, widget.trno);
                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ClassRetailMainMobile(
                                                            fromsaved: widget
                                                                .fromsaved,
                                                            pscd: widget
                                                                .outletcd!,
                                                            trno: nexttrno,
                                                            outletinfo: widget
                                                                .outletinfo!,
                                                            qty: 0,
                                                          )),
                                                  (Route<dynamic> route) =>
                                                      false);
                                        } else {
                                          print('masih ada OT');

                                          Navigator.of(context)
                                              .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ClassRetailMainMobile(
                                                            fromsaved: false,
                                                            pscd: widget
                                                                .outletcd!,
                                                            trno: widget.trno,
                                                            outletinfo: widget
                                                                .outletinfo!,
                                                            qty: 0,
                                                          )),
                                                  (Route<dynamic> route) =>
                                                      false);
                                        }
                                      });
                                    } else {
                                      await updateTrno();
                                      await ClassApi.cleartable(
                                          dbname, widget.trno);
                                      Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ClassRetailMainMobile(
                                                    fromsaved: false,
                                                    pscd: widget.outletcd!,
                                                    trno: nexttrno,
                                                    outletinfo:
                                                        widget.outletinfo!,
                                                    qty: 0,
                                                  )),
                                          (Route<dynamic> route) => false);
                                    }
                                  }
                                });
                              },
                              name: 'Transaksi baru',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
          Center(
            child: Opacity(
              opacity: loading ? 1.0 : 0,
              child: Container(
                color: Colors.grey,
                height: MediaQuery.of(context).size.height * 0.2,
                width: MediaQuery.of(context).size.width * 0.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    Text(
                      'Sending email',
                      style: TextStyle(color: Colors.blue),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
