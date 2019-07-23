codeunit 6188525 "Map Get Selected Marker"
{

    procedure GetMarkers(Marker: JsonArray);
    var
        RouteDetail: Record "Map Route Detail";
        JsonTkn: JsonToken;
        JsonObj: JsonObject;
    begin
        foreach JsonTkn in marker do begin
            JsonObj := JsonTkn.AsObject;
//            Message(Format(JsonObj));
        end;

    end;

}