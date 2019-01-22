codeunit 6188521 "Map Settings"
{
    procedure SetSettings() settings: JsonObject;
    var


        providerSettings: JsonObject;

        defaultMarkerSettings: JsonObject;
        iconMarker: JsonObject;
        circleMarker: JsonObject;

        defaultRouteSettings: JsonObject;

        attributionSettings: JsonObject;
        initialLocation: JsonObject;
        coordinates: JsonObject;

        heatmapSettings: JsonObject;
        gradient: JsonObject;
        lassoSettings: JsonObject;
    begin
        GetProviderSettings(providerSettings);
        settings.Add('providerSettings', providerSettings);

        //         /*** DEFAULT ICON SETTINGS ***/
        iconMarker.Add('iconUrl', 'images/marker-icon.png');        // REQUIRED. Default icon URL.
        iconMarker.Add('shadowUrl', 'images/marker-shadow.png');    // OPTIONAL. Default icon shadow URL.
                                                                    //         // iconMarker.Add('iconAnchor', '');                        // OPTIONAL. Icon anchor. Array of two numbers [X, Y]. Checkout leaflet docs.
                                                                    //         // iconMarker.Add('popupAnchor', '');                       // OPTIONAL. Popup anchor. Array of two numbers [X, Y]. Checkout leaflet docs.
                                                                    //         // iconMarker.Add('iconSize', '');                          // OPTIONAL. Icon size. Array of two numbers [X, Y]. Checkout leaflet docs.
                                                                    //         // iconMarker.Add('shadowSize', '');                        // OPTIONAL. Shadow size. Array of two numbers [X, Y]. Checkout leaflet docs.
                                                                    //         // iconMarker.Add('shadowAnchor', '');                      // OPTIONAL. Shadow anchor. Array of two numbers [X, Y]. Checkout leaflet docs.
        defaultMarkerSettings.Add('iconMarker', iconMarker);

        //         // Most of these options aren't really required. But it is better to provide them. In case you don't, leaflet will use it's defaults.
        //         // circleMarker.Add('fillColor', 'pink');              // OPTIONAL. Circle marker fill color. Default value is 'red'.
        //         // circleMarker.Add('fillOpacity', 0.75);              // OPTIONAL. Circle marker fill opacity. 1 - non transparent, 0 - transparent Default value is 1.
        //         // circleMarker.Add('radius', 3);                      // OPTIONAL. Circle marker radius. Default value is 10.
        //         // circleMarker.Add('strokeColor', 'yellow');          // OPTIONAL. Circle marker stroke color. Default value is 'black'.
        //         // circleMarker.Add('strokeOpacity', 0.50);            // OPTIONAL. Circle marker stroke opacity. 1 - non transparent, 0 - transparent. Default value is 1.
        //         // circleMarker.Add('strokeWidthPx', 4);               // OPTIONAL. Circle marker stroke width in pixels. Default value is 3.
        //         // defaultMarkerSettings.Add('circleMarker', circleMarker);

        settings.Add('defaultMarkerSettings', defaultMarkerSettings);

        //         /*** DEFAULT SELECTED ROUTE SETTINGS ***/
        //         // defaultRouteSettings.Add('selectable', false);      // OPTIONAL. Is route selectable. Default value is false.
        //         // defaultRouteSettings.Add('strokeColor', 'green');   // OPTIONAL. Default selected route color. Default value is 'red'.
        //         // defaultRouteSettings.Add('strokeOpacity', 1);       // OPTIONAL. Default selected route opacity. Default value is 1.
        //         // defaultRouteSettings.Add('strokeWidthPx', 4);       // OPTIONAL. Default selected route width in pixels. Default value is 5.
        //         // defaultRouteSettings.Add('dashPattern', '');        // OPTIONAL. Default route dash pattern. https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-dasharray. Default value is ''.
        //         // settings.Add('defaultRouteSettings', defaultRouteSettings);

        //         /*** ATTRIBUTION SETTINGS ***/
        //         // attributionSettings.Add('showAttribution', true);   // OPTIONAL. Show map footer. Default value is false.
        //         // attributionSettings.Add('text', '');                // OPTIONAL. Map footer text. Default value is ''.
        //         // settings.Add('attributionSettings', attributionSettings);

        //         /*** INITIAL LOCATION SETTINGS ***/
        //         // coordinates.Add('longitude', 50);
        //         // coordinates.Add('latitude', -0.03);
        //         // initialLocation.Add('coordinates', coordinates);    // OPTIONAL. Default map initial coordinates. Default value is null. If coordinates were not provided, map will try to fit the whole world.
        //         // initialLocation.Add('zoom', 14);                    // OPTIONAL. Default map initial zoom. Default value is 13.
        //         // settings.Add('initialLocation', initialLocation);

        //         /*** HEATMAP SETTINGS ***/
        //         // heatmapSettings.Add('max', 1);                      // OPTIONAL. The maximum point of intensity. From 0 to 1. Default value is 1.
        //         // heatmapSettings.Add('radius', 25);                  // OPTIONAL. The radius of each "point" of the heatmap. Default value is 25.
        //         // heatmapSettings.Add('minOpacity', 25);              // OPTIONAL. The minimum opacity the heat will start at. Default value is 25.
        //         // heatmapSettings.Add('blur', 20);                    // OPTIONAL. The amount of blur. Default value is 20.
        //         // heatmapSettings.Add('maxZoom', 15);                 // OPTIONAL. The zoom level where the points reach maximum intensity. Default value is 15.

        //         /*** HEATMAP GRADIENT SETTINGS ***/                    // OPTIONAL. Default values are: 0.4 - blue, 0.65 - lime, 1 - red.
        //         // gradient.Add('0.4', 'blue');                        // The first value indicates the intensity. Second value indicates the color for this intensity value. Colors for the intermediate values are interpolated.
        //         // gradient.Add('0.65', 'lime');
        //         // gradient.Add('1', 'red');
        //         // heatmapSettings.Add('gradient', gradient);
        //         //settings.Add('heatmapSettings', heatmapSettings);

        //         /*** LASSO SETTINGS ***/
        //         // lassoSettings.Add('fillColor', 'blue');              // OPTIONAL. The fill color of lasso. Default value is 'blue'.
        //         // lassoSettings.Add('fillOpacity', 0.1);               // OPTIONAL. The level of fill color opacity. Default value is 0.1.
        //         // lassoSettings.Add('strokeColor', 'black');           // OPTIONAL. The stroke color of lasso. Default value is 'black'.
        //         // lassoSettings.Add('strokeOpacity', 0.5);             // OPTIONAL. The stroke opacity. Default value is 0.5.
        //         // lassoSettings.Add('strokeWidthPx', 1);               // OPTIONAL. The stroke width in pixels. Default value is 1.
        //         // settings.Add('lassoSettings', lassoSettings);

        //         CurrPage.Map.SetSettings(settings);
    end;

    local procedure GetProviderSettings(var providerSettings: JsonObject)
    var
        MapSettings: Record "Map Settings";
    begin
        MapSettings.Get;
        //        if Confirm('Debug') then Error('x');
        /*** DEFAULT PROVIDER SETTINGS ***/

        providerSettings.Add('type', MapSettings.Provider);
        providerSettings.Add('baseUrl', MapSettings."Account URL");
        if MapSettings.Username <> '' then
            providerSettings.Add('username', MapSettings.Username);
        if MapSettings.Password <> '' then
            providerSettings.Add('password', MapSettings.Password);
        if MapSettings.Token <> '' then
            providerSettings.Add('token', MapSettings.Token);

        if MapSettings."Profile" <> '' then
            providerSettings.Add('profile', MapSettings."Profile");

        if MapSettings.Subdomains <> '' then
            providerSettings.Add('subdomains', MapSettings.Subdomains);
        /*** EXAMPLE OF PROVIDER SETTINGS FOR OPENSTREETMAPS ***/
        // providerSettings.Add('type', 1);
        // providerSettings.Add('baseUrl', 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png'); 

    end;

}