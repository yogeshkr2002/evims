namespace com.vendorinvoice;

using {
  cuid,
  managed
} from '@sap/cds/common';

entity Vendors : cuid, managed {
  vendorName       : String(100) @mandatory;
  email            : String(100);
  phone            : String(20);
  addressLine1     : String(150);
  addressLine2     : String(150);
  city             : String(50);
  country          : String(2);
  currency         : String(3);
  taxId            : String(30);
  externalSystemId : String(40); // S/4HANA Supplier ID
  status           : String(10) enum {
    PENDING;
    APPROVED;
    SUSPENDED;
    REJECTED;
    DELETED;
  } default 'PENDING';
  assignedManager  : String(50); // user ID of VendorManager
  invoices         : Association to many Invoices
                       on invoices.vendor = $self;
}

entity Invoices : cuid, managed {
  invoiceNumber     : String(30)             @mandatory;
  vendor            : Association to Vendors @mandatory;
  invoiceDate       : Date                   @mandatory;
  dueDate           : Date                   @mandatory;
  amount            : Decimal(15, 2)         @mandatory;
  currency          : String(3)              @mandatory;
  status            : String(10) enum {
    DRAFT;
    SUBMITTED;
    APPROVED;
    REJECTED;
    PAID;
  } default 'DRAFT';

  statusCriticality : Integer = case
                                  status
                                  when 'DRAFT'
                                       then 0
                                  when 'SUBMITTED'
                                       then 2
                                  when 'APPROVED'
                                       then 3
                                  when 'REJECTED'
                                       then 1
                                  when 'PAID'
                                       then 3
                                  else 0
                                end;

  canSubmit         : Boolean = (
    status = 'DRAFT'
  );
  canApprove        : Boolean = (
    status = 'SUBMITTED'
  );
  canReject         : Boolean = (
    status = 'SUBMITTED'
  );

  submittedBy       : String(50);
  submittedAt       : Timestamp;

  approvedBy        : String(50);
  approvedAt        : Timestamp;
  approvalComments  : String(500);

  rejectedBy        : String(50);
  rejectedAt        : Timestamp;
  rejectionReason   : String(500);

  items             : Composition of many InvoiceItems
                        on items.invoice = $self;
  attachments       : Composition of many Attachments
                        on attachments.invoice = $self;
  approvalHistory   : Composition of many ApprovalHistory
                        on approvalHistory.invoice = $self;
}

entity InvoiceItems : cuid {
  invoice     : Association to Invoices @mandatory;
  lineNo      : Integer                 @mandatory;
  description : String(255)             @mandatory;
  quantity    : Decimal(10, 2)          @mandatory;
  unitPrice   : Decimal(15, 2)          @mandatory;
  totalAmount : Decimal(15, 2); // calculated = quantity * unitPrice
}

entity Attachments : cuid, managed {
  invoice    : Association to Invoices @mandatory;
  fileName   : String(255)             @mandatory;
  fileSize   : Integer;
  mimeType   : String(100);
  uploadedBy : String(50);
  uploadedAt : Timestamp;
  url        : String(500); // storage reference
}

entity ApprovalHistory : cuid {
  invoice   : Association to Invoices @mandatory;
  action    : String(15) enum {
    SUBMITTED;
    APPROVED;
    REJECTED;
  };
  actor     : String(100)             @mandatory;
  timestamp : Timestamp               @mandatory;
  comments  : String(500);
}
