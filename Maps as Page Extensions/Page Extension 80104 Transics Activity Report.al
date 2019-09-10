pageextension 80104 "Act. Report (Map)" extends "Transics Activity Report"
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
        GetRouteForActivityReport("Trip No.", RouteDetails);
        RouteDetails.ToBuffer;
        CurrPage.Map.Page.GetDataFromBuffer;
        CurrPage.Map.Page.Update;
    end;

    procedure GetRouteForActivityReport(TripNo: code[20]; var RouteDetails: Record "Map Route Detail")
    var
        ActReport: Record "Transics Activity Report";
        Trip: Record Trip;
        xTruckNo: Code[20];
        i: Integer;
    begin
        RouteDetails.DeleteAll;
        ActReport.SetCurrentKey("Trip No.", BeginDate);
        ActReport.SetRange("Trip No.", TripNo);
        ActReport.SetFilter(Latitude, '<>0');
        ActReport.SetFilter(Longitude, '<>0');
        if ActReport.FindSet then repeat
        RouteDetails.init;
            if ActReport.VehicleID <> xTruckNo then begin
                RouteDetails."Route No." += 1;
                xTruckNo := ActReport.VehicleID;
            end;
            RouteDetails."Stop No." += 1;
            case RouteDetails."Route No." of
1 :
                RouteDetails.Color := 'Red';
2 :
                RouteDetails.Color := 'Blue';
3 :
                RouteDetails.Color := 'Green';
4 :
                RouteDetails.Color := 'Black';
            end;
            RouteDetails.Longitude := ActReport.Longitude;
            RouteDetails.Latitude := ActReport.Latitude;
            RouteDetails.Insert;
            until ActReport.Next = 0;
    end;
}