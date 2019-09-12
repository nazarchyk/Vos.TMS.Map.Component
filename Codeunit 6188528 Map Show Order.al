codeunit 6188528 "Map Show Order"
{
    TableNo = "Transport Order Line";
    trigger OnRun();
    var
        Shpmnt: Record "Shipment";
        RouteDetail: Record "Map Route Detail" temporary;
        MapBuffer: Codeunit "Map Buffer";
        Addr: Record Address;
    begin
        RouteDetail.DeleteAll;
        Shpmnt.SetRange("Transport Order No.", "Transport Order No.");
        Shpmnt.SetRange("Transport Order Line No.", "Line No.");
        Shpmnt.SetRange("Irr. No.", "Active Irregularity No.");
        Shpmnt.SetAutoCalcFields("Loading Meters");
        if Shpmnt.FindSet then repeat
            AddRoute(Shpmnt, RouteDetail);
            Addr.get(Shpmnt."From Address No.");
            AddMarker(Shpmnt, Addr, RouteDetail);
            until Shpmnt.Next = 0;

        Addr.get(Shpmnt."To Address No.");
        AddMarker(Shpmnt, Addr, RouteDetail);

        MapBuffer.SetRouteDetails(RouteDetail);

    end;

    local procedure AddRoute(Shpmnt: Record Shipment; var RouteDetail: Record "Map Route Detail")
    var
        Addr: Record Address;
    begin
        RouteDetail.Init;
        RouteDetail."Route No." := Shpmnt."Leg No." + 1;
        case Shpmnt."Lane Type" of
            Shpmnt."Lane Type"::Collection:
                RouteDetail.Color := Shpmnt.GetColor;
            Shpmnt."Lane Type"::Delivery:
                RouteDetail.Color := Shpmnt.GetColor;
            Shpmnt."Lane Type"::Direct:
                RouteDetail.Color := 'red';
            Shpmnt."Lane Type"::Linehaul:
                RouteDetail.Color := 'blue';
            Shpmnt."Lane Type"::"Post Delivery Agent":
                RouteDetail.Color := 'grey';
            Shpmnt."Lane Type"::"Pre Collection Agent":
                RouteDetail.Color := 'grey';
            Shpmnt."Lane Type"::Service:
                RouteDetail.Color := 'grey';
            Shpmnt."Lane Type"::"Temporary Collection":
                RouteDetail.Color := 'grey';
            Shpmnt."Lane Type"::"Temporary Delivery":
                RouteDetail.Color := 'grey';
        end;
        RouteDetail.Name := Format(Shpmnt."Lane Type");
        RouteDetail."Stop No." := 1;
        RouteDetail.Id := Shpmnt.Id;
        RouteDetail.Source := Shpmnt.TableName;
        Addr.Get(Shpmnt."From Address No.");
        RouteDetail.Latitude := Addr.Latitude;
        RouteDetail.Longitude := Addr.Longitude;
        RouteDetail.Type := RouteDetail.Type::Route;
        RouteDetail.Insert;

        RouteDetail."Stop No." := 2;
        RouteDetail.Id := Shpmnt.Id;
        RouteDetail.Source := Shpmnt.TableName;
        Addr.Get(Shpmnt."To Address No.");
        RouteDetail.Latitude := Addr.Latitude;
        RouteDetail.Longitude := Addr.Longitude;
        RouteDetail.Type := RouteDetail.Type::Route;
        RouteDetail.Insert;

    end;

    local procedure AddMarker(Shpmnt: Record Shipment; Addr: Record Address; var RouteDetail: Record "Map Route Detail")
    begin
        RouteDetail.SetRange("Route No.", 0);
        if RouteDetail.FindLast then
            RouteDetail."Stop No." += 1
        else
            RouteDetail."Stop No." := 1;
        RouteDetail.Init;
        RouteDetail."Route No." := 0;
        RouteDetail.Id := Shpmnt.Id;
        RouteDetail.Source := Shpmnt.TableName;
        RouteDetail."Marker Fill Color" := Shpmnt.GetColor;
        RouteDetail.Latitude := Addr.Latitude;
        RouteDetail.Color := 'blue';
        RouteDetail.Longitude := Addr.Longitude;
        RouteDetail."Marker Type" := RouteDetail."Marker Type"::Circle;
        if Shpmnt."Plan-ID" = UserId then
            RouteDetail.Selected := RouteDetail.Selected::Selected;
        RouteDetail.SetMarkerRadiusBasedOnLoadingMeters(Shpmnt."Loading Meters");
        RouteDetail.SetMarkerStrokeBasedOnSelected;
        RouteDetail."Marker Stroke With (Pixels)" := 1;
        RouteDetail."Pop Up" := Addr.Description;
        RouteDetail."Marker Text" := 'LM: ' + format(Shpmnt."Loading Meters") + ' ' + Addr.Description + ' ' + Addr.Street + ' ' + Addr."Post Code" + ' ' + Addr.City;
        RouteDetail.Insert;
        RouteDetail.Reset;
    end;
}