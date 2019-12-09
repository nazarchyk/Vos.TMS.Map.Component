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
            AddToMap(Equip, i, 'images/red-truck.png')
        until PerAlloc.Next = 0;

    end;

    procedure ShowTrucksClose();
    var
        MapBuffer: Codeunit "Map Buffer";
        RouteDetail: Record "Map Route Detail" temporary;
        Addr: Record Address;
        Equip: Record Equipment temporary;
        i: Integer;
    begin
        MapBuffer.GetRouteDetails(RouteDetail);
        RouteDetail.SetRange(Selected, RouteDetail.Selected::Clicked);
        RouteDetail.FindSet;
        repeat
            Addr.Latitude := RouteDetail.Latitude;
            Addr.Longitude := RouteDetail.Longitude;
            Addr.GetEquipmentNear(Equip, 0.5);
        until RouteDetail.Next = 0;
        if Equip.FindSet then
            repeat
                i += 1;
                AddToMap(Equip, i, 'images/red-truck.png')
until Equip.Next = 0;
    end;

    procedure ShowTrucksFromPlanningCode()
    var
        Trip: Record Trip;
        Equip: Record Equipment;
        i: Integer;
    begin
        i := 1;
        Trip.SetRange("Planning Code", 'LIMBURG');
        Trip.SetRange(Active, true);
        Trip.FindSet;
        repeat
            if (trip."Board Computer Mandatory") and (Equip.Get(trip."First Truck No.")) then
                AddToMap(Equip, i, 'images/green-truck.png');
            i += 1;
        until Trip.Next = 0;
    end;

    // procedure ShowTrucksClose(Lat: Decimal;Long: Decimal);
    //     var
    //     Equip: Record Equipment;
    //     PerAlloc: Record "Periodical Allocation";
    //     UserSetup: Record "User Setup";
    //     i: Integer;
    // begin
    //     UserSetup.Get(UserId);
    //     PerAlloc.SetRange("Default Planner No.", UserSetup."Planner No."); // To Do... Filter on close by...
    //     PerAlloc.FindSet;
    //     repeat
    //         Equip.get(PerAlloc."No.", Equip.type::Truck);
    //         AddToMap(Equip, i, 'images/red-truck.png')
    //     until PerAlloc.Next = 0;

    // end;
    local procedure AddToMap(Equip: Record Equipment; var i: Integer; Icon: Text)
    var
        RouteDetail: Record "Map Route Detail" temporary;
        MapBuffer: Codeunit "Map Buffer";
        OffSet: Integer;
    begin
        MapBuffer.GetRouteDetails(RouteDetail);
        RouteDetail.SetRange("Route No.", 0);
        if RouteDetail.FindLast then
            OffSet := RouteDetail."Stop No.";
        RouteDetail.init;
        RouteDetail.id := Equip.Id;
        RouteDetail."Route No." := 0;
        RouteDetail."Stop No." := i + OffSet;
        RouteDetail.Color := 'Red';
        RouteDetail.Longitude := Equip."Last Longitude";
        RouteDetail.Latitude := Equip."Last Latitude";
        RouteDetail."Marker Type" := RouteDetail."Marker Type"::Icon;
        RouteDetail.Icon := Icon;
        RouteDetail."Marker Text" := Equip.Description;
        RouteDetail.Source := 'Equipment';
        RouteDetail.Reset;
        MapBuffer.SetDataOneByOne(RouteDetail);
    end;

    procedure FindTripsForSelectedTrucks()
    var
        RouteDetail: Record "Map Route Detail" temporary;
        MapBuffer: Codeunit "Map Buffer";
    begin
        MapBuffer.GetRouteDetails(RouteDetail);
        RouteDetail.SetRange(Selected, RouteDetail.Selected::Clicked, RouteDetail.Selected::Selected);
        RouteDetail.SetRange(Source, 'Equipment');
        if RouteDetail.FindSet then
            repeat
                RouteDetail.FindRoute();
            until RouteDetail.Next = 0;
    end;
}