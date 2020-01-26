codeunit 50256 "Meta UI Map Routines"
{
    EventSubscriberInstance = StaticAutomatic;

    var
        RedIconPath: Label 'images/red.truck.19.png';
        BlueIconPath: Label 'images/blue.truck.19.png';
        GreenIconPath: Label 'images/green.truck.19.png';
        BlackIconPath: Label 'images/black.truck.19.png';
        AddressPopupPattern: Label 'Description: %1<br>Street: %2<br>Post Code: %3<br>City: %4';
        EquipmentPopupPattern: Label 'Truck No.: %1<br>Driver Name: %2';
        EquipmentDuplicateMessage: Label 'The %1 with %2=%3 already exists.';
        LoadingMetersPopupPattern: Label 'Loading Meters: %1';

    [EventSubscriber(ObjectType::Table, Database::"Meta UI Map Element", 'OnMapSettingsInitiate', '', false, false)]
    local procedure MetaUIMapElement_OnMapSettingsInitiate(var MapSettings: JsonObject)
    begin
        
        MapSettings := SettingsToJSON();
    end;

   local procedure SettingsToJSON() Settings: JsonObject
    var
        TrOrdSetup: Record "Transport Order Setup";
    begin
        with TrOrdSetup do begin
            Get;

            Settings.Add('type', 0);
            Settings.Add('baseUrl', "Map Account URL");

            if "Map Username" <> '' then
                Settings.Add('username', "Map Username");

            if "Map Password" <> '' then
                Settings.Add('password', "Map Password");

            if "Map Token" <> '' then
                Settings.Add('token', "Map Token");

            if "Map Profile" <> '' then
                Settings.Add('profile', "Map Profile");

            if "Map Subdomains" <> '' then
                Settings.Add('subdomains', "Map Subdomains");

            Settings.Add('providerSettings', Settings);
        end;
        /*** EXAMPLE OF PROVIDER SETTINGS FOR OPENSTREETMAPS ***/
        // Settings.Add('type', 1);
        // Settings.Add('baseUrl', 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png');
    end;

    [EventSubscriber(ObjectType::Table, Database::"Meta UI Map Element", 'OnMapStructureInitiate', '', false, false)]
    local procedure MetaUIMapElement_OnMapStructureInitiate(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Trip: Record Trip;
        TransportOrderLine: Record "Transport Order Line";
        UnknownSourceException: Label 'The source reference ''%1'' is not supported.';
    begin
        case Source.Number of
            Database::Address:
                MapElementBuffer.CreateGeoLayer('00.Base.Geo.Address', 'Address Location', true);

            Database::Equipment:
                MapElementBuffer.CreateGeoLayer('00.Base.Geo.Equipment', 'Equipment Location', true);

            Database::"Find Or Create Address Args.":
                MapElementBuffer.CreateGeoLayer('00.Base.Geo.AddressArgument', 'Address Location', true);

            Database::Shipment:
                begin
                    MapElementBuffer.CreateClusterLayer('00.Base.Cluster.Shipments', 'Shipments', true);

                    MapElementBuffer.CreateGeoLayer('01.Overlay.Geo.MyTrucks', 'My Trucks', false);
                    MapElementBuffer.CreateGeoLayer('02.Overlay.Geo.IttervoortTrucks', 'Ittervoort Trucks', false);
                    MapElementBuffer.CreateGeoLayer('03.Overlay.Geo.DeventerTrucks', 'Deventer Trucks', false);
                    MapElementBuffer.CreateGeoLayer('04.Overlay.Geo.ITTLTrucks', 'ITTL Trucks', false);
                    MapElementBuffer.CreateGeoLayer('05.Overlay.Geo.NearbyTrucks', 'Nearby Trucks', false);
                    MapElementBuffer.CreateGeoLayer('06.Overlay.Geo.FindTrips', 'Find Trips', false);
                end;

            Database::"Transics Activity Report":
                MapElementBuffer.CreateGeoLayer('00.Base.Geo.TransicsActivities', 'Transics Activities', true);

            Database::"Transport Order Line":
                begin
                    Source.SetTable(TransportOrderLine);
                    case TransportOrderLine.FilterGroup of
                        100:
                            MapElementBuffer.CreateGeoLayer('00.Base.Geo.PlanningOptions', 'Planning Options', true);
                        200:
                            MapElementBuffer.CreateGeoLayer('00.Base.Geo.TransportOrderLine', 'Transport Order Line', true);
                    end;
                end;

            Database::"Transport Planned Activity":
                MapElementBuffer.CreateGeoLayer('00.Base.Geo.TransportActivities', 'Transport Activities', true);

            Database::Trip:
                begin
                    Source.SetTable(Trip);
                    if Trip.Count > 1 then begin // Dynamic Trip Layers Planning
                        if Trip.FindSet() then
                            repeat
                                MapElementBuffer.CreateGeoLayer(
                                    StrSubstNo('00.Overlay.Geo.Trip.%1', Trip."No."), StrSubstNo('Trip No.: %1', Trip."No."), false);
                                MapElementBuffer.Selected := true;
                                MapElementBuffer.Modify;
                            until (Trip.Next = 0);
                    end else
                        MapElementBuffer.CreateGeoLayer('00.Base.Geo.ActiveTrip', 'Active Trip', true);

                    MapElementBuffer.CreateGeoLayer('01.Overlay.Geo.MyTrucks', 'My Trucks', false);
                    MapElementBuffer.CreateGeoLayer('02.Overlay.Geo.IttervoortTrucks', 'Ittervoort Trucks', false);
                    MapElementBuffer.CreateGeoLayer('03.Overlay.Geo.DeventerTrucks', 'Deventer Trucks', false);
                    MapElementBuffer.CreateGeoLayer('04.Overlay.Geo.ITTLTrucks', 'ITTL Trucks', false);

                    if Trip.Count = 1 then
                        MapElementBuffer.CreateGeoLayer('07.Overlay.Geo.Predictions', 'Predictions', false);
                end;

            Database::"TX Tango Consultation":
                MapElementBuffer.CreateGeoLayer('00.Base.Geo.Consultations', 'Consultations Trip', true);

            else
                Message(UnknownSourceException, Source);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Meta UI Map Element", 'OnElementSelectionChanged', '', false, false)]
    local procedure MetaUIMapElement_OnElementSelectionChanged(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Trip: Record Trip;
        Shipment: Record Shipment;
        DynamicTripID: Code[20];
    begin
        case MapElementBuffer.Type of
            MapElementBuffer.Type::Layer:
                if MapElementBuffer.Selected then begin
                    case MapElementBuffer.ID of
                        '00.Base.Cluster.Shipments':
                            ShipmentsToMapElements(Source, MapElementBuffer);

                        '00.Base.Geo.ActiveTrip':
                            TripsToMapElements(Source, MapElementBuffer);
                        '00.Base.Geo.Address':
                            AddressToMapElements(Source, MapElementBuffer);
                        '00.Base.Geo.AddressArgument':
                            AddressArgumentToMapElements(Source, MapElementBuffer);
                        '00.Base.Geo.Consultations':
                            ConsultationsToMapElements(Source, MapElementBuffer);
                        '00.Base.Geo.Equipment':
                            EquipmentToMapElements(Source, MapElementBuffer);
                        '00.Base.Geo.PlanningOptions':
                            PlanningOptionsToMapElements(Source, MapElementBuffer);
                        '00.Base.Geo.TransicsActivities':
                            TransicsActivitiesToMapElements(Source, MapElementBuffer);
                        '00.Base.Geo.TransportActivities':
                            TransportActivitiesToMapElements(Source, MapElementBuffer);
                        '00.Base.Geo.TransportOrderLine':
                            TransportOrderLineToMapElements(Source, MapElementBuffer);

                        '01.Overlay.Geo.MyTrucks':
                            MyTrucksToMapElements(MapElementBuffer);
                        '02.Overlay.Geo.IttervoortTrucks':
                            TrucksToMapElements('LIMBURG', MapElementBuffer);
                        '03.Overlay.Geo.DeventerTrucks':
                            TrucksToMapElements('DEVENTER', MapElementBuffer);
                        '04.Overlay.Geo.ITTLTrucks':
                            ITTLTrucksToMapElements(MapElementBuffer);
                        '05.Overlay.Geo.NearbyTrucks':
                            NearTrucksToMapElements(MapElementBuffer);
                        '06.Overlay.Geo.FindTrips':
                            FindTripsForSelectedTrucks(MapElementBuffer);
                        '07.Overlay.Geo.Predictions':
                            PredictionsToMapElements(Source, MapElementBuffer);
                    end;

                    // Dynamic Trip Layers Processing
                    if StrPos(MapElementBuffer.ID, 'Overlay.Geo.Trip.') > 0 then begin
                        DynamicTripID := CopyStr(MapElementBuffer.ID, 21);
                        Source.SetTable(Trip);
                        Trip.SetRange("No.", DynamicTripID);
                        Source.GetTable(Trip);
                        TripsToMapElements(Source, MapElementBuffer);
                    end;
                end;

            MapElementBuffer.Type::Route:
                ; // ToDo: Update visuals for selected route

            MapElementBuffer.Type::Point:
                case MapElementBuffer.Subtype of
                    MapElementBuffer.Subtype::Circle:
                        if MapElementBuffer.Selected then begin
                            MapElementBuffer.UpdatePointMarkerSettings('strokeColor', 'black');

                            if Source.Number = Database::Shipment then begin
                                Shipment.SetRange(Id, MapElementBuffer.ID);
                                if Shipment.FindFirst() then
                                    OnShipmentMarkerSelection(Shipment);
                            end;
                        end else
                            MapElementBuffer.UpdatePointMarkerSettings('strokeColor', '#4f90ca');

                    MapElementBuffer.Subtype::Icon:
                        if not MapElementBuffer.Selected then begin
                            case MapElementBuffer."Data Mark" of
                                RedIconPath:
                                    MapElementBuffer.UpdatePointMarkerSettings('iconUrl', RedIconPath);
                                GreenIconPath:
                                    MapElementBuffer.UpdatePointMarkerSettings('iconUrl', GreenIconPath);
                                BlackIconPath:
                                    MapElementBuffer.UpdatePointMarkerSettings('iconUrl', BlackIconPath);
                            end;
                        end else
                            MapElementBuffer.UpdatePointMarkerSettings('iconUrl', BlueIconPath);

                    MapElementBuffer.Subtype::Intensity:
                        ; // ToDo: Update visuals for selected Heat point
                end;
        end;
    end;

    local procedure AddressToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Address: Record Address;
    begin
        Source.SetTable(Address);

        MapElementBuffer.CreateCirclePoint(Address."No.", Address.Description);
        MapElementBuffer.UpdatePointCoordinates(Address.Latitude, Address.Longitude);
        MapElementBuffer.UpdatePointPopupSettings(StrSubstNo(AddressPopupPattern,
            Address.Description, Address.Street, Address."Post Code", Address.City), true, false);
    end;

    local procedure AddressArgumentToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        AddressArgument: Record "Find Or Create Address Args.";
    begin
        Source.SetTable(AddressArgument);

        MapElementBuffer.CreateCirclePoint(Format(AddressArgument."Entry No."), '');
        MapElementBuffer.UpdatePointCoordinates(AddressArgument.Latitude, AddressArgument.Longitude);
        MapElementBuffer.UpdatePointPopupSettings(AddressArgument.City, true, false);
    end;

    local procedure ConsultationsToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        TXTangoConsultation: Record "TX Tango Consultation";
    begin
        Source.SetTable(TXTangoConsultation);

        TXTangoConsultation.SetCurrentKey("Trip No.", "Arrival Date");
        TXTangoConsultation.SetRange("Trip No.", TXTangoConsultation."Trip No.");
        if TXTangoConsultation.FindSet() then begin
            MapElementBuffer.CreateGeoRoute(TXTangoConsultation."Trip No.", '');

            repeat
                MapElementBuffer.CreateCirclePoint(TXTangoConsultation."Place ID", '');
                MapElementBuffer.UpdatePointCoordinates(TXTangoConsultation.Latitude, TXTangoConsultation.Longitude);
                MapElementBuffer.UpdatePointMarkerSettings('radius', 7);
                MapElementBuffer.UpdatePointRouteSegmentColor('red');

                MapElementBuffer.SwitchToParent();
            until (TXTangoConsultation.Next() = 0);
        end;
    end;

    local procedure EquipmentToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Equipment: Record Equipment;
    begin
        Source.SetTable(Equipment);

        MapElementBuffer.CreateCirclePoint(Equipment."No.", Equipment.Description);
        MapElementBuffer.UpdatePointCoordinates(Equipment."Last Latitude", Equipment."Last Longitude");
        MapElementBuffer.UpdatePointPopupSettings(Equipment."Last City", true, false);
    end;

    local procedure PlanningOptionsToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Address: Record Address;
        Shipment: Record Shipment;
        TransportOrderLine: Record "Transport Order Line";
        Index: Integer;
    begin
        Source.SetTable(TransportOrderLine);

        Shipment.SetRange("Transport Order No.", TransportOrderLine."Transport Order No.");
        Shipment.SetRange("Transport Order Line No.", TransportOrderLine."Line No.");
        Shipment.SetRange("Irr. No.", TransportOrderLine."Active Irregularity No.");
        Shipment.SetAutoCalcFields("Loading Meters");
        if not Shipment.FindSet() then
            exit;

        MapElementBuffer.CreateGeoRoute(
            TransportOrderLine."Transport Order No." + Format(TransportOrderLine."Line No."), '');

        for Index := 0 to Shipment.Count() do begin
            if Index <> 0 then begin
                Address.Get(Shipment."TO Address No.");
                MapElementBuffer.CreateCirclePoint(Shipment.Id, Shipment.Description);
            end else begin
                Address.Get(TransportOrderLine."From Address No.");
                MapElementBuffer.CreateCirclePoint(Format(TransportOrderLine."Line No."), '');
            end;

            MapElementBuffer.UpdatePointCoordinates(Address.Latitude, Address.Longitude);
            MapElementBuffer.UpdatePointPopupSettings(
                StrSubstNo(LoadingMetersPopupPattern, Shipment."Loading Meters") + '<br>' +
                StrSubstNo(AddressPopupPattern, Address.Description, Address.Street,
                    Address."Post Code", Address.City), true, false);

            MapElementBuffer.UpdatePointMarkerSettings('radius', 10 + Round(Shipment."Loading Meters", 1, '>'));

            case Shipment."Lane Type" of
                Shipment."Lane Type"::Collection,
                Shipment."Lane Type"::Delivery:
                    MapElementBuffer.UpdatePointRouteSegmentColor(Shipment.GetColor());

                Shipment."Lane Type"::Direct:
                    MapElementBuffer.UpdatePointRouteSegmentColor('red');

                Shipment."Lane Type"::Linehaul:
                    MapElementBuffer.UpdatePointRouteSegmentColor('blue');

                Shipment."Lane Type"::"Post Delivery Agent",
                Shipment."Lane Type"::"Pre Collection Agent",
                Shipment."Lane Type"::Service,
                Shipment."Lane Type"::"Temporary Collection",
                Shipment."Lane Type"::"Temporary Delivery":
                    MapElementBuffer.UpdatePointRouteSegmentColor('grey');
            end;

            if Index <> 0 then begin
                if Shipment."Plan-ID" = UserId() then
                    MapElementBuffer.UpdatePointAsSelected(Source);

                Shipment.Next();
            end;

            MapElementBuffer.SwitchToParent();
        end;
    end;

    local procedure ShipmentsToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Address: Record Address;
        Shipment: Record Shipment;
    begin
        Source.SetTable(Shipment);

        Shipment.SetAutoCalcFields("Loading Meters");
        if Shipment.FindSet() then
            repeat
                case Shipment."Lane Type" of
                    Shipment."Lane Type"::Collection:
                        Address.Get(Shipment."From Address No.");

                    Shipment."Lane Type"::Delivery:
                        Address.Get(Shipment."To Address No.");
                end;

                MapElementBuffer.CreateCirclePoint(Shipment.id, Shipment.Description);
                MapElementBuffer.UpdatePointCoordinates(Address.Latitude, Address.Longitude);
                MapElementBuffer.UpdatePointPopupSettings(
                    StrSubstNo(LoadingMetersPopupPattern, Shipment."Loading Meters") + '<br>' +
                    StrSubstNo(AddressPopupPattern, Address.Description, Address.Street,
                        Address."Post Code", Address.City), true, false);

                MapElementBuffer.UpdatePointMarkerSettings('fillColor', Shipment.GetColor());
                MapElementBuffer.UpdatePointMarkerSettings('radius', 10 + Round(Shipment."Loading Meters", 1, '>'));

                if Shipment."Plan-ID" = UserId() then
                    MapElementBuffer.UpdatePointAsSelected(Source);

                MapElementBuffer.SwitchToParent();
            until (Shipment.Next() = 0);
    end;

    local procedure TransicsActivitiesToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        TransicsActivityReport: Record "Transics Activity Report";
        xVehicleID: Code[20];
        Index: Integer;
    begin
        Source.SetTable(TransicsActivityReport);

        TransicsActivityReport.SetCurrentKey("Trip No.", BeginDate);
        TransicsActivityReport.SetRange("Trip No.", TransicsActivityReport."Trip No.");
        TransicsActivityReport.SetFilter(Latitude, '<>0');
        TransicsActivityReport.SetFilter(Longitude, '<>0');
        if TransicsActivityReport.FindSet() then
            repeat
                if TransicsActivityReport.VehicleID <> xVehicleID then begin
                    if MapElementBuffer."Parent ID" <> '' then
                        MapElementBuffer.SwitchToParent();

                    MapElementBuffer.CreateGeoRoute(TransicsActivityReport.VehicleID, '');
                    xVehicleID := TransicsActivityReport.VehicleID;
                    Index := Index + 1;
                end;

                MapElementBuffer.CreateCirclePoint(Format(TransicsActivityReport.ActID), '');
                MapElementBuffer.UpdatePointCoordinates(
                    TransicsActivityReport.Latitude, TransicsActivityReport.Longitude);
                MapElementBuffer.UpdatePointMarkerSettings('radius', 7);

                case Index of
                    1:
                        MapElementBuffer.UpdatePointRouteSegmentColor('red');
                    2:
                        MapElementBuffer.UpdatePointRouteSegmentColor('blue');
                    3:
                        MapElementBuffer.UpdatePointRouteSegmentColor('green');
                    4:
                        MapElementBuffer.UpdatePointRouteSegmentColor('black');
                end;

                MapElementBuffer.SwitchToParent();
            until (TransicsActivityReport.Next() = 0);
    end;

    local procedure TransportActivitiesToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Trip: Record Trip;
        TransportPlannedActivity: Record "Transport Planned Activity";
        RecReference: RecordRef;
    begin
        Source.SetTable(TransportPlannedActivity);
        Trip.Get(TransportPlannedActivity."Trip No.");

        RecReference.GetTable(Trip);
        RecReference.SetRecFilter();
        TripsToMapElements(RecReference, MapElementBuffer);
    end;

    local procedure TransportOrderLineToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Address: Record Address;
        Shipment: Record Shipment;
        TransportOrderLine: Record "Transport Order Line";
    begin
        Source.SetTable(TransportOrderLine);

        Shipment.SetRange("Transport Order No.", TransportOrderLine."Transport Order No.");
        Shipment.SetRange("Transport Order Line No.", TransportOrderLine."Line No.");
        Shipment.SetRange("Irr. No.", TransportOrderLine."Active Irregularity No.");
        if Shipment.FindSet() then begin
            MapElementBuffer.CreateGeoRoute(
                TransportOrderLine."Transport Order No." + Format(TransportOrderLine."Line No."), '');

            repeat
                Address.Get(Shipment."From Address No.");

                MapElementBuffer.CreateCirclePoint(Shipment.Id, Shipment.Description);
                MapElementBuffer.UpdatePointCoordinates(Address.Latitude, Address.Longitude);
                MapElementBuffer.UpdatePointPopupSettings(StrSubstNo(AddressPopupPattern,
                    Address.Description, Address.Street, Address."Post Code", Address.City), true, false);
                MapElementBuffer.UpdatePointMarkerSettings('radius', 7);

                MapElementBuffer.SwitchToParent();
            until (Shipment.Next() = 0);

            if Address.Get(TransportOrderLine."To Address No.") then begin
                MapElementBuffer.CreateCirclePoint(Format(TransportOrderLine."Line No."), '');
                MapElementBuffer.UpdatePointCoordinates(Address.Latitude, Address.Longitude);
                MapElementBuffer.UpdatePointPopupSettings(StrSubstNo(AddressPopupPattern,
                    Address.Description, Address.Street, Address."Post Code", Address.City), true, false);
                MapElementBuffer.UpdatePointMarkerSettings('radius', 7);
            end;
        end;
    end;

    local procedure TripsToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Trip: Record Trip;
        Address: Record Address;
        Shipment: Record Shipment;
        TransportPlannedActivity: Record "Transport Planned Activity";
    begin
        Source.SetTable(Trip);

        if Trip.FindSet() then begin
            TransportPlannedActivity.SetCurrentKey("Trip No.", "Stop No.");
            TransportPlannedActivity.SetFilter("Address No.", '<>%1', '');
            TransportPlannedActivity.SetFilter(Timetype, '<>%1', TransportPlannedActivity.Timetype::Rest);

            repeat
                TransportPlannedActivity.SetRange("Trip No.", Trip."No.");
                if TransportPlannedActivity.FindSet() then begin
                    MapElementBuffer.CreateGeoRoute(Trip."No.", CopyStr(Trip.Name, 1, MaxStrLen(MapElementBuffer.Name)));

                    repeat
                        Address.Get(TransportPlannedActivity."Address No.");

                        MapElementBuffer.CreateCirclePoint(
                            Format(TransportPlannedActivity."Entry No."), Format(TransportPlannedActivity.Timetype));

                        MapElementBuffer.UpdatePointCoordinates(Address.Latitude, Address.Longitude);
                        MapElementBuffer.UpdatePointPopupSettings(TransportPlannedActivity."Address Description", true, false);

                        case true of
                            TransportPlannedActivity.IsLoad():
                                MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'orange');
                            TransportPlannedActivity.IsUnload():
                                MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'lime');
                        end;

                        MapElementBuffer.UpdatePointMarkerSettings('radius', 7);
                        if TransportPlannedActivity."Realised Ending Date-Time" <> 0DT then
                            MapElementBuffer.UpdatePointRouteSegmentColor('grey');

                        MapElementBuffer.SwitchToParent();
                    until (TransportPlannedActivity.Next() = 0);

                    MapElementBuffer.SwitchToParent();
                end;
            until (Trip.Next() = 0);
        end;
    end;

    local procedure IsValidCoordinates(Latitude: Decimal; Longitude: Decimal): Boolean
    begin
        if (Latitude in [38 .. 70]) and (Longitude in [-6 .. 25]) then
            exit(true);
    end;

    local procedure MyTrucksToMapElements(var MapElementBuffer: Record "Meta UI Map Element")
    var
        Equipment: Record Equipment;
        UserSetup: Record "User Setup";
        PeriodicalAllocation: Record "Periodical Allocation";
        ParentID: Text;
    begin
        UserSetup.Get(UserId());
        UserSetup.TestField("Planner No.");

        ParentID := MapElementBuffer.ID; // SEB: Is used for navigation, becase there is problems with data duplicates

        PeriodicalAllocation.SetRange(PeriodicalAllocation.Type, PeriodicalAllocation.Type::Truck);
        PeriodicalAllocation.SetRange("Default Planner No.", UserSetup."Planner No.");
        if PeriodicalAllocation.FindSet() then
            repeat
                Equipment.Get(PeriodicalAllocation."No.", Equipment.Type::Truck);
                if IsValidCoordinates(Equipment."Last Latitude", Equipment."Last Longitude") then begin
                    if MapElementBuffer.CreateIconPoint(Equipment.Id, Equipment.Description) then begin
                        MapElementBuffer.UpdatePointCoordinates(Equipment."Last Latitude", Equipment."Last Longitude");
                        MapElementBuffer.UpdatePointPopupSettings(
                            StrSubstNo(EquipmentPopupPattern, Equipment."No.", Equipment."Last Driver Name"), true, false);

                        MapElementBuffer.UpdatePointMarkerSettings('iconUrl', RedIconPath);
                        MapElementBuffer.UpdateDataMarkProperty(RedIconPath);
                        MapElementBuffer.SwitchToParent();
                    end else begin
                        Message(EquipmentDuplicateMessage,
                            MapElementBuffer.TableCaption, MapElementBuffer.FieldCaption(ID), MapElementBuffer.ID);

                        MapElementBuffer.Get(ParentID);
                    end;
                end;
            until (PeriodicalAllocation.Next() = 0);
    end;

    local procedure TrucksToMapElements(PlanningFilter: Code[10]; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Trip: Record Trip;
        Equipment: Record Equipment;
        IconURLPath: Text;
        ParentID: Text;
    begin
        ParentID := MapElementBuffer.ID; // SEB: Is used for navigation, becase there is problems with data duplicates

        Trip.SetRange("Planning Code", PlanningFilter);
        Trip.SetRange(Active, true);
        // Trip.SetRange("Board Computer Mandatory", true); // SEB: This break down the client !!!
        if Trip.FindSet() then begin
            repeat
                if Trip."Board Computer Mandatory" then // SEB: Use this instead filtering, due to issue mentioned earlier...
                    if Equipment.Get(Trip."First Truck No.", Equipment.Type::Truck) then
                        Equipment.Mark := true;
            until (Trip.Next() = 0);

            Equipment.MarkedOnly := true;
            If Equipment.FindSet() then
                repeat
                    if IsValidCoordinates(Equipment."Last Latitude", Equipment."Last Longitude") then begin
                        if MapElementBuffer.CreateIconPoint(Equipment.Id, Equipment.Description) then begin
                            MapElementBuffer.UpdatePointCoordinates(Equipment."Last Latitude", Equipment."Last Longitude");
                            MapElementBuffer.UpdatePointPopupSettings(
                                StrSubstNo(EquipmentPopupPattern, Equipment."No.", Equipment."Last Driver Name"), true, false);

                            case PlanningFilter of
                                'LIMBURG':
                                    IconURLPath := GreenIconPath;
                                'DEVENTER':
                                    IconURLPath := RedIconPath;
                            end;

                            MapElementBuffer.UpdatePointMarkerSettings('iconUrl', IconURLPath);
                            MapElementBuffer.UpdateDataMarkProperty(IconURLPath);
                            MapElementBuffer.SwitchToParent();
                        end else begin
                            Message(EquipmentDuplicateMessage,
                                MapElementBuffer.TableCaption, MapElementBuffer.FieldCaption(ID), MapElementBuffer.ID);

                            MapElementBuffer.Get(ParentID);
                        end;

                    end;
                until (Equipment.Next() = 0);
        end;
    end;

    local procedure ITTLTrucksToMapElements(var MapElementBuffer: Record "Meta UI Map Element")
    var
        Equipment: Record Equipment;
        ParentID: Text;
    begin
        ParentID := MapElementBuffer.ID; // SEB: Is used for navigation, becase there is problems with data duplicates

        Equipment.SetRange(Type, Equipment.Type::Truck);
        Equipment.SetRange("Default Company", 'UAB ITTL');
        Equipment.SetFilter("Out Of Service Date", '%1|%2..', 0D, Today());
        if Equipment.FindSet() then
            repeat
                if IsValidCoordinates(Equipment."Last Latitude", Equipment."Last Longitude") then begin
                    if MapElementBuffer.CreateIconPoint(Equipment.Id, Equipment.Description) then begin
                        MapElementBuffer.UpdatePointCoordinates(Equipment."Last Latitude", Equipment."Last Longitude");
                        MapElementBuffer.UpdatePointPopupSettings(
                            StrSubstNo(EquipmentPopupPattern, Equipment."No.", Equipment."Last Driver Name"), true, false);

                        MapElementBuffer.UpdatePointMarkerSettings('iconUrl', BlackIconPath);
                        MapElementBuffer.UpdateDataMarkProperty(BlackIconPath);
                        MapElementBuffer.SwitchToParent();
                    end else begin
                        Message(EquipmentDuplicateMessage,
                            MapElementBuffer.TableCaption, MapElementBuffer.FieldCaption(ID), MapElementBuffer.ID);

                        MapElementBuffer.Get(ParentID);
                    end;
                end;
            until (Equipment.Next() = 0);
    end;

    local procedure NearTrucksToMapElements(var MapElementBuffer: Record "Meta UI Map Element")
    var
        Address: Record Address;
        Shipment: Record Shipment;
        EquipmentBuffer: Record Equipment temporary;
        MapElementShadow: Record "Meta UI Map Element" temporary;
        NoSelectionException: Label 'This function requires selected shipment(s) as a calculation base.';
    begin
        MapElementShadow.Copy(MapElementBuffer, true);
        MapElementShadow.SelectPoints('00.Base.Cluster.Shipments');
        MapElementShadow.SetRange(Selected, true);
        if MapElementShadow.FindSet() then begin
            repeat
                Shipment.SetRange(Id, MapElementShadow.ID);
                Shipment.FindFirst();

                case Shipment."Lane Type" of
                    Shipment."Lane Type"::Collection:
                        Address.Get(Shipment."From Address No.");

                    Shipment."Lane Type"::Delivery:
                        Address.Get(Shipment."To Address No.");
                end;

                Address.GetEquipmentNear(EquipmentBuffer, 0.5);
            until (MapElementShadow.Next() = 0);

            if EquipmentBuffer.FindSet() then
                repeat
                    if IsValidCoordinates(EquipmentBuffer."Last Latitude", EquipmentBuffer."Last Longitude") then begin
                        MapElementBuffer.CreateIconPoint(EquipmentBuffer.Id, EquipmentBuffer.Description);
                        MapElementBuffer.UpdatePointCoordinates(EquipmentBuffer."Last Latitude", EquipmentBuffer."Last Longitude");
                        MapElementBuffer.UpdatePointPopupSettings(
                            StrSubstNo(EquipmentPopupPattern, EquipmentBuffer."No.", EquipmentBuffer."Last Driver Name"), true, false);

                        MapElementBuffer.UpdatePointMarkerSettings('iconUrl', RedIconPath);
                        MapElementBuffer.UpdateDataMarkProperty(RedIconPath);
                        MapElementBuffer.SwitchToParent();
                    end;
                until (EquipmentBuffer.Next() = 0);
        end else
            Message(NoSelectionException);
    end;

    local procedure FindTripsForSelectedTrucks(var MapElementBuffer: Record "Meta UI Map Element")
    var
        Trip: Record Trip;
        Equipment: Record Equipment;
        MapElementShadow: Record "Meta UI Map Element" temporary;
        NoSelectionException: Label 'This function requires selected truck(s) as a calculation base.';
        RecReference: RecordRef;
    begin
        MapElementShadow.Copy(MapElementBuffer, true);
        MapElementShadow.SelectPoints('<>00.Base.Cluster.Shipments');
        MapElementShadow.SetRange(Selected, true);
        if MapElementShadow.FindSet() then begin
            Equipment.SetCurrentKey(Id);
            Trip.SetCurrentKey("First Truck No.");

            repeat
                Equipment.SetRange(Id, MapElementShadow.ID);
                Equipment.FindFirst();

                Trip.SetRange("First Truck No.", Equipment."No.");
                Trip.SetRange(Status, Trip.Status::Released, Trip.Status::"Loaded/In Transit");
                if Trip.FindLast() then begin
                    RecReference.GetTable(Trip);
                    RecReference.SetRecFilter();
                    TripsToMapElements(RecReference, MapElementBuffer);
                end;
            until (MapElementShadow.Next() = 0);
        end else
            Message(NoSelectionException);
    end;

    local procedure PredictionsToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Trip: Record Trip;
        Address: Record Address;
        TripPrediction: Record "Trip Prediction";
        TripShipmentPrediction: Record "Trip Shipment Prediction";

        TempShipment: Record Shipment temporary;
        TempTransportPlannedActivity: Record "Transport Planned Activity" temporary;

        PredictionBuffer: Record "Prediction Buffer" temporary;
        PredictionBufferMgmt: Codeunit "Prediction Buffer Mgt.";
    begin
        Source.SetTable(Trip);
        Trip.FindImportShipments();

        // Predictions As Route (not tested) ...
        TripPrediction.SetRange("Trip No.", 'DUMMY');
        if TripPrediction.FindFirst() then begin
            TripPrediction.CalculateWithActivities(TripShipmentPrediction, TempTransportPlannedActivity, TempShipment);

            TempTransportPlannedActivity.Reset;
            TempTransportPlannedActivity.SetFilter("Address No.", '<>%1', '');
            if TempTransportPlannedActivity.FindSet() then begin
                MapElementBuffer.CreateGeoRoute(TripPrediction."Trip No.", '');

                repeat
                    Address.Get(TempTransportPlannedActivity."Address No.");

                    MapElementBuffer.CreateCirclePoint(
                        Format(TempTransportPlannedActivity."Entry No."), Format(TempTransportPlannedActivity.Timetype));

                    MapElementBuffer.UpdatePointCoordinates(Address.Latitude, Address.Longitude);
                    MapElementBuffer.UpdatePointPopupSettings(TempTransportPlannedActivity."Address Description", true, false);

                    case true of
                        TempTransportPlannedActivity.IsLoad():
                            MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'orange');
                        TempTransportPlannedActivity.IsUnload():
                            MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'lime');
                    end;

                    MapElementBuffer.UpdatePointMarkerSettings('radius', 7);
                    MapElementBuffer.SwitchToParent();
                until (TempTransportPlannedActivity.Next() = 0);
            end;
        end;

        // Predictions As Markers (not tested) ...
        PredictionBufferMgmt.GetBuffer(PredictionBuffer);
        if PredictionBuffer.FindSet() then
            repeat

                MapElementBuffer.CreateCirclePoint(PredictionBuffer."Shipment Id", '');
                MapElementBuffer.UpdatePointCoordinates(PredictionBuffer.Latitude, PredictionBuffer.Longitude);
                MapElementBuffer.UpdatePointPopupSettings(StrSubstNo(LoadingMetersPopupPattern,
                     PredictionBuffer."Loading Meters") + '<br>' + PredictionBuffer.Description, true, false);

                MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'red');
                MapElementBuffer.UpdatePointMarkerSettings('radius', 10 + Round(PredictionBuffer."Loading Meters", 1, '>'));

                MapElementBuffer.SwitchToParent();
            until (PredictionBuffer.Next() = 0);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnShipmentMarkerSelection(Shipment: Record Shipment);
    begin
        // This event is triggered when the circle marker is being selected on the Map Factbox on the Planview Shipment page.
    end;
}