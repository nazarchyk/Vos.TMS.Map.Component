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
        Shpmnt.SetAutoCalcFields("Loading Meters");
        if Shpmnt.FindSet then repeat
            RouteDetails."Route No." := 0;
            RouteDetails.Name := "Route No.";
            RouteDetails."Stop No." += 1;
            RouteDetails.Id := Id;
            RouteDetails.Source := TableName;
            if Shpmnt."Lane Type" = Shpmnt."Lane Type"::Collection then begin
                Addr.get(Shpmnt."From Address No.");
                //error(format(Addr));
                RouteDetails."Marker Fill Color" := 'red';
            end else if Shpmnt."Lane Type" = Shpmnt."Lane Type"::Delivery then begin
                Addr.get(Shpmnt."To Address No.");
                RouteDetails."Marker Fill Color" := 'blue';
            end;
            RouteDetails.Latitude := Addr.Latitude;
            RouteDetails.Longitude := Addr.Longitude;
            RouteDetails."Marker Type" := RouteDetails."Marker Type"::Circle;
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
            RouteDetails."Marker Text" := 'LM: ' + format(Shpmnt."Loading Meters") + ' ' + Addr.Description + ' ' + Addr.Street + ' ' + Addr."Post Code" + ' ' + Addr.City; 
            RouteDetails.Insert;
        until Shpmnt.Next = 0;
        
        MapBuffer.SetRouteDetails(RouteDetails);
    end;
}