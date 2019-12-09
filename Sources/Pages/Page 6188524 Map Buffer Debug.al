page 6188524 "Map Buffer Debug"
{
    PageType = List;
    SourceTable = "Map Route Detail";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Routes)
            {
                field("Route No."; "Route No.") { }
                field("Stop No."; "Stop No.") { }
                field(Id; Id) { }
                field(Source; Source) { Visible = true; }
                field(Selected; Selected) { }
                field(Type; Type) { Visible = true; }
                field(Latitude; Latitude) { Visible = true; }
                field(Longitude; Longitude) { Visible = true; }
                field("Pop Up"; "Pop Up") { }
                field("Marker Text"; "Marker Text") { }
                field("Marker Type"; "Marker Type") { Visible = true; }
                field(Icon; Icon) { Visible = true; }
                field("Marker Fill Color"; "Marker Fill Color") { }
                field("Marker Radius"; "Marker Radius") { }


            }
        }
    }

    actions
    {
        area(processing)
        {
            action(Update)
            {
                Caption = 'Update';
                trigger OnAction();

                begin
                    GetData
                end;
            }
            action(RouteAsJson)
            {
                Caption = 'Route as Json (Debug)';
                trigger OnAction();
                begin
                    //    Message(Format(ShowRoute()));
                end;
            }
            action(MarkerAsJson)
            {
                Caption = 'Marker as Json (Debug)';
                trigger OnAction();
                begin
                    Message(Format(ShowMarker()));
                end;
            }
        }
    }


    trigger OnOpenPage();
    begin
        GetData
    end;

    procedure GetData()
    var
        MapBuffer: Codeunit "Map Buffer";
    begin
        MapBuffer.GetRouteDetails(Rec);
    end;

}