pageextension 50141 "Address List (Map)" extends "Address List"
{
    layout
    {
        addlast(FactBoxes)
        {
            part(MapControl; "Meta UI Map")
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
        CurrPage.MapControl.Page.UpdateMapContent(RecReference);
    end;
}