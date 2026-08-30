# Jewelry Shop Khata Book

## Product Requirements Document (PRD)

**Version:** 1.0\
**Platform:** Windows Desktop\
**Development/Test Environment:** Fedora Linux\
**Frontend:** Flutter Desktop\
**Recommended Data Layer:** SQLite + Drift\
**Application Model:** Local-first, single bundled desktop application\
**Primary Users:** Local jewelry shop owner / shop staff

------------------------------------------------------------------------

# 1. Product Summary

Jewelry Shop Khata Book is a simple desktop application for a local
jewelry shop to replace a physical khata book with a fast, reliable
digital ledger.

The application should focus on only the things the shop actually needs:

-   Customers
-   Suppliers
-   Debit and credit transactions
-   Payments
-   Purchases and sales entries
-   Opening balances
-   Running balances
-   Customer and supplier statements
-   Search
-   Printable PDFs
-   Basic invoices/receipts where required
-   Local backup and restore

This is **not a full accounting, ERP, inventory, GST, or banking
application**.

The product should feel like a modern digital khata book rather than an
enterprise accounting system.

The central workflow is:

> **Search party → Open account → Check balance → Add transaction →
> Print/share statement**

------------------------------------------------------------------------

# 2. Product Goals

## 2.1 Primary Goals

1.  Make customer and supplier records easy to maintain.
2.  Make debit/credit entries quick.
3.  Always calculate the correct running balance.
4.  Make any customer's or supplier's complete history searchable.
5.  Provide a global search that can find people, transactions,
    invoices, payments, and references.
6.  Generate clean printable statements.
7.  Work completely offline.
8.  Install as a normal Windows desktop application with everything
    required bundled with the application.
9.  Keep the interface simple enough for a local shop owner to use
    without accounting knowledge.
10. Avoid unnecessary accounting features that increase complexity.

## 2.2 Non-Goals

The first version will **not** include:

-   GST management
-   Tax filing
-   Credit limits
-   Inventory management
-   Gold-rate management
-   Manufacturing
-   Payroll
-   Complex accounting
-   Direct bank account integration
-   Online banking
-   Multi-branch management
-   Cloud synchronization
-   Customer-facing mobile application
-   Complicated user permissions
-   AI features

These may be considered later only if the business actually needs them.

------------------------------------------------------------------------

# 3. Design Philosophy

The application should use the supplied Geist/Vercel-inspired design
system.

The design should be restrained, clean, desktop-oriented, and
functional.

The visual hierarchy should come primarily from:

-   Typography
-   Spacing
-   1px borders
-   Near-white surfaces
-   Near-black text
-   Simple layouts

Color should be used sparingly.

The application should not look like a colorful accounting dashboard.

------------------------------------------------------------------------

# 4. Design System

## 4.1 Colors

### Primary

  Token           Value       Usage
  --------------- ----------- -----------------------------------------
  Ink             `#171717`   Primary text, headings, primary buttons
  Body            `#4d4d4d`   Normal text
  Mute            `#8f8f8f`   Secondary information
  Faint           `#a1a1a1`   Placeholder/disabled text
  Canvas          `#fafafa`   Application background
  Elevated        `#ffffff`   Cards, inputs, dialogs
  Hairline        `#ebebeb`   Borders/dividers
  Hairline Soft   `#f2f2f2`   Subtle inset surfaces
  Link            `#0070f3`   Links, active/focus state
  Error           `#ee0000`   Errors and destructive states
  Warning         `#f5a623`   Warnings

The brand gradient should **not** be used as general application chrome.
For this local desktop application, it should be omitted from ordinary
screens unless a small branded welcome/start screen is later desired.

## 4.2 Typography

Use:

-   Geist Sans
-   Geist Mono

Fallback:

-   Inter / Arial for Sans
-   JetBrains Mono / IBM Plex Mono for Mono

### Typography Tokens

  --------------------------------------------------------------------------
  Token                  Size          Weight     Line Height Usage
  ----------- --------------- --------------- --------------- --------------
  Display                48px             600            48px Rare major
                                                              headings

  Heading                32px             600            40px Page headings
  Large                                                       

  Heading                20px             600            28px Card/section
  Medium                                                      headings

  Label                  14px             500            20px Labels

  Mono                   12px             500            16px Small
  Eyebrow                                                     uppercase
                                                              technical
                                                              labels

  Body Large             16px             400            24px Important
                                                              explanatory
                                                              text

  Body Medium            14px             400            20px Main
                                                              application
                                                              text

  Body Small             12px             400            16px Metadata

  Button                 14px             500            20px Application
                                                              buttons

  Code/Mono              14px             400            20px Reference
                                                              numbers and
                                                              technical
                                                              values
  --------------------------------------------------------------------------

Large headings use tight negative letter spacing according to the
supplied design system.

------------------------------------------------------------------------

# 5. Application Layout

The desktop application should use a simple fixed sidebar and content
area.

``` text
┌───────────────────────────────────────────────────────────────┐
│  Jewelry Shop Khata                              Search  Ctrl+K│
├──────────────┬────────────────────────────────────────────────┤
│              │                                                │
│ Dashboard    │                                                │
│ Customers    │                 Main Content                   │
│ Suppliers    │                                                │
│ Transactions │                                                │
│ Statements   │                                                │
│              │                                                │
│              │                                                │
│ Settings     │                                                │
│ Backup       │                                                │
│              │                                                │
└──────────────┴────────────────────────────────────────────────┘
```

