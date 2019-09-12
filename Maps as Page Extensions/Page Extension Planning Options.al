pageextension 6188526 "Planning Options (Map)" extends "Planning Options"

{
    layout
    {
        addfirst(FactBoxes)
        {
            part(Map; "Map Component Factbox") { Visible = true; }
        }
    }
    trigger OnAfterGetCurrRecord();
    var
        MapShowTrOrd: Codeunit "Map Show Order";
    begin
        MapShowTrOrd.Run(Rec);
        CurrPage.Map.Page.GetDataFromBuffer;
        CurrPage.Map.Page.Update;
    end;
}
