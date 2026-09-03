import 'package:drift/drift.dart';

enum PartyType { customer, supplier, both }

enum TransactionType {
  openingBalance,
  sale,
  purchase,
  paymentReceived,
  paymentMade,
  debitAdjustment,
  creditAdjustment,
  loanGiven,
  interestCharged,
  interestReceived,
  loanRepayment,
}

enum PaymentMode { cash, upi, bankTransfer, cheque, card, other }

@DataClassName('Party')
class Parties extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get type => text()(); // 'customer', 'supplier', 'both'
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get notes => text().nullable()();
  RealColumn get interestRate =>
      real().nullable()(); // default monthly interest rate %
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@TableIndex(name: 'idx_tx_party', columns: {#partyId})
@TableIndex(name: 'idx_tx_date', columns: {#date})
@TableIndex(name: 'idx_tx_deleted', columns: {#deletedAt})
@DataClassName('TransactionEntry')
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get transactionNo => text()();
  TextColumn get partyId => text().references(Parties, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get type => text()(); // enum string
  RealColumn get amount => real()();
  RealColumn get debit => real().withDefault(const Constant(0.0))();
  RealColumn get credit => real().withDefault(const Constant(0.0))();
  RealColumn get interestRate => real().nullable()(); // interest rate % applied
  TextColumn get paymentMode => text().nullable()();
  TextColumn get referenceNo => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get linkedTransactionId =>
      text().nullable().references(Transactions, #id)();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
    'FOREIGN KEY (party_id) REFERENCES parties(id) ON DELETE RESTRICT',
  ];
}

@DataClassName('TransactionLineItem')
class TransactionLineItems extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId => text().references(Transactions, #id)();
  TextColumn get description => text()();
  RealColumn get quantity => real().withDefault(const Constant(1.0))();
  TextColumn get unit => text().nullable()(); // e.g., NOS, PCS, KG
  RealColumn get rate => real().withDefault(const Constant(0.0))();
  RealColumn get amount => real()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PaymentDetail')
class PaymentDetails extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId => text().references(Transactions, #id)();
  TextColumn get paymentMode => text().nullable()();
  TextColumn get referenceNo => text().nullable()();
  TextColumn get utrNo => text().nullable()();
  TextColumn get bankName => text().nullable()();
  TextColumn get chequeNo => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ShopSetting')
class ShopSettings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get shopName =>
      text().withDefault(const Constant('Rukmini Jewellers'))();
  TextColumn get address =>
      text().withDefault(const Constant('Main Market, Jewelry Bazaar'))();
  TextColumn get phone =>
      text().withDefault(const Constant('+91 98765 43210'))();
  TextColumn get email => text().nullable()();
  TextColumn get invoicePrefix => text().withDefault(const Constant('INV-'))();
  TextColumn get receiptPrefix => text().withDefault(const Constant('REC-'))();
  TextColumn get txnPrefix => text().withDefault(const Constant('TXN-'))();
  IntColumn get nextSeq => integer().withDefault(const Constant(1001))();
  TextColumn get terms => text().withDefault(
    const Constant(
      '1. Goods once sold will not be taken back.\n2. Subject to local jurisdiction.',
    ),
  )();
  TextColumn get currencySymbol => text().withDefault(const Constant('Rs'))();
  TextColumn get backupDirectory => text().nullable()();
  TextColumn get invoicesDirectory => text().nullable()();
  TextColumn get lastAutoBackupDate => text().nullable()();
  BoolColumn get isFirstRunCompleted =>
      boolean().withDefault(const Constant(false))();
  TextColumn get appPin => text().nullable()();
}
