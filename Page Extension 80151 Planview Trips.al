pageextension 80151 "Planview Trips (Map)" extends "Planview Trips"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addfirst(Processing)
        {
            action(ShowOnMap)
            {
                Image = Map;
                trigger OnAction();
                begin
                    AddToMap;
                end;
            }
        }
    }

    local procedure AddToMap();
    var
        Trip: Record Trip;
        MapRoute: Record "Map Route" temporary;
        MapBuffer: Codeunit "Map Buffer";
        i: Integer;
    begin
        Trip.CopyFilters(Rec);
        if Trip.FindSet then repeat
            i += 1;
            GetRouteForTrip(Trip, MapRoute, i);
            until Trip.Next = 0;

        MapBuffer.SetData(MapRoute);
    end;

    local procedure GetRouteForTrip(Trip: Record Trip; var MapRoute: Record "Map Route"; var n: Integer)
    var
        Consultation: Record "TX Tango Consultation";
        TrPlanAct: Record "Transport Planned Activity";
        Address: Record Address;
        i: Integer;
    begin
        // Consultation.SetCurrentKey("Trip No.", "Arrival Date");
        // Consultation.SetRange("Trip No.", Trip."No.");
        // if Consultation.FindSet then repeat
        //     MapRoute.init;
        //     MapRoute."Route No." := n;
        //     MapRoute."Stop No." += 1;
        //     MapRoute.Color := 'Red';
        //     MapRoute.Longitude := Consultation.Longitude;
        //     MapRoute.Latitude := Consultation.Latitude;
        //     MapRoute.Insert;
        //     until Consultation.Next = 0;

        MapRoute."Stop No." := 0;
        TrPlanAct.SetCurrentKey("Trip No.", "Stop No.");
        TrPlanAct.SetFilter("Address No.", '<>%1', '');
        TrPlanAct.SetRange("Trip No.", Trip."No.");
        if TrPlanAct.FindSet then repeat
            Address.get(TrPlanAct."Address No.");
            MapRoute.init;
            MapRoute.Name := trip."No.";
            MapRoute."Route No." := n;
            MapRoute."Stop No." += 1;
            MapRoute.Color := 'Blue';
            MapRoute.Longitude := Address.Longitude;
            MapRoute.Latitude := Address.Latitude;
            MapRoute.Insert;
        until TrPlanAct.Next = 0;
    end;


}