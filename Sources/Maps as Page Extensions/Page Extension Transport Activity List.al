pageextension 50147 "Transport Activity List (Map)" extends "Transport Activity List"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(MapControl; "Meta UI Map")
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }

    // Warning: This trigger is not being executed in AL, because it doesn't has any code on C/Side
    trigger OnAfterGetCurrRecord()
    var
        RecReference: RecordRef;
    begin
        RecReference.GetTable(Rec);
        CurrPage.MapControl.Page.UpdateMapContent(RecReference);
    end;
}