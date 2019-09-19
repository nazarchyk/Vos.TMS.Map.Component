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
            part("Map Route Details";"Map Route Details")
            {
                SubPageLink = "Route No." = field("No.");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ShowAll)
            {
                Image = ShowSelected;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction();
                begin
                    ModifyAll(Hide, false);
                end;
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