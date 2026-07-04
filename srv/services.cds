using { com.vendorinvoice as db } from '../db/schema';

// ==================== ADMIN SERVICE ====================
service AdminService @(requires: 'Admin') {

  entity Vendors as projection on db.Vendors;

  @odata.draft.enable
  entity Invoices as projection on db.Invoices actions {
    action submitForApproval() returns Invoices;
    action approve(comments: String(500)) returns Invoices;
    action rejectInvoice(reason: String(500)) returns Invoices;
  };

  entity InvoiceItems as projection on db.InvoiceItems;
  entity Attachments as projection on db.Attachments;
  entity ApprovalHistory as projection on db.ApprovalHistory;

  action syncVendorsFromS4() returns String;

@readonly
@cds.redirection.target: false
entity InvoiceAnalytics as projection on db.Invoices {
    key vendor.ID as vendorID,
    vendor.vendorName as vendorName,
    status,
    currency,
    count(*) as totalInvoices : Integer,
    sum(amount) as totalAmount : Decimal(15,2)
  } group by vendor.ID, vendor.vendorName, status, currency;
}

// ==================== VENDOR MANAGER SERVICE ====================
service VendorManagerService @(requires: 'VendorManager') {

  @readonly
  entity Vendors as projection on db.Vendors;

  @odata.draft.enable
  entity Invoices as projection on db.Invoices actions {
    action submitForApproval() returns Invoices;
  };

  entity InvoiceItems as projection on db.InvoiceItems;
  entity Attachments as projection on db.Attachments;

  @readonly
  entity ApprovalHistory as projection on db.ApprovalHistory;
}

// ==================== APPROVER SERVICE ====================
service ApproverService @(requires: 'Approver') {

  @readonly
  entity Vendors as projection on db.Vendors;

  @readonly
  entity Invoices as projection on db.Invoices actions {
    action approve(comments: String(500)) returns Invoices;
    action rejectInvoice(reason: String(500)) returns Invoices;
  };

  @readonly
  entity InvoiceItems as projection on db.InvoiceItems;
  @readonly
  entity Attachments as projection on db.Attachments;
  @readonly
  entity ApprovalHistory as projection on db.ApprovalHistory;
}

// ==================== VIEWER SERVICE ====================
service ViewerService @(requires: 'Viewer') {

  @readonly
  entity Vendors as projection on db.Vendors;

  @readonly
  entity Invoices as projection on db.Invoices where status = 'APPROVED' or status = 'PAID';

  @readonly
  entity InvoiceItems as projection on db.InvoiceItems;

@readonly
@cds.redirection.target: false
entity InvoiceAnalytics as projection on AdminService.InvoiceAnalytics;
}