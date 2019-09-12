codeunit 6188530 "Map Show Prediction"
{
    procedure GetPredictionResults();
    var
        MapBuffer: Codeunit "Map Buffer";
        RouteDetails: Record "Map Route Detail" temporary;
        TripPrediction: Record "Trip Prediction";
        ShpmntPrediction: Record "Trip Shipment Prediction";
        TrPlanAct: Record "Transport Planned Activity" temporary;
        Shpmnt: Record Shipment temporary;
    begin
        MapBuffer.GetRouteDetails(RouteDetails);
        TripPrediction.FindFirst;
        TripPrediction.CalculateWithActivities(ShpmntPrediction, TrPlanAct, Shpmnt);
        TrPlanAct.SetFilter("Address No.", '<>%1', '');
        if TrPlanAct.FindSet then repeat
            RouteDetails.CreateFromTrPlanAct(TrPlanAct, '', 1, TripPrediction."Trip No.");
            until TrPlanAct.Next = 0;
        MapBuffer.SetRouteDetails(RouteDetails);
    end;
}