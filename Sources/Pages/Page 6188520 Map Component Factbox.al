page 6188520 "Map Component Factbox"
{
    Caption = 'Map Component Factbox';
    PageType = CardPart;

    layout
    {
        area(Content)
        {
            usercontrol(MapControl; MetaUIMapAddIn)
            {
                ApplicationArea = All;

                trigger OnMapInit()
                var
                    MapSettings: Codeunit "Map Settings";
                begin
                    CurrPage.MapControl.SetSettings(MapSettings.SetSettings());
                end;

                trigger ControlReady()
                begin
                    PerformMapStructureUpdate();
                end;

                trigger OnLayerVisibilityChanged(LayerState: JsonObject)
                begin
                    MapElementBuffer.ManageLayerVisibility(SourceReference, LayerState);

                    if MapElementBuffer.Selected then
                        PerformMapContentUpdate()
                    else
                        CurrPage.MapControl.ClearLayer(MapElementBuffer.ToJSON(true));
                end;

                trigger OnMarkerClicked(Marker: JsonObject) // Single Marker
                begin
                    MapElementBuffer.ManageSingleSelection(SourceReference, Marker);

                    PerformMapSelectionsUpdate();
                end;

                trigger OnMarkersSelected(Markers: JsonArray) // Lasso Capture
                begin
                    MapElementBuffer.ManageMultiSelection(SourceReference, Markers);

                    PerformMapSelectionsUpdate();
                end;

                // trigger OnRouteSelected(Route: JsonObject)
                // begin
                //     MapElementBuffer.ManageSingleSelection(SourceReference, Route);

                //     // ToDo: Update route selection update ...
                //     // PerformMapSelectionsUpdate(); 
                // end;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(UpdateContent)
            {
                ApplicationArea = All;
                Caption = 'Update Content';
                Image = UpdateShipment;

                trigger OnAction()
                begin
                    if IsMapControlReady then
                        PerformMapStructureUpdate();
                end;
            }

            action(LassoSelection)
            {
                ApplicationArea = All;
                Caption = 'Lasso Selection';
                Image = Map;

                trigger OnAction()
                begin
                    if IsMapControlReady then
                        CurrPage.MapControl.EnableLasso();
                end;
            }
        }
    }

    var
        MapElementBuffer: Record "Meta UI Map Element" temporary;
        SourceReference: RecordRef;
        IsMapControlReady: Boolean;

    procedure UpdateMapContent(var Source: RecordRef)
    begin
        SourceReference := Source;
        if IsMapControlReady then
            PerformMapStructureUpdate();
    end;

    local procedure PerformMapStructureUpdate();
    begin
        IsMapControlReady := false;
        CurrPage.MapControl.ClearMap();

        MapElementBuffer.InitiateMapStructure(SourceReference);

        MapElementBuffer.SelectLayers('');
        if MapElementBuffer.FindSet() then
            repeat
                case MapElementBuffer.Subtype of
                    MapElementBuffer.Subtype::Geo:
                        CurrPage.MapControl.AddGeoJSONLayer(MapElementBuffer.ToJSON(false));

                    MapElementBuffer.Subtype::Cluster:
                        CurrPage.MapControl.AddMarkerClusterLayer(MapElementBuffer.ToJSON(false));

                    MapElementBuffer.Subtype::Heat:
                        CurrPage.MapControl.AddHeatLayer(MapElementBuffer.ToJSON(false));
                end;

                if MapElementBuffer."Base Layer" then
                    CurrPage.MapControl.ShowLayer(MapElementBuffer.ToJSON(true));
            until (MapElementBuffer.Next() = 0);

        // ToDo: Show custom layer controls...
        CurrPage.MapControl.AddLayersControl(MapElementBuffer.LayersControlToJSON(false));
        CurrPage.MapControl.ShowControl(MapElementBuffer.LayersControlToJSON(true));

        IsMapControlReady := true;
    end;

    local procedure PerformMapContentUpdate()
    var
        MapRoute: Record "Meta UI Map Element" temporary;
        MapPoint: Record "Meta UI Map Element" temporary;
    begin
        MapPoint.Copy(MapElementBuffer, true);
        MapPoint.SelectPoints(MapElementBuffer.ID);
        if MapPoint.FindSet() then
            repeat
                case MapPoint.Subtype of
                    MapPoint.Subtype::Circle:
                        CurrPage.MapControl.ShowCircleMarker(MapPoint.ToJSON(false));
                    MapPoint.Subtype::Icon:
                        CurrPage.MapControl.ShowIconMarker(MapPoint.ToJSON(false));
                end;
            until (MapPoint.Next() = 0);

        MapRoute.Copy(MapElementBuffer, true);
        MapRoute.SelectRoutes(MapElementBuffer.ID);
        if MapRoute.FindSet() then begin
            CurrPage.MapControl.ShowRoute(MapRoute.ToJSON(false));

            repeat
                MapPoint.SelectPoints(MapRoute.ID);
                if MapPoint.FindSet() then
                    repeat
                        case MapPoint.Subtype of
                            MapPoint.Subtype::Circle:
                                CurrPage.MapControl.ShowCircleMarker(MapPoint.ToJSON(false));
                            MapPoint.Subtype::Icon:
                                CurrPage.MapControl.ShowIconMarker(MapPoint.ToJSON(false));
                        end;
                    until (MapPoint.Next() = 0);
            until (MapRoute.Next() = 0);
        end;

        CurrPage.MapControl.FitLayerBounds(MapElementBuffer.ToJSON(true));
    end;

    local procedure PerformMapSelectionsUpdate()
    begin
        if MapElementBuffer.FindSet() then
            repeat
                CurrPage.MapControl.RemoveMarker(MapElementBuffer.ToJSON(true));

                case MapElementBuffer.Subtype of
                    MapElementBuffer.Subtype::Circle:
                        CurrPage.MapControl.ShowCircleMarker(MapElementBuffer.ToJSON(false));
                    MapElementBuffer.Subtype::Icon:
                        CurrPage.MapControl.ShowIconMarker(MapElementBuffer.ToJSON(false));
                end;
            until (MapElementBuffer.Next() = 0);
    end;

    procedure GetDataFromBuffer(); // OBSOLETE: OLD CODE Starts Visualization ...
    begin

    end;

    // ToDo: Implement smooth map state transfer from small map the fullscreen map...
}
