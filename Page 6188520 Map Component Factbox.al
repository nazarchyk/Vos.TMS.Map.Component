page 6188520 "Map Component Factbox"
{
    PageType = CardPart;
    SourceTable = "Map Route Detail";
    SourceTableTemporary = true;

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

                trigger OnMarkerClicked(eventObject: JsonObject);
                var
                    GetSelectedMarker: Codeunit "Map Get Selected Marker";
                begin
                    GetSelectedMarker.GetMarker(eventObject);
                    ClearMap;
                    GetDataFromBuffer;
                end;

                trigger OnMarkersSelected(eventObject: JsonArray);
                var
                    GetSelectedMarker: Codeunit "Map Get Selected Marker";
                begin
                    GetSelectedMarker.GetMarkers(eventObject);
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
            action(Select)
            {
                Image = Map;
                trigger OnAction();
                begin
                    EnableLasso;
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
    procedure SetData()
    var
        RouteDetails: Record "Map Route Detail" temporary;
        MapBuffer: Codeunit "Map Buffer";
    begin
        MapBuffer.GetRouteDetails(RouteDetails);
        Rec.Copy(RouteDetails, true);
    end;

    procedure ShowMarkerOnMap();
    begin
        if IsReady then
            if findset then repeat
                if "Marker Type" = "Marker Type"::Icon then
                    CurrPage.Map.ShowIconMarker(ShowMarker(IsReady))
                else
                    CurrPage.Map.ShowCircleMarker(ShowMarker(IsReady));
                until next = 0;
    end;

    procedure ShowRouteOnMap();
    var
        Route: Record "Map Route" temporary;
    begin
        if not IsReady then
            exit;
        GetRoutes(Route);
        Route.SetRange("No.", 1, 99);
        if Route.FindSet then repeat
            CurrPage.Map.ShowRoute(Route.ShowRoute);
            until Route.Next = 0;
    end;

    procedure ClearMap();
    begin
        if IsReady then
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
        MapBuffer.GetRouteDetails(Rec);
        ShowMarkerOnMap;
        ShowRouteOnMap;
    end;

    var
        IsReady: Boolean;
}