@isTest
public with sharing class TestOrderService {

    @TestSetup
    static void makeData(){

        Account account = DataFactory.createAccount('testAccount');
        insert account;

        Product2 product = DataFactory.createProduct('testProduct');
        insert product;

        PricebookEntry pricebookEntry = DataFactory.createPriceBookEntry(product.Id, 100);
        insert pricebookEntry;

        Decimal unitPrice = pricebookEntry.UnitPrice;

        List<Order> ordersList = DataFactory.createOrders(account.Id, 1);
        insert ordersList;

        Map<String,String> productWithPricebookEntry = new Map<String,String> {
            'Product2Id' => product.Id,
            'PricebookEntryId' => pricebookEntry.Id
        };
        List<OrderItem> orderItemsList = DataFactory.createOrderItems(ordersList, productWithPricebookEntry, unitPrice);
        insert orderItemsList;
        
    }

    @isTest
    public static void calculateNetAmountTest() {

        Order testOrder = new Order();
        testOrder = [SELECT Id, ShipmentCost__c, NetAmount__c, TotalAmount FROM ORDER LIMIT 1];

        Test.startTest();
        
        System.assertEquals(0, testOrder.ShipmentCost__c, 'Shipment cost null or not equal to 0');
        testOrder.ShipmentCost__c = 100;
        update testOrder;

        Test.stopTest();

        Decimal expectedResult = 900; // 10 products * 100 (unit price) - 100 (shipment cost)
        Decimal actualResult = ([SELECT NetAmount__c FROM Order WHERE Id=:testOrder.Id].NetAmount__c);
        System.assertEquals(expectedResult, actualResult, 'Net Amount is '+ actualResult +'. Expected was ' + expectedResult);

    }

    @isTest
    public static void updateAccountAnnualRevenueTest() {

        Order testOrder = [SELECT Id, Status FROM Order WHERE Status = 'Draft'];

        Test.startTest();
        testOrder.Status = 'Activated';
        update testOrder;
        Test.stopTest();

        // After the order is updated to 'Activated', the order amount must be added to the current annual revenue of the account

        Decimal expectedResult = 1000; // 10 products * 100 (unit price). Annual revenue do not include shipment costs
        Decimal actualResult = ([SELECT Id, AnnualRevenue FROM Account WHERE Name = 'testAccount'].AnnualRevenue);
        System.assertEquals(expectedResult, actualResult, 'Annual Revenue is '+ actualResult +'. Expected was ' + expectedResult);
    }
}