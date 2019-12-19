page 6188520 "Meta UI Map"
{
    Caption = 'Meta UI Map';
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
                    Settings: JsonObject;
                begin
                    MapElementBuffer.InitiateMapSettings(Settings);
                    CurrPage.MapControl.SetSettings(Settings);
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

                // Under construction...
                // trigger OnRouteSelected(Route: JsonObject)
                // begin
                // MapElementBuffer.ManageSingleSelection(SourceReference, Route);

                // // ToDo: Update route selection update ...
                // // PerformMapSelectionsUpdate(); 
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
                Image = Refresh;

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
                Image = Group;

                trigger OnAction()
                begin
                    if IsMapControlReady then
                        CurrPage.MapControl.EnableLasso();
                end;
            }

            action(OpenAsFullMap)
            {
                ApplicationArea = All;
                Caption = 'Open as Full Map';
                Enabled = false;
                Image = Map;

                trigger OnAction()
                var
                    MetaUIFullMap: Page "Meta UI Full Map";
                begin
                    if IsMapControlReady then begin
                        // ToDo: Implement smooth map state transfer from small map the fullscreen map...
                        MetaUIFullMap.Run();
                    end;
                end;
            }
        }
    }

    var
        MapElementBuffer: Record "Meta UI Map Element" temporary;
        SourceReference: RecordRef;
        IsMapControlReady: Boolean;

    procedure UpdateMapContent(var Source: RecordRef)
    var
        DataTypeMgmt: Codeunit "Data Type Management";
        InvalidSourceException: Label 'Meta UI Map: The source reference ''%1'' is invalid.';
    begin
        if not DataTypeMgmt.GetRecordRef(Source, SourceReference) then
            Error(InvalidSourceException, Source);

        if IsMapControlReady then
            PerformMapStructureUpdate();
    end;

    local procedure PerformMapStructureUpdate()
    var
        MapLayer: Record "Meta UI Map Element" temporary;
    begin
        IsMapControlReady := false;
        CurrPage.MapControl.ClearMap();

        MapElementBuffer.InitiateMapStructure(SourceReference);

        MapLayer.Copy(MapElementBuffer, true);
        MapLayer.SelectLayers('');
        if MapLayer.FindSet() then begin
            repeat
                case MapLayer.Subtype of
                    MapLayer.Subtype::Geo:
                        CurrPage.MapControl.AddGeoJSONLayer(MapLayer.ToJSON(false));

                    MapLayer.Subtype::Cluster:
                        CurrPage.MapControl.AddMarkerClusterLayer(MapLayer.ToJSON(false));

                    MapLayer.Subtype::Heat:
                        CurrPage.MapControl.AddHeatLayer(MapLayer.ToJSON(false));
                end;
            until (MapLayer.Next() = 0);

            // ToDo: Show custom layer controls...
            CurrPage.MapControl.AddLayersControl(MapLayer.LayersControlToJSON(false));
            CurrPage.MapControl.ShowControl(MapLayer.LayersControlToJSON(true));

            MapLayer.SetRange("Base Layer", true);
            if MapLayer.FindFirst() then
                CurrPage.MapControl.ShowLayer(MapLayer.ToJSON(true));

            MapLayer.SetRange("Base Layer", false);
            MapLayer.SetRange(Selected, true);
            if MapLayer.FindSet() then
                repeat
                    CurrPage.MapControl.ShowLayer(MapLayer.ToJSON(true));
                until (MapLayer.Next() = 0);
        end;

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
        if MapRoute.FindSet() then
            repeat
                CurrPage.MapControl.ShowRoute(MapRoute.ToJSON(false));

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
}
