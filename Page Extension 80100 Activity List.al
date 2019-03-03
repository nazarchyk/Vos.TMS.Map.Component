pageextension 80100 "Activity List (Map)" extends "Transport Activity List"
{
    layout
    {
        // Add changes to page layout here
        addfirst(FactBoxes)
        {
            part(Map; "Map Component Factbox") { Visible = false; }

        }
    }

    actions
    {
        // Add changes to page actions here
    }
    trigger OnAfterGetCurrRecord();
    var
        MapRoute: Record "Map Route" temporary;
    begin
        GetRouteForActivities("Trip No.", MapRoute);
        CurrPage.Map.Page.SetData(MapRoute);
        CurrPage.Map.Page.ClearMap;
        CurrPage.Map.Page.ShowRoute;
    end;

    procedure GetRouteForActivities(TripNo: code[20]; var MapRoute: Record "Map Route")
    var
        TrPlanAct: Record "Transport Planned Activity";
        Address: Record Address;
        Trip: Record Trip;
        i: Integer;
    begin
        MapRoute.DeleteAll;

        MapRoute."Stop No." := 0;
        TrPlanAct.SetCurrentKey("Trip No.", "Stop No.");
        TrPlanAct.SetFilter("Address No.", '<>%1', '');
        TrPlanAct.SetRange("Trip No.", TripNo);
        if TrPlanAct.FindSet then repeat
        Address.get(TrPlanAct."Address No.");
            MapRoute.init;
            MapRoute."Route No." := 1;
            MapRoute."Stop No." += 1;
            MapRoute.Color := 'Blue';
            MapRoute.Longitude := Address.Longitude;
            MapRoute.Latitude := Address.Latitude;
            MapRoute.Insert;
            until TrPlanAct.Next = 0;
    end;

}