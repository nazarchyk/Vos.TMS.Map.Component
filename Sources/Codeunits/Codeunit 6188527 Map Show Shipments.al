codeunit 6188527 "Map Show Shipments"
{
    procedure ConvertShipmentsToMapContent(var Shipment: Record Shipment; var RouteDetail: Record "Map Route Detail")
    var
        Address: Record Address;
    begin
        Shipment.SetAutoCalcFields("Loading Meters");
        if Shipment.FindSet() then
            repeat
                RouteDetail.Init();
                RouteDetail."Route No." := 0;
                RouteDetail.Name := Shipment."Route No.";
                RouteDetail."Stop No." += 1;
                RouteDetail.Id := Shipment.Id;
                RouteDetail.Source := Shipment.TableName;

                case Shipment."Lane Type" of
                    Shipment."Lane Type"::Collection:
                        Address.get(Shipment."From Address No.");

                    Shipment."Lane Type"::Delivery:
                        Address.get(Shipment."To Address No.");
                end;

                RouteDetail."Marker Fill Color" := Shipment.GetColor();
                RouteDetail.Latitude := Address.Latitude;
                RouteDetail.Longitude := Address.Longitude;
                RouteDetail."Marker Type" := RouteDetail."Marker Type"::Circle;
                if Shipment."Plan-ID" = UserId then
                    RouteDetail.Selected := RouteDetail.Selected::Selected;

                RouteDetail.SetMarkerRadiusBasedOnLoadingMeters(Shipment."Loading Meters");
                RouteDetail.SetMarkerStrokeBasedOnSelected();
                RouteDetail."Marker Text" := 'LM: ' + format(Shipment."Loading Meters") + ' ' +
                    Address.Description + ' ' + Address.Street + ' ' + Address."Post Code" + ' ' + Address.City;

                RouteDetail.Insert();
            until (Shipment.Next() = 0);
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
        RouteDetail.Reset;
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
        RouteDetail.Reset;
        MapBuffer.SetRouteDetails(RouteDetail);
    end;
}