## 5.1 Sidebar

Navigation:

1.  Dashboard
2.  Customers
3.  Suppliers
4.  Transactions
5.  Statements
6.  Settings
7.  Backup & Restore

Global search should always be accessible from the top bar.

## 5.2 Desktop Behavior

The application is primarily designed for:

-   Windows desktop
-   Keyboard and mouse
-   1024px+ window width
-   1200px+ preferred working width

The window should be resizable.

Important tables should use horizontal scrolling instead of breaking
their layout.

------------------------------------------------------------------------

# 6. Core Data Model

The application should have one central concept:

## Party

A party can be:

-   Customer
-   Supplier
-   Both

This prevents duplicate records when the same person/business buys from
and sells to the shop.

``` text
Party
 ├── Customer
 ├── Supplier
 └── Both
```

Every party can have transactions.

``` text
Party
  │
  ├── Opening Balance
  ├── Sale
  ├── Purchase
  ├── Payment Received
  ├── Payment Made
  ├── Debit
  ├── Credit
  └── Adjustment
```

The account balance is calculated from these entries.

------------------------------------------------------------------------

# 7. Customer Management

## 7.1 Customer List

The customer screen should display:

  Field              Description
  ------------------ ------------------------
  Name               Customer name
  Phone              Primary contact number
  Address            Basic address
  Balance            Current balance
  Last Transaction   Most recent activity

No unnecessary customer fields should be required.

## 7.2 Add Customer

Required:

-   Name
-   Phone

Optional:

-   Address
-   Notes

The user should be able to save a customer with only a name if the shop
does not have a phone number.

## 7.3 Customer Profile

``` text
Customer Name
Phone
Address

Current Balance

[Add Transaction] [Print Statement]

Transactions
Invoices/Records
Notes
```

The most important information should be visible immediately:

> **Current Balance**

------------------------------------------------------------------------

# 8. Supplier Management

Suppliers should use the same simple structure as customers.

## 8.1 Supplier List

  Supplier       Phone        Balance Last Transaction
  -------------- ---------- --------- ------------------
  ABC Supplier   98xxxxxx     ₹25,000 29 Aug
  XYZ Supplier   97xxxxxx     ₹10,000 28 Aug

## 8.2 Supplier Profile

``` text
Supplier Name
Phone
Address

Current Balance

[Add Transaction] [Print Statement]

Transactions
Notes
```

The same underlying party/transaction system should be used for
customers and suppliers.

------------------------------------------------------------------------

# 9. Transaction System

Transactions are the core of the application.

The application must not allow ambiguous transaction behavior.

Every transaction must have:

-   Party
-   Date
-   Transaction type
-   Amount
-   Debit/Credit direction
-   Optional reference number
-   Optional description
-   Optional payment details

------------------------------------------------------------------------

# 10. Supported Transaction Types

Keep the first version intentionally small.

## Customer-side transactions

### Sale / Debit

The customer owes the shop money.

Example:

``` text
Sale: ₹20,000
```

Balance increases by ₹20,000.

### Payment Received / Credit

The customer pays the shop.

Example:

``` text
Payment: ₹5,000
```

Balance decreases by ₹5,000.

### Credit Adjustment

Used when the amount owed by the customer needs to be reduced without
recording a normal payment.

### Debit Adjustment

Used when the amount owed by the customer needs to be increased without
recording a normal sale.

------------------------------------------------------------------------

## Supplier-side transactions

### Purchase / Credit

The shop receives goods/value from the supplier and owes the supplier
money.

### Payment Made / Debit

The shop pays the supplier.

### Credit Adjustment

Reduces the shop's payable amount.

### Debit Adjustment

Increases the shop's payable amount.

------------------------------------------------------------------------

# 11. Opening Balance

Opening balance is required when migrating an existing physical khata
into the application.

Example:

``` text
Customer: Ahmed
Opening Balance: ₹25,000 Due
```

The opening balance becomes the first ledger entry.

It should appear in the statement as:

``` text
01/04/2026   Opening Balance   ₹25,000   -
```

The opening balance should not be directly editable from the balance
display.

If the balance needs correction later, the user should create an
adjustment transaction.

------------------------------------------------------------------------

# 12. Debit/Credit Rules

The application must have a single consistent balance engine.

## Customer

``` text
Debit  = Customer owes more
Credit = Customer owes less
```

Example:

``` text
Opening Balance       ₹10,000 Dr

Sale                  +₹20,000
Balance               ₹30,000 Dr

Payment Received      -₹5,000
Balance               ₹25,000 Dr
```

## Supplier

The UI should still show the supplier's account clearly, while the
internal ledger maintains the appropriate debit/credit direction.

The user should not have to manually calculate accounting signs.

------------------------------------------------------------------------

# 13. Balance Engine

Balance must be derived from the ledger.

Conceptually:

``` text
Opening Balance
      +
All applicable debit amounts
      -
All applicable credit amounts
      =
Current Balance
```

Every transaction changes the running balance.

The application must never have two competing sources of truth for
balance.

Do not allow:

``` text
Party.balance = manually edited value
```

while transactions contain another value.

The ledger is the source of truth.

------------------------------------------------------------------------

# 14. Add Transaction Screen

This screen should be extremely fast.

``` text
Add Transaction

Party
[ Search party... ]

Transaction Type
[ Sale ▼ ]

Date
[ 29/08/2026 ]

Amount
[ ₹ __________ ]

Payment Mode
[ Cash ▼ ]

Reference Number
[ __________ ]

Description
[ ______________________________ ]

                 [ Cancel ] [ Save ]
```

