pageextension 50143 "Planning Options (Map)" extends "Planning Options"
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
        RecReference.FilterGroup := 100;
        CurrPage.Map.Page.UpdateMapContent(RecReference);
    end;
}