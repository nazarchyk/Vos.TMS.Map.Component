pageextension 80150 "Planview Shipment (Map)" extends "Planview Shipments"
{
    layout
    {
        addbefore(TableShip)
        {
            part(Map; "Map Component Factbox") { }
            part(MapDetails; "Map Route Factbox") { Visible = false; }
        }
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
                    UpdateMap;
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord();
    begin
        if FiltersChanged then
            UpdateMap;
    end;

    procedure UpdateMap();
    var
        ShowShipments: Codeunit "Map Show Shipments";
    begin
        ShowShipments.Run(Rec);
        CurrPage.Map.Page.GetDataFromBuffer;
    end;

    procedure FiltersChanged(): Boolean
    begin
        if GetFilters = xFilters then
            exit(false);
        xFilters := GetFilters;
        exit(true);
    end;

    var
        xFilters: Text;


}