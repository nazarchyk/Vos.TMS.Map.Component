page 6188521 "Map Component Full Page"
{
    PageType = Card;
    SourceTable = "Map Route Detail";
    SourceTableTemporary = true;
    UsageCategory = Documents;

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
                begin
                    Message(format(eventObject));
                end;

                trigger OnMarkersSelected(eventObject: JsonArray);
                begin
                    Message(format(eventObject));

                end;

                trigger OnRouteVisibilityToggled(eventObject: JsonObject)
                begin
                    Message(format(eventObject));

                end;
            }
        }
        area(FactBoxes)
        {
                   
            part(MapDetails;"Map Route Factbox") {}
            part(MapBox; "Map Component Factbox") {  }
        
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
                    Currpage.MapDetails.Page.UpdateFactbox;
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
    procedure SetData(var MapRoute: Record "Map Route")
    begin
        Reset;
        DeleteAll;
        Rec.Copy(MapRoute, true);
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
        if Route.FindSet then repeat
            CurrPage.Map.ShowRoute(Route.ShowRoute);
        until Route.Next = 0;
    end;

    procedure ClearMap();
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

    local procedure GetDataFromBuffer();
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