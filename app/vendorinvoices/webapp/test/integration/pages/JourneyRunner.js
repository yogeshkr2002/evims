sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"vendorinvoices/test/integration/pages/InvoicesList",
	"vendorinvoices/test/integration/pages/InvoicesObjectPage",
	"vendorinvoices/test/integration/pages/InvoiceItemsObjectPage"
], function (JourneyRunner, InvoicesList, InvoicesObjectPage, InvoiceItemsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('vendorinvoices') + '/test/flp.html#app-preview',
        pages: {
			onTheInvoicesList: InvoicesList,
			onTheInvoicesObjectPage: InvoicesObjectPage,
			onTheInvoiceItemsObjectPage: InvoiceItemsObjectPage
        },
        async: true
    });

    return runner;
});

