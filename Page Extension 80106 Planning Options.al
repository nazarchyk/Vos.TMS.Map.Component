pageextension 80106 "Planning Options (Map)" extends "Planning Options"

{
    layout
    {
        addlast(Content)
        {
            part(Map; "Map Component Factbox") { Visible = false; }
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
            RouteDetails."Route No." := 1;
            RouteDetails."Stop No." += 1;
            RouteDetails.Latitude := Addr.Latitude;
            RouteDetails.Longitude := Addr.Longitude;
            RouteDetails."Marker Text" := Addr.Description + ' ' + Addr.Street + ' ' + Addr."Post Code" + ' ' + Addr.City;
            RouteDetails.Insert;
            until Shpmnt.Next = 0;
        Addr.get("To Address No.");
        RouteDetails."Route No." := 1;
        RouteDetails."Stop No." += 1;
        RouteDetails.Latitude := Addr.Latitude;
        RouteDetails.Longitude := Addr.Longitude;
        RouteDetails."Marker Text" := Addr.Description + ' ' + Addr.Street + ' ' + Addr."Post Code" + ' ' + Addr.City;
        RouteDetails.Insert;
        CurrPage.Map.Page.ClearMap;
        RouteDetails.ToBuffer;

        CurrPage.Map.Page.setData;
    end;
}
