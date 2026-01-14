pageextension 50144 "Planview Shipment (Map)" extends "PTE Planview Shipments"
{
    PromotedActionCategories = 'New,Process,Report,Meta UI Grid: Shipments,Meta UI Map';

    layout
    {
        addfirst(FactBoxes)
        {
            part(MapControl; "Meta UI Map")
            {
                ApplicationArea = All;
                UpdatePropagation = Both;
                Visible = IsMapControlVisible;
            }
        }
    }

    actions
    {
        addlast(Processing)
        {
            group(MetaUIMap)
            {
                Caption = 'Meta UI Map';

                action(ToggleMapVisibility)
                {
                    ApplicationArea = All;
                    Caption = 'Toggle Visibility';
                    Image = Map;

                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        IsMapControlVisible := not IsMapControlVisible;
                    end;
                }
            }
        }
    }

    var
        IsMapControlVisible: Boolean;
        xFilters: Text;

    trigger OnOpenPage()
    begin
        IsMapControlVisible := true;
    end;

    trigger OnAfterGetCurrRecord()
    var
        RecReference: RecordRef;
    begin
        if CurrPage.MapControl.Page.GetSelected() then begin
            GetNewTotals();
        end;
        if xFilters <> Rec.GetFilters() then begin
            xFilters := Rec.GetFilters();

            If IsMapControlVisible then
                if Rec.GetFilter("Route No.") <> '' then begin
                    RecReference.GetTable(Rec);
                    CurrPage.MapControl.Page.UpdateMapContent(RecReference);
                end;
        end;
    end;
}