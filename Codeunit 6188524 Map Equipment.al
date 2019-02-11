codeunit 6188524 "Map Equipment"
{
    trigger OnRun();
    begin
    end;

    procedure ShowMyTrucks();
    var
        Equip: Record Equipment;
        PerAlloc: Record "Periodical Allocation";
        UserSetup: Record "User Setup";
        i: Integer;
    begin
        UserSetup.Get(UserId);
        PerAlloc.SetRange("Default Planner No.", UserSetup."Planner No.");
        PerAlloc.FindSet;
        repeat
            i += 1;
            Equip.get(PerAlloc."No.", Equip.type::Truck);
            AddToMap(Equip, i)
        until PerAlloc.Next = 0;

    end;

    procedure ShowTrucksClose(Lat: Decimal;Long: Decimal);
        var
        Equip: Record Equipment;
        PerAlloc: Record "Periodical Allocation";
        UserSetup: Record "User Setup";
        i: Integer;
    begin
        UserSetup.Get(UserId);
        PerAlloc.SetRange("Default Planner No.", UserSetup."Planner No."); // To Do... Filter on close by...
        PerAlloc.FindSet;
        repeat
            Equip.get(PerAlloc."No.", Equip.type::Truck);
            AddToMap(Equip, i)
        until PerAlloc.Next = 0;

    end;
    local procedure AddToMap(Equip: Record Equipment; var i: Integer)
    var
        MapRoute: Record "Map Route" temporary;
        MapBuffer: Codeunit "Map Buffer";
    begin

        MapRoute.init;
        MapRoute."Route No." := 0;
        MapRoute."Stop No." := i;
        MapRoute.Color := 'Red';
        MapRoute.Longitude := Equip."Last Longitude";
        MapRoute.Latitude := Equip."Last Latitude";
        MapRoute."Marker Type" := MapRoute."Marker Type"::Circle;
        MapRoute."Marker Text" := Equip.Description;
        MapBuffer.SetDataOneByOne(MapRoute);
    end;

    var
        myInt: Integer;
}