pageextension 50154 "Via Points (Map)" extends "Address List - Via Points"
{
    layout
    {
        addlast(FactBoxes)
        {
            part(Map; "Meta UI Map") { ApplicationArea = All; }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        RecReference: RecordRef;
    begin
        RecReference.GetTable(Rec);
        CurrPage.Map.Page.UpdateMapContent(RecReference);
    end;
}