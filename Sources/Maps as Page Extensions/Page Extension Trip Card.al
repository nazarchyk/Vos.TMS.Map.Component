pageextension 50149 "Trip Card (Map)" extends "Trip Card"
{
    layout
    {
        addfirst(FactBoxes)
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
        RecReference.SetRecFilter();
        CurrPage.MapControl.Page.UpdateMapContent(RecReference);
    end;
}