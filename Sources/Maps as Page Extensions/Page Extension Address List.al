pageextension 6188522 "Address List (Map)" extends "Address List"
{
    layout
    {
        addlast(FactBoxes)
        {
            part(Map; "Map Component Factbox") { }
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
