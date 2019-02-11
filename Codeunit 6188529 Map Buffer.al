codeunit 6188529 "Map Buffer"
{
    SingleInstance = true;

    var
        MapRoute: Record "Map Route" temporary;
        MustRefresh: Boolean;

    procedure GetData(var Rec: Record "Map Route");
    begin
        Rec.Copy(MapRoute, true);
    end;
    procedure DoRefresh();
    begin
        MustRefresh := false;
    end;
    procedure ClearAll();
    begin
        MapRoute.Reset;
        MapRoute.DeleteAll;
        MustRefresh := true;
    end;

    procedure SetData(var Rec: Record "Map Route");
    begin
        MapRoute.Copy(Rec, true);
        MustRefresh := true;
    end;

    procedure SetDataOneByOne(var Rec: Record "Map Route");
    begin
        MapRoute := Rec;
        if MapRoute.IsValid then
            MapRoute.Insert;
        MustRefresh := true;
    end;
    

}