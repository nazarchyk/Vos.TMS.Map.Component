codeunit 6188525 "Map Get Selected Marker"
{

    procedure GetMarkers(Marker: JsonArray);
    var
        RouteDetail: Record "Map Route Detail" temporary;
        MapBuffer: Codeunit "Map Buffer";
        JsonTkn: JsonToken;
        JsonObj: JsonObject;
        JsonVal: JsonValue;
        Id: guid;
    begin
        MapBuffer.GetRouteDetails(RouteDetail);
        foreach JsonTkn in marker do begin
            JsonObj := JsonTkn.AsObject;
            Message('Selected : ' + Format(JsonObj));
            JsonObj.Get('id', JsonTkn);
            JsonVal := JsonTkn.AsValue;
            Evaluate(Id,  JsonVal.AsText);
            RouteDetail.SetRange(id, Id);
            RouteDetail.FindFirst;
            RouteDetail.Selected := true;
            RouteDetail.Modify;
            MapBuffer.SetRouteDetails(RouteDetail);
        end;

    end;

}