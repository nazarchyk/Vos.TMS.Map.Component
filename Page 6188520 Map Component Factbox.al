page 6188520 "Map Component Factbox"
{
    PageType = CardPart;

    layout
    {
        area(Content)
        {
            usercontrol(Map; Map)
            {
                ApplicationArea = All;

                trigger OnMapInit();
                begin
                    SetSettings;
                end;

                trigger ControlReady();
                begin
                    IsReady := true;
                    ShowRouteOnMap;
                    ShowMarkerOnMap;
                end;

                trigger OnRouteSelected(eventObject: JsonObject);
                begin
                    Message(format(eventObject));

                end;

                trigger OnMarkerClicked(eventObject: JsonObject); // Single Marker
                var
                    GetSelectedMarker: Codeunit "Map Get Selected Marker";
                begin
                    GetSelectedMarker.GetMarker(eventObject);
                    GetDataFromBuffer;
                    //CurrPage.Update(false);
                end;

                trigger OnMarkersSelected(eventObject: JsonArray); // Lasso
                var
                    GetSelectedMarker: Codeunit "Map Get Selected Marker";
                begin
                    GetSelectedMarker.GetMarkers(eventObject);
                    GetDataFromBuffer;
                end;

                trigger OnRouteVisibilityToggled(eventObject: JsonObject)
                begin
                    Message(format(eventObject));
                end;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Update)
            {
                Image = UpdateShipment;
                trigger OnAction();
                begin
                    GetDataFromBuffer;
                end;
            }
            action(MyTrucks)
            {
                Image = Travel;
                trigger OnAction();
                var
                    MapEquip: Codeunit "Map Equipment";
                begin
                    MapEquip.ShowMyTrucks;
                    GetDataFromBuffer;
                end;
            }
            action(OtherTrucks)
            {
                Image = InsertTravelFee;
                trigger OnAction();
                var
                    MapEquip: Codeunit "Map Equipment";
                begin
                    MapEquip.ShowTrucksFromPlanningCode;
                    GetDataFromBuffer;
                end;
            }
            action(Marker)
            {
                Image = Position;
                trigger OnAction();
                begin
                    ShowMarkerOnMap;
                end;
            }
            action(Route)
            {
                Image = "Grid";
                trigger OnAction();
                begin
                    ShowRouteOnMap;
                end;
            }
            action(Lasso)
            {
                Image = Map;
                Caption = 'Lasso';
                trigger OnAction();
                begin
                    EnableLasso;
                    GetDataFromBuffer;
                    CurrPage.Update(false);
                end;
            }
            action(SelectForPlanning)
            {
                Image = SelectEntries;
                Caption = 'Select';
                trigger OnAction();
                var
                    ShowShipment: Codeunit "Map Show Shipments";
                begin
                    ShowShipment.SelectShipments;
                    GetDataFromBuffer;
                    CurrPage.Update(false);
                end;
            }
            action(UnSelectForPlanning)
            {
                Image = UnApply;
                Caption = 'Unselect';
                trigger OnAction();
                var
                    ShowShipment: Codeunit "Map Show Shipments";
                begin
                    ShowShipment.DeSelectShipments;
                    GetDataFromBuffer;
                    CurrPage.Update(false);
                end;
            }
            action(Clear)
            {
                Image = ClearLog;
                trigger OnAction();
                begin
                    ClearMap;
                end;
            }
            action("Toggle Selected Only")
            {
                Image = SelectItemSubstitution;
                trigger OnAction();
                var
                    MapBuffer: Codeunit "Map Buffer";
                    RouteDetail: Record "Map Route Detail" temporary;
                begin
                    MapBuffer.GetRouteDetails(RouteDetail);
                    if RouteDetail.GetFilter(Selected) = '' then
                        RouteDetail.SetRange(Selected, RouteDetail.Selected::Clicked, RouteDetail.Selected::Selected)
                    else
                        RouteDetail.SetRange(Selected);
                    MapBuffer.SetRouteDetails(RouteDetail);
                    GetDataFromBuffer;
                        
                end;
            }

            action("Enable heatmap")
            {
                Image = Approve;
                trigger OnAction();
                begin
                    EnableHeatmap;
                end;
            }

            action("Update heatmap")
            {
                Image = UpdateDescription;
                trigger OnAction();
                begin
                    UpdateHeatmap;
                end;
            }

            action("Disable heatmap")
            {
                Image = UnApply;
                trigger OnAction();
                begin
                    DisableHeatmap;
                end;
            }
        }
    }

    local procedure ShowMarkerOnMap();
    var
        RouteDetail: Record "Map Route Detail" temporary;
        MapBuffer: Codeunit "Map Buffer";
    begin
        MapBuffer.GetRouteDetails(RouteDetail);
        RouteDetail.SetRange(Type, RouteDetail.Type::Markers);
        if RouteDetail.findset then repeat
            if RouteDetail."Marker Type" = RouteDetail."Marker Type"::Icon then
                CurrPage.Map.ShowIconMarker(RouteDetail.ShowMarker(IsReady))
            else
                CurrPage.Map.ShowCircleMarker(RouteDetail.ShowMarker(IsReady));
        until RouteDetail.next = 0;
    end;

    local procedure ShowRouteOnMap();
    var
        Route: Record "Map Route" temporary;
        MapBuffer: Codeunit "Map Buffer";
    begin
        if not IsReady then
            exit;
        MapBuffer.GetRoutes(Route);
        Route.SetRange("No.", 1, 99);
        if Route.FindSet then repeat
            CurrPage.Map.ShowRoute(Route.ShowRoute);
        until Route.Next = 0;
    end;

    local procedure ClearMap();
    begin
        CurrPage.Map.ClearMap();
    end;

    local procedure SetSettings();
    var
        MapSettings: Codeunit "Map Settings";
    begin
        CurrPage.Map.SetSettings(MapSettings.SetSettings);
    end;

    local procedure EnableLasso()
    begin
        if not IsReady then
            exit;
        CurrPage.Map.EnableLasso();
    end;

    local procedure EnableHeatmap()
    begin
        if not IsReady then
            exit;
        CurrPage.Map.EnableHeatmap();
    end;

    local procedure UpdateHeatmap()
    begin
        if not IsReady then
            exit;
        CurrPage.Map.UpdateHeatmap();
    end;

    local procedure DisableHeatmap()
    begin
        if not IsReady then
            exit;
        CurrPage.Map.DisableHeatmap();
    end;

    procedure GetDataFromBuffer();
    var
        MapBuffer: Codeunit "Map Buffer";
    begin
        ClearMap;
        if not IsReady then
            exit;
        ShowMarkerOnMap;
        ShowRouteOnMap;
    end;

    var
        IsReady: Boolean;
}