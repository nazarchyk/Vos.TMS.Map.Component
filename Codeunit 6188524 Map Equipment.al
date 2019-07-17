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
        RouteDetails: Record "Map Route Detail" temporary;
        MapBuffer: Codeunit "Map Buffer";
    begin

        RouteDetails.init;
        RouteDetails."Route No." := 0;
        RouteDetails."Stop No." := i;
        RouteDetails.Color := 'Red';
        RouteDetails.Longitude := Equip."Last Longitude";
        RouteDetails.Latitude := Equip."Last Latitude";
        RouteDetails."Marker Type" := RouteDetails."Marker Type"::Icon;
        RouteDetails.Icon := 'images/red-truck.png';
        RouteDetails."Marker Text" := Equip.Description;
        MapBuffer.SetDataOneByOne(RouteDetails);
    end;

    var
        myInt: Integer;
}