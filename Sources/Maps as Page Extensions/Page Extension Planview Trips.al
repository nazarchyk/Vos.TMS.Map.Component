pageextension 50145 "Planview Trips (Map)" extends "Planview Trips"
{
    layout
    {
        // addlast(Content)
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
            action(ShowAllOnMap)
            {
                ApplicationArea = All;
                Caption = 'Show All on Map';
                Image = Map;

                trigger OnAction()
                begin
                    ShowAllOnMap := not ShowAllOnMap;
                end;
            }
        }
    }

    var
        IsMapVisible: Boolean;
        ShowAllOnMap: Boolean;
        xFilters: Text;

    trigger OnOpenPage()
    begin
        IsMapVisible := true;
    end;

    // Variant 1 - Visualization only when filters changed
    // trigger OnAfterGetCurrRecord()
    // var
    //     RecReference: RecordRef;
    // begin
    //     if xFilters <> GetFilters() then begin
    //         xFilters := GetFilters();

    //         If IsMapVisible then begin
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
        if not IsMapVisible then
            exit;

        if ShowAllOnMap then begin
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

        CurrPage.Map.Page.UpdateMapContent(RecReference);
    end;
}