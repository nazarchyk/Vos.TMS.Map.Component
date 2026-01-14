pageextension 50157 "Trailer List (Map)" extends "PTE Trailer List"
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