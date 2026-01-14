codeunit 50256 "Meta UI Map Routines"
{
    EventSubscriberInstance = StaticAutomatic;

    [EventSubscriber(ObjectType::Table, Database::"Meta UI Map Element", 'OnMapSettingsInitiate', '', false, false)]
    local procedure MetaUIMapElement_OnMapSettingsInitiate(var MapSettings: JsonObject)
    begin
        LogExecutionActivity('Meta UI Map Routines', '      MetaUIMapElement_OnMapSettingsInitiate', '');

        MapSettings := SettingsToJSON();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Meta UI Map Element", 'OnMapStructureInitiate', '', false, false)]
    local procedure MetaUIMapElement_OnMapStructureInitiate(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Trip: Record "PTE Trip";
        TransportOrderLine: Record "PTE Transport Order Line";
        PlanningOptions: Record "PTE Planning Options";
    begin
        if Source.Number <> 0 then
            LogExecutionActivity('Meta UI Map Routines', '      MetaUIMapElement_OnMapStructureInitiate', 'Table: ' + Source.Name)
        else
            LogExecutionActivity('Meta UI Map Routines', '      MetaUIMapElement_OnMapStructureInitiate', 'No Table Selected');

        case Source.Number of
            Database::"PTE Address":
                begin
                    MapElementBuffer.CreateGeoLayer('00.Base.Geo.Address', 'Address Location', true);
                    MapElementBuffer.CreateGeoLayer('01.Overlay.Geo.Address.POI', 'Last POI Coordinates', false);
                end;
            Database::"PTE Truck":
                MapElementBuffer.CreateGeoLayer('00.Base.Geo.Equipment', 'Equipment Location', true);

            Database::"PTE Trailer":
                MapElementBuffer.CreateGeoLayer('00.Base.Geo.Equipment', 'Equipment Location', true);

            Database::"PTE Find Or Create Addr. Args.":
                MapElementBuffer.CreateGeoLayer('00.Base.Geo.AddressArgument', 'Address Location', true);

            Database::"PTE Via Point Address":
                MapElementBuffer.CreateGeoLayer('00.Base.Geo.ViaPointAddress', 'Via Point Address', true);

            Database::"PTE Truck Entry":
                MapElementBuffer.CreateGeoLayer('00.Base.Geo.TruckEntry', 'Truck Entries', true);

            Database::"PTE Point of Interest Entry":
                begin
                    MapElementBuffer.CreateGeoLayer('00.Base.Geo.POI', 'POI', true);
                    MapElementBuffer.CreateGeoLayer('01.Overlay.Geo.POI.ActivityReportDetails', 'ActivityReportDetails', false);
                    MapElementBuffer.CreateGeoLayer('02.Overlay.Geo.POI.TruckEntries', 'TruckEntries', false);
                end;
            Database::"PTE Shipment":
                begin
                    MapElementBuffer.CreateClusterLayer('00.Base.Cluster.Shipments', 'Shipments', true);
                    MapElementBuffer.UpdateLayerSettings('disableClusteringAtZoom', GetZoomLevel());

                    MapElementBuffer.CreateGeoLayer('01.Overlay.Geo.MyTrucks', 'My Trucks', false);
                    MapElementBuffer.CreateGeoLayer('02.Overlay.Geo.IttervoortTrucks', 'Ittervoort Trucks', false);
                    MapElementBuffer.CreateGeoLayer('03.Overlay.Geo.DeventerTrucks', 'Deventer Trucks', false);
                    MapElementBuffer.CreateGeoLayer('04.Overlay.Geo.ITTLTrucks', 'ITTL Trucks', false);
                    MapElementBuffer.CreateGeoLayer('05.Overlay.Geo.AlblasserdamTrucks', 'Alblasserdam Trucks', false);

                    MapElementBuffer.CreateGeoLayer('10.Overlay.Geo.NearbyTrucks', 'Nearby Trucks', false);
                    MapElementBuffer.CreateGeoLayer('11.Overlay.Geo.FindTrips', 'Find Trips', false);
                end;

            Database::"PTE Transics Activity Report":
                MapElementBuffer.CreateGeoLayer('00.Base.Geo.TransicsActivities', 'Transics Activities', true);

            Database::"PTE Planning Options":
                begin
                    Source.SetTable(PlanningOptions);
                    MapElementBuffer.CreateGeoLayer('00.Base.Geo.PlanningOptions', 'Planning Options', true);
                end;
            Database::"PTE Transport Order Line":
                begin
                    Source.SetTable(TransportOrderLine);
                    MapElementBuffer.CreateGeoLayer('00.Base.Geo.PlanTrOrderLine', 'Planning Transport Order', true);
                    MapElementBuffer.CreateGeoLayer('01.Base.Geo.TrackingTrOrderLine', 'Transport Order Tracking', true);
                end;

            Database::"PTE Transport Planned Activity":
                MapElementBuffer.CreateGeoLayer('00.Base.Geo.TransportActivities', 'Transport Activities', true);

            Database::"PTE Trip Stop":
                MapElementBuffer.CreateGeoLayer('00.Base.Geo.Stops', 'Stops', true);

            Database::"PTE Trip":
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
                    MapElementBuffer.CreateGeoLayer('05.Overlay.Geo.AlblasserdamTrucks', 'Alblasserdam Trucks', false);
                end;

            Database::"PTE TX Tango Consultation":
                MapElementBuffer.CreateGeoLayer('00.Base.Geo.Consultations', 'Consultations Trip', true);
            Database::"PTE Internal Charter Invoice":
                MapElementBuffer.CreateGeoLayer('00.Base.Geo.IntCharter', 'Internal Charter', true);

            else
                SuperUserMessage(Source);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Meta UI Map Element", 'OnElementSelectionChanged', '', false, false)]
    local procedure MetaUIMapElement_OnElementSelectionChanged(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Trip: Record "PTE Trip";
        Shipment: Record "PTE Shipment";
        DynamicTripID: Code[20];
    begin
        LogExecutionActivity('Meta UI Map Routines', '      MetaUIMapElement_OnElementSelectionChanged',
            StrSubstNo('ID: %1 Type:%2 Subtype:%3 Parent:%4 Selected:%5', MapElementBuffer.ID,
                MapElementBuffer.Type, MapElementBuffer.Subtype, MapElementBuffer."Parent ID", MapElementBuffer.Selected));

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
                        '01.Overlay.Geo.Address.POI':
                            AddressPOIToMapElements(Source, MapElementBuffer);
                        '00.Base.Geo.AddressArgument':
                            AddressArgumentToMapElements(Source, MapElementBuffer);
                        '00.Base.Geo.ViaPointAddress':
                            ViaPointEntryToMapElements(Source, MapElementBuffer);
                        '00.Base.Geo.TruckEntry':
                            TruckEntryToMapElements(Source, MapElementBuffer);
                        '00.Base.Geo.POI':
                            POIToMapElements(Source, MapElementBuffer);
                        '01.Overlay.Geo.POI.ActivityReportDetails':
                            POIActReportToMapElements(Source, MapElementBuffer);
                        '02.Overlay.Geo.POI.TruckEntries':
                            POITruckEntriesToMapElements(Source, MapElementBuffer);
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
                        '00.Base.Geo.PlanTrOrderLine':
                            TransportOrderLineToMapElements(Source, MapElementBuffer);
                        '01.Base.Geo.TrackingTrOrderLine':
                            TrOrderTruckEntryToMapElements(Source, MapElementBuffer);
                        '01.Overlay.Geo.MyTrucks':
                            MyTrucksToMapElements(MapElementBuffer);
                        '02.Overlay.Geo.IttervoortTrucks':
                            TrucksToMapElements('LIMBURG', MapElementBuffer);
                        '03.Overlay.Geo.DeventerTrucks':
                            TrucksToMapElements('DEVENTER', MapElementBuffer);
                        '04.Overlay.Geo.ITTLTrucks':
                            ITTLTrucksToMapElements(MapElementBuffer);
                        '05.Overlay.Geo.AlblasserdamTrucks':
                            TrucksToMapElements('ALBLASSERD', MapElementBuffer);
                        '10.Overlay.Geo.NearbyTrucks':
                            NearTrucksToMapElements(MapElementBuffer);
                        '11.Overlay.Geo.FindTrips':
                            FindTripsForSelectedTrucks(MapElementBuffer);
                        '00.Base.Geo.Stops':
                            StopsToMapElements(Source, MapElementBuffer);
                        '00.Base.Geo.IntCharter':
                            IntCharterToMapElements(Source, MapElementBuffer);
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

                            LogExecutionActivity('Meta UI Map Routines',
                                '      MetaUIMapElement_OnElementSelectionChanged', 'Before Shipment.FindFirst...');

                            if Source.Number = Database::"PTE Shipment" then begin
                                Shipment.SetCurrentKey(Id);
                                Shipment.SetRange(Id, MapElementBuffer.ID);
                                if Shipment.FindFirst() then
                                    OnShipmentMarkerSelection(Shipment);
                            end;

                            LogExecutionActivity('Meta UI Map Routines',
                                '      MetaUIMapElement_OnElementSelectionChanged', 'After Shipment.FindFirst...');
                        end else begin
                            MapElementBuffer.UpdatePointMarkerSettings('strokeColor', '#4f90ca');
                            if Source.Number = Database::"PTE Shipment" then begin
                                Shipment.SetCurrentKey(Id);
                                Shipment.SetRange(Id, MapElementBuffer.ID);
                                if Shipment.FindFirst() then
                                    OnShipmentMarkerSelection(Shipment);
                            end;
                        end;
                    MapElementBuffer.Subtype::Icon:
                        if not MapElementBuffer.Selected then begin
                            case MapElementBuffer."Data Mark" of
                                RedIconPath:
                                    MapElementBuffer.UpdatePointMarkerSettings('iconUrl', RedIconPath);
                                GreenIconPath:
                                    MapElementBuffer.UpdatePointMarkerSettings('iconUrl', GreenIconPath);
                                BlackIconPath:
                                    MapElementBuffer.UpdatePointMarkerSettings('iconUrl', BlackIconPath);
                                LightBlueIconPath:
                                    MapElementBuffer.UpdatePointMarkerSettings('iconUrl', LightBlueIconPath);
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
        Address: Record "PTE Address";
        POI: Record "PTE Point of Interest Entry";
    begin
        Source.SetTable(Address);

        MapElementBuffer.CreateCirclePoint(Address."No.", Address.Description);
        MapElementBuffer.UpdatePointCoordinates(Address.Latitude, Address.Longitude);
        MapElementBuffer.UpdatePointPopupSettings(StrSubstNo(AddressPopupPattern,
            Address.Description, Address.Street, Address."Post Code", Address.City), true, false);

        if ((Address."POI Latitude" <> Address.Latitude) or (Address."POI Longitude" <> Address.Longitude)) and
        ((Address."POI Latitude" <> 0) and (Address."POI Longitude" <> 0)) then begin
            MapElementBuffer.SwitchToParent();
            MapElementBuffer.CreateCirclePoint('poi' + Address."No.", Address.Description);
            MapElementBuffer.UpdatePointCoordinates(Address."POI Latitude", Address."POI Longitude");
            MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'red');
            MapElementBuffer.UpdatePointPopupSettings('POI Coordinates', true, false);
        end;
    end;

    local procedure AddressPOIToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Address: Record "PTE Address";
        POI: Record "PTE Point of Interest Entry";
    begin
        Source.SetTable(Address);

        poi.Reset();
        poi.SetRange("Address No.", Address."No.");
        poi.SetFilter(poi."In Latitude", '<>%1', 0);
        if POI.FindLast() then begin
            MapElementBuffer.CreateCirclePoint('in' + Format(POI."Entry No."), Format(POI."Calculated In Datetime"));
            MapElementBuffer.UpdatePointCoordinates(POI."In Latitude", POI."In Longitude");
            MapElementBuffer.UpdatePointMarkerSettings('radius', 4);
            MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'green');
            MapElementBuffer.UpdatePointPopupSettings('In', true, false);
            MapElementBuffer.SwitchToParent();

        end;
        poi.Reset();
        poi.SetRange("Address No.", Address."No.");
        poi.SetFilter(poi."Out Latitude", '<>%1', 0);
        if POI.FindLast() then begin
            MapElementBuffer.CreateCirclePoint('out' + Format(POI."Entry No."), Format(POI."Calculated In Datetime"));
            MapElementBuffer.UpdatePointCoordinates(POI."Out Latitude", POI."Out Longitude");
            MapElementBuffer.UpdatePointMarkerSettings('radius', 4);
            MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'blue');
            MapElementBuffer.UpdatePointPopupSettings('Out', true, false);
        end;
    end;

    local procedure AddressArgumentToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        AddressArgument: Record "PTE Find Or Create Addr. Args.";
    begin
        Source.SetTable(AddressArgument);

        MapElementBuffer.CreateCirclePoint(Format(AddressArgument."Entry No."), '');
        MapElementBuffer.UpdatePointCoordinates(AddressArgument.Latitude, AddressArgument.Longitude);
        MapElementBuffer.UpdatePointPopupSettings(AddressArgument.City, true, false);
    end;

    local procedure ViaPointEntryToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        ViaPointAddr: Record "PTE Via Point Address";
        Addr: Record "PTE Address";
    begin
        Source.SetTable(ViaPointAddr);
        if ViaPointAddr.FindSet then begin
            MapElementBuffer.CreateGeoRoute(ViaPointAddr."Via Point Code", '');
            repeat
                MapElementBuffer.CreateCirclePoint(Format(ViaPointAddr."Sequence No."), ViaPointAddr."Via Address Description");
                Addr.Get(ViaPointAddr."Via Address No.");
                MapElementBuffer.UpdatePointCoordinates(Addr.Latitude, Addr.Longitude);
                MapElementBuffer.UpdatePointMarkerSettings('radius', 7);
                MapElementBuffer.UpdatePointPopupSettings(ViaPointAddr."Via Address Description", true, false);
                MapElementBuffer.SwitchToParent();
            until ViaPointAddr.Next = 0;

        end;

    end;

    local procedure TruckEntryToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        TruckEntry: Record "PTE Truck Entry";
    begin
        Source.SetTable(TruckEntry);
        if TruckEntry.FindSet then begin
            MapElementBuffer.CreateGeoRoute(TruckEntry."Truck No.", '');
            repeat
                MapElementBuffer.CreateCirclePoint(Format(TruckEntry."Entry No."), Format(TruckEntry."Created Date Time"));
                MapElementBuffer.UpdatePointCoordinates(TruckEntry.Latitude, TruckEntry.Longitude);
                MapElementBuffer.UpdatePointMarkerSettings('radius', 7);
                MapElementBuffer.UpdatePointPopupSettings(TruckEntry."Address Info", true, false);
                MapElementBuffer.SwitchToParent();
            until TruckEntry.Next = 0;

        end;
    end;

    local procedure POIToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        POI: Record "PTE Point of Interest Entry";
        Shipment: Record "PTE Shipment";
        Address: Record "PTE Address";

    begin
        Source.SetTable(POI);

        Shipment.get(poi."Transport Order No.", poi."Transport Order Line No.", poi."Irr. No.", poi."Leg No.");
        if poi.Latitude = 0 then begin
            if poi.Load then
                Address.get(Shipment."From Address No.")
            else
                Address.get(Shipment."To Address No.");
            poi.Latitude := Address.Latitude;
            poi.Longitude := Address.Longitude;
        end;
        if poi.Load then begin
            if Shipment."Realised Latitude (Loading)" <> 0 then begin
                MapElementBuffer.CreateCirclePoint('ready' + Format(POI."Entry No."), Format(POI."Calculated In Datetime"));
                MapElementBuffer.UpdatePointCoordinates(Shipment."Realised Latitude (Loading)", Shipment."Realised Longitude (Loading)");
                MapElementBuffer.UpdatePointMarkerSettings('radius', 4);
                MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'red');
                MapElementBuffer.UpdatePointPopupSettings('Ready in ' + format(Shipment."Realised Loading Time From"), true, false);
                MapElementBuffer.SwitchToParent();
            end;
        end else begin
            if Shipment."Realised Latitude (Unloading)" <> 0 then begin
                MapElementBuffer.CreateCirclePoint('ready' + Format(POI."Entry No."), Format(POI."Calculated In Datetime"));
                MapElementBuffer.UpdatePointCoordinates(Shipment."Realised Latitude (Unloading)", Shipment."Realised Longitude (Unloading)");
                MapElementBuffer.UpdatePointMarkerSettings('radius', 4);
                MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'red');
                MapElementBuffer.UpdatePointPopupSettings('Ready in ' + format(Shipment."Realised Unloading Time From"), true, false);
                MapElementBuffer.SwitchToParent();

            end;
        end;
        MapElementBuffer.CreateCirclePoint(Format(POI."Entry No."), Format(POI."Calculated In Datetime"));
        MapElementBuffer.UpdatePointCoordinates(POI.Latitude, POI.Longitude);
        MapElementBuffer.UpdatePointMarkerSettings('radius', 7);
        //MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'red');
        MapElementBuffer.UpdatePointPopupSettings(poi."Combined Key", true, false);
        MapElementBuffer.SwitchToParent();

        if POI."In Latitude" <> 0 then begin
            MapElementBuffer.CreateCirclePoint('in' + Format(POI."Entry No."), Format(POI."Calculated In Datetime"));
            MapElementBuffer.UpdatePointCoordinates(POI."In Latitude", POI."In Longitude");
            MapElementBuffer.UpdatePointMarkerSettings('radius', 4);
            MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'green');
            MapElementBuffer.UpdatePointPopupSettings('In ' + format(poi."In Datetime"), true, false);
            MapElementBuffer.SwitchToParent();
        end;
        if POI."Out Latitude" <> 0 then begin
            MapElementBuffer.CreateCirclePoint('out' + Format(POI."Entry No."), Format(POI."Calculated In Datetime"));
            MapElementBuffer.UpdatePointCoordinates(POI."Out Latitude", POI."Out Longitude");
            MapElementBuffer.UpdatePointMarkerSettings('radius', 4);
            MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'blue');
            MapElementBuffer.UpdatePointPopupSettings('Out ' + Format(poi."Out Datetime"), true, false);
            MapElementBuffer.SwitchToParent();
        end;

    end;

    local procedure POIActReportToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        POI: Record "PTE Point of Interest Entry";
        POITruck: Record "PTE Transics Activity Report" temporary;
        OutDate: DateTime;
        InDate: DateTime;
    begin
        Source.SetTable(POI);

        if poi."In Datetime" = 0DT then
            InDate := POI."Calculated In Datetime"
        else
            InDate := POI."In Datetime";
        IF poi."Out Datetime" = 0DT THEN
            OutDate := InDate
        ELSE
            OutDate := poi."Out Datetime";
        InDate := InDate - (4 * 60 * 60 * 1000);
        OutDate := OutDate + (4 * 60 * 60 * 1000);
        // poi.GetTransicsData(InDate, OutDate, POITruck);
        if POITruck.FindSet then begin
            MapElementBuffer.CreateGeoRoute('actRep' + POI."Truck No.", '');
            repeat
                MapElementBuffer.CreateCirclePoint('ar' + Format(POITruck.id), Format(POITruck.ActivityID));
                MapElementBuffer.UpdatePointCoordinates(POITruck.Latitude, POITruck.Longitude);
                MapElementBuffer.UpdatePointMarkerSettings('radius', 4);
                MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'orange');
                MapElementBuffer.UpdatePointRouteSegmentColor('orange');
                MapElementBuffer.UpdatePointPopupSettings(POITruck.ActivityName + Format(POITruck.BeginDate), true, false);
                MapElementBuffer.SwitchToParent();
            until POITruck.Next = 0;

        end;
    end;

    local procedure POITruckEntriesToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        POI: Record "PTE Point of Interest Entry";
        POITruck: Record "PTE Truck Entry";
        OutDate: DateTime;
        InDate: DateTime;
    begin
        Source.SetTable(POI);
        if poi."In Datetime" = 0DT then
            InDate := POI."Calculated In Datetime"
        else
            InDate := POI."In Datetime";
        IF poi."Out Datetime" = 0DT THEN
            OutDate := InDate
        ELSE
            OutDate := poi."Out Datetime";
        InDate := InDate - (4 * 60 * 60 * 1000);
        OutDate := OutDate + (4 * 60 * 60 * 1000);
        POITruck.SetCurrentKey("Truck No.", "Created Date Time");
        POITruck.SetRange("Truck No.", POI."Truck No.");
        POITruck.SetRange("Created Date Time", InDate, OutDate);
        if POITruck.IsEmpty then begin
            POITruck.SetRange("Truck No.");
            POITruck.SetRange("Last Trailer No.", POI."Truck No.");
        end;
        if POITruck.FindSet then begin
            MapElementBuffer.CreateGeoRoute('trucks_' + POI."Truck No.", '');
            repeat
                MapElementBuffer.CreateCirclePoint('tr' + Format(POITruck."Entry No."), Format(POITruck."Entry No."));
                MapElementBuffer.UpdatePointCoordinates(POITruck.Latitude, POITruck.Longitude);
                MapElementBuffer.UpdatePointMarkerSettings('radius', 4);
                MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'lime');
                MapElementBuffer.UpdatePointRouteSegmentColor('lime');
                MapElementBuffer.UpdatePointPopupSettings(format(POITruck."Created Date Time"), true, false);
                MapElementBuffer.SwitchToParent();
            until POITruck.Next = 0;

        end;
    end;

    local procedure TrOrderTruckEntryToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        TruckEntry: Record "PTE Truck Entry" temporary;
        TransportOrderLine: Record "PTE Transport Order Line";
        Shipment: Record "PTE Shipment";
        Address: Record "PTE Address";
        GetEntries: Codeunit "PTE Truck Entries Management";
        Index: Integer;
    begin
        Source.SetTable(TransportOrderLine);

        GetEntries.GetTruckEntriesForTrOrderRec(TransportOrderLine, TruckEntry);
        //TruckEntry.SetCurrentKey("Truck No.");
        if TruckEntry.FindSet then begin
            MapElementBuffer.CreateGeoRoute(TruckEntry."Truck No.", '');
            if Address.Get(TransportOrderLine."From Address No.") then begin
                MapElementBuffer.CreateCirclePoint(format(CreateGuid), '');
                MapElementBuffer.UpdatePointCoordinates(Address.Latitude, Address.Longitude);
                MapElementBuffer.UpdatePointMarkerSettings('radius', 1);
                MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'green');
                MapElementBuffer.SwitchToParent();
            end;

            repeat
                MapElementBuffer.CreateCirclePoint(Format(TruckEntry."Entry No."), Format(TruckEntry."Created Date Time"));
                MapElementBuffer.UpdatePointCoordinates(TruckEntry.Latitude, TruckEntry.Longitude);
                MapElementBuffer.UpdatePointMarkerSettings('radius', 1);
                MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'green');
                MapElementBuffer.UpdatePointPopupSettings(Format(TruckEntry."Created Date Time"), true, false);
                MapElementBuffer.SwitchToParent();
            until TruckEntry.Next = 0;
            MapElementBuffer.SwitchToParent();
        end;

        Shipment.SetRange("Transport Order No.", TransportOrderLine."Transport Order No.");
        Shipment.SetRange("Transport Order Line No.", TransportOrderLine."Line No.");
        Shipment.SetRange("Irr. No.", TransportOrderLine."Active Irregularity No.");
        if Shipment.FindSet() then begin
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

    local procedure ConsultationsToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        TXTangoConsultation: Record "PTE TX Tango Consultation";
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
        Truck: Record "PTE Truck";
        Trailer: Record "PTE Trailer";
        TruckEntry: Record "PTE Truck Entry";
        i: Integer;
    begin
        if Source.Number = Database::"PTE Truck" then begin
            Source.SetTable(Truck);

            MapElementBuffer.CreateCirclePoint(Truck."No.", Truck.Description);
            MapElementBuffer.UpdatePointCoordinates(Truck.GetLatitude, Truck.GetLongitude);
            MapElementBuffer.UpdatePointPopupSettings(Truck.GetLastCity, true, false);
        end else begin
            Source.SetTable(Trailer);
            if TruckEntry.FindLast then begin
                MapElementBuffer.CreateGeoRoute(Trailer."No.", '');
                repeat
                    i := i + 1;
                    MapElementBuffer.CreateCirclePoint(Format(TruckEntry."Entry No."), Format(TruckEntry."Created Date Time"));
                    MapElementBuffer.UpdatePointCoordinates(TruckEntry.Latitude, TruckEntry.Longitude);
                    MapElementBuffer.UpdatePointMarkerSettings('radius', 1);
                    MapElementBuffer.UpdatePointPopupSettings(TruckEntry."Address Info", true, false);
                    MapElementBuffer.SwitchToParent();
                until (TruckEntry.Next(-1) = 0) or (i > 10);
            end;
        end;
    end;

    local procedure PlanningOptionsToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Address: Record "PTE Address";
        Shipment: Record "PTE Shipment";
        //TransportOrderLine: Record "PTE Transport Order Line";
        PlanningOptions: Record "PTE Planning Options";
        Index: Integer;
    begin
        Source.SetTable(PlanningOptions);

        Shipment.SetRange("Transport Order No.", PlanningOptions."Transport Order No.");
        Shipment.SetRange("Transport Order Line No.", PlanningOptions."Line No.");
        Shipment.SetRange("Irr. No.", PlanningOptions."Active Irregularity No.");
        Shipment.SetAutoCalcFields("Loading Meters");
        if not Shipment.FindSet() then
            exit;

        MapElementBuffer.CreateGeoRoute(
            PlanningOptions."Transport Order No." + Format(PlanningOptions."Line No."), '');

        for Index := 0 to Shipment.Count() do begin
            if Index <> 0 then begin
                Address.Get(Shipment."TO Address No.");
                MapElementBuffer.CreateCirclePoint(Shipment.Id, Shipment.Description);
            end else begin
                Address.Get(Shipment."From Address No.");
                MapElementBuffer.CreateCirclePoint(Format(PlanningOptions."Line No."), '');
            end;

            MapElementBuffer.UpdatePointCoordinates(Address.Latitude, Address.Longitude);
            MapElementBuffer.UpdatePointPopupSettings(
                StrSubstNo(LoadingMetersPopupPattern, Shipment."Loading Meters") + '<br>' +
                StrSubstNo(AddressPopupPattern, Address.Description, Address.Street,
                    Address."Post Code", Address.City), true, false);

            // MapElementBuffer.UpdatePointMarkerSettings('radius', 10 + Round(Shipment."Loading Meters", 1, '>'));

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
        Address: Record "PTE Address";
        Shipment: Record "PTE Shipment";
    begin
        Source.SetTable(Shipment);

        Shipment.SetAutoCalcFields("Loading Meters");
        if Shipment.FindSet() then
            repeat
                if Shipment."Temp. Trip No." = '' then begin
                    case Shipment."Lane Type" of
                        Shipment."Lane Type"::Collection:
                            Address.Get(Shipment."From Address No.");
                        Shipment."Lane Type"::Delivery:
                            Address.Get(Shipment."To Address No.");
                        Shipment."Lane Type"::Direct:
                            if Shipment."From Address Depot" then
                                Address.Get(Shipment."To Address No.")
                            else
                                Address.Get(Shipment."From Address No.");
                    end;

                    if Address.CoordinatesNotInCountry() then
                        Address.SetDefaultCoordinates();

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
                end;
            until (Shipment.Next() = 0);
    end;

    local procedure TransicsActivitiesToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        TransicsActivityReport: Record "PTE Transics Activity Report" temporary;
        xVehicleID: Code[20];
        Index: Integer;
    begin
        if Source.FindSet() then
            repeat
                Source.SetTable(TransicsActivityReport);
                TransicsActivityReport.Insert();
            until Source.Next() = 0;

        TransicsActivityReport.SetCurrentKey("Trip", BeginDate);
        TransicsActivityReport.SetRange("Trip", TransicsActivityReport."Trip");
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

                MapElementBuffer.CreateCirclePoint(Format(TransicsActivityReport.ID), '');
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
        Trip: Record "PTE Trip";
        TrPlanAct: Record "PTE Transport Planned Activity";
        RecReference: RecordRef;
    begin
        Source.SetTable(TrPlanAct);
        Trip.Get(TrPlanAct."Trip No.");

        RecReference.GetTable(Trip);
        RecReference.SetRecFilter();
        TripsToMapElements(RecReference, MapElementBuffer);
    end;

    local procedure TransportOrderLineToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Address: Record "PTE Address";
        Shipment: Record "PTE Shipment";
        TransportOrderLine: Record "PTE Transport Order Line";
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
        Trip: Record "PTE Trip";
        Addr: Record "PTE Address";
        Shpmnt: Record "PTE Shipment";
        TrPlanAct: Record "PTE Transport Planned Activity";
        TruckEntry: Record "PTE Truck Entry";
        CurrentTruckNo: Code[20];
    begin
        Source.SetTable(Trip);
        if Trip.FindSet() then begin
            TrPlanAct.SetCurrentKey("Trip No.", "Sequence No.");
            TrPlanAct.SetFilter("Address No.", '<>%1', '');
            TrPlanAct.SetFilter(Timetype, '<>%1', TrPlanAct.Timetype::Rest);

            repeat
                CurrentTruckNo := Trip."First Truck No.";
                TrPlanAct.SetRange("Trip No.", Trip."No.");
                if TrPlanAct.FindSet() then begin
                    MapElementBuffer.CreateGeoRoute(Trip."No.", CopyStr(Trip.Name, 1, MaxStrLen(MapElementBuffer.Name)));

                    repeat
                        Addr.Get(TrPlanAct."Address No.");

                        MapElementBuffer.CreateCirclePoint(Format(TrPlanAct."Entry No."), Format(TrPlanAct.Timetype));

                        MapElementBuffer.UpdatePointCoordinates(Addr.Latitude, Addr.Longitude);
                        MapElementBuffer.UpdatePointPopupSettings(TrPlanAct."Address Description", true, false);

                        if TrPlanAct.IsLoad then
                            MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'orange')
                        else
                            if TrPlanAct.IsUnload then
                                MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'lime')
                            else
                                if TrPlanAct."Cost No." <> 0 then
                                    MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'skyblue')
                                else
                                    MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'red');


                        MapElementBuffer.UpdatePointMarkerSettings('radius', 7);
                        if TrPlanAct."Realised Ending Date-Time" <> 0DT then
                            MapElementBuffer.UpdatePointRouteSegmentColor('grey');

                        if TrPlanAct."Equipment Change No." > 0 then begin
                            if (TrPlanAct."Planned Starting Date-Time" < CurrentDateTime) and (TrPlanAct."Truck No." <> CurrentTruckNo) and (TrPlanAct."Truck No." <> '') then
                                CurrentTruckNo := TrPlanAct."Truck No.";
                        end;

                        MapElementBuffer.SwitchToParent();
                    until (TrPlanAct.Next() = 0);

                    MapElementBuffer.SwitchToParent();
                end;
                if trip.Status = Trip.Status::"Loaded/In Transit" then begin
                    TruckEntry.SetCurrentKey("Truck No.");
                    TruckEntry.SetRange("Truck No.", CurrentTruckNo);
                    IF TruckEntry.FindLast() then begin

                        MapElementBuffer.CreateIconPoint(Format(TruckEntry."Entry No."), Format(TruckEntry."Truck Description"));

                        MapElementBuffer.UpdatePointCoordinates(TruckEntry.Latitude, TruckEntry.Longitude);
                        MapElementBuffer.UpdatePointPopupSettings(StrSubstNo('%1 - %2', TruckEntry."Truck No.", TruckEntry."Created Date Time"), true, false);
                        MapElementBuffer.UpdatePointMarkerSettings('iconUrl', RedIconPath);
                        MapElementBuffer.UpdateDataMarkProperty(RedIconPath);
                    end;
                end;
            until (Trip.Next() = 0);
        end;
    end;

    local procedure StopsToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Stop: Record "PTE Trip Stop" temporary;
        Addr: Record "PTE Address";
        Shpmnt: Record "PTE Shipment";
        TrPlanAct: Record "PTE Transport Planned Activity";
    begin
        if Source.FindSet() then
            repeat
                Source.SetTable(Stop);
                Stop.Insert();
            until Source.Next() = 0;

        if Stop.FindSet() then begin
            MapElementBuffer.CreateGeoRoute('Route1', 'Route1');
            repeat
                Addr.Get(Stop."Address No.");

                MapElementBuffer.CreateCirclePoint(Format(stop."Stop No."), Format(stop."Stop No."));

                MapElementBuffer.UpdatePointCoordinates(Addr.Latitude, Addr.Longitude);
                MapElementBuffer.UpdatePointPopupSettings(Stop."Address Description", true, false);

                MapElementBuffer.UpdatePointMarkerSettings('radius', 7);

                MapElementBuffer.SwitchToParent();
            until (Stop.Next() = 0);
            MapElementBuffer.SwitchToParent();
        end;
    end;

    local procedure IsValidCoordinates(Latitude: Decimal; Longitude: Decimal): Boolean
    begin
        if (Latitude in [38 .. 70]) and (Longitude in [-6 .. 25]) then
            exit(true);
    end;

    local procedure MyTrucksToMapElements(var MapElementBuffer: Record "Meta UI Map Element")
    var
        Equipment: Record "PTE Truck";
        UserSetup: Record "User Setup";
        PeriodicalAllocation: Record "PTE Periodical Allocation";
    begin
        UserSetup.Get(UserId());
        UserSetup.TestField("PTE Planner No.");

        PeriodicalAllocation.SetRange(PeriodicalAllocation.Type, PeriodicalAllocation.Type::Truck);
        PeriodicalAllocation.SetRange("Default Planner No.", UserSetup."PTE Planner No.");
        if PeriodicalAllocation.FindSet() then
            repeat
                Equipment.Get(PeriodicalAllocation."No.");
                if IsValidCoordinates(Equipment.GetLatitude, Equipment.GetLongitude) then begin
                    MapElementBuffer.CreateIconPoint(Equipment.Id, Equipment.Description);
                    MapElementBuffer.UpdatePointCoordinates(Equipment.GetLatitude, Equipment.GetLongitude);
                    MapElementBuffer.UpdatePointPopupSettings(
                        StrSubstNo(EquipmentPopupPattern, Equipment."No.", ''), true, false);

                    MapElementBuffer.UpdatePointMarkerSettings('iconUrl', RedIconPath);
                    MapElementBuffer.UpdateDataMarkProperty(RedIconPath);
                    MapElementBuffer.SwitchToParent();
                end;
            until (PeriodicalAllocation.Next() = 0);
    end;

    local procedure TrucksToMapElements(PlanningFilter: Code[10]; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Trip: Record "PTE Trip";
        Equipment: Record "PTE Truck";
        IconURLPath: Text;
    begin
        Trip.SetRange("Planning Code", PlanningFilter);
        Trip.SetRange(Active, true);
        // Trip.SetRange("Board Computer Mandatory", true); // SEB: This break down the client !!!
        if Trip.FindSet() then begin
            repeat
                if Trip."Board Computer Mandatory" then // SEB: Use this instead filtering, due to issue mentioned earlier...
                    if Equipment.Get(Trip."First Truck No.") then
                        Equipment.Mark := true;
            until (Trip.Next() = 0);

            Equipment.MarkedOnly := true;
            If Equipment.FindSet() then
                repeat
                    if IsValidCoordinates(Equipment.GetLatitude, Equipment.GetLongitude) then begin
                        MapElementBuffer.CreateIconPoint(Equipment.Id, Equipment.Description);
                        MapElementBuffer.UpdatePointCoordinates(Equipment.GetLatitude, Equipment.GetLongitude);
                        MapElementBuffer.UpdatePointPopupSettings(
                            StrSubstNo(EquipmentPopupPattern, Equipment."No.", ''), true, false);

                        case PlanningFilter of
                            'LIMBURG':
                                IconURLPath := GreenIconPath;
                            'DEVENTER':
                                IconURLPath := RedIconPath;
                            'ALBLASSERD':
                                IconURLPath := LightBlueIconPath;
                        end;

                        MapElementBuffer.UpdatePointMarkerSettings('iconUrl', IconURLPath);
                        MapElementBuffer.UpdateDataMarkProperty(IconURLPath);
                        MapElementBuffer.SwitchToParent();
                    end;
                until (Equipment.Next() = 0);
        end;
    end;

    local procedure ITTLTrucksToMapElements(var MapElementBuffer: Record "Meta UI Map Element")
    var
        Equipment: Record "PTE Truck";
    begin
        Equipment.SetRange("Default Company", 'UAB ITTL');
        Equipment.SetFilter("Out Of Service Date", '%1|%2..', 0D, Today());
        if Equipment.FindSet() then
            repeat
                if IsValidCoordinates(Equipment.GetLatitude, Equipment.GetLongitude) then begin
                    MapElementBuffer.CreateIconPoint(Equipment.Id, Equipment.Description);
                    MapElementBuffer.UpdatePointCoordinates(Equipment.GetLatitude, Equipment.GetLongitude);
                    MapElementBuffer.UpdatePointPopupSettings(
                        StrSubstNo(EquipmentPopupPattern, Equipment."No.", ''), true, false);

                    MapElementBuffer.UpdatePointMarkerSettings('iconUrl', BlackIconPath);
                    MapElementBuffer.UpdateDataMarkProperty(BlackIconPath);
                    MapElementBuffer.SwitchToParent();
                end;
            until (Equipment.Next() = 0);
    end;

    local procedure NearTrucksToMapElements(var MapElementBuffer: Record "Meta UI Map Element")
    var
        Address: Record "PTE Address";
        Shipment: Record "PTE Shipment";
        EquipmentBuffer: Record "PTE Truck" temporary;
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
                    if IsValidCoordinates(EquipmentBuffer.GetLatitude, EquipmentBuffer.GetLongitude) then begin
                        MapElementBuffer.CreateIconPoint(EquipmentBuffer.Id, EquipmentBuffer.Description);
                        MapElementBuffer.UpdatePointCoordinates(EquipmentBuffer.GetLatitude, EquipmentBuffer.GetLongitude);
                        MapElementBuffer.UpdatePointPopupSettings(
                                StrSubstNo(EquipmentPopupPattern, EquipmentBuffer."No.", ''), true, false);

                        MapElementBuffer.UpdatePointMarkerSettings('iconUrl', RedIconPath);
                        MapElementBuffer.UpdateDataMarkProperty(RedIconPath);
                        MapElementBuffer.SwitchToParent();
                    end;
                until (EquipmentBuffer.Next() = 0);
        end else
            Message(NoSelectionException);
    end;

    local procedure IntCharterToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        IntCharter: Record "PTE Internal Charter Worksheet";
        IntCharterInvoice: Record "PTE Internal Charter Invoice";
        Address: Record "PTE Address";
    begin
        Source.SetTable(IntCharterInvoice);

        IntCharter.SetRange("Invoice No.", IntCharterInvoice."No.");
        IntCharter.SetRange("Trip No.", IntCharterInvoice."Current Trip No.");
        if IntCharter.FindSet then begin
            MapElementBuffer.CreateGeoRoute('invoice' + format(IntCharter."Invoice No.") + ' ' + IntCharter."Truck No.", '');
            repeat
                MapElementBuffer.CreateCirclePoint(IntCharter."Trip No." + Format(IntCharter."Stop No."), IntCharter."Trip No." + Format(IntCharter."Stop No."));
                Address.Get(IntCharter."From Address No.");
                MapElementBuffer.UpdatePointCoordinates(Address.Latitude, Address.Longitude);
                MapElementBuffer.UpdatePointMarkerSettings('radius', 5);
                MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'blue');
                MapElementBuffer.UpdatePointRouteSegmentColor('blue');

                MapElementBuffer.UpdatePointPopupSettings(StrSubstNo('%1#%2#%3', IntCharter."Trip No.", IntCharter."Stop No.", IntCharter."From Address City"), true, false);
                MapElementBuffer.SwitchToParent();
            until IntCharter.Next = 0;
            MapElementBuffer.CreateCirclePoint(IntCharter."Trip No." + Format(IntCharter."Stop No." + 1), IntCharter."Trip No." + Format(IntCharter."Stop No."));
            Address.Get(IntCharter."To Address No.");
            MapElementBuffer.UpdatePointCoordinates(Address.Latitude, Address.Longitude);
            MapElementBuffer.UpdatePointMarkerSettings('radius', 7);
            MapElementBuffer.UpdatePointMarkerSettings('fillColor', 'blue');
            MapElementBuffer.UpdatePointRouteSegmentColor('blue');
            MapElementBuffer.UpdatePointPopupSettings(StrSubstNo('%1#%2#%3', IntCharter."Trip No.", IntCharter."Stop No.", IntCharter."From Address City"), true, false);
            MapElementBuffer.SwitchToParent();

        end;
    end;

    local procedure FindTripsForSelectedTrucks(var MapElementBuffer: Record "Meta UI Map Element")
    var
        Trip: Record "PTE Trip";
        Equipment: Record "PTE Truck";
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


    // This event is triggered when the circle marker is being selected on the Map Factbox on the Planview Shipment page.
    local procedure OnShipmentMarkerSelection(Shipment: Record "PTE Shipment");
    begin
        Shipment.SelectIt();
    end;

    local procedure SettingsToJSON() Settings: JsonObject
    var
        TransportOrderSetup: Record "PTE Transport Order Setup";
    begin
        /*** EXAMPLE OF PROVIDER SETTINGS FOR OPENSTREETMAPS ***/
        // Settings.Add('type', 1);
        // Settings.Add('baseUrl', 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png');

        TransportOrderSetup.Get;
        Settings.Add('type', 0);
        Settings.Add('baseUrl', TransportOrderSetup."Map Account URL");

        if TransportOrderSetup."Map Username" <> '' then
            Settings.Add('username', TransportOrderSetup."Map Username");

        if TransportOrderSetup."Map Password" <> '' then
            Settings.Add('password', TransportOrderSetup."Map Password");

        if TransportOrderSetup."Map Token" <> '' then
            Settings.Add('token', TransportOrderSetup."Map Token");

        if TransportOrderSetup."Map Profile" <> '' then
            Settings.Add('profile', TransportOrderSetup."Map Profile");

        if TransportOrderSetup."Map Subdomains" <> '' then
            Settings.Add('subdomains', TransportOrderSetup."Map Subdomains");

        Settings.Add('providerSettings', Settings);
    end;

    local procedure GetZoomLevel(): Integer
    var
        UserSetup: Record "User Setup";
    begin
        UserSetup.Get(UserId);
        exit(UserSetup."PTE Zoom Level (Map)");
    end;

    local procedure SuperUserMessage(Source: RecordRef)
    var
        UserSetup: Record "User Setup";
        UnknownSourceException: Label 'The source reference ''%1'' is not supported.';
    begin
        UserSetup.Get(UserId());
        if not UserSetup."PTE Super User" then
            exit;

        Message(UnknownSourceException, Source);
    end;

    local procedure LogExecutionActivity(Context: Text[30]; Activity: Text; Details: Text)
    var
        UserSetup: Record "User Setup";
        ActivityLog: Record "Activity Log";
    begin
        if UserId() = 'GLOBAL.MEDIATOR@VOS-GROUP.EU' then begin
            if UserSetup.Get(UserId()) then begin
                ActivityLog.LogActivity(UserSetup, ActivityLog.Status::Success, Context, Activity, Details);
                Commit();
            end;
        end;
    end;

    var
        RedIconPath: Label 'sources/controls/images/red.truck.19.png';
        BlueIconPath: Label 'sources/controls/images/blue.truck.19.png';
        GreenIconPath: Label 'sources/controls/images/green.truck.19.png';
        BlackIconPath: Label 'sources/controls/images/black.truck.19.png';
        LightBlueIconPath: Label 'sources/controls/images/light-blue.truck.19.png';

        AddressPopupPattern: Label 'Description: %1<br>Street: %2<br>Post Code: %3<br>City: %4';
        EquipmentPopupPattern: Label 'Truck No.: %1<br>Driver Name: %2';
        EquipmentDuplicateMessage: Label 'The %1 with %2=%3 already exists.';
        LoadingMetersPopupPattern: Label 'Loading Meters: %1';
}