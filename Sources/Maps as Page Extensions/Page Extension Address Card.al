pageextension 6188523 "Address Card (Map)" extends "Address Card"
{
    layout
    {
        addlast(FactBoxes)
        {
            part(Map; "Map Component Factbox")
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