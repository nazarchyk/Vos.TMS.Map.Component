#pragma implicitwith disable
pageextension 50153 "Via Point Addresses (Map)" extends "PTE Via Point Addresses"
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
        ViaPointAddress: Record "PTE Via Point Address";
        RecReference: RecordRef;
    begin
        ViaPointAddress.SetRange("Via Point Code", Rec."Via Point Code");

        RecReference.GetTable(ViaPointAddress);
        CurrPage.MapControl.Page.UpdateMapContent(RecReference);
    end;
}
#pragma implicitwith restore
