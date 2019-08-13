codeunit 6188526 "Map Show Trip"
{
    TableNo = Trip;
    trigger OnRun();
    var
        RouteDetails: Record "Map Route Detail" temporary;
    begin
        GetActualTripFromBoardComputer(Rec, RouteDetails);
        GetInternationalRoute(Rec, RouteDetails);
        GetRoundTripRoute(Rec, RouteDetails);
        RouteDetails.ToBuffer;
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
            CreateRouteDetailsFromTrPlanAct(TrPlanAct, RouteDetails, 'Blue', 2);
        until TrPlanAct.Next = 0;

        if Equip.get(Trip."First Truck No.", Equip.Type::Truck) then begin
            RouteDetails.init;
            RouteDetails."Route No." := 0;
            RouteDetails."Marker Type" := RouteDetails."Marker Type"::Icon;
            RouteDetails."Stop No." := 1;
            RouteDetails.Longitude := Equip."Last Longitude";
            RouteDetails.Latitude := Equip."Last Latitude";
            RouteDetails.Insert;
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

        RouteDetails."Stop No." := 0;
        TrPlanAct.SetCurrentKey("Trip No.", "Stop No.");
        TrPlanAct.SetFilter("Address No.", '<>%1', '');
        TrPlanAct.SetRange("Trip No.", Trip."No.");
        TrPlanAct.SetRange("Shipment Type", TrPlanAct."Shipment Type"::Export);
        TrPlanAct.SetFilter(Timetype, '<>%1', TrPlanAct.Timetype::Rest);
        if TrPlanAct.FindSet then repeat
            CreateRouteDetailsFromTrPlanAct(TrPlanAct, RouteDetails, 'Blue', 2);
            LastExportStop := TrPlanAct."Stop No.";
        until TrPlanAct.Next = 0;

        TrPlanAct.SetCurrentKey("Trip No.", "Stop No.");
        TrPlanAct.SetFilter("Address No.", '<>%1', '');
        TrPlanAct.SetRange("Trip No.", Trip."No.");
        TrPlanAct.SetRange("Shipment Type", TrPlanAct."Shipment Type"::Import);
        TrPlanAct.SetFilter(Timetype, '<>%1', TrPlanAct.Timetype::Rest);
        if TrPlanAct.FindSet then begin
            FirstImportStop := TrPlanAct."Stop No.";
            repeat
                CreateRouteDetailsFromTrPlanAct(TrPlanAct, RouteDetails, 'Green', 3);
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
                CreateRouteDetailsFromTrPlanAct(TrPlanAct, RouteDetails, 'Orange', 4);
            until TrPlanAct.Next = 0;
        end;

        Trip.FindCurrentEquipImpExpCol(TruckNo, DriverNo, TrailerNo, LZVTrailerNo, CoDriverNo);

        if Equip.get(TruckNo, Equip.Type::Truck) then begin
            RouteDetails.init;
            RouteDetails."Route No." := 0;
            RouteDetails."Marker Type" := RouteDetails."Marker Type"::Icon;
            RouteDetails."Stop No." := 1;
            RouteDetails.Longitude := Equip."Last Longitude";
            RouteDetails.Latitude := Equip."Last Latitude";
            RouteDetails.Insert;
        end;
    end;

    local procedure CreateRouteDetailsFromTrPlanAct(TrPlanAct: Record "Transport Planned Activity"; var RouteDetails: Record "Map Route Detail"; Color: Text; RouteNo: Integer)
    var
        Address: Record Address;
    begin
        Address.get(TrPlanAct."Address No.");
        RouteDetails.init;
        RouteDetails."Route No." := RouteNo;
        RouteDetails."Pop Up" := TrPlanAct."Address Description";
        RouteDetails.Name := TrPlanAct."Address Description";
        RouteDetails."Stop No." += 1;
        RouteDetails."Marker Type" := RouteDetails."Marker Type"::Circle;
        RouteDetails.Color := Color;
        RouteDetails.Longitude := Address.Longitude;
        RouteDetails.Latitude := Address.Latitude;
        RouteDetails.Insert;
    end;

}