// The controladdin type declares the new add-in.
controladdin MetaUIMapAddIn
{
    // The Scripts property can reference both external and local scripts.
    Scripts =
        'scripts/map.js',
        'https://dev-navnxt-map.azurewebsites.net/dist/meta-ui-map.js';


    // The StartupScript is a special script that the web client calls once the page is loaded.
    StartupScript =
        'scripts/start.js';


    // Specifies the StyleSheets that are included in the control add-in.
    StyleSheets =
        'https://dev-navnxt-map.azurewebsites.net/dist/meta-ui.map/styles.css';


    // Specifies the Images that are included in the control add-in.
    Images =
        'images/black.truck.19.png',
        'images/blue.truck.19.png',
        'images/green.truck.19.png',
        'images/red.truck.19.png';


    // The layout properties define how control add-in are displayed on the page
    RequestedHeight = 600;
    RequestedWidth = 800;

    MaximumWidth = 1920;
    MaximumHeight = 1080;
    VerticalShrink = true;
    HorizontalShrink = true;
    VerticalStretch = true;
    HorizontalStretch = true;


    // The event declarations specify what callbacks could be raised from JavaScript by using the webclient API
    event OnMapInit();
    event ControlReady();

    event OnMarkerClicked(Marker: JsonObject);
    event OnMarkersSelected(Markers: JsonArray);
    event OnRouteSelected(Route: JsonObject);
    event OnRouteVisibilityToggled(eventObject: JsonObject);
    event OnLayerVisibilityChanged(LayerState: JsonObject);


    // The procedure declarations specify what JavaScript methods could be called from AL.
    procedure SetSettings(Settings: JsonObject);
    procedure ClearMap();

    procedure AddGeoJSONLayer(GeoLayer: JsonObject);
    procedure AddMarkerClusterLayer(ClusterLayer: JsonObject);
    procedure AddHeatLayer(HeatLayer: JsonObject);
    procedure ShowLayer(LayerID: JsonObject);
    procedure HideLayer(LayerID: JsonObject);
    procedure ClearLayer(LayerID: JsonObject);
    procedure RemoveLayer(LayerID: JsonObject);
    procedure FitLayerBounds(LayerID: JsonObject);

    procedure ShowIconMarker(Marker: JsonObject);
    procedure ShowIconMarkerArray(Markers: JsonArray);
    procedure ShowCircleMarker(Marker: JsonObject);
    procedure ShowCircleMarkerArray(Markers: JsonArray);
    procedure RemoveMarker(LayerMarkerID: JsonObject);
    procedure ShowRoute(Route: JsonObject);
    procedure AddHeatPoint(HeatPoint: JsonObject);

    procedure AddLayersControl(Control: JsonObject);
    procedure ShowControl(ControlID: JsonObject);
    procedure HideControl(ControlID: JsonObject);
    procedure RemoveControl(ControlID: JsonObject);

    procedure EnableLasso();
    procedure SetZoomAround(zoomObject: JsonObject);
}
