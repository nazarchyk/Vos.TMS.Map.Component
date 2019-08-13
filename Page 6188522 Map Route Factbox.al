page 6188522 "Map Route Factbox"
{
    PageType = ListPart;
    SourceTable = "Map Route";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Routes)
            {
                field("No."; "No.") { }
                field("Name"; "Name") { }
                field(Color; Color) { }
                field(Type; Type) { }
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
        MapBuffer.GetRoutes(Rec);
    end;

}