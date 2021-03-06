pageextension 50152 "Truck Entries (Map)" extends "Truck Entries"
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
        TruckEntry: Record "Truck Entry";
        RecReference: RecordRef;
    begin
        CurrPage.SetSelectionFilter(TruckEntry);
        if TruckEntry.Count() = 1 then begin
            RecReference.GetTable(Rec);
            RecReference.SetRecFilter();
        end else
            RecReference.GetTable(TruckEntry);

        CurrPage.MapControl.Page.UpdateMapContent(RecReference);
    end;
}