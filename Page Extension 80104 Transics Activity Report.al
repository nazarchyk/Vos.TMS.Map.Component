pageextension 80104 "Act. Report (Map)" extends "Transics Activity Report"
{
    layout
    {
        // Add changes to page layout here
        addfirst(FactBoxes)
        {
            part(Map; "Map Component Factbox")
            {
            }

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
        GetRouteForActivityReport("Trip No.", MapRoute);
        CurrPage.Map.Page.SetData(MapRoute);
        CurrPage.Map.Page.ClearMap;
    end;

    procedure GetRouteForActivityReport(TripNo: code[20]; var MapRoute: Record "Map Route")
    var
        ActReport: Record "Transics Activity Report";
        Trip: Record Trip;
        xTruckNo: Code[20];
        i: Integer;
    begin
        MapRoute.DeleteAll;
        ActReport.SetCurrentKey("Trip No.", BeginDate);
        ActReport.SetRange("Trip No.", TripNo);
        ActReport.SetFilter(Latitude, '<>0');
        ActReport.SetFilter(Longitude, '<>0');
        if ActReport.FindSet then repeat
        MapRoute.init;
            if ActReport.VehicleID <> xTruckNo then begin
                MapRoute."Route No." += 1;
                xTruckNo := ActReport.VehicleID;
            end;
            MapRoute."Stop No." += 1;
            case MapRoute."Route No." of
1 :
                MapRoute.Color := 'Red';
2 :
                MapRoute.Color := 'Blue';
3 :
                MapRoute.Color := 'Green';
4 :
                MapRoute.Color := 'Black';
            end;
            MapRoute.Longitude := ActReport.Longitude;
            MapRoute.Latitude := ActReport.Latitude;
            MapRoute.Insert;
            until ActReport.Next = 0;
    end;
}