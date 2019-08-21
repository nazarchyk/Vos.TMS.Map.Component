codeunit 6188525 "Map Get Selected Marker"
{

    procedure GetMarkers(Markers: JsonArray);
    var
        JsonTkn: JsonToken;
        Marker: JsonObject;
    begin
        foreach JsonTkn in Markers do
        begin
            Marker := JsonTkn.AsObject;
            GetMarker(Marker);
        end;

    end;

    procedure GetMarker(Marker: JsonObject);
    var
        RouteDetail: Record "Map Route Detail" temporary;
        PredictionBuffer: Codeunit "Prediction Buffer Mgt.";
        MapBuffer: Codeunit "Map Buffer";
        JsonTkn: JsonToken;
        JsonObj: JsonObject;
        JsonVal: JsonValue;
        Id: guid;
    begin
        MapBuffer.GetRouteDetails(RouteDetail);
        //    Message('Selected : ' + Format(JsonObj));
        Marker.Get('id', JsonTkn);
        JsonVal := JsonTkn.AsValue;
        Evaluate(Id, JsonVal.AsText);
        RouteDetail.SetRange(id, Id);
        RouteDetail.FindFirst;
        case RouteDetail.Selected of
            RouteDetail.Selected::Clicked:
                RouteDetail.Selected := RouteDetail.Selected::" ";
            RouteDetail.Selected::" ":
                RouteDetail.Selected := RouteDetail.Selected::Clicked;
            RouteDetail.Selected::Selected:
                RouteDetail.SelectShipment;
        end;
        RouteDetail.SetMarkerStrokeBasedOnSelected;
        RouteDetail.Modify;
        RouteDetail.Reset;
        MapBuffer.SetRouteDetails(RouteDetail);
        PredictionBuffer.Show(Id);
    end;


}