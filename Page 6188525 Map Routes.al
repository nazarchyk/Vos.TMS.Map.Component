page 6188525 "Map Routes"
{
    PageType = List;
    SourceTable = "Map Route";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; "No.") { }
                field(Name;Name) {}
                field(Type;Type) {}
                field(Color;Color){}
                field(Hide;Hide) {}
            }
        }
    }
    trigger OnOpenPage();
    var
        MapBuffer: Codeunit "Map Buffer";
    begin
        MapBuffer.GetRoutes(Rec);
    end;
    trigger OnClosePage();
    var
        MapBuffer: Codeunit "Map Buffer";
    begin
        MapBuffer.SetRoutes(Rec);
    end;

}