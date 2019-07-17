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
                Visible = false;
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
        i: Integer;
    begin
        Trip.CopyFilters(Rec);
        if Trip.FindSet then repeat
            GetRouteForTrip(Trip, i);
        until Trip.Next = 0;      
    end;

    local procedure GetRouteForTrip(Trip: Record Trip; var n: Integer)
    var
        RouteDetails: Record "Map Route Detail" temporary;
        Consultation: Record "TX Tango Consultation";
        TrPlanAct: Record "Transport Planned Activity";
        Address: Record Address;
        MapBuffer: Codeunit "Map Buffer";
        i: Integer;
    begin
        n += 1;
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

        RouteDetails."Stop No." := 0;
        TrPlanAct.SetCurrentKey("Trip No.", "Stop No.");
        TrPlanAct.SetFilter("Address No.", '<>%1', '');
        TrPlanAct.SetRange("Trip No.", Trip."No.");
        if TrPlanAct.FindSet then repeat
            Address.get(TrPlanAct."Address No.");
            RouteDetails.init;
            RouteDetails.Name := trip."No.";
            RouteDetails."Route No." := n;
            RouteDetails."Stop No." += 1;
            RouteDetails.Color := 'Blue';
            RouteDetails.Longitude := Address.Longitude;
            RouteDetails.Latitude := Address.Latitude;
            RouteDetails.Insert;
        until TrPlanAct.Next = 0;
        MapBuffer.SetRouteDetails(RouteDetails);
    end;


}