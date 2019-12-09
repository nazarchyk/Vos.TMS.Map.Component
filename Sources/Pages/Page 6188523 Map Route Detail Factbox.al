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
                field(Id; Id) { }
                field(Source; Source) { Visible = false; }
                field(Selected; Selected) { }
                field(Type; Type) { Visible = false; }
                field(Latitude; Latitude) { Visible = false; }
                field(Longitude; Longitude) { Visible = false; }
                field("Pop Up"; "Pop Up") { }
                field("Marker Text"; "Marker Text") { }
                field("Marker Type"; "Marker Type") { Visible = false; }
                field(Icon; Icon) { Visible = false; }
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
        UpdateFactbox
    end;

    procedure UpdateFactbox()
    var
        MapBuffer: Codeunit "Map Buffer";
    begin
        MapBuffer.GetRouteDetails(Rec);
    end;

}