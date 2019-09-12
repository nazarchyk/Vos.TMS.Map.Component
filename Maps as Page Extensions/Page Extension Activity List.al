pageextension 6188520 "Activity List (Map)" extends "Transport Activity List"
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
        RouteDetails: Record "Map Route Detail" temporary;
    begin
        GetRouteForActivities("Trip No.", RouteDetails);
        RouteDetails.ToBuffer;
        CurrPage.Map.Page.GetDataFromBuffer;
        CurrPage.Map.Page.Update;
    end;

    procedure GetRouteForActivities(TripNo: code[20]; var RouteDetails: Record "Map Route Detail")
    var
        TrPlanAct: Record "Transport Planned Activity";
        Address: Record Address;
        Trip: Record Trip;
        i: Integer;
    begin
        RouteDetails.DeleteAll;

        RouteDetails."Stop No." := 0;
        TrPlanAct.SetCurrentKey("Trip No.", "Stop No.");
        TrPlanAct.SetFilter("Address No.", '<>%1', '');
        TrPlanAct.SetRange("Trip No.", TripNo);
        if TrPlanAct.FindSet then repeat
        Address.get(TrPlanAct."Address No.");
            RouteDetails.init;
            RouteDetails."Route No." := 1;
            RouteDetails."Stop No." += 1;
            RouteDetails.Color := 'Blue';
            RouteDetails.Longitude := Address.Longitude;
            RouteDetails.Latitude := Address.Latitude;
            RouteDetails.Insert;
            until TrPlanAct.Next = 0;
    end;

}