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
                var
                    ShowShipments: Codeunit "Map Show Shipments";
                begin
                    ShowShipments.Run(Rec);
                end;
            }
        }
    }
    
}