import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:posq/classui/api.dart';
import 'package:posq/classui/buttonclass.dart';
import 'package:posq/classui/classformat.dart';
import 'package:posq/classui/classtextfield.dart';
import 'package:posq/databasehandler.dart';
import 'package:posq/model.dart';
import 'package:posq/reporting/cashiersummary.dart';
import 'package:posq/reporting/classkirimlaporan.dart';
import 'package:posq/reporting/classlaporanmobile.dart';
import 'package:posq/reporting/classringkasan.dart';
import 'package:posq/reporting/reportingtablet/classcashierreporttab.dart';
import 'package:posq/reporting/reportingtablet/classdetailmenuterjual.dart';
import 'package:posq/reporting/reportingtablet/classringkasanreporttab.dart';
import 'package:posq/userinfo.dart';
import 'package:toast/toast.dart';

typedef MyBuilder = void Function(
    BuildContext context, void Function() methodA);

class ClassSummaryReportTab extends StatefulWidget {
  final String user;
  const ClassSummaryReportTab({Key? key, required this.user}) : super(key: key);

  @override
  State<ClassSummaryReportTab> createState() => _ClassSummaryReportTabState();
}

class _ClassSummaryReportTabState extends State<ClassSummaryReportTab> {
  var now = DateTime.now();
  var formatter = DateFormat('yyyy-MM-dd');
  var formatter2 = DateFormat('dd-MMM-yyyy');
  var formaterprd = DateFormat('yyyyMM');
  String? formattedDate;
  String? formatdate;
  String? periode;
  late DatabaseHandler handler;
  String? fromdate;
  String? todate;
  String? fromdatenamed;
  String? todatenamed;
  final TextEditingController _controllerdate = TextEditingController();
  final TextEditingController _controllerpilihan =
      TextEditingController(text: "Pilih tipe report");
  DateTimeRange? _selectedDateRange;
  String query = '';
  String type = '';
  int myIndex = 0;
  String selected = '';
  late void Function() myMethod;
  late void Function() ringkasan;
  List<IafjrnhdClass> listdatapayment = [];
  List<IafjrndtClass> data = [];
  List<IafjrndtClass> topMenu = [];
  List<IafjrndtClass> menukuranglaku = [];
  List<int> datarev = [];
  int totalKenaikan = 0;
  double persentaseKenaikan = 0;
  String? fromdateringkasan;
  bool todayringkasan = false;
  late Future<Null> initialDatas;

  void initState() {
    super.initState();
    type = 'Ringkasan';
    formattedDate = formatter2.format(now);
    formatdate = formatter.format(now);
    periode = formaterprd.format(now);
    startDate();
    handler = DatabaseHandler();
    _controllerpilihan.text = 'Ringkasan';
    fromdatenamed = formattedDate;
    todatenamed = formattedDate;
    _controllerdate.text = '$fromdatenamed - $todatenamed';
    ToastContext().init(context);
    selected = 'Hari ini';
    getDataRingkasan();
  }

  startDate() {
    setState(() {
      fromdate = formatdate;
      todate = formatdate;
    });
    print("ini formatdate sql $formatdate");
    print("ini from date$fromdate");
    print("ini todate $todate");
  }

/////fungsi pengambilan tanggal////
  Future<void> _selectDate(BuildContext context) async {
    final DateTimeRange? result = await showDateRangePicker(
        saveText: 'Done',
        context: context,
        // initialDate: now,
        firstDate: DateTime(2020, 8),
        lastDate: DateTime(2201));
    if (result != null) {
      // Rebuild the UI
      // print(result.start.toString());

      setState(() {
        _selectedDateRange = result;

        ///tanggal dan nama
        fromdatenamed = formatter2.format(result.start);
        todatenamed = formatter2.format(result.end);

        ///tanggal format database///
        fromdate = formatter.format(result.start);
        todate = formatter.format(result.end);
        _controllerdate.text = '$fromdatenamed - $todatenamed';
      });
    }
    getDataReport();
  }

  getDataReport() {
    //mengambil data list payment cashier summary//
    ClassApi.getSummaryCashierDetail(fromdate!, todate!, dbname, '')
        .then((value) {
      setState(() {
        listdatapayment = value;
      });
      print('Data harusnya terisi');
    });
  }

