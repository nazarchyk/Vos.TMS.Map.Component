pageextension 6188531 "Address Validation Card (Map)" extends "Address Validation Card"
{
    layout
    {
        addlast(FactBoxes)
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
        CurrPage.Map.Page.UpdateMapContent(RecReference);
    end;
}