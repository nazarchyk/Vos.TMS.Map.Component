pageextension 6188527 "Trip Card (Map)" extends "Trip Card"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(Map; "Meta UI Map")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addfirst(Processing)
        {
            action(SuggestShipments)
            {
                ApplicationArea = All;
                Caption = 'Suggest Shipments';
                Image = Map;

                trigger OnAction()
                begin
                    FindImportShipments();
                    // ToDo: Identify what is next.....
                end;
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        RecReference: RecordRef;
    begin
        RecReference.GetTable(Rec);
        RecReference.SetRecFilter();
        CurrPage.Map.Page.UpdateMapContent(RecReference);
    end;
}