## Required fields

-   Party
-   Transaction type
-   Date
-   Amount

## Optional fields

-   Payment mode
-   Reference number
-   Description

------------------------------------------------------------------------

# 15. Payment Modes

Keep only commonly useful modes:

-   Cash
-   UPI
-   Bank Transfer
-   Cheque
-   Card
-   Other

No banking integration is required.

If the payment is made through UPI or bank transfer, the user can store
its reference/UTR manually.

------------------------------------------------------------------------

# 16. Payment Details

For a payment transaction, optionally store:

``` text
Payment Mode
Reference Number
UTR Number
Bank Name
Cheque Number
```

These are transaction details, not a live connection to a bank account.

This allows the user to search for a payment later.

------------------------------------------------------------------------

# 17. Global Search

Global search is a core feature, not a separate advanced feature.

Keyboard shortcut:

> **Ctrl + K**

The search box should be accessible from every screen.

## Search Across

### Parties

-   Customer name
-   Supplier name
-   Phone number
-   Address

### Transactions

-   Transaction number
-   Description
-   Reference number
-   Amount

### Payments

-   UPI reference
-   UTR
-   Cheque number
-   Bank reference

### Records

-   Invoice number
-   Receipt number
-   Statement-related records

------------------------------------------------------------------------

# 18. Global Search Results

Example:

``` text
Search: 9834

CUSTOMERS
────────────────────────────
Ahmed Khan
9834472260
Balance: ₹25,000 Dr

TRANSACTIONS
────────────────────────────
29/08/2026
Payment Received
₹10,000
Reference: UPI12345

PAYMENTS
────────────────────────────
UPI12345
₹10,000
Ahmed Khan
```

Pressing Enter opens the selected record.

Search should support partial matches.

------------------------------------------------------------------------

# 19. Customer 360° View

Keep this simple.

When a customer is opened, show:

``` text
Ahmed Khan
98XXXXXXXX

Balance
₹25,000 Dr

Recent Transactions
────────────────────────────
29 Aug   Sale       ₹15,000
27 Aug   Payment     ₹5,000
25 Aug   Sale       ₹15,000

[View Full Statement]
[Add Transaction]
[Print Statement]
```

The user should be able to reach the complete history from this screen.

------------------------------------------------------------------------

# 20. Statement Screen

The statement is one of the most important features.

It should support:

-   Customer statement
-   Supplier statement
-   Date range
-   All transactions
-   Running balance
-   Total debit
-   Total credit
-   Closing balance
-   Print
-   PDF

The supplied party statement reference uses a party name/contact area
followed by a transaction table containing date, transaction type,
invoice/bill reference, debit, credit, and running balance, followed by
totals and closing balance. The application statement should preserve
that basic structure. fileciteturn0file0L3-L12

------------------------------------------------------------------------

# 21. Statement UI

``` text
PARTY STATEMENT

Ahmed Khan
98XXXXXXXX

From [01/08/2026]   To [31/08/2026]

[Print] [Save PDF]

Date       Type          Reference       Debit     Credit    Balance
---------------------------------------------------------------------
01 Aug     Opening       -               ₹10,000   -         ₹10,000 Dr
05 Aug     Sale          TXN-001         ₹15,000   -         ₹25,000 Dr
10 Aug     Payment       PAY-001         -         ₹5,000    ₹20,000 Dr
20 Aug     Sale          TXN-002         ₹10,000   -         ₹30,000 Dr
25 Aug     Payment       PAY-002         -         ₹5,000    ₹25,000 Dr
---------------------------------------------------------------------
Total                                      ₹35,000   ₹10,000

Closing Balance                                      ₹25,000 Dr
```

------------------------------------------------------------------------

# 22. Statement Filters

Only useful filters should be provided.

-   From date
-   To date
-   Party
-   Transaction type

Optional quick filters:

-   This month
-   Last month
-   This year
-   Custom

Do not create a large report-filtering interface.

------------------------------------------------------------------------

# 23. Supplier Statement

Supplier statements should use the same visual format.

``` text
SUPPLIER STATEMENT

ABC Supplier
98XXXXXXXX

Date       Type          Reference       Debit     Credit    Balance
---------------------------------------------------------------------
01 Aug     Opening       -               ...       ...       ...
03 Aug     Purchase      PUR-001         ...       ...       ...
08 Aug     Payment       PAY-003         ...       ...       ...
```

The user should not need to learn a different workflow for suppliers.

------------------------------------------------------------------------

# 24. General Ledger

A basic general ledger report should also be available.

The supplied general ledger reference uses:

-   Date
-   Description
-   Debit
-   Credit
-   Balance
-   Opening balance
-   Total debit
-   Total credit
-   Closing balance

The application should preserve that simple structure.
fileciteturn0file2L2-L8

Example:

``` text
GENERAL LEDGER

Date       Description          Debit      Credit      Balance
----------------------------------------------------------------
01 Aug     Opening Balance      ₹10,000                ₹10,000
05 Aug     Sale                 ₹15,000                ₹25,000
10 Aug     Payment                         ₹5,000      ₹20,000

Opening Balance: ₹10,000
Total Debit:     ₹25,000
Total Credit:     ₹5,000
Closing Balance: ₹20,000
```

------------------------------------------------------------------------

# 25. Printing and PDF

