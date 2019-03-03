pageextension 80107 "Trip Card (Map)" extends "Trip Card"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(Map; "Map Component Factbox") { Visible = false; }
        }
    }
    trigger OnAfterGetCurrRecord();
    var
        MapRoute: Record "Map Route" temporary;
    begin
        GetRouteForTrip("No.", MapRoute);
        CurrPage.Map.Page.SetData(MapRoute);
    end;

    procedure GetRouteForTrip(TripNo: code[20]; var MapRoute: Record "Map Route")
    var
        Consultation: Record "TX Tango Consultation";
        TrPlanAct: Record "Transport Planned Activity";
        Address: Record Address;
        Trip: Record Trip;
        i: Integer;
    begin
        MapRoute.DeleteAll;
        Consultation.SetCurrentKey("Trip No.", "Arrival Date");
        Consultation.SetRange("Trip No.", TripNo);
        if Consultation.FindSet then repeat
        MapRoute.init;
            MapRoute."Route No." := 1;
            MapRoute."Stop No." += 1;
            MapRoute.Color := 'Red';
            MapRoute.Longitude := Consultation.Longitude;
            MapRoute.Latitude := Consultation.Latitude;
            MapRoute.Insert;
            until Consultation.Next = 0;

        MapRoute."Stop No." := 0;
        TrPlanAct.SetCurrentKey("Trip No.", "Stop No.");
        TrPlanAct.SetFilter("Address No.", '<>%1', '');
        TrPlanAct.SetRange("Trip No.", TripNo);
        if TrPlanAct.FindSet then repeat
        Address.get(TrPlanAct."Address No.");
            MapRoute.init;
            MapRoute."Route No." := 2;
            MapRoute."Stop No." += 1;
            MapRoute.Color := 'Blue';
            MapRoute.Longitude := Address.Longitude;
            MapRoute.Latitude := Address.Latitude;
            MapRoute.Insert;
            until TrPlanAct.Next = 0;
    end;

}
