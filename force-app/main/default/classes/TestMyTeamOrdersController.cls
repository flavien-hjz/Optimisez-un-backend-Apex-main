@isTest
public with sharing class TestMyTeamOrdersController {

    @TestSetup
    static void makeData(){

        List<Account> accounts = new List<Account>();
        for (Integer i=0; i < 10; i++) {
            Account account = DataFactory.createAccount('testAccount' + i);
            accounts.add(account);
        }
        insert accounts;

        Product2 product = DataFactory.createProduct('testProduct');
        insert product;

        PricebookEntry pricebookEntry = DataFactory.createPriceBookEntry(product.Id, 100);
        insert pricebookEntry;

        Decimal unitPrice = pricebookEntry.UnitPrice;

        List<Order> ordersList = new List<Order>();
        for (Account account : accounts) {
            for (Integer i=0; i < 5; i++) {
                ordersList.add(DataFactory.createOrder(account.Id));
            }
        }
        insert ordersList;

        Map<String,String> productWithPricebookEntry = new Map<String, String> {
            'Product2Id' => product.Id,
            'PricebookEntryId' => pricebookEntry.Id
        };
        List<OrderItem> orderItemsList = DataFactory.createOrderItems(ordersList, productWithPricebookEntry, unitPrice);
        insert orderItemsList;
        
    }

    @isTest
    public static void sumOrdersTest() {

        MyTeamOrdersController myTeamOrdersController = new MyTeamOrdersController();
        List<Order> activatedOrders = new List<Order>();
        List<Order> orders = [SELECT Id, Status FROM Order WHERE Status = 'Draft'];
        for (Order order : orders) {
            order.Status = 'Activated';
            activatedOrders.add(order);
        }

        Test.startTest();
        update activatedOrders;
        Test.stopTest();

        // Sum of total amount of all activated orders must be the same as the figure displayed on MyTeamsOrders vfpage

        Decimal expectedResult = 50000; // 10 accounts * 5 orders * 10 products * 100 (unit price)
        Decimal actualResult = myTeamOrdersController.sumOrders;

        System.assertEquals(expectedResult, actualResult, 'Turnover displayed is : ' + actualResult + ' Expected was : ' + expectedResult);

    }
}