pageextension 50153 "Via Point Addresses (Map)" extends "Via Point Addresses"
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
        ViaPointAddress: Record "Via Point Address";
        RecReference: RecordRef;
    begin
        ViaPointAddress.SetRange("Via Point Code", "Via Point Code");

        RecReference.GetTable(ViaPointAddress);
        CurrPage.MapControl.Page.UpdateMapContent(RecReference);
    end;
}