pageextension 80105 "Transport Order Ln. Card (Map)" extends "Transport Order Line Card"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(Map; "Map Component Factbox")
            {
            }
        }
    }
    trigger OnAfterGetCurrRecord();
    var
        MapRoute: Record "Map Route" temporary;
        Shpmnt: Record Shipment;
        Addr: Record Address;
    begin
        Shpmnt.SetRange("Transport Order No.", "Transport Order No.");
        Shpmnt.SetRange("Transport Order Line No.", "Line No.");
        Shpmnt.SetRange("Irr. No.", "Active Irregularity No.");
        if Shpmnt.FindSet then repeat        
            Addr.get(Shpmnt."From Address No.");
            MapRoute."Route No." := 1;
            MapRoute."Stop No." += 1;
            MapRoute.Latitude := Addr.Latitude;
            MapRoute.Longitude := Addr.Longitude;
            MapRoute."Marker Text" := Addr.Description + ' ' + Addr.Street + ' ' + Addr."Post Code" + ' ' + Addr.City; 
            MapRoute.Insert;
        until Shpmnt.Next = 0;
        if not Addr.get("To Address No.") then
            exit;
        MapRoute."Route No." := 1;
        MapRoute."Stop No." += 1;
        MapRoute.Latitude := Addr.Latitude;
        MapRoute.Longitude := Addr.Longitude;
        MapRoute."Marker Text" := Addr.Description + ' ' + Addr.Street + ' ' + Addr."Post Code" + ' ' + Addr.City; 
        MapRoute.Insert;
        CurrPage.Map.Page.ClearMap;
        CurrPage.Map.Page.setData(MapRoute);
        
    end;
}
