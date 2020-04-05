pageextension 50145 "Planview Trips (Map)" extends "Planview Trips"
{
    PromotedActionCategories = 'New,Process,Report,Meta UI Grid: Trips,Meta UI Map';

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

                action(ToggleMultiTripsSelection)
                {
                    ApplicationArea = All;
                    Caption = 'Toggle Multi Trips Selection';
                    Image = ShowSelected; // RefreshPlanningLine

                    Promoted = true;
                    PromotedCategory = Category5;
                    PromotedIsBig = true;

                    trigger OnAction()
                    begin
                        IsMultiTripsSelectionEnabled := not IsMultiTripsSelectionEnabled;
                    end;
                }
            }
        }
    }

    var
        IsMapControlVisible: Boolean;
        IsMultiTripsSelectionEnabled: Boolean;
        xFilters: Text;

    trigger OnOpenPage()
    begin
        IsMapControlVisible := true;
    end;

    // Variant 1 - Visualization only when filters changed
    // trigger OnAfterGetCurrRecord()
    // var
    //     RecReference: RecordRef;
    // begin
    //     if xFilters <> GetFilters() then begin
    //         xFilters := GetFilters();

    //         If IsMapControlVisible then begin
    //             RecReference.GetTable(Rec);
    //             CurrPage.Map.Page.UpdateMapContent(RecReference);
    //         end;
    //     end;
    // end;

    // Variant 2 - Visualization on record or selection change
    trigger OnAfterGetCurrRecord()
    var
        Trip: Record Trip;
        RecReference: RecordRef;
    begin
        if not IsMapControlVisible then
            exit;

        if IsMultiTripsSelectionEnabled then begin
            CurrPage.SetSelectionFilter(Trip);
            if Trip.Count() = 1 then begin
                RecReference.GetTable(Rec);
                RecReference.SetRecFilter();
            end else
                RecReference.GetTable(Trip);
        end else begin
            RecReference.GetTable(Rec);
            RecReference.SetRecFilter();
        end;

        CurrPage.MapControl.Page.UpdateMapContent(RecReference);
    end;
}