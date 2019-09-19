codeunit 6188530 "Map Show Prediction"
{
    procedure GetPredictionResults();
    begin
        GetCalculatedShipmentsAsTrip;
        GetCalculatedShipments;
    end;
    local procedure GetCalculatedShipmentsAsTrip();
    var
        MapBuffer: Codeunit "Map Buffer";
        RouteDetails: Record "Map Route Detail" temporary;
        TripPrediction: Record "Trip Prediction";
        ShpmntPrediction: Record "Trip Shipment Prediction";
        TrPlanAct: Record "Transport Planned Activity" temporary;
        Shpmnt: Record Shipment temporary;
    begin
        MapBuffer.GetRouteDetails(RouteDetails);
        TripPrediction.SetRange("Trip No.", 'DUMMY');
        if not TripPrediction.FindFirst then
            exit;
        TripPrediction.CalculateWithActivities(ShpmntPrediction, TrPlanAct, Shpmnt);
        TrPlanAct.Reset;
        TrPlanAct.SetFilter("Address No.", '<>%1', '');
        if TrPlanAct.FindSet then repeat
            RouteDetails.CreateFromTrPlanAct(TrPlanAct, '', 1, TripPrediction."Trip No.", false);
            until TrPlanAct.Next = 0;
        MapBuffer.SetRouteDetails(RouteDetails);
    end;
    local procedure GetCalculatedShipments();
    var
        MapBuffer: Codeunit "Map Buffer";
        RouteDetail: Record "Map Route Detail" temporary;
        PredictionBuffer: Record "Prediction Buffer" temporary;
        PredictionBufferMgt: Codeunit "Prediction Buffer Mgt.";
        i: Integer;
    begin
        MapBuffer.GetRouteDetails(RouteDetail);
        RouteDetail.SetRange("Route No.", 0);
        if RouteDetail.FindLast then
            i := RouteDetail."Stop No.";
        RouteDetail.Reset;

        PredictionBufferMgt.GetBuffer(PredictionBuffer);
        if PredictionBuffer.FindSet then repeat
            RouteDetail.init;
            RouteDetail.id := PredictionBuffer."Shipment Id";
            RouteDetail."Route No." := 0;
            i += 1;
            RouteDetail."Stop No." := i;
            RouteDetail.Color := 'Red';
            RouteDetail.Longitude := PredictionBuffer.Longitude;
            RouteDetail.Latitude := PredictionBuffer.Latitude;
            RouteDetail."Marker Type" := RouteDetail."Marker Type"::Circle;
            RouteDetail.Source := 'Prediction';
            RouteDetail.SetMarkerRadiusBasedOnLoadingMeters(PredictionBuffer."Loading Meters");
            RouteDetail.SetMarkerStrokeBasedOnSelected;
            RouteDetail.Insert;
        until PredictionBuffer.Next = 0;
        MapBuffer.SetRouteDetails(RouteDetail);
    end;

}