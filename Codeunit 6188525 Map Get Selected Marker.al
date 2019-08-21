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
        foreach JsonTkn in marker do
        begin
            JsonObj := JsonTkn.AsObject;
            //      Message('Selected : ' + Format(JsonObj));
            JsonObj.Get('id', JsonTkn);
            JsonVal := JsonTkn.AsValue;
            Evaluate(Id, JsonVal.AsText);
            RouteDetail.SetRange(id, Id);
            RouteDetail.FindFirst;
            RouteDetail.Selected := RouteDetail.Selected::Clicked;
            RouteDetail.Modify;
            MapBuffer.SetRouteDetails(RouteDetail);
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
                Message('To Do');
        end;
        RouteDetail.SetMarkerStrokeBasedOnSelected;
        RouteDetail.Modify;
        RouteDetail.Reset;
        MapBuffer.SetRouteDetails(RouteDetail);
//        if Confirm('Show Prediction?') then
        PredictionBuffer.Show(Id);
    end;


}