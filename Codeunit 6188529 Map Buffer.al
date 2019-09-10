codeunit 6188529 "Map Buffer"
{
    SingleInstance = true;

    var
        Route: Record "Map Route" temporary;
        RouteDetail: Record "Map Route Detail" temporary;

        MustRefresh: Boolean;

    procedure GetRoutes(var Rec: Record "Map Route");
    begin
        Rec.Copy(Route, true);

    end;

    procedure GetRouteDetails(var Rec: Record "Map Route Detail");
    begin
        if RouteDetail.Count > 500 then
            exit;
        Rec.Copy(RouteDetail, true);

    end;

    procedure DoRefresh();
    begin
        MustRefresh := false;
    end;

    procedure ClearAll();
    begin
        Route.Reset;
        Route.DeleteAll;
        RouteDetail.Reset;
        RouteDetail.DeleteAll;
        MustRefresh := true;
    end;

    procedure SetRouteDetails(var Details: Record "Map Route Detail");
    begin
        RouteDetail.Copy(Details, true);
        //        Message(Format(RouteDetail.Count));
        //      RouteDetail.FindSet;
        if RouteDetail.FindSet then repeat
            if not Route.Get(RouteDetail."Route No.") then begin
                Route."No." := RouteDetail."Route No.";
                Route.Color := RouteDetail.Color;
                Route.Name := RouteDetail.Name;
                Route.Type := RouteDetail.Type;
                Route.Insert;
            end;

            until RouteDetail.next = 0;
        MustRefresh := true;
    end;

    procedure SetDataOneByOne(var Rec: Record "Map Route Detail");
    begin
        RouteDetail := Rec;
        if RouteDetail.IsValid then
            RouteDetail.Insert;
        MustRefresh := true;
    end;


}