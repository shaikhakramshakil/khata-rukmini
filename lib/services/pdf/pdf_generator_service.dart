import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/database/database.dart';
import '../../repositories/models/statement_models.dart';
import '../../repositories/transaction_repository.dart';

class PdfGeneratorService {
  static const PdfColor inkColor = PdfColor.fromInt(0xFF171717);
  static const PdfColor muteColor = PdfColor.fromInt(0xFF666666);
  static const PdfColor faintColor = PdfColor.fromInt(0xFF999999);
  static const PdfColor hairlineColor = PdfColor.fromInt(0xFFE5E5E5);
  static const PdfColor tableHeaderBg = PdfColor.fromInt(0xFFF9F9F9);

  /// Helper to format currency in PDF (matching exact screenshot Rs 1,000)
  static String formatPdfCurrency(double amount) {
    // We want Rs 1,234 instead of Rs1234.00 for whole numbers if possible,
    // but AppFormatters.formatCurrency gives Rs1,234.00.
    // So let's use a simpler format here for PDF:
    final f = NumberFormat('#,##,##0.00', 'en_IN');
    return 'Rs ${f.format(amount)}';
  }

  static String formatPdfBalance(double balance) {
    if (balance > 0.0001) {
      return '${formatPdfCurrency(balance)} (Dr)';
    } else if (balance < -0.0001) {
      return '${formatPdfCurrency(balance.abs())} (Cr)';
    } else {
      return '${formatPdfCurrency(0)} (Nil)';
    }
  }