Every important record should be printable.

## Must support

-   Customer statement
-   Supplier statement
-   General ledger
-   Transaction receipt
-   Basic invoice/transaction document

The PDF output should be designed specifically for A4 printing.

------------------------------------------------------------------------

# 26. PDF Design

The PDF style should be based on the supplied reference documents.

The supplied invoice reference uses a compact business document layout
with:

-   Business heading
-   Invoice number
-   Date
-   Bill-to information
-   Item/description table
-   Quantity
-   Unit price
-   Amount
-   Total
-   Terms and conditions

The app should follow the same general visual language without adding
fields that the local shop does not use. fileciteturn0file3L3-L12

## PDF Style

-   A4
-   White background
-   Black/dark text
-   Thin borders
-   Compact tables
-   Clear headings
-   No unnecessary graphics
-   No colorful backgrounds
-   Proper ₹ currency formatting
-   Shop name at top
-   Generated date/time where useful

------------------------------------------------------------------------

# 27. Customer Statement PDF

Recommended structure:

``` text
SHOP NAME
Address
Phone

              CUSTOMER STATEMENT

Customer: Ahmed Khan
Phone: 98XXXXXXXX

Period: 01/08/2026 - 31/08/2026

---------------------------------------------------------------
Date | Type | Reference | Debit | Credit | Running Balance
---------------------------------------------------------------
...

---------------------------------------------------------------

Total Debit:   ₹35,000
Total Credit:  ₹10,000

Closing Balance: ₹25,000 Dr
```

The PDF should remain readable even when the customer has many
transactions.

For long statements, automatically continue onto additional pages.

Repeat the table header on every page.

------------------------------------------------------------------------

# 28. Supplier Statement PDF

Same structure:

``` text
SHOP NAME

              SUPPLIER STATEMENT

Supplier: ABC Supplier
Phone: 98XXXXXXXX

Period: 01/08/2026 - 31/08/2026

---------------------------------------------------------------
Date | Type | Reference | Debit | Credit | Running Balance
---------------------------------------------------------------
...

Total Debit:
Total Credit:

Closing Balance:
```

------------------------------------------------------------------------

# 29. Transaction Receipt

When a payment is recorded, the application should be able to print a
simple receipt.

``` text
SHOP NAME

PAYMENT RECEIPT

Receipt No: PAY-0001
Date: 29/08/2026

Received From:
Ahmed Khan

Amount:
₹10,000

Payment Mode:
UPI

Reference:
UPI12345

Previous Balance:
₹35,000 Dr

Payment:
₹10,000

Balance:
₹25,000 Dr
```

Keep this document simple.

------------------------------------------------------------------------

# 30. Basic Invoice / Sale Document

A basic sale document may be generated when required.

The first version should not become a full tax-invoice system.

Fields:

-   Shop name
-   Shop address
-   Customer name
-   Customer phone
-   Invoice/record number
-   Date
-   Description
-   Quantity
-   Rate
-   Amount
-   Total
-   Payment received
-   Balance
-   Terms/notes

The supplied invoice reference demonstrates a compact invoice structure
with seller/buyer information, an item table, total and payment
information. fileciteturn0file3L3-L12

------------------------------------------------------------------------

# 31. Transactions List

The Transactions page should provide a complete chronological list.

``` text
Transactions

[Search transactions...]

Date       Party           Type              Amount
------------------------------------------------------
29 Aug     Ahmed Khan      Sale              ₹15,000
29 Aug     Ahmed Khan      Payment           ₹5,000
28 Aug     ABC Supplier    Purchase          ₹20,000
27 Aug     ABC Supplier    Payment           ₹10,000
```

Filters:

-   Date
-   Party
-   Transaction type

Clicking a transaction opens its details.

------------------------------------------------------------------------

# 32. Transaction Details

``` text
Transaction

Transaction No: TXN-0001
Date: 29/08/2026

Party:
Ahmed Khan

Type:
Payment Received

Amount:
₹5,000

Payment Mode:
UPI

Reference:
UPI12345

Description:
Payment against previous balance

[Edit]
[Print]
```

Delete should require confirmation.

------------------------------------------------------------------------

# 33. Dashboard

The dashboard should be simple.

## Summary

``` text
Customers              245
Suppliers               32

Customer Outstanding   ₹4,25,000
Supplier Outstanding   ₹2,80,000
```

## Today's Activity

``` text
Today's Transactions    18
Payments Received       ₹45,000
Payments Made           ₹20,000
```

## Recent Transactions

Show the latest 5-10 records.

No complex charts are necessary for V1.

------------------------------------------------------------------------

# 34. Outstanding Summary

A simple outstanding screen is useful because it directly answers:

> Who owes the shop money?

and:

> Whom does the shop owe?

Example:

``` text
CUSTOMERS

Ahmed Khan        ₹25,000 Dr
Rahul             ₹12,500 Dr
Sameer             ₹8,000 Dr


SUPPLIERS

ABC Supplier      ₹40,000 Cr
XYZ Supplier      ₹15,000 Cr
```

Clicking a party opens their statement.

No credit-limit system is required.

------------------------------------------------------------------------

# 35. Settings

Keep settings minimal.

## Shop Information

-   Shop name
-   Address
-   Phone
-   Email, optional

## Document Settings

-   Invoice/transaction number prefix
-   Starting number
-   Default terms/notes

## Application

-   Database location
-   Backup location
-   Print settings

Do not add complex configuration.

------------------------------------------------------------------------

