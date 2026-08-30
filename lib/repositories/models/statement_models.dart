class StatementRow {
  final DateTime date;
  final String typeLabel;
  final String? referenceNo;
  final String? description;
  final double debit;
  final double credit;
  final double runningBalance;
  final bool isBroughtForward;
  final String? transactionId;

  StatementRow({
    required this.date,
    required this.typeLabel,
    this.referenceNo,
    this.description,
    required this.debit,
    required this.credit,
    required this.runningBalance,
    this.isBroughtForward = false,
    this.transactionId,
  });
}

class PartyStatementData {
  final String partyId;
  final String partyName;
  final String partyType;
  final String? phone;
  final String? address;
  final DateTime fromDate;
  final DateTime toDate;
  final double broughtForwardBalance;
  final List<StatementRow> rows;
  final double totalDebit;
  final double totalCredit;
  final double closingBalance;

  PartyStatementData({
    required this.partyId,
    required this.partyName,
    required this.partyType,
    this.phone,
    this.address,
    required this.fromDate,
    required this.toDate,
    required this.broughtForwardBalance,
    required this.rows,
    required this.totalDebit,
    required this.totalCredit,
    required this.closingBalance,
  });
}

class GeneralLedgerRow {
  final DateTime date;
  final String partyName;
  final String typeLabel;
  final String? referenceNo;
  final String? description;
  final double debit;
  final double credit;
  final double runningBalance;

  GeneralLedgerRow({
    required this.date,
    required this.partyName,
    required this.typeLabel,
    this.referenceNo,
    this.description,
    required this.debit,
    required this.credit,
    required this.runningBalance,
  });
}

class GeneralLedgerData {
  final DateTime fromDate;
  final DateTime toDate;
  final double broughtForwardBalance;
  final List<GeneralLedgerRow> rows;
  final double totalDebit;
  final double totalCredit;
  final double closingBalance;

  GeneralLedgerData({
    required this.fromDate,
    required this.toDate,
    required this.broughtForwardBalance,
    required this.rows,
    required this.totalDebit,
    required this.totalCredit,
    required this.closingBalance,
  });
}
