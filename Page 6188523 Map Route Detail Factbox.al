page 6188523 "Map Route Detail Factbox"
{
    PageType = ListPart;
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
                field(Color; Color) { }
                field(Name; Name) { }
                field(Type; Type) { }
                field(Latitude; Latitude) { }
                field(Longitude; Longitude) { }
                field("Pop Up"; "Pop Up") { }
                field("Marker Text"; "Marker Text") { }
                field("Marker Type"; "Marker Type") { }
                field(Icon; Icon) { }
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
                    UpdateFactbox
                end;
            }
            action(RouteAsJson)
            {
                Caption = 'Route as Json (Debug)';
                trigger OnAction();
                begin
                //    Message(Format(ShowRoute(true)));
                end;
            }
            action(MarkerAsJson)
            {
                Caption = 'Marker as Json (Debug)';
                trigger OnAction();
                begin
                    Message(Format(ShowMarker(true)));
                end;
            }
        }
    }


    trigger OnOpenPage();
    begin
        UpdateFactbox
    end;

    procedure UpdateFactbox()
    var
        MapBuffer: Codeunit "Map Buffer";
    begin
        MapBuffer.GetRouteDetails(Rec);
    end;

}