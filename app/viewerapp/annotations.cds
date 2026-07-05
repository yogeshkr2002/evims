using ViewerService as service from '../../srv/services';

annotate service.Invoices with @(

    UI.HeaderInfo               : {
        TypeName      : 'Invoice',
        TypeNamePlural: 'Invoices',
        Title         : {Value: invoiceNumber},
        Description   : {Value: status},
    },

    UI.FieldGroup #GeneralGroup : {
        $Type: 'UI.FieldGroupType',
        Data : [
            {
                $Type: 'UI.DataField',
                Label: 'Invoice Number',
                Value: invoiceNumber
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
                Label: 'Approved By',
                Value: approvedBy
            },
            {
                $Type: 'UI.DataField',
                Label: 'Approved At',
                Value: approvedAt
            },
        ],
    },

    UI.Facets                   : [
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'GeneralInfoFacet',
            Label : 'General Information',
            Target: '@UI.FieldGroup#GeneralGroup',
        },
        {
            $Type : 'UI.ReferenceFacet',
            ID    : 'LineItemsFacet',
            Label : 'Line Items',
            Target: 'items/@UI.LineItem',
        },
    ],

    UI.LineItem                 : [
        {
            $Type: 'UI.DataField',
            Label: 'Invoice Number',
            Value: invoiceNumber
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
    ],

    UI.SelectionFields           : [
        status,
        invoiceDate
    ],
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

annotate service.InvoiceAnalytics with @(
    UI.HeaderInfo: {
        TypeName      : 'Invoice Analytics',
        TypeNamePlural: 'Invoice Analytics',
    },
    UI.LineItem  : [
        {
            $Type: 'UI.DataField',
            Label: 'Vendor',
            Value: vendorName
        },
        {
            $Type: 'UI.DataField',
            Label: 'Status',
            Value: status
        },
        {
            $Type: 'UI.DataField',
            Label: 'Currency',
            Value: currency
        },
        {
            $Type: 'UI.DataField',
            Label: 'Total Invoices',
            Value: totalInvoices
        },
        {
            $Type: 'UI.DataField',
            Label: 'Total Amount',
            Value: totalAmount
        },
    ],
    UI.SelectionFields: [
        status,
        currency
    ],
);