# 36. Backup and Restore

Because the application is local-first, backup is mandatory.

The application should provide:

``` text
Backup Now
Restore Backup
```

It should also support automatic backup.

Recommended:

-   One automatic backup per day
-   Keep recent backups
-   Allow the user to select backup location

Backup should be a complete copy of the application's database.

Example:

``` text
JewelryKhata_Backup_2026-08-29.db
```

------------------------------------------------------------------------

# 37. Windows Installation Requirement

The final application must behave as a **single installable Windows
application**.

The shop owner should not need to install:

-   Flutter
-   Dart
-   SQLite separately
-   Python
-   Node.js
-   Java
-   PostgreSQL
-   Any server
-   Any development tool

Everything required by the application must be packaged with the Windows
build.

The user should be able to:

``` text
Run Installer
      ↓
Install Jewelry Khata
      ↓
Open Application
      ↓
Start Using It
```

No terminal commands should be required.

------------------------------------------------------------------------

# 38. Local Database

Recommended:

**SQLite**

with:

**Drift**

as the Flutter database layer.

The database should live in the application's appropriate user-data
directory, not inside the installed program directory.

This prevents data loss or permission issues when the application is
updated.

Conceptually:

``` text
Windows Application
        │
        ├── Program files
        │
        └── User Data
              └── jewelry_khata.sqlite
```

------------------------------------------------------------------------

# 39. Why SQLite + Drift

For this application, a traditional backend server is unnecessary.

The shop's data is primarily:

-   Local
-   Relational
-   Small
-   Transactional
-   Used by one local application

SQLite is therefore a better fit than adding a remote backend.

Benefits:

-   Offline
-   Fast
-   Simple
-   No server
-   No hosting cost
-   Easy backup
-   Easy installation
-   Works well with Flutter desktop

Drift provides a structured way to work with SQLite from Dart and helps
keep database operations maintainable.

------------------------------------------------------------------------

# 40. Future Cloud Architecture

Cloud should not be part of V1.

If the shop later needs:

-   Multiple computers
-   Mobile access
-   Remote backup
-   Cloud synchronization

then a future version can add:

``` text
Flutter
   │
Local SQLite + Drift
   │
Sync Layer
   │
Cloud Database
```

A PostgreSQL-based service such as Supabase can be considered at that
point.

The important requirement for V1 is to keep the repository/data layer
separated from the UI so this future change does not require rebuilding
the application.

------------------------------------------------------------------------

# 41. Database Schema

## Parties

``` text
parties
---------
id
name
type
phone
address
notes
created_at
updated_at
```

`type`:

``` text
customer
supplier
both
```

------------------------------------------------------------------------

## Transactions

``` text
transactions
------------
id
transaction_no
party_id
date
type
debit
credit
amount
reference_no
description
payment_mode
created_at
updated_at
deleted_at
```

The exact representation of debit/credit should be standardized in the
business-logic layer so the UI never produces contradictory values.

------------------------------------------------------------------------

## Payment Details

``` text
payment_details
---------------
id
transaction_id
payment_mode
reference_no
utr_no
bank_name
cheque_no
notes
```

All of these can be optional.

------------------------------------------------------------------------

# 42. Data Integrity Rules

These rules are critical.

## Rule 1

Every transaction belongs to exactly one party.

## Rule 2

Every transaction has exactly one transaction type.

## Rule 3

A transaction must have a positive amount.

## Rule 4

A transaction cannot simultaneously create contradictory debit and
credit values.

## Rule 5

The running balance is derived from transactions.

## Rule 6

Deleting a transaction must also remove its effect from the calculated
balance.

## Rule 7

Editing a transaction must recalculate the affected statement.

## Rule 8

Changing a party's name must not break historical transactions.

## Rule 9

Deleting a party should not silently delete their financial history.

Prefer disabling/archive behavior if party deletion becomes necessary.

## Rule 10

Dates must be stored consistently and displayed according to the user's
locale.

------------------------------------------------------------------------

# 43. Avoiding Logical Breaks

The application must have one source of truth.

The core relationship is:

``` text
Party
  ↓
Transactions
  ↓
Ledger
  ↓
Balance
  ↓
Statement
  ↓
PDF
```

Not:

``` text
Customer Balance
        +
Customer Transactions
        +
Separate Statement Balance
```

There should never be separate manually maintained balances.

A statement must be generated from the same transaction records used to
calculate the party's current balance.

------------------------------------------------------------------------

# 44. Editing Transactions

If a transaction is edited:

1.  Load the original transaction.
2.  Apply the updated values.
3.  Recalculate the affected party's ledger.
4.  Recalculate running balances.
5.  Update the statement.
6.  Update reports.
7.  Update the displayed current balance.

The application must not leave old balance values behind.

------------------------------------------------------------------------

# 45. Deleting Transactions

Deletion should require confirmation:

``` text
Delete Transaction?

This transaction will be removed from
the party's ledger and balance.

[Cancel] [Delete]
```

Prefer soft deletion internally so accidental deletion can be handled
safely.

Deleted transactions should not appear in normal reports.

------------------------------------------------------------------------

# 46. Search Requirements

Search should be fast even when the database becomes large.

Create database indexes for:

``` text
party name
phone
transaction number
reference number
invoice/record number
UTR/reference
```

The global search should query the database rather than loading every
record into memory.

------------------------------------------------------------------------

# 47. Keyboard Shortcuts

Desktop users should be able to work quickly.

