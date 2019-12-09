pageextension 6188529 "Planview Trips (Map)" extends "Planview Trips"
{
    layout
    {
        addlast(Content)
        {
            part(Map; "Map Component Factbox") 
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

                trigger OnAction();
                begin
                    IsMapVisible := not IsMapVisible;
                end;
            }
        }
    }

    var
        IsMapVisible: Boolean;
        xFilters: Text;

    trigger OnOpenPage();
    var
        MapBuffer: Codeunit "Map Buffer";
    begin
        MapBuffer.ClearAll();
        // IsMapVisible := true;
    end;

    trigger OnAfterGetCurrRecord();
    begin
        if xFilters <> GetFilters() then begin
            xFilters := GetFilters();
            
            If IsMapVisible then
                UpdateMap();
        end;
    end;

    local procedure UpdateMap();
    var
        Trip: Record Trip;
        RouteDetail: Record "Map Route Detail" temporary;
        MapShowTrip: Codeunit "Map Show Trip";
        MapBuffer: Codeunit "Map Buffer";
    begin
        // MapBuffer.GetRouteDetails(RouteDetail);
        // RouteDetail.SetRange(Type, RouteDetail.Type::Route);
        // RouteDetail.DeleteAll();
        // MapBuffer.SetRouteDetails(RouteDetail);

        // MapShowTrip.SetMultiple();
        // Trip.CopyFilters(Rec);
        // if Trip.FindSet() then 
        //     repeat
        //         MapShowTrip.Run(Trip);
        //     until (Trip.Next() = 0);
    end;
}