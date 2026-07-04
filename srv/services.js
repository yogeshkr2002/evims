const cds = require('@sap/cds');

module.exports = cds.service.impl(async function () {

  const { Vendors, Invoices, InvoiceItems, ApprovalHistory } = this.entities;

  // ==================== AUTO-CALCULATE LINE ITEM TOTAL ====================
  this.before(['CREATE', 'UPDATE'], 'InvoiceItems', (req) => {
    const { quantity, unitPrice } = req.data;
    if (quantity != null && unitPrice != null) {
      req.data.totalAmount = quantity * unitPrice;
    }
  });

  // ==================== INVOICE CREATION VALIDATIONS ====================
  this.before('CREATE', 'Invoices', async (req) => {
    const { vendor_ID, invoiceDate, amount } = req.data;

    // Rule 1: Vendor must be APPROVED
    if (vendor_ID) {
      const vendor = await SELECT.one.from(Vendors).where({ ID: vendor_ID });
      if (!vendor) {
        return req.error(400, 'Selected vendor does not exist');
      }
      if (vendor.status !== 'APPROVED') {
        return req.error(400, 'Please select an approved vendor');
      }
    }

    // Rule 2: Amount > 0 and <= 1,000,000
    if (amount != null && (amount <= 0 || amount > 1000000)) {
      return req.error(400, 'Amount must be between 0.01 and 1,000,000');
    }

    // Rule 3: Invoice date cannot be future dated
    if (invoiceDate) {
      const today = new Date().toISOString().split('T')[0];
      if (invoiceDate > today) {
        return req.error(400, 'Invoice date cannot be in the future');
      }
    }

    // Rule 7: Invoice number must be unique per vendor
    if (req.data.invoiceNumber && vendor_ID) {
      const existing = await SELECT.one.from(Invoices).where({
        invoiceNumber: req.data.invoiceNumber,
        vendor_ID: vendor_ID
      });
      if (existing) {
        return req.error(400, `Invoice number ${req.data.invoiceNumber} already exists for this vendor`);
      }
    }
  });

  // ==================== SUBMIT FOR APPROVAL ====================
  this.on('submitForApproval', 'Invoices', async (req) => {
    const invoiceID = req.params[0].ID || req.params[0];
    const invoice = await SELECT.one.from(Invoices).where({ ID: invoiceID });

    if (!invoice) return req.error(404, 'Invoice not found');

    // Rule: must be DRAFT
    if (invoice.status !== 'DRAFT') {
      return req.error(400, 'Only draft invoices can be submitted');
    }

    // Rule: at least one line item
    const items = await SELECT.from(InvoiceItems).where({ invoice_ID: invoiceID });
    if (!items.length) {
      return req.error(400, 'Invoice must have at least one line item');
    }

    // Rule: sum of line items = header amount
    const sum = items.reduce((acc, i) => acc + Number(i.totalAmount), 0);
    if (Math.abs(sum - Number(invoice.amount)) > 0.01) {
      return req.error(400, `Line items total (${sum}) does not match invoice amount (${invoice.amount}). Adjustment required.`);
    }

    const user = req.user.id || 'unknown';
    const now = new Date().toISOString();

    await UPDATE(Invoices).set({
      status: 'SUBMITTED',
      submittedBy: user,
      submittedAt: now
    }).where({ ID: invoiceID });

    await INSERT.into(ApprovalHistory).entries({
      invoice_ID: invoiceID,
      action: 'SUBMITTED',
      actor: user,
      timestamp: now,
      comments: 'Invoice submitted for approval'
    });

    return SELECT.one.from(Invoices).where({ ID: invoiceID });
  });

  // ==================== APPROVE INVOICE ====================
  this.on('approve', 'Invoices', async (req) => {
    const invoiceID = req.params[0].ID || req.params[0];
    const { comments } = req.data;
    const invoice = await SELECT.one.from(Invoices).where({ ID: invoiceID });

    if (!invoice) return req.error(404, 'Invoice not found');

    if (invoice.status !== 'SUBMITTED') {
      return req.error(400, 'Only submitted invoices can be approved');
    }

    const user = req.user.id || 'unknown';

    // Rule: approver cannot approve their own submission
    if (invoice.submittedBy === user) {
      return req.error(403, 'You cannot approve your own submitted invoice');
    }

    const now = new Date().toISOString();

    await UPDATE(Invoices).set({
      status: 'APPROVED',
      approvedBy: user,
      approvedAt: now,
      approvalComments: comments || null
    }).where({ ID: invoiceID });

    await INSERT.into(ApprovalHistory).entries({
      invoice_ID: invoiceID,
      action: 'APPROVED',
      actor: user,
      timestamp: now,
      comments: comments || 'Invoice approved'
    });

    return SELECT.one.from(Invoices).where({ ID: invoiceID });
  });

  // ==================== REJECT INVOICE ====================
  this.on('rejectInvoice', 'Invoices', async (req) => {
    const invoiceID = req.params[0].ID || req.params[0];
    const { reason } = req.data;
    const invoice = await SELECT.one.from(Invoices).where({ ID: invoiceID });

    if (!invoice) return req.error(404, 'Invoice not found');

    if (invoice.status !== 'SUBMITTED') {
      return req.error(400, 'Only submitted invoices can be rejected');
    }

    if (!reason || !reason.trim()) {
      return req.error(400, 'Rejection reason is mandatory');
    }

    const user = req.user.id || 'unknown';
    const now = new Date().toISOString();

    await UPDATE(Invoices).set({
      status: 'REJECTED',
      rejectedBy: user,
      rejectedAt: now,
      rejectionReason: reason
    }).where({ ID: invoiceID });

    await INSERT.into(ApprovalHistory).entries({
      invoice_ID: invoiceID,
      action: 'REJECTED',
      actor: user,
      timestamp: now,
      comments: reason
    });

    return SELECT.one.from(Invoices).where({ ID: invoiceID });
  });

  // ==================== S/4HANA VENDOR SYNC ====================
  this.on('syncVendorsFromS4', async (req) => {
    try {
      const S4 = await cds.connect.to('API_BUSINESS_PARTNER');

      const suppliers = await S4.run(
        SELECT.from('A_Supplier')
          .columns('Supplier', 'SupplierName', 'SupplierFullName')
          .limit(15)
      );

      let created = 0, updated = 0;

      for (const s of suppliers) {
        const externalId = s.Supplier;
        const vendorName = s.SupplierFullName || s.SupplierName || 'Unknown Supplier';

        const existing = await SELECT.one.from(Vendors).where({ externalSystemId: externalId });

        if (existing) {
          await UPDATE(Vendors).set({ vendorName }).where({ externalSystemId: externalId });
          updated++;
        } else {
          await INSERT.into(Vendors).entries({
            vendorName,
            externalSystemId: externalId,
            status: 'PENDING',
            country: 'US',
            currency: 'USD'
          });
          created++;
        }
      }

      return `Vendor sync completed successfully! Total: ${suppliers.length}, Created: ${created}, Updated: ${updated}`;
    } catch (err) {
      console.error('S4 Sync Error:', err.message);
      return req.error(500, 'Failed to connect to S/4HANA system. Please check destination configuration.');
    }
  });

});