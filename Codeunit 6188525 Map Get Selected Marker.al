codeunit 6188525 "Map Get Selected Marker"
{

    procedure GetMarkers(Marker: JsonArray);
    var
        RouteDetail: Record "Map Route Detail";
        JsonTkn: JsonToken;
        JsonObj: JsonObject;
        JsonVal: JsonValue;
        Id: guid;
    begin
        foreach JsonTkn in marker do begin
            JsonObj := JsonTkn.AsObject;
            Message('Selected : ' + Format(JsonObj));
            if not JsonObj.Get('id', JsonTkn) then
                exit;
            JsonVal := JsonTkn.AsValue;
            Evaluate(Id,  JsonVal.AsText);
            RouteDetail.SetRange(id, Id);
            RouteDetail.FindFirst;
            RouteDetail.Selected := true;
            RouteDetail.Modify;
        end;

    end;

}