pageextension 80101 "Consultation (Map)" extends "TX Tango Consultation"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(Map; "Map Component Factbox") { }
        }
    }

    trigger OnAfterGetCurrRecord();
    var
        MapRoute: Record "Map Route" temporary;
    begin
        GetRouteForConsultation("Trip No.", MapRoute);
        CurrPage.Map.Page.SetData(MapRoute);
        CurrPage.Map.Page.ClearMap;
        CurrPage.Map.Page.ShowRoute;
    end;
        procedure GetRouteForConsultation(TripNo: code[20]; var MapRoute: Record "Map Route")
    var
        Consultation: Record "TX Tango Consultation";
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
    end;
}