Recommended:

  Shortcut     Action
  ------------ -------------------------------------
  `Ctrl + K`   Global search
  `Ctrl + N`   New transaction
  `Ctrl + P`   Print current record
  `Ctrl + S`   Save current form
  `Esc`        Close dialog
  `Enter`      Confirm/search/open selected result

Shortcuts should never interfere with normal text input.

------------------------------------------------------------------------

# 48. Empty States

Every list should have a useful empty state.

Example:

``` text
No customers yet.

Add your first customer to start
maintaining the khata.

[Add Customer]
```

Do not show empty tables with no explanation.

------------------------------------------------------------------------

# 49. Error Handling

Errors should be understandable to a shop owner.

Bad:

``` text
SQLite constraint violation: UNIQUE party_id...
```

Good:

``` text
This transaction could not be saved.
Please check the party and amount.
```

Technical details can be logged internally.

------------------------------------------------------------------------

# 50. Confirmation Rules

Require confirmation for destructive operations:

-   Delete transaction
-   Restore backup
-   Replace database
-   Delete/archive party

Do not require confirmation for normal actions such as:

-   Opening a customer
-   Opening a statement
-   Printing
-   Searching

------------------------------------------------------------------------

# 51. Performance Requirements

The application should feel instant for normal shop usage.

Target:

-   App startup: fast
-   Search: near-instant for normal datasets
-   Opening a party: near-instant
-   Saving a transaction: near-instant
-   Generating normal statement: fast
-   Printing: handed off to OS print system

The application should remain usable with thousands or tens of thousands
of transactions.

------------------------------------------------------------------------

# 52. Offline Requirement

All primary functions must work without internet:

-   Customers
-   Suppliers
-   Transactions
-   Search
-   Statements
-   PDF generation
-   Printing
-   Backup
-   Restore

Internet must not be required for normal daily operation.

------------------------------------------------------------------------

# 53. Printing

Printing should use the operating system's normal print dialog.

The user should be able to:

``` text
Print
  ↓
Windows Print Dialog
  ↓
Select Printer
  ↓
Print
```

The application should also provide:

``` text
Save as PDF
```

where supported.

------------------------------------------------------------------------

# 54. PDF Generation Technology

Use Flutter packages suitable for desktop PDF generation and printing.

Recommended:

-   `pdf`
-   `printing`

The PDF should be generated directly by the application.

The user should not need another PDF application to create the document.

A PDF viewer may be used by the operating system when opening a saved
PDF, but PDF generation itself is bundled into the application.

------------------------------------------------------------------------

# 55. Application Updates

The application should be designed so future versions can update the
application without deleting the database.

Update process:

``` text
New Version
     ↓
Install Update
     ↓
Run Database Migration
     ↓
Existing Data Remains
```

Database migrations must be versioned.

Never assume the database schema is always new.

------------------------------------------------------------------------

# 56. Backup Safety

Before a database migration or major application update:

``` text
Create Backup
      ↓
Apply Migration
      ↓
Start Application
```

If migration fails, the application should not silently destroy or
replace the existing database.

------------------------------------------------------------------------

# 57. Recommended Flutter Project Structure

``` text
lib/
│
├── core/
│   ├── database/
│   ├── theme/
│   ├── routing/
│   └── utils/
│
├── features/
│   ├── dashboard/
│   ├── parties/
│   │   ├── customers/
│   │   └── suppliers/
│   ├── transactions/
│   ├── statements/
│   ├── search/
│   ├── settings/
│   └── backup/
│
├── services/
│   ├── pdf/
│   ├── printing/
│   └── backup/
│
├── repositories/
│
└── main.dart
```

Keep business logic outside widgets.

------------------------------------------------------------------------

# 58. State Management

Use Riverpod or another lightweight structured state-management
solution.

The important requirement is not the specific state-management package.

The important requirement is:

``` text
UI
 ↓
Controller/Notifier
 ↓
Repository
 ↓
Database
```

Avoid putting database queries directly inside UI widgets.

------------------------------------------------------------------------

# 59. Repository Layer

Use repositories such as:

``` text
PartyRepository
TransactionRepository
StatementRepository
BackupRepository
```

Example:

``` text
PartyRepository
 ├── createParty()
 ├── updateParty()
 ├── searchParties()
 └── getParty()

TransactionRepository
 ├── createTransaction()
 ├── updateTransaction()
 ├── deleteTransaction()
 └── getPartyTransactions()

StatementRepository
 ├── getStatement()
 └── calculateBalance()
```

This keeps the architecture clean without overengineering it.

------------------------------------------------------------------------

# 60. Main User Flows

## Flow A: Add Customer

``` text
Customers
 ↓
Add Customer
 ↓
Name + Phone
 ↓
Save
 ↓
Customer Profile
```

------------------------------------------------------------------------

## Flow B: Record Sale

``` text
Global Search / Customer
 ↓
Open Customer
 ↓
Add Transaction
 ↓
Sale
 ↓
Amount
 ↓
Save
 ↓
Balance Updates
```

------------------------------------------------------------------------

## Flow C: Record Payment

``` text
Customer
 ↓
Add Transaction
 ↓
Payment Received
 ↓
Amount
 ↓
Payment Mode
 ↓
Reference (optional)
 ↓
Save
 ↓
Balance Updates
 ↓
Print Receipt (optional)
```

------------------------------------------------------------------------

## Flow D: Print Statement

