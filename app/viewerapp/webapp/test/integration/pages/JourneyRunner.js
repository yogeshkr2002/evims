sap.ui.define([
    "sap/fe/test/JourneyRunner",
	"viewerapp/test/integration/pages/InvoicesList",
	"viewerapp/test/integration/pages/InvoicesObjectPage",
	"viewerapp/test/integration/pages/InvoiceItemsObjectPage"
], function (JourneyRunner, InvoicesList, InvoicesObjectPage, InvoiceItemsObjectPage) {
    'use strict';

    var runner = new JourneyRunner({
        launchUrl: sap.ui.require.toUrl('viewerapp') + '/test/flp.html#app-preview',
        pages: {
			onTheInvoicesList: InvoicesList,
			onTheInvoicesObjectPage: InvoicesObjectPage,
			onTheInvoiceItemsObjectPage: InvoiceItemsObjectPage
        },
        async: true
    });

    return runner;
});

