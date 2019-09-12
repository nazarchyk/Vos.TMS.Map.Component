codeunit 6188530 "Map Show Prediction"
{
    trigger OnRun();
    begin
        end;
            procedure GetPredictionResults(var RouteDetails: Record "Map Route Detail");
    var
//        PredictionBufferMgt: Codeunit "Prediction Buffer Mgt.";
//        PredictionBuffer: Record "Prediction Buffer" temporary;
        TripPrediction: Record "Trip Prediction";
        ShpmntPrediction: Record "Trip Shipment Prediction";
        TrPlanAct: Record "Transport Planned Activity" temporary;
        Shpmnt: Record Shipment temporary;
    begin
        //RouteDetails.SetRange("Route No.", 0);
        //if RouteDetails.FindLast then;
        //RouteDetails.Reset;
        
        TripPrediction.FindFirst;
        TripPrediction.CalculateWithActivities(ShpmntPrediction, TrPlanAct, Shpmnt);
        if TrPlanAct.FindSet then repeat
            RouteDetails.CreateFromTrPlanAct(TrPlanAct, '', 1, TripPrediction."Trip No.");
        until TrPlanAct.Next = 0;
    end;

}