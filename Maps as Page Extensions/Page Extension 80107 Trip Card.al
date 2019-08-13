pageextension 80107 "Trip Card (Map)" extends "Trip Card"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(Map; "Map Component Factbox") { }
            part(MapDetails; "Map Route Factbox") { }
        }
    }
    trigger OnAfterGetCurrRecord();
    var
        ShowTrip: Codeunit "Map Show Trip";
    begin
        ShowTrip.Run(Rec);
        CurrPage.Map.Page.SetData();
    end;
}
