codeunit 6188531 "Meta UI Map Routines"
{
    EventSubscriberInstance = StaticAutomatic;

    var
        RedIconPath: Label 'images/red.truck.19.png';
        BlueIconPath: Label 'images/blue.truck.19.png';
        GreenIconPath: Label 'images/green.truck.19.png';
        BlackIconPath: Label 'images/black.truck.19.png';
        EquipmentPopupPattern: Label 'Truck No.: %1<br>Driver Name: %2';
        EquipmentDuplicateMessage: Label 'The %1 with %2=%3 already exists.';


    [EventSubscriber(ObjectType::Table, Database::"Meta UI Map Element", 'OnMapStructureInitiate', '', false, false)]
    local procedure MetaUIMapElement_OnMapStructureInitiate(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    begin
        case Source.Number of
            Database::Address:
                MapElementBuffer.CreateGeoLayer('00.Base.Geo.Address', 'Address Location', true);

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

            Database::Trip:
                begin
                    MapElementBuffer.CreateGeoLayer('00.Base.Geo.ActiveTrip', 'Active Trip', true);

                    MapElementBuffer.CreateGeoLayer('01.Overlay.Geo.MyTrucks', 'My Trucks', false);
                    MapElementBuffer.CreateGeoLayer('02.Overlay.Geo.IttervoortTrucks', 'Ittervoort Trucks', false);
                    MapElementBuffer.CreateGeoLayer('03.Overlay.Geo.DeventerTrucks', 'Deventer Trucks', false);
                    MapElementBuffer.CreateGeoLayer('04.Overlay.Geo.ITTLTrucks', 'ITTL Trucks', false);
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Meta UI Map Element", 'OnElementSelectionChanged', '', false, false)]
    local procedure MetaUIMapElement_OnElementSelectionChanged(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var 
        Shipment: Record Shipment;
    begin
        case MapElementBuffer.Type of
            MapElementBuffer.Type::Layer:
                if MapElementBuffer.Selected then
                    case MapElementBuffer.ID of
                        '00.Base.Geo.Address':
                            AddressToMapElement(Source, MapElementBuffer);
                        '00.Base.Cluster.Shipments':
                            ShipmentsToMapElements(Source, MapElementBuffer);
                        '00.Base.Geo.ActiveTrip':
                            TripToMapElements(Source, MapElementBuffer);

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
                    end;

            MapElementBuffer.Type::Route:
                ; // ToDo: Update  visuals for selected route

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
                        ; // ToDo: Update  visuals for selected Heat point
                end;
        end;
    end;

    local procedure AddressToMapElement(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Address: Record Address;
    begin
        Source.SetTable(Address);

        MapElementBuffer.CreateCirclePoint(Address."No.", Address.Description);
        MapElementBuffer.UpdatePointCoordinates(Address.Latitude, Address.Longitude);
        MapElementBuffer.UpdatePointPopupSettings(StrSubstNo('%1 %2 %3 %4',
            Address.Description, Address.Street, Address."Post Code", Address.City), true, false);
    end;

    procedure ShipmentsToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
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
                MapElementBuffer.UpdatePointPopupSettings(StrSubstNo('LM: %1 %2 %3 %4 %5', Shipment."Loading Meters",
                    Address.Description, Address.Street, Address."Post Code", Address.City), true, false);

                MapElementBuffer.UpdatePointMarkerSettings('fillColor', Shipment.GetColor());
                MapElementBuffer.UpdatePointMarkerSettings('radius', 10 + Round(Shipment."Loading Meters", 1, '>'));

                MapElementBuffer.SwitchToParent();
            until (Shipment.Next() = 0);
    end;

    procedure TripToMapElements(var Source: RecordRef; var MapElementBuffer: Record "Meta UI Map Element")
    var
        Trip: Record Trip;
        Address: Record Address;
        Shipment: Record Shipment;
        TransportPlannedActivity: Record "Transport Planned Activity";
    begin
        Source.SetTable(Trip);

        TransportPlannedActivity.SetCurrentKey("Trip No.", "Stop No.");
        TransportPlannedActivity.SetRange("Trip No.", Trip."No.");
        TransportPlannedActivity.SetFilter("Address No.", '<>%1', '');
        TransportPlannedActivity.SetFilter(Timetype, '<>%1', TransportPlannedActivity.Timetype::Rest);
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
                    MapElementBuffer.UpdatePointRouteSegmentColor('Grey');

                MapElementBuffer.SwitchToParent();
            until (TransportPlannedActivity.Next() = 0);
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

    local procedure NearTrucksToMapElements(var MapElementBuffer: Record "Meta UI Map Element");
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
                    TripToMapElements(RecReference, MapElementBuffer);
                    MapElementBuffer.SwitchToParent();
                end;
            until (MapElementShadow.Next() = 0);
        end else
            Message(NoSelectionException);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnShipmentMarkerSelection(Shipment: Record Shipment);
    begin
        // This event is triggered when the circle marker is being selected on the Map Factbox on the Planview Shipment page.
    end;
}