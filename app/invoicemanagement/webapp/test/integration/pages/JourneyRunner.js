sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"invoicemanagement/test/integration/pages/InvoicesList",
	"invoicemanagement/test/integration/pages/InvoicesObjectPage",
	"invoicemanagement/test/integration/pages/InvoiceItemsObjectPage"
], function (JourneyRunner, InvoicesList, InvoicesObjectPage, InvoiceItemsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('invoicemanagement') + '/test/flp.html#app-preview',
        pages: {
			onTheInvoicesList: InvoicesList,
			onTheInvoicesObjectPage: InvoicesObjectPage,
			onTheInvoiceItemsObjectPage: InvoiceItemsObjectPage
        },
        async: true
    });

    return runner;
});

