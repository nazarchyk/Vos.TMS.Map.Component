pageextension 6188525 "Transport Order Ln. Card (Map)" extends "Transport Order Line Card"
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
        Route: Record "Map Route" temporary;
        RouteDetails: Record "Map Route Detail" temporary;
        Shpmnt: Record Shipment;
        Addr: Record Address;
    begin
        Shpmnt.SetRange("Transport Order No.", "Transport Order No.");
        Shpmnt.SetRange("Transport Order Line No.", "Line No.");
        Shpmnt.SetRange("Irr. No.", "Active Irregularity No.");
        if Shpmnt.FindSet then repeat
            Addr.get(Shpmnt."From Address No.");
            RouteDetails."Marker Type" := RouteDetails."Marker Type"::Circle;
            RouteDetails."Route No." := 1;
            RouteDetails."Stop No." += 1;
            RouteDetails.Latitude := Addr.Latitude;
            RouteDetails.Longitude := Addr.Longitude;
            RouteDetails."Pop Up" := 'Popup';
            RouteDetails."Marker Text" := Addr.Description + ' ' + Addr.Street + ' ' + Addr."Post Code" + ' ' + Addr.City;
            RouteDetails.Insert;
            until Shpmnt.Next = 0;
        if not Addr.get("To Address No.") then
            exit;
        RouteDetails."Route No." := 1;
        RouteDetails."Stop No." += 1;
        RouteDetails.Latitude := Addr.Latitude;
        RouteDetails.Longitude := Addr.Longitude;
        RouteDetails."Marker Text" := Addr.Description + ' ' + Addr.Street + ' ' + Addr."Post Code" + ' ' + Addr.City;
        RouteDetails.Insert;
        RouteDetails.ToBuffer;
        CurrPage.Map.Page.GetDataFromBuffer;
        CurrPage.Map.Page.Update;
    end;
}