``` text
Customer
 ↓
Statement
 ↓
Choose Date Range
 ↓
Print / Save PDF
```

------------------------------------------------------------------------

## Flow E: Supplier Payment

``` text
Supplier
 ↓
Add Transaction
 ↓
Payment Made
 ↓
Amount
 ↓
Payment Mode
 ↓
Save
 ↓
Supplier Balance Updates
```

------------------------------------------------------------------------

# 61. Logical Consistency Example

Suppose:

``` text
Opening balance = ₹10,000
Sale = ₹20,000
Payment = ₹5,000
```

The system must show:

``` text
Opening     ₹10,000
Sale        +₹20,000
Payment     -₹5,000
--------------------
Balance      ₹25,000
```

The same ₹25,000 must appear in:

-   Customer profile
-   Customer list
-   Statement
-   Dashboard outstanding
-   Search result
-   Any generated report

There must not be one screen showing ₹20,000 and another showing
₹25,000.

------------------------------------------------------------------------

# 62. Minimum Viable Product

V1 is complete when the following work reliably.

## Parties

-   [ ] Add customer
-   [ ] Edit customer
-   [ ] Search customer
-   [ ] Add supplier
-   [ ] Edit supplier
-   [ ] Search supplier

## Transactions

-   [ ] Opening balance
-   [ ] Sale/debit
-   [ ] Purchase
-   [ ] Payment received
-   [ ] Payment made
-   [ ] Debit adjustment
-   [ ] Credit adjustment
-   [ ] Edit transaction
-   [ ] Delete/soft-delete transaction

## Ledger

-   [ ] Running balance
-   [ ] Customer statement
-   [ ] Supplier statement
-   [ ] General ledger
-   [ ] Correct totals
-   [ ] Correct closing balance

## Search

-   [ ] Global search
-   [ ] Search by name
-   [ ] Search by phone
-   [ ] Search by transaction number
-   [ ] Search by payment reference
-   [ ] Search by UTR/cheque reference

## Documents

-   [ ] Customer statement PDF
-   [ ] Supplier statement PDF
-   [ ] General ledger PDF
-   [ ] Payment receipt
-   [ ] Basic invoice/sale document
-   [ ] Print support

## System

-   [ ] Offline operation
-   [ ] Backup
-   [ ] Restore
-   [ ] Windows installer
-   [ ] Fedora development/testing
-   [ ] Database migrations

------------------------------------------------------------------------

# 63. Recommended Tech Stack

  Area                Technology
  ------------------- -----------------------------------
  UI                  Flutter
  Language            Dart
  Database            SQLite
  Database Layer      Drift
  State Management    Riverpod
  PDF                 `pdf`
  Printing            `printing`
  File Picker         `file_picker`
  Local Paths         `path_provider`
  Formatting          `intl`
  Windows Packaging   Flutter Windows build + installer
  Linux Testing       Flutter Linux desktop

------------------------------------------------------------------------

# 64. Backend Decision

## V1: No traditional backend

Recommended architecture:

``` text
Flutter
   ↓
Application Logic
   ↓
Repository Layer
   ↓
Drift
   ↓
SQLite
```

This is intentional.

A local shop does not need a server just to maintain a khata book.

Advantages:

-   Works offline
-   Simple installation
-   No hosting
-   No API failures
-   No server maintenance
-   Easy backup
-   Fast local search
-   All data stays on the shop computer

------------------------------------------------------------------------

# 65. Single Application Requirement

The final Windows product should be distributable as one installer.

The installer should contain the application and all runtime
dependencies required for normal operation.

After installation:

``` text
Jewelry Khata
├── Application
├── Required Flutter runtime
├── PDF/printing functionality
└── Local database support
```

The shop owner should not know or care that SQLite, Flutter, or Drift
are being used.

------------------------------------------------------------------------

# 66. Security and Data Protection

For a basic local application:

-   Store the database in the user's application-data directory.
-   Do not expose the database through a network port.
-   Do not send customer data anywhere by default.
-   Backups should be ordinary database backup files.
-   Avoid storing unnecessary personal information.
-   Do not log financial data unnecessarily.

A password lock can be considered later, but it is not required for the
initial MVP unless the shop requests it.

------------------------------------------------------------------------

# 67. UI Component Rules

Use the supplied design system consistently.

## Buttons

Application controls use the tight 6px radius.

Primary:

``` text
Background: #171717
Text: #ffffff
Radius: 6px
```

Secondary:

``` text
Background: #ffffff
Border: #ebebeb
Text: #171717
Radius: 6px
```

Avoid marketing-style pill buttons inside the main application.

## Inputs

``` text
Background: #ffffff
Border: #ebebeb
Radius: 6px
Padding: 8px 12px
```

## Cards

``` text
Background: #ffffff
Border: #ebebeb
Radius: 12px
Padding: 24px
```

## Tables

Tables should primarily use:

-   White background
-   1px hairline separators
-   Near-black headers
-   Muted metadata
-   No heavy shadows

------------------------------------------------------------------------

# 68. Status and Semantic Colors

Color should communicate meaning only.

### Error

Use `#ee0000` for:

-   Invalid input
-   Failed operations
-   Destructive warnings

### Warning

Use `#f5a623` sparingly.

### Success/Active

Use the supplied blue `#0070f3` for:

-   Active/focused states
-   Links
-   Successful state where a color indicator is useful

Do not create green/red accounting dashboards.

------------------------------------------------------------------------

# 69. Accessibility

Minimum requirements:

