pageextension 50146 "Transics Activity Report (Map)" extends "Transics Activity Report"
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

    trigger OnAfterGetCurrRecord()
    var
        RecReference: RecordRef;
    begin
        RecReference.GetTable(Rec);
        CurrPage.Map.Page.UpdateMapContent(RecReference);
    end;
}