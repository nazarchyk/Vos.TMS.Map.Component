page 6188521 "Map Component Full Page"
{
    PageType = Card;
    // SourceTable = "Map Route Detail";
    // SourceTableTemporary = true;
    UsageCategory = Documents;

    layout
    {
        area(Content)
        {
            usercontrol(MapControl; MetaUIMapAddIn)
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
        area(FactBoxes)
        {
            part(MapRoute; "Map Route Factbox") { }
            part(MapDetails; "Map Route Detail Factbox") { }
            part(MapBox; "Map Component Factbox") { Visible = false; }

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
            action(Clear)
            {
                Image = ClearLog;
                trigger OnAction();
                begin
                    ClearMap;
                end;
            }

            // action("Enable heatmap")
            // {
            //     Image = Approve;
            //     trigger OnAction();
            //     begin
            //         EnableHeatmap;
            //     end;
            // }

            // action("Update heatmap")
            // {
            //     Image = UpdateDescription;
            //     trigger OnAction();
            //     begin
            //         UpdateHeatmap;
            //     end;
            // }

            // action("Disable heatmap")
            // {
            //     Image = UnApply;
            //     trigger OnAction();
            //     begin
            //         DisableHeatmap;
            //     end;
            // }
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
                CurrPage.MapControl.ShowIconMarker(RouteDetail.ShowMarker())
            else
                CurrPage.MapControl.ShowCircleMarker(RouteDetail.ShowMarker());
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
            CurrPage.MapControl.ShowRoute(Route.ShowRoute);
        until Route.Next = 0;
    end;

    local procedure ClearMap();
    begin
        CurrPage.MapControl.ClearMap();
    end;

    local procedure SetSettings();
    var
        MapSettings: Codeunit "Map Settings";
    begin
        CurrPage.MapControl.SetSettings(MapSettings.SetSettings);
    end;

    local procedure EnableLasso()
    begin
        if not IsReady then
            exit;
        CurrPage.MapControl.EnableLasso();
    end;

    // local procedure EnableHeatmap()
    // begin
    //     if not IsReady then
    //         exit;
    //     CurrPage.MapControl.EnableHeatmap();
    // end;

    // local procedure UpdateHeatmap()
    // begin
    //     if not IsReady then
    //         exit;
    //     CurrPage.MapControl.UpdateHeatmap();
    // end;

    // local procedure DisableHeatmap()
    // begin
    //     if not IsReady then
    //         exit;
    //     CurrPage.MapControl.DisableHeatmap();
    // end;

    local procedure GetDataFromBuffer();
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