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
     //   Route : Record "Map Route" temporary;
        RouteDetails: Record "Map Route Detail" temporary;
        MapBuffer: Codeunit "Map Buffer";
        Addr: Record Address;
    begin
        RouteDetails.DeleteAll;
        Shpmnt.CopyFilters(Rec);
        if Shpmnt.FindSet then repeat        
            Addr.get(Shpmnt."To Address No.");
            RouteDetails."Route No." := 0;
            RouteDetails."Stop No." += 1;
            RouteDetails.Latitude := Addr.Latitude;
            RouteDetails.Longitude := Addr.Longitude;
            RouteDetails."Marker Type" := RouteDetails."Marker Type"::Circle;
            RouteDetails."Marker Fill Color" := 'blue';
            //Error(Format("Payable Weight (Order)"));
            if Shpmnt."Payable Weight (Order)" >= 25000 then
                RouteDetails."Marker Radius" := 25
            else if Shpmnt."Payable Weight (Order)" >= 10000 then 
                RouteDetails."Marker Radius" := 20
            else if Shpmnt."Payable Weight (Order)" >= 5000 then
                 RouteDetails."Marker Radius" := 15
            else
                RouteDetails."Marker Radius" := 10;
//MapRoute."Marker Radius" := round("Payable Weight (Order)", 1);
            RouteDetails."Marker Text" := Addr.Description + ' ' + Addr.Street + ' ' + Addr."Post Code" + ' ' + Addr.City; 
            RouteDetails.Insert;Commit;
        until Shpmnt.Next = 0;
        
        MapBuffer.SetRouteDetails(RouteDetails);
    end;
}