sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"approverapp/test/integration/pages/InvoicesList",
	"approverapp/test/integration/pages/InvoicesObjectPage",
	"approverapp/test/integration/pages/InvoiceItemsObjectPage"
], function (JourneyRunner, InvoicesList, InvoicesObjectPage, InvoiceItemsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('approverapp') + '/test/flp.html#app-preview',
        pages: {
			onTheInvoicesList: InvoicesList,
			onTheInvoicesObjectPage: InvoicesObjectPage,
			onTheInvoiceItemsObjectPage: InvoiceItemsObjectPage
        },
        async: true
    });

    return runner;
});

