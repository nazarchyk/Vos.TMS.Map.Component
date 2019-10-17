page 6188526 "Map Route Details"
{
    PageType = ListPart;
    SourceTable = "Map Route Detail";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
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
    trigger OnOpenPage();
    var
//        RouteDetail: Record "Map Route Detail" temporary;
        MapBuffer: Codeunit "Map Buffer";
    begin
        MapBuffer.GetRouteDetails(Rec);
    end;    
}