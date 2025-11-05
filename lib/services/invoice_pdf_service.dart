import 'dart:io';
import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

import '../models/cutomer_info.dart';
import '../models/service_item.dart';

class InvoicePdfService {
  /// Generates a 2-page PDF:
  ///  - Page 1: Invoice with header logo
  ///  - Page 2: Full-bleed A4 image
  ///
  static Future<void> generateAndOpenInvoicePdf({
    required String invoiceNumber,
    required DateTime invoiceDate,
    required CustomerInfo customer,
    required List<ServiceItem> services,
    required double subTotal,
    required double taxPercent,
    required String taxNo,
    required double taxAmount,
    required double total,
    required String remarks,
    required String nextServiceDate,
    required Uint8List? fullPageImageBytes,
    required Uint8List? logoBytes,
  }) async {
    final pdf = pw.Document();

    final dateStr = DateFormat('dd-MMM-yyyy').format(invoiceDate);

    // ---- PAGE 1: INVOICE ----
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16),
        build: (context) {
          return _invoiceBody(
            invoiceNumber: invoiceNumber,
            dateStr: dateStr,
            customer: customer,
            services: services,
            subTotal: subTotal,
            taxPercent: taxPercent,
            taxNo: taxNo,
            taxAmount: taxAmount,
            total: total,
            remarks: remarks,
            nextServiceDate: nextServiceDate,
            logoBytes: logoBytes,
          );
        },
      ),
    );

    // ---- PAGE 2: FULL A4 IMAGE ----
    if (fullPageImageBytes != null && fullPageImageBytes.isNotEmpty) {
      final bgImg = pw.MemoryImage(fullPageImageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: pw.EdgeInsets.all(16),
          build: (context) {
            return pw.Container(
              width: double.infinity,
              height: double.infinity,
              child: pw.Image(bgImg, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }

    // Save locally
    final dir = await getApplicationDocumentsDirectory();
    final filePath = "${dir.path}/invoice_$invoiceNumber.pdf";
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Open with default viewer
    await OpenFilex.open(filePath);
  }

  // PAGE 1 CONTENT
  static pw.Widget _invoiceBody({
    required String invoiceNumber,
    required String dateStr,
    required CustomerInfo customer,
    required List<ServiceItem> services,
    required double subTotal,
    required double taxPercent,
    required String taxNo,
    required double taxAmount,
    required double total,
    required String remarks,
    required String nextServiceDate,
    required Uint8List? logoBytes,
  }) {
    final borderColor = PdfColor.fromInt(0xFFBFC4CA); // light gray border
    final headerBg = PdfColor.fromInt(0xFFEFF2F5); // light gray row bg
    final tableTextStyle = pw.TextStyle(fontSize: 10);
    final boldTableTextStyle = pw.TextStyle(
      fontSize: 10,
      fontWeight: pw.FontWeight.bold,
    );

    pw.Widget cell(
      String text, {
      pw.TextStyle? style,
      pw.Alignment alignment = pw.Alignment.centerLeft,
      pw.EdgeInsets padding = const pw.EdgeInsets.all(4),
      PdfColor? bg,
      pw.BoxBorder? border,
    }) {
      return pw.Container(
        padding: padding,
        alignment: alignment,
        decoration: pw.BoxDecoration(color: bg, border: border),
        child: pw.Text(text, style: style ?? tableTextStyle),
      );
    }

    // ===== HEADER BLOCK (logo + company + invoice meta) =====
    final headerSection = pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // LEFT: Logo
              pw.Expanded(
                flex: 2,
                child: pw.Container(
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      right: pw.BorderSide(color: borderColor, width: 0.5),
                    ),
                  ),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      // Logo box
                      if (logoBytes != null && logoBytes.isNotEmpty)
                        pw.Container(
                          height: 60,
                          width: 250,
                          margin: const pw.EdgeInsets.symmetric(horizontal: 20),
                          child: pw.Image(
                            pw.MemoryImage(logoBytes),
                            fit: pw.BoxFit.fill,
                          ),
                        )
                      else
                        pw.Container(
                          height: 40,
                          width: 40,
                          margin: const pw.EdgeInsets.only(right: 8),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(
                              color: PdfColors.blue,
                              width: 0.5,
                            ),
                          ),
                          alignment: pw.Alignment.center,
                          child: pw.Text(
                            'LOGO',
                            style: pw.TextStyle(
                              fontSize: 8,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.blue,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // RIGHT: Invoice number + Date
              pw.Expanded(
                flex: 1,
                child: pw.Container(
                  child: pw.Table(
                    border: pw.TableBorder.all(color: borderColor, width: 0.5),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(1),
                      1: const pw.FlexColumnWidth(1),
                    },
                    children: [
                      pw.TableRow(
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.all(4),
                            alignment: pw.Alignment.centerLeft,
                            height: 38,
                            child: pw.Text("Invoice #", style: tableTextStyle),
                          ),
                          pw.Container(
                            padding: const pw.EdgeInsets.all(4),
                            height: 38,
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                              invoiceNumber,
                              style: tableTextStyle,
                            ),
                          ),
                        ],
                      ),
                      pw.TableRow(
                        children: [
                          pw.Container(
                            padding: const pw.EdgeInsets.all(4),
                            alignment: pw.Alignment.centerLeft,
                            height: 38,
                            child: pw.Text("Date", style: tableTextStyle),
                          ),
                          pw.Container(
                            height: 38,
                            padding: const pw.EdgeInsets.all(4),
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(dateStr, style: tableTextStyle),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Tagline strip
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(6),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: borderColor, width: 0.5),
                bottom: pw.BorderSide(color: borderColor, width: 0.5),
              ),
              color: headerBg,
            ),
            alignment: pw.Alignment.center,
            child: pw.Text(
              "BREATHE FRESH CLEAN AIR",
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ),

          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: borderColor, width: 0.5),
                bottom: pw.BorderSide(color: borderColor, width: 0.5),
              ),
              color: headerBg,
            ),
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(
              "Customer Details",
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),

          // CUSTOMER DETAILS TABLE
          pw.Table(
            border: pw.TableBorder.all(color: borderColor, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(12),
            },
            children: [
              pw.TableRow(
                children: [
                  cell('Name', style: boldTableTextStyle),
                  cell('${customer.firstName} ${customer.lastName}'),
                ],
              ),
              pw.TableRow(
                children: [
                  cell('Street', style: boldTableTextStyle),
                  cell(customer.street),
                ],
              ),
              pw.TableRow(
                children: [
                  cell('City', style: boldTableTextStyle),
                  cell(customer.city),
                ],
              ),
            ],
          ),
          pw.Table(
            border: pw.TableBorder.all(color: borderColor, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(6),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(4),
            },
            children: [
              pw.TableRow(
                children: [
                  cell('Province', style: boldTableTextStyle),
                  cell(customer.province),
                  cell('Postal Code', style: boldTableTextStyle),
                  cell(customer.postalCode),
                ],
              ),
              pw.TableRow(
                children: [
                  cell('Email', style: boldTableTextStyle),
                  cell(customer.email),
                  cell('Phone', style: boldTableTextStyle),
                  cell(customer.phone),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    // ===== SERVICES TABLE HEADER =====
    final servicesHeader = pw.Table(
      border: pw.TableBorder.all(color: borderColor, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: headerBg),
          children: [
            cell(
              "Service Description",
              style: boldTableTextStyle,
              alignment: pw.Alignment.center,
            ),
            cell(
              "Qty",
              style: boldTableTextStyle,
              alignment: pw.Alignment.center,
            ),
            cell(
              "Price",
              style: boldTableTextStyle,
              alignment: pw.Alignment.center,
            ),
          ],
        ),
      ],
    );

    // ===== SERVICES DYNAMIC ROWS =====
    final serviceRows = <pw.TableRow>[];
    for (final s in services) {
      serviceRows.add(
        pw.TableRow(
          children: [
            cell(s.name, alignment: pw.Alignment.centerLeft),
            cell(
              s.qty == 0 ? "-" : s.qty.toString(),
              alignment: pw.Alignment.center,
            ),
            cell(
              s.price == 0 ? "-" : '\$${s.price.toStringAsFixed(2)}',
              alignment: pw.Alignment.centerRight,
            ),
          ],
        ),
      );
    }

    final servicesTable = pw.Table(
      border: pw.TableBorder.all(color: borderColor, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
      },
      children: serviceRows,
    );

    // ===== SUMMARY BLOCK (subtotal/tax/total/remarks) =====
    final summaryTable = pw.Table(
      border: pw.TableBorder.all(color: borderColor, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          children: [
            cell(
              "Subtotal",
              style: boldTableTextStyle,
              alignment: pw.Alignment.center,
            ),
            cell(
              "\$${subTotal.toStringAsFixed(2)}",
              alignment: pw.Alignment.centerRight,
              style: tableTextStyle,
            ),
          ],
        ),
        pw.TableRow(
          children: [
            cell(
              "Tax ($taxNo) ${(taxPercent * 100).toStringAsFixed(2)}%",
              alignment: pw.Alignment.center,
              style: boldTableTextStyle,
            ),
            cell(
              "\$${taxAmount.toStringAsFixed(2)}",
              alignment: pw.Alignment.centerRight,
              style: tableTextStyle,
            ),
          ],
        ),
        pw.TableRow(
          children: [
            cell(
              "Total",
              style: boldTableTextStyle,
              alignment: pw.Alignment.center,
            ),
            cell(
              "\$${total.toStringAsFixed(2)}",
              alignment: pw.Alignment.centerRight,
              style: tableTextStyle,
            ),
          ],
        ),
        pw.TableRow(
          children: [
            cell(
              "Remarks",
              style: boldTableTextStyle,
              alignment: pw.Alignment.center,
            ),
            cell('', alignment: pw.Alignment.centerLeft, style: tableTextStyle),
          ],
        ),
      ],
    );

    // ===== CUSTOMER SATISFACTION / NEXT SERVICE / SIGNATURES =====
    final customerSatisfactionHeader = pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: borderColor, width: 0.5),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(4),
            decoration: pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: borderColor, width: 0.5),
                bottom: pw.BorderSide(color: borderColor, width: 0.5),
              ),
              color: headerBg,
            ),
            alignment: pw.Alignment.centerLeft,
            child: pw.Text(
              "Customer Satisfaction",
              style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    final customerSatisfaction = pw.Table(
      border: pw.TableBorder.all(color: borderColor, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          children: [
            cell(remarks, style: tableTextStyle),
            cell("Recommended Next service:", style: boldTableTextStyle),
            cell(
              nextServiceDate.isEmpty ? "-" : nextServiceDate,
              style: tableTextStyle,
              alignment: pw.Alignment.centerLeft,
            ),
          ],
        ),
      ],
    );
    final signature = pw.Table(
      border: pw.TableBorder.all(color: borderColor, width: 0.5),
      columnWidths: {
        0: const pw.FlexColumnWidth(1),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          children: [
            cell(
              'Customer Signature',
              alignment: pw.Alignment.centerLeft,
              style: tableTextStyle,
            ),
            cell('', style: tableTextStyle, alignment: pw.Alignment.centerLeft),
            cell(
              "Company Authorized Signature",
              style: tableTextStyle,
              alignment: pw.Alignment.centerLeft,
            ),
            cell(
              "Not required for electronic receipt",
              style: tableTextStyle,
              alignment: pw.Alignment.centerLeft,
            ),
          ],
        ),
      ],
    );

    // ===== FOOTER =====
    final footerRow = pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text("BlueGuard.ca", style: boldTableTextStyle),
          pw.Text(
            "Thank you for choosing Blueguard",
            style: boldTableTextStyle,
          ),
          pw.Text("Tel: 1-844-498-8364", style: boldTableTextStyle),
        ],
      ),
    );

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        headerSection,
        pw.SizedBox(height: 8),
        servicesHeader,
        servicesTable,
        summaryTable,
        pw.SizedBox(height: 8),
        customerSatisfactionHeader,
        customerSatisfaction,
        signature,
        footerRow,
      ],
    );
  }
}
