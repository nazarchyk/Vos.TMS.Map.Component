controladdin Map
{
    Images = 'images/marker-icon.png',
        'images/marker-shadow.png',
        'images/red-truck.png','images/green-truck.png';

    Scripts =
        'scripts/map.js',
        'https://test-navnxt-map.azurewebsites.net/dist/meta-ui-map.js';

    StartupScript = 'scripts/start.js';
    StyleSheets =
        'https://test-navnxt-map.azurewebsites.net/dist/meta-ui-map/styles.css';
    RequestedHeight = 600;
    RequestedWidth = 800;

    MaximumWidth = 1920;
    MaximumHeight = 1080;
    VerticalShrink = true;
    HorizontalShrink = true;
    VerticalStretch = true;
    HorizontalStretch = true;

    event OnMapInit();
    event ControlReady();
    event OnMarkerClicked(eventObject: JsonObject);
    event OnRouteSelected(eventObject: JsonObject);
    event OnMarkersSelected(eventObject: JsonArray);
    event OnRouteVisibilityToggled(eventObject: JsonObject);

    procedure SetSettings(settings: JsonObject);
    procedure ShowIconMarker(marker: JsonObject);
    procedure ShowIconMarkerArray(marker: JsonArray);
    procedure ShowCircleMarker(marker: JsonObject);
    procedure ShowCircleMarkerArray(marker: JsonArray);
    procedure ShowRoute(route: JsonObject);
    procedure ClearMap();
    procedure EnableLasso();
    procedure EnableHeatmap();
    procedure UpdateHeatmap();
    procedure DisableHeatmap();

    procedure EnableFitMarkersBounds();
    procedure DisableFitMarkersBounds();
    procedure SetZoomAround(zoomObject: JsonObject);
    procedure RemoveMarker(markerId: Text);
}
