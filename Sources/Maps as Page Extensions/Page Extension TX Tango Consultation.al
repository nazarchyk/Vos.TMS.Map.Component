pageextension 6188521 "TX Tango Consultation (Map)" extends "TX Tango Consultation"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(Map; "Meta UI Map")
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
        CurrPage.Map.Page.UpdateMapContent(RecReference);
    end;
}