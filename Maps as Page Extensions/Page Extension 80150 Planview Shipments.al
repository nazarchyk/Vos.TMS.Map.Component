pageextension 80150 "Planview Shipment (Map)" extends "Planview Shipments"
{
    layout
    {
        addbefore(TableShip)
        {
            part(Map; "Map Component Factbox") { Visible = MapVisible; UpdatePropagation = Both; }
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
                    MapVisible := not MapVisible;
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord();
    begin
        GetShpmntBuffer(ShpmntBuffer);
        AddSelectedShpmntsToMap;
        if FiltersChanged then
            UpdateMap;
    end;

    trigger OnOpenPage();
    var
        MapBuffer: Codeunit "Map Buffer";
    begin
        MapBuffer.ClearAll;
        MapVisible := true;
    end;

    local procedure AddSelectedShpmntsToMap()
    var
        MapBuffer: Codeunit "Map Buffer";
        RouteDetail: Record "Map Route Detail" temporary;
    begin
        MapBuffer.GetRouteDetails(RouteDetail);
        if ShpmntBuffer.FindSet then repeat
            RouteDetail.SetRange(Id, ShpmntBuffer.Id);
            if RouteDetail.FindFirst then begin
                if ShpmntBuffer."Plan-ID" = '' then
                    RouteDetail.Selected := RouteDetail.Selected::Clicked
                else
                    RouteDetail.Selected := RouteDetail.Selected::Selected;
                RouteDetail.SetMarkerStrokeBasedOnSelected;
                RouteDetail.Modify;
            end;
        until ShpmntBuffer.Next = 0;
        RouteDetail.Reset;
        MapBuffer.SetRouteDetails(RouteDetail);
        CurrPage.Map.Page.GetDataFromBuffer;
    end;

    local procedure UpdateMap();
    var
        ShowShipments: Codeunit "Map Show Shipments";
    begin
        ShowShipments.Run(Rec);
        CurrPage.Map.Page.GetDataFromBuffer;
    end;

    local procedure FiltersChanged(): Boolean
    begin
        if GetFilters = xFilters then
            exit(false);
        xFilters := GetFilters;
        exit(true);
    end;

    var
        ShpmntBuffer: Record Shipment temporary;
        xFilters: Text;
        MapVisible: Boolean;

}