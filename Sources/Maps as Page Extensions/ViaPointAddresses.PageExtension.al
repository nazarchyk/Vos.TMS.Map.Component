pageextension 50153 "Via Point Addresses (Map)" extends "Via Point Addresses"
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
        ViaPointAddr: Record "Via Point Address";
        RecReference: RecordRef;
    begin
        ViaPointAddr.SetRange("Via Point Code", "Via Point Code");
        RecReference.GetTable(ViaPointAddr);
        CurrPage.Map.Page.UpdateMapContent(RecReference);
    end;
}