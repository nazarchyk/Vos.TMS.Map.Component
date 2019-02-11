codeunit 6188522 "Map Show Route"
{

    procedure ShowRoute(var MapRoute: Record "Map Route"; IsReady: Boolean)route: JsonObject;
    var
        
        
        coordinate: JsonObject;
        coordinates: JsonArray;
        i: Integer;

        marker: JsonObject;
        markerSettings: JsonObject;

        buttonSettings: JsonObject;
        selectionSettings: JsonObject;
    begin
        if not IsReady then
            exit;
        with MapRoute do
        begin

            SetFilter("Route No.", '>0');
            if IsEmpty then
                exit;
            SetCurrentKey("Route No.");
            FindLast;
            for i := 1 to "Route No." do
            begin
                Clear(route);
                Clear(coordinates);
                Clear(buttonSettings);
                Clear(selectionSettings);

                SetRange("Route No.", i);
                SetCurrentKey("Route No.", "Stop No.");
                FindSet;
                repeat
                    coordinate.Add('latitude', Latitude);
                coordinate.Add('longitude', Longitude);

                // Each coordinate can have marker: Icon marker or Circle marker.
                // If marker is not provided, it won't be displayed

                /*** ICON MARKER EXAMPLE ***/
                // DEFAULT VALUES ARE DETERMINED BY DEFAULT SETTINGS

                // marker.Add('type', 0);                        // REQUIRED. Type 0 - Icon Marker, Type 1 - Circle Marker.
                // markerSettings.Add('iconUrl', someUrl);       // REQUIRED. Icon URL.
                // markerSettings.Add('shadowUrl', someUrl);     // Optional. Shadow URL.
                // markerSettings.Add('iconAnchor', '');         // Optional. Icon anchor. Array of two numbers [X, Y].
                // markerSettings.Add('popupAnchor', '');        // Optional. Popup anchor. Array of two numbers [X, Y].
                // markerSettings.Add('iconSize', '');           // Optional. Icon size. Array of two numbers [X, Y].
                // markerSettings.Add('shadowSize', '');         // Optional. Shadow size. Array of two numbers [X, Y].
                // markerSettings.Add('shadowAnchor', '');       // Optional. Shadow anchor. Array of two numbers [X, Y].
                // marker.Add('settings', markerSettings);

                /*** CIRCLE MARKER EXAMPLE ***/
                // DEFAULT VALUES ARE DETERMINED BY DEFAULT SETTINGS
                marker.Add('type', "Marker Type");                            // REQUIRED. Type 0 - Icon Marker, Type 1 - Circle Marker.
                markerSettings.Add('fillColor', 'red');           // Optional. Circle marker fill color.
                markerSettings.Add('fillOpacity', 1);             // Optional. Circle marker fill opacity. 1 - non transparent, 0 - transparent
                markerSettings.Add('radius', 10);                 // Optional. Circle marker radius.
                markerSettings.Add('strokeColor', 'black');       // Optional. Circle marker stroke color.
                markerSettings.Add('strokeOpacity', 1);           // Optional. Circle marker stroke opacity. 1 - non transparent, 0 - transparent.
                markerSettings.Add('strokeWidthPx', 3);           // Optional. Circle marker stroke width in pixels.
                marker.Add('settings', markerSettings);

                coordinate.Add('marker', marker);

                coordinates.Add(coordinate);
                Clear(coordinate);
                Clear(marker);
                Clear(markerSettings);
                until Next = 0;

                route.Add('coordinates', coordinates);
                route.Add('color', Color.ToLower);

                /*** ROUTE BUTTON SETTINGS ***/
                // Button settings. Shows checkbox. When checked, the route is shown. When unchecked, the route is hidden.
                buttonSettings.Add('showButton', true);     // REQUIRED. Show button. If button's not shown, you won't be able to hide the route.
                if Name = '' then
                    buttonSettings.Add('label', 'Route ' + Format("Route No."))
                else
                    buttonSettings.Add('label', Name);

                route.Add('buttonSettings', buttonSettings);

                /*** ROUTE SELECTION SETTINGS ***/
                // DEFAULT VALUES ARE DETERMINED BY DEFAULT SETTINGS
                // selectionSettings.Add('selectable', true);           // OPTIONAL.
                // selectionSettings.Add('strokeColor', 'yellow');      // OPTIONAL.
                // selectionSettings.Add('strokeOpacity', 1);           // OPTIONAL.
                // selectionSettings.Add('strokeWidthPx', 5);           // OPTIONAL.
                // selectionSettings.Add('dashPattern', '');            // OPTIONAL.
                // route.Add('selectionSettings', selectionSettings);
            end;
        end;

    end;
}