  getDataRingkasan() async {
    data =
        await ClassApi.getAnalisaRingkasan(fromdate!, todate!, dbname, query);
    print('terpanggil');

    topMenu = await ClassApi.getAnalisaRingkasanTopitem(
        fromdate!, todate!, dbname, query);

    menukuranglaku = await ClassApi.getAnalisaRingkasanItemKuranglaku(
        fromdate!, todate!, dbname, query);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          title: Text(
            'Laporan',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: TextFieldMobileButton(
                        suffixicone: Icon(Icons.date_range),
                        controller: _controllerdate,
                        onChanged: (value) {},
                        ontap: () async {
                          await _selectDate(context);
                        },
                        typekeyboard: TextInputType.text,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      child: TextFieldMobileButton(
                        suffixicone: Icon(Icons.arrow_drop_down_outlined),
                        controller: _controllerpilihan,
                        onChanged: (value) {},
                        ontap: () async {
                          type = await Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (BuildContext context) {
                            return ClassLaporanMobile();
                          }));
                          setState(() {
                            _controllerpilihan.text = type;
                          });
                          getDataReport();
                          print(type);
                          if (type == 'Summary Cashier') {
                            myMethod.call();
                            setState(() {});
                          }
                          if (type == 'Ringkasan') {
                            // ringkasan.call();
                            await getDataRingkasan();
                          }
                          setState(() {});
                        },
                        typekeyboard: TextInputType.text,
                      ),
                    ),
                    ButtonNoIcon2(
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: MediaQuery.of(context).size.height * 0.08,
                      color: Colors.white,
                      textcolor: Color.fromARGB(255, 0, 155, 160),
                      name: 'Print',
                      onpressed: () {},
                    ),
                    ButtonNoIcon2(
                      width: MediaQuery.of(context).size.width * 0.15,
                      height: MediaQuery.of(context).size.height * 0.08,
                      color: Color.fromARGB(255, 0, 155, 160),
                      textcolor: Colors.white,
                      name: 'Kirim Laporan',
                      onpressed: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return ClassKirimLaporan(
                            datapayment: listdatapayment,
                          );
                        }));
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ButtonNoIcon2(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.05,
                      color:
                          selected == 'Hari ini' ? Colors.white : Colors.orange,
                      textcolor:
                          selected == 'Hari ini' ? Colors.orange : Colors.white,
                      name: 'Hari ini',
                      onpressed: () async {
                        selected = 'Hari ini';
                        fromdatenamed = formatter2.format(now);
                        todatenamed = formatter2.format(now);
                        formatdate = formatter.format(now);
                        fromdate = formatdate;
                        todate = formatdate;
                        _controllerdate.text = '$fromdatenamed - $todatenamed';

                        print(todayringkasan);
                        if (type == 'Ringkasan') {
                          ringkasan.call();
                          await getDataRingkasan();

                          setState(() {});
                        }
                        if (type == 'Summary Cashier') {
                          myMethod.call();
                          setState(() {});
                        }

                        setState(() {});
                      },
                    ),
                    ButtonNoIcon2(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.05,
                      color:
                          selected == '7 Hari' ? Colors.white : Colors.orange,
                      textcolor:
                          selected == '7 Hari' ? Colors.orange : Colors.white,
                      name: '7 Hari',
                      onpressed: () async {
                        var weeks;

                        setState(() {
                          selected = '7 Hari';
                          formatdate = formatter.format(now);
                          weeks =
                              formatter.format(now.add((Duration(days: -6))));
                          fromdate = weeks;
                          todate = formatdate;
                          fromdatenamed =
                              formatter2.format(now.add((Duration(days: -6))));
                          todatenamed = formatter2.format(now);
                          formatdate =
                              formatter.format(now.add((Duration(days: -6))));

                          _controllerdate.text =
                              '$fromdatenamed - $todatenamed';
                        });
                        print(todayringkasan);

                        if (type == 'Summary Cashier') {
                          myMethod.call();
                          setState(() {});
                        }
                        if (type == 'Ringkasan') {
                          ringkasan.call();
                          await getDataRingkasan();
                        }
                        setState(() {});
                      },
                    ),
                    ButtonNoIcon2(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.05,
                      color:
                          selected == '30 Hari' ? Colors.white : Colors.orange,
                      textcolor:
                          selected == '30 Hari' ? Colors.orange : Colors.white,
                      name: '30 Hari',
                      onpressed: () async {
                        var month;

                        selected = '30 Hari';
                        formatdate = formatter.format(now);
                        month =
                            formatter.format(now.add((Duration(days: -30))));
                        fromdate = month;
                        todate = formatdate;
                        fromdatenamed =
                            formatter2.format(now.add((Duration(days: -30))));
                        todatenamed = formatter2.format(now);

                        _controllerdate.text = '$fromdatenamed - $todatenamed';
                        setState(() {});

                        if (type == 'Summary Cashier') {
                          myMethod.call();
                          setState(() {});
                        }
                        if (type == 'Ringkasan') {
                          ringkasan.call();
                          await getDataRingkasan();
                          setState(() {});
                        }

                        setState(() {});
                      },
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Builder(builder: (context) {
                  // print(type);
                  switch (type) {
                    case 'Summary Cashier':
                      return CashierSummaryTab(
                        builder:
                            (BuildContext context, void Function() methodA) {
                          myMethod = methodA;
                        },
                        fromdate: fromdate!,
                        todate: todate!,
                      );
                    case 'Detail Item Terjual':
                      return ClasMeuTerjualtab(
                        builder:
                            (BuildContext context, void Function() methodA) {
                          myMethod = methodA;
                        },
                        fromdate: fromdate!,
                        todate: todate!,
                      );
                    case 'Ringkasan':
                      ClassRingkasantab(
                        topMenu: topMenu,
                        menukuranglaku: menukuranglaku,
                        builder:
                            (BuildContext context, void Function() methodA) {
                          ringkasan = methodA;
                        },
                        datasales: data,
                        fromdate: fromdate!,
                        todate: todate!,
                      );
                      break;
                    default:
                      return ClassRingkasantab(
                        topMenu: topMenu,
                        menukuranglaku: menukuranglaku,
                        builder:
                            (BuildContext context, void Function() methodA) {
                          ringkasan = methodA;
                        },
                        datasales: data,
                        fromdate: fromdate!,
                        todate: todate!,
                      );
                  }
                  return ClassRingkasantab(
                    topMenu: topMenu,
                    menukuranglaku: menukuranglaku,
                    builder: (BuildContext context, void Function() methodA) {
                      ringkasan = methodA;
                    },
                    datasales: data,
                    fromdate: fromdate!,
                    todate: todate!,
                  );
                  ;
                })
              ],
            ),
          ],
        ));
  }
}