table 6188523 "Meta UI Map Element"
{
    Caption = 'Meta UI Map Element';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; ID; Text[50])
        {
            Caption = 'ID';
            DataClassification = ToBeClassified;
            NotBlank = true;
        }

        field(2; Name; Text[50])
        {
            Caption = 'Name';
            DataClassification = ToBeClassified;
        }

        field(3; Type; Option)
        {
            Caption = 'Type';
            DataClassification = ToBeClassified;
            OptionMembers = Layer,Route,Point;
        }

        field(4; Subtype; Option)
        {
            Caption = 'Subtype';
            DataClassification = ToBeClassified;
            OptionMembers = Geo,Cluster,Heat,,,,,,,,Route,,,,,,,,,,Circle,Icon,Intensity,,,,,,,;
        }

        field(5; "Parent ID"; Text[50])
        {
            Caption = 'Parent ID';
            DataClassification = ToBeClassified;
        }

        field(6; "Serial No."; Integer)
        {
            Caption = 'Serial No.';
            DataClassification = ToBeClassified;
        }

        field(7; Selected; Boolean)
        {
            Caption = 'Selected';
            DataClassification = ToBeClassified;
        }

        field(8; "Data Mark"; Text[50])
        {
            Caption = 'Data Mark';
            DataClassification = ToBeClassified;
        }

        field(9; "Primary Settings"; Blob)
        {
            Caption = 'Primary Settings';
            DataClassification = ToBeClassified;
        }

        field(10; "Base Layer"; Boolean)
        {
            Caption = 'Base Layer';
            DataClassification = ToBeClassified;
        }

        field(15; "Route Button Settings"; Blob)
        {
            Caption = 'Route Button Settings';
            DataClassification = ToBeClassified;
        }

        field(16; "Route Selection Settings"; Blob)
        {
            Caption = 'Route Selection Settings';
            DataClassification = ToBeClassified;
        }

        field(17; "Route Decorator Settings"; Blob)
        {
            Caption = 'Route Decorator Settings';
            DataClassification = ToBeClassified;
        }

        field(20; "Point Coordinates"; Blob)
        {
            Caption = 'Point Coordinates';
            DataClassification = ToBeClassified;
        }

        field(21; "Point Popup Settings"; Blob)
        {
            Caption = 'Point Popup Settings';
            DataClassification = ToBeClassified;
        }

        field(22; "Point Marker Settings"; Blob)
        {
            Caption = 'Point Marker Settings';
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(PrimaryKey; ID)
        {
            Clustered = true;
        }

        key(SerialNo; "Serial No.") { }
    }

    trigger OnInsert()
    var
        MapElementShadow: Record "Meta UI Map Element" temporary;
        ParentSerialNo: Integer;
    begin
        AssertRecordIsTemporary();

        MapElementShadow.Copy(Rec, true);
        if MapElementShadow.Get("Parent ID") then
            ParentSerialNo := MapElementShadow."Serial No.";

        MapElementShadow.Reset();
        MapElementShadow.SetCurrentKey("Serial No.");
        MapElementShadow.SetRange(Type, Type);
        MapElementShadow.SetRange(Subtype, Subtype);
        if MapElementShadow.FindLast() then
            "Serial No." := MapElementShadow."Serial No." + 1
        else
            case Type of
                Type::Layer:
                    "Serial No." := 1;
                Type::Route:
                    "Serial No." := ParentSerialNo * 100;
                Type::Point:
                    "Serial No." := ParentSerialNo * 10000;
            end;
    end;

    local procedure AssertRecordIsTemporary()
    var
        NonTemporaryException: Label 'This function can only be used when the record is temporary.';
    begin
        if not IsTemporary then
            Error(NonTemporaryException);
    end;

    local procedure AssertRecordIsExist()
    var
        NoRecordException: Label 'This function can only be used when record is created.';
    begin
        if not Get(ID) then
            Error(NoRecordException);
    end;

    local procedure LoadPrimarySettings(var Settings: JsonObject)
    var
        DataInStream: InStream;
    begin
        CalcFields("Primary Settings");
        if "Primary Settings".HasValue() then begin
            "Primary Settings".CreateInStream(DataInStream);
            Settings.ReadFrom(DataInStream);
        end;
    end;

    local procedure SavePrimarySettings(var Settings: JsonObject)
    var
        DataOutStream: OutStream;
    begin
        Clear("Primary Settings");
        "Primary Settings".CreateOutStream(DataOutStream);
        Settings.WriteTo(DataOutStream);
    end;

    /* ------------------------------------------ Process Functions ---------------------------------------- */

    procedure InitiateMapStructure(var Source: RecordRef);
    begin
        AssertRecordIsTemporary();

        Reset();
        DeleteAll();

        OnMapStructureInitiate(Source, Rec);
    end;

    procedure ManageSingleSelection(var Source: RecordRef; Element: JsonObject)
    var
        ElementID: JsonToken;
    begin
        Element.Get('id', ElementID);

        Reset();
        Get(ElementID.AsValue().AsText());
        Selected := not Selected;
        Modify();

        OnElementSelectionChanged(Source, Rec);

        Mark := true;
        MarkedOnly := true;
    end;

    procedure ManageMultiSelection(var Source: RecordRef; ElementList: JsonArray)
    var
        Element: JsonToken;
        ElementID: JsonToken;
        Index: Integer;
    begin
        Reset();
        foreach Element in ElementList do begin
            Element.AsObject().Get('id', ElementID);

            Get(ElementID.AsValue().AsText());
            Selected := not Selected;
            Modify();

            OnElementSelectionChanged(Source, Rec);

            Mark := true;
        end;
        MarkedOnly := true;
    end;

    procedure ManageLayerVisibility(var Source: RecordRef; LayerState: JsonObject)
    var
        MapElementShadow: Record "Meta UI Map Element" temporary;
        StateToken: JsonToken;
        LayerID: Text;
    begin
        LayerState.Get('id', StateToken);
        LayerID := StateToken.AsValue().AsText();
        LayerState.Get('visible', StateToken);

        Reset;
        Get(LayerID);
        Selected := StateToken.AsValue().AsBoolean();
        Modify();

        if not Selected then begin
            MapElementShadow.Copy(Rec, true);

            MapElementShadow.SelectPoints(ID);
            MapElementShadow.DeleteAll();

            SelectRoutes(ID);
            if FindSet() then begin
                repeat
                    MapElementShadow.SelectPoints(ID);
                    MapElementShadow.DeleteAll();
                until (Next() = 0);

                DeleteAll();
            end;

            Reset;
            Get(LayerID);
        end;

        OnElementSelectionChanged(Source, Rec);
        Get(LayerID);
    end;

    /* ---------------------------------------- Map Layer Functions ---------------------------------------- */

    local procedure CreateLayer(LayerID: Text[50]; LayerName: Text[50]; IsBase: Boolean)
    begin
        Clear(Rec);
        ID := LayerID;
        Name := LayerName;
        Type := Type::Layer;
        "Base Layer" := IsBase;
    end;

    local procedure LayerToJSON(OnlyID: Boolean) Layer: JsonObject
    begin
        TestField(Type, Type::Layer);

        if not OnlyID then
            LoadPrimarySettings(Layer);

        Layer.Add('id', ID);
    end;

    procedure CreateGeoLayer(LayerID: Text[50]; LayerName: Text[50]; IsBase: Boolean)
    var
        LayerProperties: JsonObject;
    begin
        CreateLayer(LayerID, LayerName, IsBase);
        Subtype := Subtype::Geo;

        SavePrimarySettings(LayerProperties);
        Insert(true);
    end;

    procedure CreateClusterLayer(LayerID: Text[50]; LayerName: Text[50]; IsBase: Boolean)
    var
        Settings: JsonObject;
    begin
        CreateLayer(LayerID, LayerName, IsBase);
        Subtype := Subtype::Cluster;

        // Property {boolean} [showCoverageOnHover=true] 
        // When you mouse over a cluster it shows the bounds of its markers
        Settings.Add('showCoverageOnHover', true);

        // Property {boolean} [zoomToBoundsOnClick=true]
        // When you click a cluster we zoom to its bounds
        Settings.Add('zoomToBoundsOnClick', true);

        // Property {boolean} [spiderfyOnMaxZoom=true] 
        // When you click a cluster at the bottom zoom level we spiderfy it so you can see all of its markers
        Settings.Add('spiderfyOnMaxZoom', true);

        // Property {boolean} [removeOutsideVisibleBounds=true] 
        // Clusters and markers too far from the viewport are removed from the map for performance
        Settings.Add('removeOutsideVisibleBounds', true);

        // Property {boolean} [animate=true] 
        // Smoothly split / merge cluster children when zooming and spiderfying (May not have any effect in IE)
        Settings.Add('animate', true);

        // Property {boolean} [animateAddingMarkers=false] 
        // If set to true (and animate option is also true) then adding individual markers to the MarkerClusterGroup 
        // after it has been added to the map will add the marker and animate it into the cluster
        // Defaults to false as this gives better performance when bulk adding markers
        // addLayers does not support this, only addLayer with individual Markers
        Settings.Add('animateAddingMarkers', false);

        // Property {boolean} [disableClusteringAtZoom=18] 
        // If set, at this zoom level and below markers will not be clustered. This defaults to disabled.
        Settings.Add('disableClusteringAtZoom', 18);

        // Property {number} [maxClusterRadius=80] 
        // The maximum radius that a cluster will cover from the central marker (in pixels)
        // Decreasing will make more, smaller clusters
        // You can also use a function that accepts the current map zoom and returns the maximum cluster radius in pixels
        Settings.Add('maxClusterRadius', 80);

        // Property {boolean} [singleMarkerMode=false] 
        // If set to true, overrides the icon for all added markers to make them appear as a 1 size cluster
        Settings.Add('singleMarkerMode', false);

        // Property {boolean} [spiderfyDistanceMultiplier=1] 
        // Increase from 1 to increase the distance away from the center that spiderfied markers are placed
        // Use if you are using big marker icons
        Settings.Add('spiderfyDistanceMultiplier', 1);

        // Property {boolean} [chunkedLoading=false] 
        // Boolean to split the addLayers processing in to small intervals so that the page does not freeze
        Settings.Add('chunkedLoading', false);

        // Property {number} [chunkDelay=50] 
        // Time delay (in ms) between consecutive periods of processing for addLayers
        Settings.Add('chunkDelay', 50);

        // Property {number} [chunkInterval=200] 
        // Time interval (in ms) during which addLayers works before pausing to let the rest of the page process
        // In particular, this prevents the page from freezing while adding a lot of markers
        Settings.Add('chunkInterval', 200);

        SavePrimarySettings(Settings);
        Insert(true);
    end;

    procedure CreateHeatLayer(LayerID: Text[50]; LayerName: Text[50]; IsBase: Boolean)
    var
        Settings: JsonObject;
        Gradient: JsonObject;
    begin
        CreateLayer(LayerID, LayerName, IsBase);
        Subtype := Subtype::Heat;

        // Property {number} [minOpacity=0.05] 
        // The minimum opacity the heat will start at
        Settings.Add('minOpacity', 0.05);

        // Property {number} [maxZoom=18] 
        // Zoom level where the points reach maximum intensity (as intensity scales with zoom), equals maxZoom of the map by default
        Settings.Add('maxZoom', 18);

        // Property {number} [max=1.0] 
        // Maximum point intensity
        Settings.Add('max', 1.0);

        // Property {number} [radius=25] 
        // Radius of each "point" of the heatmap
        Settings.Add('radius', 25);

        // Property {number} [blur=15] 
        // Amount of blur
        Settings.Add('blur', 15);

        Gradient.Add('0.4', 'blue');
        Gradient.Add('0.65', 'lime');
        Gradient.Add('1', 'red');

        // Property {object} [gradient={0.4: 'blue', 0.65: 'lime', 1: 'red'}]
        //  Color gradient config, e.g. {0.4: 'blue', 0.65: 'lime', 1: 'red'}
        Settings.Add('gradient', Gradient);

        SavePrimarySettings(Settings);
        Insert(true);
    end;

    procedure UpdateLayerSettings(Property: Text; Value: Variant)
    var
        Settings: JsonObject;
        UnknownPropertyException: Label 'There is no ''%1'' property within layer''s settings.';
    begin
        if Property <> '' then begin
            AssertRecordIsExist();
            TestField(Type, Type::Layer);

            LoadPrimarySettings(Settings);
            if not Settings.Contains(Property) then
                Error(UnknownPropertyException, Property);

            Settings.Replace(Property, Format(Value));
            SavePrimarySettings(Settings);
        end;
    end;

    /* ---------------------------------------- Map Route Functions ---------------------------------------- */

    local procedure LoadRouteSelectionSettings(var Settings: JsonObject)
    var
        DataInStream: InStream;
    begin
        CalcFields("Route Selection Settings");
        if "Route Selection Settings".HasValue() then begin
            "Route Selection Settings".CreateInStream(DataInStream);
            Settings.ReadFrom(DataInStream);
        end;
    end;

    local procedure LoadRouteDecoratorSettings(var Settings: JsonObject)
    var
        DataInStream: InStream;
    begin
        CalcFields("Route Decorator Settings");
        if "Route Decorator Settings".HasValue() then begin
            "Route Decorator Settings".CreateInStream(DataInStream);
            Settings.ReadFrom(DataInStream);
        end;
    end;

    local procedure SaveRouteSelectionSettings(var Settings: JsonObject)
    var
        DataOutStream: OutStream;
    begin
        Clear("Route Selection Settings");
        "Route Selection Settings".CreateOutStream(DataOutStream);
        Settings.WriteTo(DataOutStream);
    end;

    local procedure SaveRouteDecoratorSettings(var Settings: JsonObject)
    var
        DataOutStream: OutStream;
    begin
        Clear("Route Decorator Settings");
        "Route Decorator Settings".CreateOutStream(DataOutStream);
        Settings.WriteTo(DataOutStream);
    end;

    local procedure CreateRoute(RouteID: Text[50]; RouteName: Text[50])
    var
        Settings: JsonObject;
        ParentID: Text[50];
    begin
        ParentID := ID;

        Clear(Rec);
        ID := RouteID;
        Name := RouteName;
        Type := Type::Route;
        "Parent ID" := ParentID;

        Settings.Add('layerId', ParentID);
        SavePrimarySettings(Settings);
        Insert(true);
    end;

    local procedure RouteToJSON(OnlyID: Boolean) Route: JsonObject
    var
        MapElementShadow: Record "Meta UI Map Element" temporary;
        xMapElementShadow: Record "Meta UI Map Element" temporary;
        RouteSegments: JsonArray;
        RouteSegment: JsonObject;
        SegmentPoints: JsonArray;
        PointCoordinatesA: JsonObject;
        PointCoordinatesB: JsonObject;
        PointSettings: JsonObject;
        SegmentColor: JsonToken;
        ButtonSettings: JsonObject;
        SelectionSettings: JsonObject;
        DecoratorSettings: JsonObject;
        DataInStream: InStream;
    begin
        TestField(Type, Type::Route);

        if not OnlyID then begin
            LoadPrimarySettings(Route);

            MapElementShadow.Copy(Rec, true);
            MapElementShadow.SelectPoints(ID);
            if MapElementShadow.FindSet() then begin
                xMapElementShadow.Copy(MapElementShadow, true);

                repeat
                    xMapElementShadow.Get(MapElementShadow.ID);
                    if xMapElementShadow.Next(-1) <> 0 then begin
                        Clear(RouteSegment);
                        Clear(SegmentPoints);
                        Clear(PointCoordinatesA);
                        Clear(PointCoordinatesB);

                        xMapElementShadow.CalcFields("Point Coordinates");
                        if xMapElementShadow."Point Coordinates".HasValue() then begin
                            xMapElementShadow."Point Coordinates".CreateInStream(DataInStream);
                            PointCoordinatesA.ReadFrom(DataInStream);
                            SegmentPoints.Add(PointCoordinatesA);
                        end;

                        MapElementShadow.CalcFields("Point Coordinates");
                        if MapElementShadow."Point Coordinates".HasValue() then begin
                            MapElementShadow."Point Coordinates".CreateInStream(DataInStream);
                            PointCoordinatesB.ReadFrom(DataInStream);
                            SegmentPoints.Add(PointCoordinatesB);
                        end;

                        RouteSegment.Add('points', SegmentPoints);

                        MapElementShadow.CalcFields("Primary Settings");
                        if MapElementShadow."Primary Settings".HasValue() then begin
                            MapElementShadow."Primary Settings".CreateInStream(DataInStream);
                            PointSettings.ReadFrom(DataInStream);
                            PointSettings.Get('segmentColor', SegmentColor);
                            RouteSegment.Add('color', SegmentColor.AsValue());
                        end;

                        RouteSegments.Add(RouteSegment);
                    end;
                until (MapElementShadow.Next() = 0);

                Route.Add('segments', RouteSegments);
            end;

            CalcFields("Route Button Settings");
            if "Route Button Settings".HasValue() then begin
                "Route Button Settings".CreateInStream(DataInStream);
                ButtonSettings.ReadFrom(DataInStream);
                Route.Add('buttonSettings', ButtonSettings);
            end;

            CalcFields("Route Selection Settings");
            if "Route Selection Settings".HasValue() then begin
                "Route Selection Settings".CreateInStream(DataInStream);
                SelectionSettings.ReadFrom(DataInStream);
                Route.Add('selectionSettings', SelectionSettings);
            end;

            CalcFields("Route Decorator Settings");
            if "Route Decorator Settings".HasValue() then begin
                "Route Decorator Settings".CreateInStream(DataInStream);
                DecoratorSettings.ReadFrom(DataInStream);
                Route.Add('decorator', DecoratorSettings);
            end;
        end;

        Route.Add('id', ID);
    end;

    procedure CreateGeoRoute(RouteID: Text[50]; RouteName: Text[50])
    var
        SelectionSettings: JsonObject;
        DecoratorSettings: JsonObject;
        DecoratorAttributes: JsonObject;
    begin
        AssertRecordIsExist();
        TestField(Type, Type::Layer);
        TestField(Subtype, Subtype::Geo);

        CreateRoute(RouteID, RouteName);
        UpdateRouteButtonSettings(false, '');

        // Property {boolean} [selectable=false]
        SelectionSettings.Add('selectable', false);

        // Property {string} [strokeColor='#FFA524']
        SelectionSettings.Add('strokeColor', '#FFA524');

        // Property {number} [strokeOpacity=1]
        SelectionSettings.Add('strokeOpacity', 1);

        // Property {number} [strokeWidthPx=4]
        SelectionSettings.Add('strokeWidthPx', 4);

        // Property {string} [dashPattern='']
        // Defines the pattern of dashes and gaps used to paint. It's a list of comma or whitespace separated 
        // lengths and percentages. https://developer.mozilla.org/en-US/docs/Web/SVG/Attribute/stroke-dasharray
        // '5,1' will result in   ----- ----- ----- -----
        // '4' will result in     ----    ----    ----
        // '3,2' will result in   ---  ---  ---  ---  ---
        // '' will result in      -----------------------
        SelectionSettings.Add('dashPattern', '');

        SaveRouteSelectionSettings(SelectionSettings);

        // Property {string} value
        // Value to be displayed on the route. Can be any unicode value, like >, ⮞, ⯈, ⭆, etc
        // If you want more space between the arrows, just add more spaces to the value
        DecoratorSettings.Add('value', '   ⮞');

        // Property {boolean} [repeat=false] 
        // Specifies if the text should be repeated along the polyline
        DecoratorSettings.Add('repeat', false);

        // Property {boolean} [center=false] 
        // Centers the text according to the polyline's bounding box
        DecoratorSettings.Add('center', false);

        // Property {boolean} [below=false] 
        // Show text below the path
        DecoratorSettings.Add('below', false);

        // Property {number} [offset=0] 
        // Set an offset to position text relative to the polyline
        DecoratorSettings.Add('offset', 6.5);

        // Property {number | 'angle' | 'flip' | 'perpendicular'} [orientation=0]
        // {orientation: angle} - rotate to a specified angle (e.g. {orientation: 15})
        // {orientation: flip} - filps the text 180deg correction for upside down text placement on west -> east lines
        // {orientation: perpendicular} - places text at right angles to the line
        DecoratorSettings.Add('orientation', 0);

        // Property {object} [attributes={}] 
        // Object containing the attributes applied to the text tag
        // Check valid attributes https://developer.mozilla.org/en-US/docs/Web/SVG/Element/text#Attributes
        DecoratorSettings.Add('attributes', DecoratorAttributes);

        SaveRouteDecoratorSettings(DecoratorSettings);
        Modify();
    end;

    procedure UpdateRouteButtonSettings(ShowButton: boolean; ButtonLabel: Text)
    var
        ButtonSettings: JsonObject;
        DataOutStream: OutStream;
    begin
        AssertRecordIsExist();
        TestField(Type, Type::Route);

        Clear("Route Button Settings");
        "Route Button Settings".CreateOutStream(DataOutStream);

        ButtonSettings.Add('showButton', ShowButton);
        ButtonSettings.Add('label', ButtonLabel);
        ButtonSettings.WriteTo(DataOutStream);
        Modify();
    end;

    procedure UpdateRouteSelectionSettings(Property: Text; Value: Variant)
    var
        SelectionSettings: JsonObject;
        UnknownPropertyException: Label 'There is no ''%1'' property within route''s selection settings.';
    begin
        if Property <> '' then begin
            AssertRecordIsExist();
            TestField(Type, Type::Route);

            LoadRouteSelectionSettings(SelectionSettings);
            if not SelectionSettings.Contains(Property) then
                Error(UnknownPropertyException, Property);

            SelectionSettings.Replace(Property, Format(Value));
            SaveRouteSelectionSettings(SelectionSettings);
            Modify();
        end;
    end;

    procedure UpdateRouteDecoratorSettings(Property: Text; Value: Text)
    var
        DecoratorSettings: JsonObject;
        UnknownPropertyException: Label 'There is no ''%1'' property within route''s decorator settings.';
    begin
        if Property <> '' then begin
            AssertRecordIsExist();
            TestField(Type, Type::Route);

            LoadRouteDecoratorSettings(DecoratorSettings);
            if not DecoratorSettings.Contains(Property) then
                Error(UnknownPropertyException, Property);

            DecoratorSettings.Replace(Property, Format(Value));
            SaveRouteDecoratorSettings(DecoratorSettings);
            Modify();
        end;
    end;

    /* ---------------------------------------- Map Point Functions ---------------------------------------- */

    local procedure AssertParentIsSelected()
    var
        ParentException: Label 'This function can only be used when parent layer or route is selected.';
    begin
        if Type = Type::Point then
            Error(ParentException);
    end;

    local procedure LoadPointMarkerSettings(var Settings: JsonObject)
    var
        DataInStream: InStream;
    begin
        CalcFields("Point Marker Settings");
        if "Point Marker Settings".HasValue() then begin
            "Point Marker Settings".CreateInStream(DataInStream);
            Settings.ReadFrom(DataInStream);
        end;
    end;

    local procedure SavePointMarkerSettings(var Settings: JsonObject)
    var
        DataOutStream: OutStream;
    begin
        Clear("Point Marker Settings");
        "Point Marker Settings".CreateOutStream(DataOutStream);
        Settings.WriteTo(DataOutStream);
    end;

    local procedure GetPointMarkerSettings(Property: Text; var Settings: JsonObject): Boolean
    var
        UnknownPropertyException: Label 'There is no ''%1'' property within point''s marker settings.';
    begin
        if Property <> '' then begin
            AssertRecordIsExist();
            TestField(Type, Type::Point);

            LoadPointMarkerSettings(Settings);
            if not Settings.Contains(Property) then
                Error(UnknownPropertyException, Property);

            exit(true);
        end;
    end;

    local procedure CreatePoint(PointID: Text[50]; PointName: Text[50])
    var
        MapElementShadow: Record "Meta UI Map Element" temporary;
        Settings: JsonObject;
    begin
        MapElementShadow.Copy(Rec, true);

        Clear(Rec);
        ID := PointID;
        Name := PointName;
        Type := Type::Point;
        "Parent ID" := MapElementShadow.ID;

        if MapElementShadow.Type <> MapElementShadow.Type::Layer then begin
            MapElementShadow.Get(MapElementShadow."Parent ID");

            // Default color ot the route segment
            Settings.Add('segmentColor', 'RoyalBlue');
        end;

        Settings.Add('layerId', MapElementShadow.ID);
        SavePrimarySettings(Settings);
    end;

    local procedure PointToJSON(OnlyID: Boolean) Point: JsonObject
    var
        Settings: JsonObject;
        SettingsToken: JsonToken;
        Coordinates: JsonObject;
        PopupSettings: JsonObject;
        MarkerSettings: JsonObject;
        DataInStream: InStream;
    begin
        TestField(Type, Type::Point);

        if not OnlyID then begin
            LoadPrimarySettings(Point);

            CalcFields("Point Coordinates");
            if "Point Coordinates".HasValue() then begin
                "Point Coordinates".CreateInStream(DataInStream);
                Coordinates.ReadFrom(DataInStream);
                Point.Add('coordinates', Coordinates);
            end;

            CalcFields("Point Popup Settings");
            if "Point Popup Settings".HasValue() then begin
                "Point Popup Settings".CreateInStream(DataInStream);
                PopupSettings.ReadFrom(DataInStream);
                Point.Add('popup', PopupSettings);
            end;

            LoadPointMarkerSettings(MarkerSettings);
            Point.Add('settings', MarkerSettings);

            Point.Add('id', ID);
        end else begin
            LoadPrimarySettings(Settings);
            Settings.Get('layerId', SettingsToken);

            Point.Add('id', ID);
            Point.Add('layerId', SettingsToken.AsValue());
        end;
    end;

    procedure CreateCirclePoint(PointID: Text[50]; PointName: Text[50]): Boolean
    var
        MarkerSettings: JsonObject;
    begin
        AssertRecordIsExist();
        AssertParentIsSelected();

        CreatePoint(PointID, PointName);
        Subtype := Subtype::Circle;

        // Property {string} [fillColor='#FFA524']
        MarkerSettings.Add('fillColor', '#FFA524');

        // Property {number} [fillOpacity=1]
        MarkerSettings.Add('fillOpacity', 1);

        // Property {number} [radius=10]
        MarkerSettings.Add('radius', 10);

        // Property {string} [strokeColor='#4f90ca']
        MarkerSettings.Add('strokeColor', '#4f90ca');

        // Property {number} [strokeOpacity=1]
        MarkerSettings.Add('strokeOpacity', 1);

        // Property {number} [strokeWidthPx=2]
        MarkerSettings.Add('strokeWidthPx', 2);

        SavePointMarkerSettings(MarkerSettings);
        exit(Insert(true));
    end;

    procedure CreateIconPoint(PointID: Text[50]; PointName: Text[50]): Boolean
    var
        Numbers: JsonArray;
        MarkerSettings: JsonObject;
    begin
        AssertRecordIsExist();
        AssertParentIsSelected();

        CreatePoint(PointID, PointName);
        Subtype := Subtype::Icon;

        // Property {string} [iconUrl='']
        MarkerSettings.Add('iconUrl', '');

        // Property {string} [shadowUrl='']
        MarkerSettings.Add('shadowUrl', '');

        // Property {[number,number]} iconAnchor
        MarkerSettings.Add('iconAnchor', Numbers);

        // Property {[number,number]} popupAnchor
        MarkerSettings.Add('popupAnchor', Numbers);

        // Property {[number,number]} iconSize
        MarkerSettings.Add('iconSize', Numbers);

        // Property {[number,number]} shadowSize
        MarkerSettings.Add('shadowSize', Numbers);

        // Property {[number,number]} shadowAnchor
        MarkerSettings.Add('shadowAnchor', Numbers);

        SavePointMarkerSettings(MarkerSettings);
        exit(Insert(true));
    end;

    procedure CreateHeatPoint(PointID: Text[50]; PointName: Text[50]): Boolean
    begin
        AssertRecordIsExist();
        AssertParentIsSelected();
        TestField(Subtype, Subtype::Heat);

        CreatePoint(PointID, PointName);
        Subtype := Subtype::Intensity;

        //ToDo: Implement default settings

        exit(Insert(true));
    end;

    procedure UpdatePointCoordinates(Latitude: Decimal; Longitude: Decimal)
    var
        Coordinates: JsonObject;
        DataOutStream: OutStream;
    begin
        AssertRecordIsExist();
        TestField(Type, Type::Point);

        Clear("Point Coordinates");
        "Point Coordinates".CreateOutStream(DataOutStream);

        Coordinates.Add('latitude', Latitude);
        Coordinates.Add('longitude', Longitude);
        Coordinates.WriteTo(DataOutStream);
        Modify();
    end;

    procedure UpdatePointPopupSettings(Content: Text; AutoClose: Boolean; CloseOnClick: Boolean)
    var
        PopupSettings: JsonObject;
        DataOutStream: OutStream;
    begin
        AssertRecordIsExist();
        TestField(Type, Type::Point);

        Clear("Point Popup Settings");
        "Point Popup Settings".CreateOutStream(DataOutStream);

        PopupSettings.Add('text', Content);
        PopupSettings.Add('autoClose', AutoClose);
        PopupSettings.Add('closeOnClick', CloseOnClick);
        PopupSettings.WriteTo(DataOutStream);
        Modify();
    end;

    procedure UpdatePointMarkerSettings(Property: Text; Value: Variant)
    var
        MarkerSettings: JsonObject;
    begin
        if GetPointMarkerSettings(Property, MarkerSettings) then begin
            MarkerSettings.Replace(Property, Format(Value));
            SavePointMarkerSettings(MarkerSettings);
            Modify();
        end;
    end;

    procedure UpdatePointMarkerSettings_Arr(Property: Text; Number1: Integer; Number2: Integer)
    var
        Numbers: JsonArray;
        MarkerSettings: JsonObject;
    begin
        if GetPointMarkerSettings(Property, MarkerSettings) then begin
            Numbers.Add(Number1);
            Numbers.Add(Number2);

            MarkerSettings.Replace(Property, Numbers);
            SavePointMarkerSettings(MarkerSettings);
            Modify();
        end;
    end;

    procedure UpdatePointRouteSegmentColor(Color: Text)
    var
        Settings: JsonObject;
    begin
        LoadPrimarySettings(Settings);
        Settings.Replace('segmentColor', Color);
        SavePrimarySettings(Settings);
        Modify();
    end;

    /* ------------------------------------------ Global Functions ----------------------------------------- */

    procedure UpdateDataMarkProperty(Value: Text[50])
    begin
        "Data Mark" := Value;
        Modify();
    end;

    procedure ToJSON(OnlyID: Boolean) Element: JsonObject
    begin
        AssertRecordIsExist();

        case Type of
            Type::Layer:
                exit(LayerToJSON(OnlyID));
            Type::Route:
                exit(RouteToJSON(OnlyID));
            Type::Point:
                exit(PointToJSON(OnlyID));
        end;
    end;

    procedure LayersControlToJSON(OnlyID: Boolean) Control: JsonObject
    var
        LayerControl: JsonObject;
        BaseLayerControls: JsonArray;
        OverlayLayerControls: JsonArray;
    begin
        Control.Add('id', 'Control');

        if not OnlyID then begin
            SelectLayers('');
            if FindSet() then
                repeat
                    Clear(LayerControl);

                    // Property {string} id 
                    // Existing layer id
                    LayerControl.Add('id', ID);

                    // Property {string} label 
                    // Label that will be used in control
                    LayerControl.Add('label', Name);

                    if "Base Layer" then
                        BaseLayerControls.Add(LayerControl)
                    else
                        OverlayLayerControls.Add(LayerControl);
                until (Next() = 0);

            // Property {LayerControl[]} [baseLayers=[]] 
            // Base layers will be switched with radio buttons
            Control.Add('baseLayers', BaseLayerControls);

            // Property {LayerControl[]} [overlayLayers=[]] 
            // Overlays will be switched with checkboxes
            Control.Add('overlayLayers', OverlayLayerControls);

            // Property {boolean} [autoZIntex=true] 
            // If true, the control will assign zIndexes in increasing order to all of its layers so that the order is preserved when switching them on/off
            Control.Add('autoZIntex', true);

            // Property {boolean} [collapsed=true] 
            // If true, the control will be collapsed into an icon and expanded on mouse hover or touch
            Control.Add('collapsed', true);

            // Property {boolean} [hideSingleBase=false] 
            // If true, the base layers in the control will be hidden when there is only one
            Control.Add('hideSingleBase', false);

            // Property {string} [position='topright'] 
            // The position of the control (one of the map corners). Possible values are 'topleft', 'topright', 'bottomleft' or 'bottomright'
            Control.Add('position', 'topright');
        end;
    end;

    /* ---------------------------------------- Navigation Functions --------------------------------------- */

    procedure SwitchToParent()
    begin
        AssertRecordIsExist();
        TestField("Parent ID");

        Get("Parent ID");
    end;

    procedure SelectBaseLayers()
    begin
        Reset();
        SetCurrentKey("Serial No.");
        SetRange("Base Layer", true);
        SetRange(Type, Type::Layer);
    end;

    procedure SelectLayers(LayerIDFilter: Text)
    begin
        Reset();
        SetCurrentKey("Serial No.");
        SetFilter(ID, LayerIDFilter);
        SetRange(Type, Type::Layer);
    end;

    procedure SelectRoutes(LayerIDFilter: Text)
    begin
        Reset();
        SetCurrentKey("Serial No.");
        SetFilter("Parent ID", LayerIDFilter);
        SetRange(Type, Type::Route);
    end;

    procedure SelectPoints(ParentIDFilter: Text)
    begin
        Reset();
        SetCurrentKey("Serial No.");
        SetRange(Type, Type::Point);
        SetFilter("Parent ID", ParentIDFilter);
    end;

    /* ------------------------------------------ Events Functions ----------------------------------------- */

    [IntegrationEvent(false, false)]
    local procedure OnMapStructureInitiate(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    begin
        // This event is meant to be the starting point in the map-drawing process. 
        // It is raised by InitiateMapStructure method that must be called in the beginning.
        // Basically, on this event subscriber, it requires future map structure (numbers of base and overlay layers).  
    end;

    [IntegrationEvent(false, false)]
    local procedure OnElementSelectionChanged(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    begin
        // This event is a response for map elements selection.
        // It is raised by multiple methods depending on element being selected:
        //  - Single marker or route raised by ManageSingleSelection method;
        //  - Markers lasso raised by ManageMultiSelection method;
        //  - Layer raised by ManageLayerVisibility method
    end;

    // ToDo: Update Methods must use value types when it is no string value...
    // ToDo: Possible restrictions for layers: is to have at least one base ???
    // ToDo: Include Map Settigns for different providers...
    // ToDo: Allow multiple controls & setteing for them...
}