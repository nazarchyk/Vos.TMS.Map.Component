pageextension 80101 "Consultation (Map)" extends "TX Tango Consultation"
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
        RouteDetails: Record "Map Route Detail" temporary;
    begin
        GetRouteForConsultation("Trip No.", RouteDetails);
        RouteDetails.ToBuffer;
        CurrPage.Map.Page.SetData;
        CurrPage.Map.Page.ClearMap;
        CurrPage.Map.Page.ShowRouteOnMap;
    end;

    procedure GetRouteForConsultation(TripNo: code[20]; var RouteDetails: Record "Map Route Detail")
    var
        Consultation: Record "TX Tango Consultation";
        Trip: Record Trip;
        i: Integer;
    begin
        RouteDetails.DeleteAll;
        Consultation.SetCurrentKey("Trip No.", "Arrival Date");
        Consultation.SetRange("Trip No.", TripNo);
        if Consultation.FindSet then repeat
        RouteDetails.init;
            RouteDetails."Route No." := 1;
            RouteDetails."Stop No." += 1;
            RouteDetails.Color := 'Red';
            RouteDetails.Longitude := Consultation.Longitude;
            RouteDetails.Latitude := Consultation.Latitude;
            RouteDetails.Insert;
            until Consultation.Next = 0;
    end;
}