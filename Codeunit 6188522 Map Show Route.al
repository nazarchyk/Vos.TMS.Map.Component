codeunit 6188522 "Map Show Route"
{

    procedure ShowRoute(var MapRoute: Record "Map Route"; IsReady: Boolean) route: JsonObject;
    var
        coordinate: JsonObject;
        coordinates: JsonArray;
        i: Integer;
        marker: JsonObject;
        markerSettings: JsonObject;
        buttonSettings: JsonObject;
        decorator: JsonObject;
        decoratorAttributes: JsonObject;
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
                markerSettings.Add('fillColor', "Marker Fill Color");           // Optional. Circle marker fill color.
                markerSettings.Add('fillOpacity', "Marker Fill Opacity");             // Optional. Circle marker fill opacity. 1 - non transparent, 0 - transparent
                markerSettings.Add('radius', "Marker Radius");                 // Optional. Circle marker radius.
                markerSettings.Add('strokeColor', "Marker Stroke Color");       // Optional. Circle marker stroke color.
                markerSettings.Add('strokeOpacity', "Marker Stroke Opacity");           // Optional. Circle marker stroke opacity. 1 - non transparent, 0 - transparent.
                markerSettings.Add('strokeWidthPx', "Marker Stroke With (Pixels)");           // Optional. Circle marker stroke width in pixels.
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

                /*** DECORATOR SETTINGS ***/
                decorator.Add('value', ' > ');  // Value to be displayed on the route. Can be any unicode value, like >, ⮞, ⯈, ⭆, etc. 
                                                //!!IMPORTANT!! If you want to display an arrow, use any rightwards one.
                                                //!!IMPORTANT!! If you want more space between the arrows, just add more spaces to the value

                decorator.Add('repeat', true);  // Specifies if the value should be repeated along the route

                decorator.Add('center', false); // Centers the value according to the route's bounding box

                decorator.Add('below', false);  // Show value below the path

                decorator.Add('offset', 10);    // Set an offset to position value relative to the route
							                    //!!IMPORTANT!! If you want to center the value, offset must be calculated using the next formula: offset = font-size / 3. 
                                                // So if your font-size is 30, offset should be 10. 

                decorator.Add('orientation', 0);// Value rotation to a specified angle
                
                // SVG attributes. Checkout https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute
                decoratorAttributes.Add('font-size', 30);   // determines font-size
                decoratorAttributes.Add('fill', 'blue');    // determines font fill color
                
                decorator.Add('attributes', decoratorAttributes);

                route.Add('decorator', decorator);
            end;
        end;

    end;
}