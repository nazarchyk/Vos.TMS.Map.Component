page 6188520 "Map Component Factbox"
{
    PageType = CardPart;
    SourceTable = "Map Route";
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
                    ShowRoute;
                    ShowMarker;
                end;

                trigger OnRouteSelected(eventObject: JsonObject);
                begin
                    Message(format(eventObject));
                end;

                trigger OnMarkerClicked(eventObject: JsonObject);
                begin
                    Message(format(eventObject));
                end;

                trigger OnMarkersSelected(eventObject: JsonObject);
                begin
                    Message(format(eventObject));
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
            action(Marker)
            {
                Image = Position;
                trigger OnAction();
                begin
                    ShowMarker;
                end;
            }
            action(Route)
            {
                Image = "Grid";
                trigger OnAction();
                begin
                    ShowRoute;
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

    procedure ShowMarker();
    var
        MapShowMarker: Codeunit "Map Show Marker";
    begin
        if IsReady then
            CurrPage.Map.ShowIconMarker(MapShowMarker.ShowMarker(Rec, IsReady));
    end;

    procedure ShowRoute();
    var
        MapShowMarker: Codeunit "Map Show Marker";
        ShowRoute: Codeunit "Map Show Route";
    begin
        //Message(format(ShowRoute.ShowRoute(Rec, IsReady)));
        if IsReady then begin
            //Message(format(MapShowMarker.ShowMarker(Rec, IsReady)));

            CurrPage.Map.ShowRoute(ShowRoute.ShowRoute(Rec, IsReady));
            if findset then repeat
                CurrPage.Map.ShowIconMarker(MapShowMarker.ShowMarker(Rec, IsReady));
            until next = 0;
        end;
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

    var
        IsReady: Boolean;
}