public without sharing class MyTeamOrdersController {

    // Method called to display the company's turnover on MyTeamOrders vfpage

    public decimal sumOrders{
        get{
			AggregateResult aggregateResults = OrderSelector.getSumOfTotalAmountOfActivatedOrders();
			return (decimal) aggregateResults.get('total');

        }
        set;
    }

    // Method called to display the chart showing the turnover made by each sales rep on MyTeamOrders vfpage
    
    public List<AggregateResult> aggregateResults { get; set; }
    public List<AggregateResultWrapper> displayAggregates { get; set; }
    
    public MyTeamOrdersController() {
        aggregateResults = [SELECT SUM(TotalAmount) total, Owner.Name ownerName FROM Order WHERE Status = 'Activated' GROUP BY Owner.Name];
        displayAggregates = new List<AggregateResultWrapper>();
        
        for (AggregateResult result : aggregateResults) {
            displayAggregates.add(new AggregateResultWrapper(result));
        }
    }
    
    public class AggregateResultWrapper {
        public Decimal total { get; set; }
        public String ownerName { get; set; }
        
        public AggregateResultWrapper(AggregateResult ar) {
            this.total = (Decimal)ar.get('total');
            this.ownerName = (String)ar.get('ownerName');
        }
    }
}