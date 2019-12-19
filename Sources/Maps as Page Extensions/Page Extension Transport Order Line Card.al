pageextension 6188525 "Trans. Order Line Card (Map)" extends "Transport Order Line Card"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(Map; "Meta UI Map")
            {
                ApplicationArea = All;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        RecReference: RecordRef;
    begin
        RecReference.GetTable(Rec);
        RecReference.FilterGroup := 200;
        CurrPage.Map.Page.UpdateMapContent(RecReference);
    end;
}