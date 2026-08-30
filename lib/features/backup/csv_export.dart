import 'dart:convert';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../core/database/database.dart';
import 'package:path/path.dart' as p;

class CsvExportService {
  final AppDatabase _db;

  CsvExportService(this._db);

  String _escapeCsv(String? input) {
    if (input == null) return '';
    if (input.contains(',') || input.contains('"') || input.contains('\n')) {
      final escaped = input.replaceAll('"', '""');
      return '"$escaped"';
    }
    return input;
  }

  Future<File> exportTransactionsToCsv(
    String directoryPath, {
    bool includeDeleted = false,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final allTxns = await _db.getAllTransactionsWithParty(
      includeDeleted: includeDeleted,
      startDate: startDate,
      endDate: endDate,
    );

    final buffer = StringBuffer();
    // Headers
    buffer.writeln(
      'Date,Transaction No,Party Name,Party Type,Txn Type,Debit,Credit,Interest Rate (%),Payment Mode,Reference No,Description,Is Deleted',
    );

    for (final txnWP in allTxns) {
      final txn = txnWP.transaction;
      final partyName = txnWP.party.name;
      final partyType = txnWP.party.type;

      final dateStr = DateFormat('yyyy-MM-dd').format(txn.date);

      buffer.writeln(
        '${_escapeCsv(dateStr)},'
        '${_escapeCsv(txn.transactionNo)},'
        '${_escapeCsv(partyName)},'
        '${_escapeCsv(partyType)},'
        '${_escapeCsv(txn.type)},'
        '${txn.debit.toStringAsFixed(2)},'
        '${txn.credit.toStringAsFixed(2)},'
        '${txn.interestRate != null ? txn.interestRate!.toStringAsFixed(2) : ""},'
        '${_escapeCsv(txn.paymentMode)},'
        '${_escapeCsv(txn.referenceNo)},'
        '${_escapeCsv(txn.description)},'
        '${txn.deletedAt != null ? "Yes" : "No"}',
      );
    }

    final dateStr = DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now());
    final csvFile = File(
      p.join(directoryPath, 'khata_transactions_$dateStr.csv'),
    );
    await csvFile.writeAsString(buffer.toString(), encoding: utf8);
    return csvFile;
  }
}