-   Keyboard navigation
-   Visible focus state
-   Readable text
-   Clear labels
-   Adequate click targets
-   No color-only meaning
-   Useful error messages

The application is desktop-first, but controls should remain comfortable
for mouse use.

------------------------------------------------------------------------

# 70. Testing Requirements

## Unit Tests

Test the ledger engine heavily.

Examples:

``` text
Opening 10000
Debit 5000
Credit 2000
Expected = 13000
```

Test:

-   Opening balance
-   Debit
-   Credit
-   Multiple transactions
-   Editing transactions
-   Deleting transactions
-   Date ranges
-   Zero transactions
-   Same-day transactions
-   Large amounts
-   Decimal amounts

## Integration Tests

Test:

``` text
Create party
 ↓
Create transaction
 ↓
Read party balance
 ↓
Generate statement
 ↓
Verify statement total
```

## PDF Tests

Verify:

-   Correct party
-   Correct date range
-   Correct transactions
-   Correct totals
-   Correct closing balance
-   Multiple-page statements
-   Repeated table headers

------------------------------------------------------------------------

# 71. Acceptance Criteria

The MVP is accepted only if:

### Customer

A user can create a customer and immediately start recording
transactions.

### Supplier

A user can create a supplier and maintain their account independently.

### Balance

Every transaction immediately updates the correct balance.

### Search

A user can find a customer using name or phone and open their complete
account.

### Global Search

A user can search for a person, transaction, or payment reference from
anywhere.

### Statement

A customer or supplier statement shows all relevant transactions in
chronological order with debit, credit and running balance.

### PDF

The statement can be printed and saved as an A4 PDF.

### Backup

The complete database can be backed up and restored.

### Offline

The application continues to work without internet access.

### Installation

A normal Windows user can install and run the application without
installing development tools or a database server.

------------------------------------------------------------------------

# 72. Example Final Application

The intended experience should be approximately:

``` text
OPEN APP
   ↓
Dashboard
   ↓
Ctrl + K
   ↓
Search "Ahmed"
   ↓
Ahmed Khan
₹25,000 Dr
   ↓
Open Account
   ↓
View Statement
   ↓
Add Payment
₹5,000
UPI
   ↓
Balance becomes ₹20,000 Dr
   ↓
Print Statement
   ↓
A4 PDF
```

No unnecessary screens.

No complicated accounting terminology.

No internet requirement.

No server.

No GST module.

No inventory system.

No credit-limit system.

No unnecessary configuration.

------------------------------------------------------------------------

# 73. Final Product Definition

**Jewelry Shop Khata Book is a simple, offline Windows desktop ledger
application for maintaining customer and supplier accounts.**

Its core is:

``` text
PARTIES
   ↓
TRANSACTIONS
   ↓
DEBIT / CREDIT
   ↓
RUNNING BALANCE
   ↓
STATEMENTS
   ↓
PRINT / PDF
```

Everything else should support this flow.

The application should be:

-   Fast
-   Simple
-   Offline
-   Reliable
-   Searchable
-   Printable
-   Easy to install
-   Easy to backup
-   Easy for a local shop owner to understand

The first version should prioritize **correct ledger behavior and
usability over feature count**.

------------------------------------------------------------------------

# 74. Build Order

Recommended implementation sequence:

## Phase 1: Foundation

1.  Flutter desktop project
2.  Geist typography/theme
3.  Window setup
4.  SQLite + Drift
5.  Database migrations
6.  Application shell/sidebar

## Phase 2: Parties

7.  Party database
8.  Customer list
9.  Supplier list
10. Add/edit party
11. Party profile
12. Party search

## Phase 3: Ledger

13. Transaction database
14. Opening balance
15. Debit/credit engine
16. Running balance
17. Add transaction
18. Edit transaction
19. Delete/soft-delete transaction
20. Transaction list

## Phase 4: Search

21. Global search
22. Search indexing
23. Ctrl+K command/search interface
24. Search result navigation

## Phase 5: Statements

25. Customer statement
26. Supplier statement
27. General ledger
28. Date filtering
29. Totals
30. Closing balance

## Phase 6: Documents

31. PDF template system
32. Customer statement PDF
33. Supplier statement PDF
34. General ledger PDF
35. Payment receipt
36. Basic sale/invoice document
37. Windows printing

## Phase 7: Safety

38. Backup
39. Restore
40. Automatic backup
41. Migration backup
42. Error handling

## Phase 8: Packaging

43. Windows release build
44. Installer
45. Clean-machine installation test
46. Database persistence test
47. Backup/restore test
48. PDF/printing test

------------------------------------------------------------------------

# 75. Final Technical Recommendation

### Use this:

``` text
Flutter Desktop
       │
       ├── Geist Design System
       │
       ├── Riverpod
       │
       ├── Repository Layer
       │
       ├── Drift
       │
       ├── SQLite
       │
       ├── PDF
       │
       └── Windows Printing
```

### Do not use this for V1:

``` text
Flutter
   ↓
REST API
   ↓
Node/Python Server
   ↓
PostgreSQL
   ↓
Cloud Hosting
```

That architecture would add infrastructure that this basic local-shop
application does not need.

If cloud or multi-device support is required later, it can be introduced
as a separate synchronization layer.

------------------------------------------------------------------------

# 76. One-Sentence Product Rule

> **If a feature does not make it easier to maintain a party's khata,
> find a transaction, understand the balance, or print the record, it
> probably does not belong in V1.**
