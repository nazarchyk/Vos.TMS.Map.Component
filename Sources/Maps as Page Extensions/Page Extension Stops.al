pageextension 50155 "Stops (Map)" extends "xServer Stops"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(MapControl; "Meta UI Map")
            {
                ApplicationArea = All;
                Visible = true;
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