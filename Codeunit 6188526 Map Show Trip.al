codeunit 6188526 "Map Show Trip"
{
    TableNo = Trip;
    trigger OnRun();
    var
        Consultation: Record "TX Tango Consultation";
        TrPlanAct: Record "Transport Planned Activity";
        RouteDetails: Record "Map Route Detail" temporary;
        Address: Record Address;
        Trip: Record Trip;
        i: Integer;
        TruckNo: Code[20];
        DriverNo: Code[20];
        TrailerNo: Code[20];
        LZVTrailerNo: Code[20];
        CoDriverNo: Code[20];
        Equip: Record Equipment;
        LastExportStop: Integer;
        FirstImportStop: Integer;
    begin

        Consultation.SetCurrentKey("Trip No.", "Arrival Date");
        Consultation.SetRange("Trip No.", "No.");
        if Consultation.FindSet then repeat
            RouteDetails.init;
            RouteDetails."Route No." := 1;
            RouteDetails."Stop No." += 1;
            RouteDetails.Color := 'Red';
            RouteDetails.Longitude := Consultation.Longitude;
            RouteDetails.Latitude := Consultation.Latitude;
            RouteDetails.Insert;
            until Consultation.Next = 0;

        RouteDetails."Stop No." := 0;
        TrPlanAct.SetCurrentKey("Trip No.", "Stop No.");
        TrPlanAct.SetFilter("Address No.", '<>%1', '');
        TrPlanAct.SetRange("Trip No.", "No.");
        TrPlanAct.SetRange("Shipment Type", TrPlanAct."Shipment Type"::Export);
        TrPlanAct.SetFilter(Timetype, '<>%1', TrPlanAct.Timetype::Rest);
        if TrPlanAct.FindSet then repeat
        Address.get(TrPlanAct."Address No.");
            RouteDetails.init;
            RouteDetails."Route No." := 2;
            RouteDetails."Stop No." += 1;
            RouteDetails."Marker Type" := RouteDetails."Marker Type"::Circle;
            RouteDetails."Pop Up" := TrPlanAct."Address Description";
            RouteDetails.Name := 'Export';
            RouteDetails.Color := 'Blue';
            RouteDetails.Longitude := Address.Longitude;
            RouteDetails.Latitude := Address.Latitude;
            RouteDetails.Insert;
            LastExportStop := TrPlanAct."Stop No.";
            until TrPlanAct.Next = 0;

        TrPlanAct.SetCurrentKey("Trip No.", "Stop No.");
        TrPlanAct.SetFilter("Address No.", '<>%1', '');
        TrPlanAct.SetRange("Trip No.", "No.");
        TrPlanAct.SetRange("Shipment Type", TrPlanAct."Shipment Type"::Import);
        TrPlanAct.SetFilter(Timetype, '<>%1', TrPlanAct.Timetype::Rest);
        if TrPlanAct.FindSet then begin
            FirstImportStop := TrPlanAct."Stop No.";
            repeat
            Address.get(TrPlanAct."Address No.");
            RouteDetails.init;
            RouteDetails."Route No." := 3;
            RouteDetails."Stop No." += 1;
            RouteDetails."Pop Up" := TrPlanAct."Address Description";
            RouteDetails.Name := 'Import';
            RouteDetails."Marker Type" := RouteDetails."Marker Type"::Circle;
            RouteDetails.Color := 'Green';
            RouteDetails.Longitude := Address.Longitude;
            RouteDetails.Latitude := Address.Latitude;
            RouteDetails.Insert;
            until TrPlanAct.Next = 0;
        end;

        TrPlanAct.SetCurrentKey("Trip No.", "Stop No.");
        TrPlanAct.SetFilter("Address No.", '<>%1', '');
        TrPlanAct.SetRange("Trip No.", "No.");
        TrPlanAct.SetRange("Shipment Type");
        TrPlanAct.SetRange("Stop No.", LastExportStop, FirstImportStop);
        TrPlanAct.SetFilter(Timetype, '<>%1', TrPlanAct.Timetype::Rest);
        if TrPlanAct.FindSet then begin
            FirstImportStop := TrPlanAct."Stop No.";
            repeat
            Address.get(TrPlanAct."Address No.");
            RouteDetails.init;
            RouteDetails."Route No." := 4;
            RouteDetails."Pop Up" := TrPlanAct."Address Description";
            RouteDetails.Name := 'Empty';
            RouteDetails."Stop No." += 1;
            RouteDetails."Marker Type" := RouteDetails."Marker Type"::Circle;
            RouteDetails.Color := 'Orange';
            RouteDetails.Longitude := Address.Longitude;
            RouteDetails.Latitude := Address.Latitude;
            RouteDetails.Insert;
            until TrPlanAct.Next = 0;
        end;


        FindCurrentEquipImpExpCol(TruckNo, DriverNo, TrailerNo, LZVTrailerNo, CoDriverNo);

        if Equip.get(TruckNo, Equip.Type::Truck) then begin
            RouteDetails.init;
            RouteDetails."Route No." := 0;
            RouteDetails."Marker Type" := RouteDetails."Marker Type"::Icon;
            RouteDetails."Stop No." := 1;
            RouteDetails.Longitude := Equip."Last Longitude";
            RouteDetails.Latitude := Equip."Last Latitude";
            RouteDetails.Insert;
        end;
        RouteDetails.ToBuffer;
    end;


}