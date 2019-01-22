codeunit 6188523 "Map Show Marker"
{
    trigger OnRun();
    begin
    end;

    procedure ShowMarker(var MapRoute: Record "Map Route"; IsReady: Boolean) marker: JsonObject;
    var

        coordinates: JsonObject;
        popup: JsonObject;
        settings: JsonObject;
    begin
        if not IsReady then
            exit;
        with MapRoute do
        begin

            SetRange("Route No.", 0);
            if IsEmpty then
                exit;

            // FindSet;
            // repeat
            marker.Add('type', 0);                  // Type 0 - Icon Marker, Type 1 - Circle Marker.

            coordinates.Add('latitude', Latitude);
            coordinates.Add('longitude', Longitude);
            marker.Add('coordinates', coordinates);

            if "Marker Text" <> '' then begin
                popup.Add('text', "Marker Text");
                popup.Add('autoClose', false);      // If true, popup will be automatically closed when added. If false, map will keep popup opened.
                popup.Add('closeOnClick', false);   // If true, popup will be closed on map click.
                marker.Add('popup', popup);
            end;

            settings.Add('iconUrl', '');            // Optional. Icon URL, if you want custom marker.
            settings.Add('shadowUrl', '');          // Optional. Shadow URL, if you want custom marker.
            settings.Add('iconAnchor', '');         // Optional. Icon anchor. Array of two numbers [X, Y].
            settings.Add('popupAnchor', '');        // Optional. Popup anchor. Array of two numbers [X, Y].
            settings.Add('iconSize', '');           // Optional. Icon size. Array of two numbers [X, Y].
            settings.Add('shadowSize', '');         // Optional. Shadow size. Array of two numbers [X, Y].
            settings.Add('shadowAnchor', '');       // Optional. Shadow anchor. Array of two numbers [X, Y].

            marker.Add('settings', settings);
            //until next = 0;

            /*** CIRCLE MARKER EXAMPLE ***/
            //To add circle marker, use the next settings

            // marker.Add('type', 1);               // Type 0 - Icon Marker, Type 1 - Circle Marker.

            // coordinates.Add('latitude', Latitude);
            // coordinates.Add('longitude', Longitude);
            // marker.Add('coordinates', coordinates);

            // if "Marker Text" <> '' then begin
            //     popup.Add('text', "Marker Text");
            //     popup.Add('autoClose', false);      // If true, popup will be automatically closed when added. If false, map will keep popup opened.
            //     popup.Add('closeOnClick', false);   // If true, popup will be closed on map click.
            //     marker.Add('popup', popup);
            // end;

            // settings.Add('fillColor', 'red');           // Optional. Circle marker fill color.
            // settings.Add('fillOpacity', 1);             // Optional. Circle marker fill opacity. 1 - non transparent, 0 - transparent
            // settings.Add('radius', 10);                 // Optional. Circle marker radius.
            // settings.Add('strokeColor', 'black');       // Optional. Circle marker stroke color.
            // settings.Add('strokeOpacity', 1);           // Optional. Circle marker stroke opacity. 1 - non transparent, 0 - transparent.
            // settings.Add('strokeWidthPx', 3);           // Optional. Circle marker stroke width in pixels.
            // marker.Add('settings', settings);
        end;

    end;
}