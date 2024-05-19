import 'dart:io';
import 'package:flutter/services.dart';
import 'package:waterbill/models/User.dart';
import './FileHandleAPI.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfInvoiceApi {
  static Future<File> generate(PdfColor color, pw.Font fontFamily, User user) async {
    final pdf = pw.Document();

    final iconImage = (await rootBundle.load('assets/images/logo.png')).buffer.asUint8List();

    DateTime now = DateTime.now();
    String currentMonthYear = '${DateTime(now.year, now.month).month}/${DateTime(now.year, now.month).year}';
    num excessBill = user.excessBill[currentMonthYear] ?? 0;
    num excessConsumed = user.excessConsumed[currentMonthYear] ?? 0;
    num minimumBill = user.minimumBill[currentMonthYear] ?? 0;
    num readings = user.readings[currentMonthYear] ?? 0;
    num usage = user.usage[currentMonthYear] ?? 0;

    num totalBill = excessBill + minimumBill;

    final tableHeaders = [
      'Minimum Bill',
      'Excess Bill',
      'Excess Consumed',
      'Readings',
      'Usage',
    ];

    final tableData = [
      [
        '\$ $minimumBill php',
        '\$ $excessBill php',
        '$excessConsumed',
        '$readings',
        '$usage Litres',
      ]
    ];

    pdf.addPage(
      pw.MultiPage(
        build: (context) {
          return [
            pw.Row(
              children: [
                pw.Image(
                  pw.MemoryImage(iconImage),
                  height: 72,
                  width: 72,
                ),
                pw.SizedBox(width: 1 * PdfPageFormat.mm),
                pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'INVOICE',
                      style: pw.TextStyle(
                        fontSize: 17.0,
                        fontWeight: pw.FontWeight.bold,
                        color: color,
                        font: fontFamily,
                      ),
                    ),
                    pw.Text(
                      'Water Bill',
                      style: pw.TextStyle(
                        fontSize: 15.0,
                        color: color,
                        font: fontFamily,
                      ),
                    ),
                  ],
                ),
                pw.Spacer(),
                pw.Column(
                  mainAxisSize: pw.MainAxisSize.min,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      user.name,
                      style: pw.TextStyle(
                        fontSize: 15.5,
                        fontWeight: pw.FontWeight.bold,
                        color: color,
                        font: fontFamily,
                      ),
                    ),
                    pw.Text(
                      user.location,
                      style: pw.TextStyle(
                        fontSize: 14.0,
                        color: color,
                        font: fontFamily,
                      ),
                    ),
                    pw.Text(
                      currentMonthYear,
                      style: pw.TextStyle(
                        fontSize: 14.0,
                        color: color,
                        font: fontFamily,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Divider(),
            pw.SizedBox(height: 1 * PdfPageFormat.mm),
            pw.Text(
              'Dear ${user.name},\nLorem ipsum dolor sit amet consectetur adipisicing elit. Maxime mollitia, molestiae quas vel sint commodi repudiandae consequuntur voluptatum laborum numquam blanditiis harum quisquam eius sed odit fugiat iusto fuga praesentium optio, eaque rerum! Provident similique accusantium nemo autem. Veritatis obcaecati tenetur iure eius earum ut molestias architecto voluptate aliquam nihil, eveniet aliquid culpa officia aut! Impedit sit sunt quaerat, odit, tenetur error',
              textAlign: pw.TextAlign.justify,
              style: pw.TextStyle(
                fontSize: 14.0,
                color: color,
                font: fontFamily,
              ),
            ),
            pw.SizedBox(height: 5 * PdfPageFormat.mm),

            pw.Table.fromTextArray(
              headers: tableHeaders,
              data: tableData,
              border: null,
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration:
                  const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30.0,
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerRight,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
              },
            ),
            pw.Divider(),
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Row(
                children: [
                  pw.Spacer(flex: 6),
                  pw.Expanded(
                    flex: 4,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Net total',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              '\$ $totalBill php',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.Divider(),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Total amount due',
                                style: pw.TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: pw.FontWeight.bold,
                                  color: color,
                                  font: fontFamily,
                                ),
                              ),
                            ),
                            pw.Text(
                              '\$ $totalBill php',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                color: color,
                                font: fontFamily,
                              ),
                            ),
                          ],
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        pw.Container(height: 1, color: PdfColors.grey400),
                        pw.SizedBox(height: 0.5 * PdfPageFormat.mm),
                        pw.Container(height: 1, color: PdfColors.grey400),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        footer: (context) {
          return pw.Column(
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Divider(),
              pw.SizedBox(height: 2 * PdfPageFormat.mm),
              pw.Text(
                'Water Bill',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, color: color, font: fontFamily),
              ),
              pw.SizedBox(height: 1 * PdfPageFormat.mm),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Address: ',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, color: color, font: fontFamily),
                  ),
                  pw.Text(
                    '[insert address here]',
                    style: pw.TextStyle(color: color, font: fontFamily),
                  ),
                ],
              ),
              pw.SizedBox(height: 1 * PdfPageFormat.mm),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Email: ',
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, color: color, font: fontFamily),
                  ),
                  pw.Text(
                    '[email here]',
                    style: pw.TextStyle(color: color, font: pw.Font.courier()),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return FileHandleApi.saveDocument(name: 'my_invoice.pdf', pdf: pdf);
  }
}