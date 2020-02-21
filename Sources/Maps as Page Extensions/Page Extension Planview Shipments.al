pageextension 50144 "Planview Shipment (Map)" extends "Planview Shipments"
{
    layout
    {
        // addbefore(TableShip)
        addfirst(FactBoxes)
        {
            part(Map; "Meta UI Map")
            {
                ApplicationArea = All;
                UpdatePropagation = Both;
                Visible = IsMapVisible;
            }
        }
    }

    actions
    {
        addfirst(Processing)
        {
            action(ShowOnMap)
            {
                ApplicationArea = All;
                Caption = 'Show/Hide Map';
                Image = Map;

                trigger OnAction()
                begin
                    IsMapVisible := not IsMapVisible;
                end;
            }
        }
    }

    var
        IsMapVisible: Boolean;
        xFilters: Text;

    trigger OnOpenPage()
    begin
        IsMapVisible := true;
    end;

    trigger OnAfterGetCurrRecord()
    var
        RecReference: RecordRef;
    begin
        if xFilters <> GetFilters() then begin
            xFilters := GetFilters();

            If IsMapVisible then
                if GetFilter("Route No.") <> '' then begin
                    RecReference.GetTable(Rec);
                    CurrPage.Map.Page.UpdateMapContent(RecReference);
                end;
        end;
    end;
}