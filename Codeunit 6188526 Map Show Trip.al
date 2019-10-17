codeunit 6188526 "Map Show Trip"
{
    TableNo = Trip;

    var
        IsMultipleRoutes: Boolean;

    trigger OnRun();
    var
        RouteDetails: Record "Map Route Detail" temporary;
    begin
        RouteDetails.FromBuffer();
        // GetActualTripFromBoardComputer(Rec, RouteDetails);
        if IsMultipleRoutes then
            GetMultipleTripRoute(Rec, RouteDetails)
        else begin
            GetInternationalRoute(Rec, RouteDetails);
            GetTakenOverTripRoute(Rec, RouteDetails);
            GetRoundTripRoute(Rec, RouteDetails);
        	// GetPredictionResults(RouteDetails);
        end;
        RouteDetails.ToBuffer();
    end;

    procedure SetMultiple()
    begin
        IsMultipleRoutes := true;
    end;

    local procedure GetMultipleTripRoute(Trip: Record Trip; var RouteDetails: Record "Map Route Detail")
    var
        TransportPlannedActivity: Record "Transport Planned Activity";
        RouteNo: Integer;
    begin
        RouteDetails."Stop No." := 0;

        if RouteDetails.FindLast() then
            RouteNo := RouteDetails."Route No." + 1
        else
            RouteNo := 1;
        
        TransportPlannedActivity.SetCurrentKey("Trip No.", "Stop No.");
        TransportPlannedActivity.SetRange("Trip No.", Trip."No.");
        TransportPlannedActivity.SetFilter("Address No.", '<>%1', '');
        TransportPlannedActivity.SetFilter(Timetype, '<>%1', TransportPlannedActivity.Timetype::Rest);
        if TransportPlannedActivity.FindSet() then 
            repeat
                // RouteDetails.CreateFromTrPlanAct(TransportPlannedActivity, '', RouteNo, Trip."No.", true);
                RouteDetails.CreateFromTrPlanAct(TransportPlannedActivity, '', RouteNo, Trip."No.", false);
            until (TransportPlannedActivity.Next() = 0);
    end;

    local procedure GetActualTripFromBoardComputer(Trip: Record Trip; var RouteDetails: Record "Map Route Detail");
    var
        Consultation: Record "TX Tango Consultation";
    begin
        Consultation.SetCurrentKey("Trip No.", "Arrival Date");
        Consultation.SetRange("Trip No.", Trip."No.");
        if Consultation.FindSet then repeat
            RouteDetails.init;
            RouteDetails."Route No." := 1;
            RouteDetails."Stop No." += 1;
            RouteDetails.Color := 'Red';
            RouteDetails.Longitude := Consultation.Longitude;
            RouteDetails.Latitude := Consultation.Latitude;
            RouteDetails.Id := CreateGuid; //* To Do, unkown...
            RouteDetails.Insert;
            until Consultation.Next = 0;
    end;

    local procedure GetRoundTripRoute(Trip: Record Trip; var RouteDetails: Record "Map Route Detail")
    var
        TrPlanAct: Record "Transport Planned Activity";
        Equip: Record Equipment;
    begin
        if Trip."Trip Type" <> Trip."Trip Type"::Roundtrip then
            exit;

        RouteDetails."Stop No." := 0;
        TrPlanAct.SetCurrentKey("Trip No.", "Stop No.");
        TrPlanAct.SetFilter("Address No.", '<>%1', '');
        TrPlanAct.SetRange("Trip No.", Trip."No.");
        TrPlanAct.SetFilter(Timetype, '<>%1', TrPlanAct.Timetype::Rest);
        if TrPlanAct.FindSet then repeat
            RouteDetails.CreateFromTrPlanAct(TrPlanAct, 'Blue', 1, Trip."No.", false)
            until TrPlanAct.Next = 0;

        if Equip.get(Trip."First Truck No.", Equip.Type::Truck) then begin
            RouteDetails.init;
            RouteDetails."Route No." := 0;
            RouteDetails."Marker Type" := RouteDetails."Marker Type"::Icon;
            RouteDetails."Stop No." := 1;
            RouteDetails.Longitude := Equip."Last Longitude";
            RouteDetails.Latitude := Equip."Last Latitude";
           // RouteDetails.Insert;
        end;
    end;

    local procedure GetTakenOverTripRoute(Trip: Record Trip; var RouteDetails: Record "Map Route Detail")
    var
        TrPlanAct: Record "Transport Planned Activity";
        TruckNo: Code[20];
        DriverNo: Code[20];
        TrailerNo: Code[20];
        LZVTrailerNo: Code[20];
        CoDriverNo: Code[20];
        Equip: Record Equipment;
        FirstDistributionStop: Integer;
        LastImportStop: Integer;
    begin
        if Trip."Trip Type" <> Trip."Trip Type"::International then
            exit;

        if trip."Collection Status" < trip."Collection Status"::Assigned then
            exit;

        RouteDetails."Stop No." := 0;
        TrPlanAct.SetCurrentKey("Trip No.", "Stop No.");
        TrPlanAct.SetFilter("Address No.", '<>%1', '');
        TrPlanAct.SetRange("Trip No.", Trip."No.");
        TrPlanAct.SetRange("Shipment Type", TrPlanAct."Shipment Type"::Distribution);
        TrPlanAct.SetFilter(Timetype, '%1|%2|%3', TrPlanAct.Timetype::"Uncouple Trailer", TrPlanAct.Timetype::Unload, TrPlanAct.Timetype::Load);
        if TrPlanAct.FindSet then begin
            FirstDistributionStop := TrPlanAct."Stop No.";;
            repeat
                RouteDetails.CreateFromTrPlanAct(TrPlanAct, 'Blue', 1, 'Distribution', false);
            until TrPlanAct.Next = 0;
        end;

        TrPlanAct.SetCurrentKey("Trip No.", "Stop No.");
        TrPlanAct.SetFilter("Address No.", '<>%1', '');
        TrPlanAct.SetRange("Trip No.", Trip."No.");
        TrPlanAct.SetRange("Shipment Type", TrPlanAct."Shipment Type"::Import);
        TrPlanAct.SetFilter(Timetype, '%1|%2', TrPlanAct.Timetype::UnLoad, TrPlanAct.Timetype::Miscellaneous);
        TrPlanAct.SetFilter("Crossing Activity Type", '%1|%2', TrPlanAct."Crossing Activity Type"::Arrival, TrPlanAct."Crossing Activity Type"::" ");
        if TrPlanAct.FindSet then begin
            repeat
                RouteDetails.CreateFromTrPlanAct(TrPlanAct, 'Green', 2, 'Import', false);
                LastImportStop := TrPlanAct."Stop No.";
            until TrPlanAct.Next = 0;
        end;

        TrPlanAct.SetCurrentKey("Trip No.", "Stop No.");
        TrPlanAct.SetFilter("Address No.", '<>%1', '');
        TrPlanAct.SetRange("Trip No.", Trip."No.");
        TrPlanAct.SetRange("Shipment Type");
        TrPlanAct.SetRange("Stop No.", LastImportStop, FirstDistributionStop);
        TrPlanAct.SetFilter(Timetype, '<>%1', TrPlanAct.Timetype::Rest);
        if TrPlanAct.FindSet then repeat
            RouteDetails.CreateFromTrPlanAct(TrPlanAct, 'Orange', 3, 'Empty', false);
        until TrPlanAct.Next = 0;

        Trip.FindCurrentEquipImpExpCol(TruckNo, DriverNo, TrailerNo, LZVTrailerNo, CoDriverNo);

        if Equip.get(TruckNo, Equip.Type::Truck) then begin
            RouteDetails.init;
            RouteDetails."Route No." := 0;
            RouteDetails."Marker Type" := RouteDetails."Marker Type"::Icon;
            RouteDetails."Stop No." := 1;
            RouteDetails.Longitude := Equip."Last Longitude";
            RouteDetails.Latitude := Equip."Last Latitude";
           // RouteDetails.Insert;
        end;
    end;

    local procedure GetInternationalRoute(Trip: Record Trip; var RouteDetails: Record "Map Route Detail")
    var
        TrPlanAct: Record "Transport Planned Activity";
        TruckNo: Code[20];
        DriverNo: Code[20];
        TrailerNo: Code[20];
        LZVTrailerNo: Code[20];
        CoDriverNo: Code[20];
        Equip: Record Equipment;
        LastExportStop: Integer;
        FirstImportStop: Integer;
    begin
        if Trip."Trip Type" <> Trip."Trip Type"::International then
            exit;

        if trip."Collection Status" >= trip."Collection Status"::Assigned then
            exit;

        RouteDetails."Stop No." := 0;
        TrPlanAct.SetCurrentKey("Trip No.", "Stop No.");
        TrPlanAct.SetFilter("Address No.", '<>%1', '');
        TrPlanAct.SetRange("Trip No.", Trip."No.");
        TrPlanAct.SetRange("Shipment Type", TrPlanAct."Shipment Type"::Export);
        TrPlanAct.SetFilter(Timetype, '%1|%2', TrPlanAct.Timetype::Unload, TrPlanAct.Timetype::Miscellaneous);
        TrPlanAct.SetFilter("Crossing Activity Type", '%1|%2', TrPlanAct."Crossing Activity Type"::Arrival, TrPlanAct."Crossing Activity Type"::" ");
        if TrPlanAct.FindSet then repeat
            RouteDetails.CreateFromTrPlanAct(TrPlanAct, 'Blue', 1, 'Export', false);
            LastExportStop := TrPlanAct."Stop No.";
        until TrPlanAct.Next = 0;

        TrPlanAct.SetCurrentKey("Trip No.", "Stop No.");
        TrPlanAct.SetFilter("Address No.", '<>%1', '');
        TrPlanAct.SetRange("Trip No.", Trip."No.");
        TrPlanAct.SetRange("Shipment Type", TrPlanAct."Shipment Type"::Import);
        TrPlanAct.SetFilter(Timetype, '%1|%2', TrPlanAct.Timetype::Load, TrPlanAct.Timetype::Miscellaneous);
        TrPlanAct.SetFilter("Crossing Activity Type", '%1|%2', TrPlanAct."Crossing Activity Type"::Departure, TrPlanAct."Crossing Activity Type"::" ");
        if TrPlanAct.FindSet then begin
            FirstImportStop := TrPlanAct."Stop No.";
            repeat
                RouteDetails.CreateFromTrPlanAct(TrPlanAct, 'Green', 2, 'Import', false);
            until TrPlanAct.Next = 0;
        end;

        TrPlanAct.SetCurrentKey("Trip No.", "Stop No.");
        TrPlanAct.SetFilter("Address No.", '<>%1', '');
        TrPlanAct.SetRange("Trip No.", Trip."No.");
        TrPlanAct.SetRange("Shipment Type");
        TrPlanAct.SetRange("Stop No.", LastExportStop, FirstImportStop);
        TrPlanAct.SetFilter(Timetype, '<>%1', TrPlanAct.Timetype::Rest);
        if TrPlanAct.FindSet then begin
            FirstImportStop := TrPlanAct."Stop No.";
            repeat
                RouteDetails.CreateFromTrPlanAct(TrPlanAct, 'Orange', 3, 'Empty', false);
            until TrPlanAct.Next = 0;
        end;

        Trip.FindCurrentEquipImpExpCol(TruckNo, DriverNo, TrailerNo, LZVTrailerNo, CoDriverNo);

        if Equip.get(TruckNo, Equip.Type::Truck) then begin
            RouteDetails.init;
            RouteDetails.Id := Equip.Id;
            RouteDetails."Route No." := 0;
            RouteDetails."Marker Type" := RouteDetails."Marker Type"::Icon;
            RouteDetails."Stop No." := 1;
            RouteDetails.Longitude := Equip."Last Longitude";
            RouteDetails.Latitude := Equip."Last Latitude";
           // RouteDetails.Insert;
        end;
    end;

//    local procedure CreateRouteDetailsFromTrPlanAct()
//    end;

}