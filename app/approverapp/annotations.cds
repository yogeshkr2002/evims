using ApproverService as service from '../../srv/services';

annotate service.Invoices with @(

    UI.HeaderInfo                : {
        TypeName      : 'Invoice',
        TypeNamePlural: 'Invoices',
        Title         : {Value: invoiceNumber},
        Description   : {Value: status},
    },

    UI.FieldGroup #GeneralGroup   : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'Invoice Number',
                Value: invoiceNumber
            },
            {
                $Type: 'UI.DataField',
                Label: 'Vendor',
                Value: vendor.vendorName
            },
            {
                $Type: 'UI.DataField',
                Label: 'Invoice Date',
                Value: invoiceDate
            },
            {
                $Type: 'UI.DataField',
                Label: 'Due Date',
                Value: dueDate
            },
            {
                $Type: 'UI.DataField',
                Label: 'Amount',
                Value: amount
            },
            {
                $Type: 'UI.DataField',
                Label: 'Currency',
                Value: currency
            },
            {
                $Type      : 'UI.DataField',
                Label      : 'Status',
                Value      : status,
                Criticality: statusCriticality
            },
            {
                $Type: 'UI.DataField',
                Label: 'Submitted By',
                Value: submittedBy
            },
            {
                $Type: 'UI.DataField',
                Label: 'Submitted At',
                Value: submittedAt
            },
        ],
    },

    UI.FieldGroup #DecisionGroup  : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'Approved By',
                Value: approvedBy
            },
            {
                $Type: 'UI.DataField',
                Label: 'Approved At',
                Value: approvedAt
            },
            {
                $Type: 'UI.DataField',
                Label: 'Approval Comments',
                Value: approvalComments
            },
            {
                $Type: 'UI.DataField',
                Label: 'Rejected By',
                Value: rejectedBy
            },
            {
                $Type: 'UI.DataField',
                Label: 'Rejected At',
                Value: rejectedAt
            },
            {
                $Type: 'UI.DataField',
                Label: 'Rejection Reason',
                Value: rejectionReason
            },
        ],
    },

    UI.Facets                    : [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'GeneralInfoFacet',
            Label : 'General Information',
            Target: '@UI.FieldGroup#GeneralGroup',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'DecisionFacet',
            Label : 'Decision Details',
            Target: '@UI.FieldGroup#DecisionGroup',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'LineItemsFacet',
            Label : 'Line Items',
            Target: 'items/@UI.LineItem',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'AttachmentsFacet',
            Label : 'Attachments',
            Target: 'attachments/@UI.LineItem',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'ApprovalHistoryFacet',
            Label : 'Approval History',
            Target: 'approvalHistory/@UI.LineItem',
        },
    ],

    UI.LineItem                  : [
        {
            $Type: 'UI.DataField',
            Label: 'Invoice Number',
            Value: invoiceNumber
        },
        {
            $Type: 'UI.DataField',
            Label: 'Vendor',
            Value: vendor.vendorName
        },
        {
            $Type: 'UI.DataField',
            Label: 'Invoice Date',
            Value: invoiceDate
        },
        {
            $Type: 'UI.DataField',
            Label: 'Amount',
            Value: amount
        },
        {
            $Type: 'UI.DataField',
            Label: 'Currency',
            Value: currency
        },
        {
            $Type      : 'UI.DataField',
            Label      : 'Status',
            Value      : status,
            Criticality: statusCriticality
        },
        {
            $Type     : 'UI.DataField',
            Value     : canApprove,
            @UI.Hidden: true
        },
        {
            $Type     : 'UI.DataField',
            Value     : canReject,
            @UI.Hidden: true
        },
        {
            $Type                     : 'UI.DataFieldForAction',
            Label                     : 'Approve',
            Action                    : 'ApproverService.approve',
            ![Core.OperationAvailable]: canApprove,
        },
        {
            $Type                     : 'UI.DataFieldForAction',
            Label                     : 'Reject',
            Action                    : 'ApproverService.rejectInvoice',
            ![Core.OperationAvailable]: canReject,
        },
    ],

    // Buttons on the Object Page header itself (List Report toolbar alone is not enough)
    UI.Identification             : [
        {
            $Type                     : 'UI.DataFieldForAction',
            Label                     : 'Approve',
            Action                    : 'ApproverService.approve',
            ![Core.OperationAvailable]: canApprove,
        },
        {
            $Type                     : 'UI.DataFieldForAction',
            Label                     : 'Reject',
            Action                    : 'ApproverService.rejectInvoice',
            ![Core.OperationAvailable]: canReject,
        },
    ],

    UI.SelectionFields            : [
        vendor_ID,
        status,
        invoiceDate
    ],

    UI.HeaderFacets               : [{
        $Type : 'UI.ReferenceFacet',
        Target: '@UI.FieldGroup#DecisionGroup',
    }, ],
);

annotate service.InvoiceItems with @(UI.LineItem: [
    {
        $Type: 'UI.DataField',
        Label: 'Line No',
        Value: lineNo
    },
    {
        $Type: 'UI.DataField',
        Label: 'Description',
        Value: description
    },
    {
        $Type: 'UI.DataField',
        Label: 'Quantity',
        Value: quantity
    },
    {
        $Type: 'UI.DataField',
        Label: 'Unit Price',
        Value: unitPrice
    },
    {
        $Type: 'UI.DataField',
        Label: 'Total Amount',
        Value: totalAmount
    },
], );

annotate service.Attachments with @(UI.LineItem: [
    {
        $Type: 'UI.DataField',
        Label: 'File Name',
        Value: fileName
    },
    {
        $Type: 'UI.DataField',
        Label: 'File Size',
        Value: fileSize
    },
    {
        $Type: 'UI.DataField',
        Label: 'Uploaded By',
        Value: uploadedBy
    },
    {
        $Type: 'UI.DataField',
        Label: 'Uploaded At',
        Value: uploadedAt
    },
], );

annotate service.ApprovalHistory with @(UI.LineItem: [
    {
        $Type: 'UI.DataField',
        Label: 'Action',
        Value: action
    },
    {
        $Type: 'UI.DataField',
        Label: 'Actor',
        Value: actor
    },
    {
        $Type: 'UI.DataField',
        Label: 'Timestamp',
        Value: timestamp
    },
    {
        $Type: 'UI.DataField',
        Label: 'Comments',
        Value: comments
    },
], );