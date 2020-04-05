pageextension 50148 "Trans. Order Line Card (Map)" extends "Transport Order Line Card"
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
        RecReference.FilterGroup := 200;
        CurrPage.MapControl.Page.UpdateMapContent(RecReference);
    end;
}