  /// Builds A4 Party Statement PDF
  static Future<Uint8List> generateStatementPdf({
    required ShopSetting shop,
    required PartyStatementData statement,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (context) {
          return pw.Column(
            children: [
              pw.Text(
                shop.shopName,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: inkColor,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Address: ${shop.address.isNotEmpty ? shop.address : '-'}, Ph. no.: ${shop.phone.isNotEmpty ? shop.phone : '-'}',
                style: const pw.TextStyle(fontSize: 10, color: inkColor),
              ),
              pw.SizedBox(height: 18),
              pw.Text(
                'Party Statement',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                  color: inkColor,
                ),
              ),
              pw.SizedBox(height: 24),
            ],
          );
        },
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          // Party Info
          pw.Row(
            children: [
              pw.Text(
                'Party name: ',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: inkColor,
                ),
              ),
              pw.Text(
                statement.partyName,
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: inkColor,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 2),
          pw.Text(
            'Contact no.: ${statement.phone ?? '-'}',
            style: const pw.TextStyle(fontSize: 10, color: inkColor),
          ),
          pw.SizedBox(height: 16),

          // Duration Info
          pw.Row(
            children: [
              pw.Text(
                'Duration: ',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: inkColor,
                ),
              ),
              pw.Text(
                'From ${DateFormat('dd/MM/yyyy').format(statement.fromDate)} to ${DateFormat('dd/MM/yyyy').format(statement.toDate)}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: inkColor,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),

          // Table
          pw.Table(
            border: pw.TableBorder(
              horizontalInside: const pw.BorderSide(
                color: hairlineColor,
                width: 1,
              ),
            ),
            columnWidths: const {
              0: pw.FlexColumnWidth(2.0), // Date
              1: pw.FlexColumnWidth(3.0), // Type
              2: pw.FlexColumnWidth(3.0), // Invoice No
              3: pw.FlexColumnWidth(2.0), // Debit
              4: pw.FlexColumnWidth(2.0), // Credit
              5: pw.FlexColumnWidth(2.5), // Balance
            },
            children: [
              // Header Row
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFE5E5E5),
                ),
                children: [
                  _tableHeaderCell('Date'),
                  _tableHeaderCell('Txn Type'),
                  _tableHeaderCell('Invoice/ Bill\nNo.'),
                  _tableHeaderCell('Debit', align: pw.TextAlign.right),
                  _tableHeaderCell('Credit', align: pw.TextAlign.right),
                  _tableHeaderCell(
                    'Running Balance',
                    align: pw.TextAlign.right,
                  ),
                ],
              ),

              // Beginning Balance Row
              pw.TableRow(
                children: [
                  _tableCell(
                    DateFormat('dd/MM/yyyy').format(statement.fromDate),
                  ),
                  _tableCell('Beginning Balance'),
                  _tableCell(''),
                  _tableCell(
                    statement.broughtForwardBalance > 0
                        ? formatPdfCurrency(statement.broughtForwardBalance)
                        : '',
                    align: pw.TextAlign.right,
                  ),
                  _tableCell(
                    statement.broughtForwardBalance < 0
                        ? formatPdfCurrency(
                            statement.broughtForwardBalance.abs(),
                          )
                        : '',
                    align: pw.TextAlign.right,
                  ),
                  _tableCell(
                    formatPdfBalance(statement.broughtForwardBalance),
                    align: pw.TextAlign.right,
                  ),
                ],
              ),

              // Data Rows
              ...statement.rows.map((row) {
                // Map system types to screenshot terminology
                String typeLabel = row.typeLabel;
                if (typeLabel == 'Payment In') typeLabel = 'Payment-in';
                if (typeLabel == 'Payment Out') typeLabel = 'Payment-out';

                String invoiceNo = row.referenceNo ?? '';
                if (typeLabel == 'Sale' &&
                    invoiceNo.isEmpty &&
                    row.description != null) {
                  invoiceNo = row.description!;
                }

                // If invoice contains a space, break it into two lines if it's long like "KS/2025/1001 1143"
                if (invoiceNo.contains(' ')) {
                  invoiceNo = invoiceNo.replaceFirst(' ', '\n');
                }

                return pw.TableRow(
                  children: [
                    _tableCell(DateFormat('dd/MM/yyyy').format(row.date)),
                    _tableCell(typeLabel),
                    _tableCell(invoiceNo, align: pw.TextAlign.center),
                    _tableCell(
                      row.debit > 0 ? formatPdfCurrency(row.debit) : '',
                      align: pw.TextAlign.right,
                    ),
                    _tableCell(
                      row.credit > 0 ? formatPdfCurrency(row.credit) : '',
                      align: pw.TextAlign.right,
                    ),
                    _tableCell(
                      formatPdfBalance(row.runningBalance),
                      align: pw.TextAlign.right,
                    ),
                  ],
                );
              }),

              // Footer Row (Total)
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFE5E5E5),
                ),
                children: [
                  _tableCell(''),
                  _tableCell(''),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 5,
                    ),
                    child: pw.Text(
                      'Total',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: inkColor,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 5,
                    ),
                    child: pw.Text(
                      formatPdfCurrency(statement.totalDebit),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: inkColor,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 5,
                    ),
                    child: pw.Text(
                      formatPdfCurrency(statement.totalCredit),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: inkColor,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 5,
                    ),
                    child: pw.Text(
                      formatPdfBalance(statement.closingBalance),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: inkColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
    return pdf.save();
  }

  /// Builds A4 / A5 Payment Receipt PDF
  static Future<Uint8List> generateReceiptPdf({
    required ShopSetting shop,
    required TransactionWithDetails details,
    required double previousBalance,
    required double newBalance,
  }) async {
    final type = details.transaction.type;
    final title = type == 'paymentReceived' 
        ? 'PAYMENT RECEIPT' 
        : (type == 'paymentMade' ? 'PAYMENT VOUCHER' : 'VOUCHER');
        
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPdfShopHeader(shop, title),
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: hairlineColor, width: 1),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Voucher No: ${details.transaction.transactionNo}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: inkColor,
                        ),
                      ),
                      pw.Text(
                        'Date: ${DateFormat('dd/MM/yyyy').format(details.transaction.date)}',
                        style: const pw.TextStyle(
                          fontSize: 11,
                          color: muteColor,
                        ),
                      ),
                    ],
                  ),
                  pw.Divider(color: hairlineColor, height: 20),
                  _buildPdfKeyValue(
                    'Received From / Party:',
                    details.party.name,
                  ),
                  if (details.party.phone != null)
                    _buildPdfKeyValue('Phone:', details.party.phone!),
                  _buildPdfKeyValue(
                    'Payment Mode:',
                    details.transaction.paymentMode ?? 'Cash',
                  ),
                  if (details.transaction.referenceNo != null)
                    _buildPdfKeyValue(
                      'Reference / UTR:',
                      details.transaction.referenceNo!,
                    ),
                  if (details.paymentDetail?.bankName != null)
                    _buildPdfKeyValue(
                      'Bank Name:',
                      details.paymentDetail!.bankName!,
                    ),
                  if (details.transaction.description != null)
                    _buildPdfKeyValue(
                      'Remarks:',
                      details.transaction.description!,
                    ),
                  pw.Divider(color: hairlineColor, height: 24),
                  _buildPdfKeyValue(
                    'Previous Balance:',
                    formatPdfBalance(previousBalance),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Payment Amount:',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: inkColor,
                        ),
                      ),
                      pw.Text(
                        formatPdfCurrency(details.transaction.amount),
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: inkColor,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  _buildPdfKeyValue(
                    'Remaining Balance:',
                    formatPdfBalance(newBalance),
                  ),
                ],
              ),
            ),
            pw.Spacer(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Thank you for your business!',
                  style: const pw.TextStyle(fontSize: 10, color: muteColor),
                ),
                pw.Column(
                  children: [
                    pw.Container(width: 120, height: 1, color: hairlineColor),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Authorized Signatory',
                      style: const pw.TextStyle(fontSize: 9, color: muteColor),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  /// Builds A4 Sale Invoice / Bill PDF
  static Future<Uint8List> generateInvoicePdf({
    required ShopSetting shop,
    required TransactionWithDetails details,
    required double currentPartyBalance,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _buildPdfShopHeader(shop, 'SALE INVOICE'),
            pw.SizedBox(height: 16),
            // Buyer & Invoice details
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: hairlineColor, width: 1),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Bill To:',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: muteColor,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        details.party.name,
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: inkColor,
                        ),
                      ),
                      if (details.party.phone != null)
                        pw.Text(
                          'Phone: ${details.party.phone}',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: muteColor,
                          ),
                        ),
                      if (details.party.address != null)
                        pw.Text(
                          'Address: ${details.party.address}',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: muteColor,
                          ),
                        ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Invoice No: ${details.transaction.transactionNo}',
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: inkColor,
                        ),
                      ),
                      pw.SizedBox(height: 2),
                      pw.Text(
                        'Date: ${DateFormat('dd/MM/yyyy').format(details.transaction.date)}',
                        style: const pw.TextStyle(
                          fontSize: 10,
                          color: muteColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),

            // Item table
            pw.Table(
              border: pw.TableBorder.all(color: hairlineColor, width: 0.5),
              columnWidths: const {
                0: pw.FlexColumnWidth(1),
                1: pw.FlexColumnWidth(5),
                2: pw.FlexColumnWidth(1.5),
                3: pw.FlexColumnWidth(2.5),
                4: pw.FlexColumnWidth(2.5),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: tableHeaderBg),
                  children: [
                    _tableHeaderCell('#'),
                    _tableHeaderCell('Item Description'),
                    _tableHeaderCell('Qty', align: pw.TextAlign.right),
                    _tableHeaderCell('Rate', align: pw.TextAlign.right),
                    _tableHeaderCell('Amount', align: pw.TextAlign.right),
                  ],
                ),
                if (details.lineItems.isNotEmpty)
                  ...details.lineItems.asMap().entries.map((entry) {
                    final idx = entry.key + 1;
                    final item = entry.value;
                    return pw.TableRow(
                      children: [
                        _tableCell('$idx'),
                        _tableCell(item.description),
                        _tableCell('${item.quantity.toInt()} ${item.unit ?? ''}'),
                        _tableCell(
                          formatPdfCurrency(item.rate),
                          align: pw.TextAlign.right,
                        ),
                        _tableCell(
                          formatPdfCurrency(item.amount),
                          align: pw.TextAlign.right,
                        ),
                      ],
                    );
                  })
                else
                  pw.TableRow(
                    children: [
                      _tableCell('1'),
                      _tableCell(
                        details.transaction.description ?? 'Jewelry Sale Entry',
                      ),
                      _tableCell('1'),
                      _tableCell(
                        formatPdfCurrency(details.transaction.amount),
                        align: pw.TextAlign.right,
                      ),
                      _tableCell(
                        formatPdfCurrency(details.transaction.amount),
                        align: pw.TextAlign.right,
                      ),
                    ],
                  ),
              ],
            ),
            pw.SizedBox(height: 12),

            // Invoice Totals
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 250,
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: hairlineColor, width: 1),
                    borderRadius: const pw.BorderRadius.all(
                      pw.Radius.circular(6),
                    ),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _buildPdfKeyValue(
                        'Total Amount:',
                        formatPdfCurrency(details.transaction.amount),
                      ),
                      pw.SizedBox(height: 3),
                      _buildPdfKeyValue(
                        'Account Balance:',
                        formatPdfBalance(currentPartyBalance),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (shop.terms.isNotEmpty) ...[
              pw.SizedBox(height: 14),
              pw.Text(
                'Terms & Conditions:',
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: inkColor,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                shop.terms,
                style: const pw.TextStyle(fontSize: 8, color: muteColor),
              ),
            ],

            pw.Spacer(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Subject to local jurisdiction',
                  style: const pw.TextStyle(fontSize: 8, color: muteColor),
                ),
                pw.Column(
                  children: [
                    pw.Container(width: 120, height: 1, color: hairlineColor),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'For ${shop.shopName}',
                      style: const pw.TextStyle(fontSize: 9, color: muteColor),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  // --- PDF Component Helpers ---

  static pw.Widget _buildPdfShopHeader(ShopSetting shop, String docTitle) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    shop.shopName.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: inkColor,
                    ),
                  ),
                  if (shop.address.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      shop.address,
                      style: const pw.TextStyle(fontSize: 9, color: muteColor),
                    ),
                  ],
                  if (shop.phone.isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Phone: ${shop.phone}',
                      style: const pw.TextStyle(fontSize: 9, color: muteColor),
                    ),
                  ],
                ],
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: inkColor, width: 1),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Text(
                docTitle,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: inkColor,
                ),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(color: hairlineColor, thickness: 1),
      ],
    );
  }

  static pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'Printed on ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
          style: const pw.TextStyle(fontSize: 8, color: faintColor),
        ),
        pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 8, color: faintColor),
        ),
      ],
    );
  }

  static pw.Widget _tableHeaderCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
          color: inkColor,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        textAlign: align,
        style: const pw.TextStyle(fontSize: 8.5, color: inkColor),
      ),
    );
  }

  static pw.Widget _buildPdfKeyValue(String key, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            key,
            style: const pw.TextStyle(fontSize: 10, color: muteColor),
          ),
          pw.SizedBox(width: 12),
          pw.Expanded(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: inkColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<Uint8List> generateGeneralLedgerPdf({
    required ShopSetting shop,
    required GeneralLedgerData ledger,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        header: (context) {
          return pw.Column(
            children: [
              pw.Text(
                shop.shopName,
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  color: inkColor,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Address: ${shop.address.isNotEmpty ? shop.address : '-'}, Ph. no.: ${shop.phone.isNotEmpty ? shop.phone : '-'}',
                style: const pw.TextStyle(fontSize: 10, color: inkColor),
              ),
              pw.SizedBox(height: 18),
              pw.Text(
                'General Ledger',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  decoration: pw.TextDecoration.underline,
                  color: inkColor,
                ),
              ),
              pw.SizedBox(height: 24),
            ],
          );
        },
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          pw.Row(
            children: [
              pw.Text(
                'Duration: ',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: inkColor,
                ),
              ),
              pw.Text(
                'From ${DateFormat('dd/MM/yyyy').format(ledger.fromDate)} to ${DateFormat('dd/MM/yyyy').format(ledger.toDate)}',
                style: pw.TextStyle(
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                  color: inkColor,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 16),
          pw.Table(
            border: pw.TableBorder(
              horizontalInside: const pw.BorderSide(
                color: hairlineColor,
                width: 1,
              ),
            ),
            columnWidths: const {
              0: pw.FlexColumnWidth(2.0),
              1: pw.FlexColumnWidth(3.0),
              2: pw.FlexColumnWidth(2.5),
              3: pw.FlexColumnWidth(2.0),
              4: pw.FlexColumnWidth(2.0),
              5: pw.FlexColumnWidth(2.0),
              6: pw.FlexColumnWidth(2.5),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFE5E5E5),
                ),
                children: [
                  _tableHeaderCell('Date'),
                  _tableHeaderCell('Party Name'),
                  _tableHeaderCell('Txn Type'),
                  _tableHeaderCell('Ref No.'),
                  _tableHeaderCell('Debit', align: pw.TextAlign.right),
                  _tableHeaderCell('Credit', align: pw.TextAlign.right),
                  _tableHeaderCell('Balance', align: pw.TextAlign.right),
                ],
              ),
              ...ledger.rows.map((row) {
                return pw.TableRow(
                  children: [
                    _tableCell(DateFormat('dd/MM/yyyy').format(row.date)),
                    _tableCell(row.partyName),
                    _tableCell(row.typeLabel),
                    _tableCell(row.referenceNo ?? '-'),
                    _tableCell(
                      row.debit > 0 ? formatPdfCurrency(row.debit) : '',
                      align: pw.TextAlign.right,
                    ),
                    _tableCell(
                      row.credit > 0 ? formatPdfCurrency(row.credit) : '',
                      align: pw.TextAlign.right,
                    ),
                    _tableCell(
                      formatPdfBalance(row.runningBalance),
                      align: pw.TextAlign.right,
                    ),
                  ],
                );
              }),
              pw.TableRow(
                decoration: const pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFFE5E5E5),
                ),
                children: [
                  _tableCell(''),
                  _tableCell(''),
                  _tableCell(''),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 5,
                    ),
                    child: pw.Text(
                      'Total',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: inkColor,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 5,
                    ),
                    child: pw.Text(
                      formatPdfCurrency(ledger.totalDebit),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: inkColor,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 5,
                    ),
                    child: pw.Text(
                      formatPdfCurrency(ledger.totalCredit),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: inkColor,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 5,
                    ),
                    child: pw.Text(
                      formatPdfBalance(ledger.closingBalance),
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: inkColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
    return pdf.save();
  }
}
