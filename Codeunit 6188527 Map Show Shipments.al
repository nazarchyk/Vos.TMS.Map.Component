codeunit 6188527 "Map Show Shipments"
{
    TableNo = Shipment;
    trigger OnRun();
    var
        Shpmnt: Record Shipment;
        //   Route : Record "Map Route" temporary;
        RouteDetail: Record "Map Route Detail" temporary;
        MapBuffer: Codeunit "Map Buffer";
        Addr: Record Address;
    begin
        RouteDetail.DeleteAll;
        Shpmnt.CopyFilters(Rec);
        Shpmnt.SetAutoCalcFields("Loading Meters");
        if Shpmnt.FindSet then repeat
            RouteDetail."Route No." := 0;
            RouteDetail.Name := "Route No.";
            RouteDetail."Stop No." += 1;
            RouteDetail.Id := Shpmnt.Id;
            RouteDetail.Source := TableName;
            if Shpmnt."Lane Type" = Shpmnt."Lane Type"::Collection then begin
                Addr.get(Shpmnt."From Address No.");
                //error(format(Addr));
                RouteDetail."Marker Fill Color" := 'red';
            end else if Shpmnt."Lane Type" = Shpmnt."Lane Type"::Delivery then begin
                    Addr.get(Shpmnt."To Address No.");
                    RouteDetail."Marker Fill Color" := 'blue';
                end;
            RouteDetail.Latitude := Addr.Latitude;
            RouteDetail.Longitude := Addr.Longitude;
            RouteDetail."Marker Type" := RouteDetail."Marker Type"::Circle;
            RouteDetail.SetMarkerRadiusBasedOnLoadingMeters(Shpmnt."Loading Meters");
            RouteDetail.SetMarkerStrokeBasedOnSelected;
            RouteDetail."Marker Text" := 'LM: ' + format(Shpmnt."Loading Meters") + ' ' + Addr.Description + ' ' + Addr.Street + ' ' + Addr."Post Code" + ' ' + Addr.City;
            RouteDetail.Insert;
            until Shpmnt.Next = 0;

        MapBuffer.SetRouteDetails(RouteDetail);
    end;

    procedure SelectShipments()
    var
        RouteDetail: Record "Map Route Detail" temporary;
        MapBuffer: Codeunit "Map Buffer";
    begin
        MapBuffer.GetRouteDetails(RouteDetail);
        RouteDetail.SetRange(Selected, RouteDetail.Selected::Clicked);
        RouteDetail.FindSet;
        repeat
            RouteDetail.SelectShipment;
        RouteDetail.Modify;
        until RouteDetail.Next = 0;
        MapBuffer.SetRouteDetails(RouteDetail);

    end;

    procedure DeSelectShipments()
    var
        RouteDetail: Record "Map Route Detail" temporary;
        MapBuffer: Codeunit "Map Buffer";
    begin
        MapBuffer.GetRouteDetails(RouteDetail);
        RouteDetail.SetRange(Selected, RouteDetail.Selected::Selected);
        RouteDetail.FindSet;
        repeat
        RouteDetail.SelectShipment;
        RouteDetail.Modify;
        until RouteDetail.Next = 0;
        MapBuffer.SetRouteDetails(RouteDetail);

    end;
}