pageextension 80150 "Planview Shipment (Map)" extends "Planview Shipments"
{
    layout
    {
        // Add changes to page layout here
    }

    actions
    {
        addfirst(Processing)
        {
            action(ShowOnMap)
            {
                Image = Map;
                Visible = false;
                trigger OnAction();
                begin
                    AddToMap;
                end;
            }
        }
    }
    
    local procedure AddToMap();
    var
        Shpmnt: Record Shipment;
        MapRoute: Record "Map Route" temporary;
        MapBuffer: Codeunit "Map Buffer";
        Addr: Record Address;
    begin
        Shpmnt.CopyFilters(Rec);
        if Shpmnt.FindSet then repeat        
            Addr.get(Shpmnt."To Address No.");
            MapRoute."Route No." := 0;
            MapRoute."Stop No." += 1;
            MapRoute.Latitude := Addr.Latitude;
            MapRoute.Longitude := Addr.Longitude;
            MapRoute."Marker Text" := Addr.Description + ' ' + Addr.Street + ' ' + Addr."Post Code" + ' ' + Addr.City; 
            MapRoute.Insert;
        until Shpmnt.Next = 0;
        
        MapBuffer.SetData(MapRoute);
    end;
}