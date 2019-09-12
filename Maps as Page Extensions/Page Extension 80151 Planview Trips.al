pageextension 80151 "Planview Trips (Map)" extends "Planview Trips"
{
    layout
    {
        addlast(Content)
        {
            part(Map; "Map Component Factbox") { Visible = MapVisible; UpdatePropagation = Both; }
        }
    }

    actions
    {
        addfirst(Processing)
        {
            action(ShowOnMap)
            {
                Image = Map;
                trigger OnAction();
                begin
                    MapVisible := not MapVisible;
                end;
            }
        }
    }
    
    trigger OnAfterGetCurrRecord();
    begin
        //GetShpmntBuffer(ShpmntBuffer);
        //AddSelectedShpmntsToMap;
        if FiltersChanged then;
            UpdateMap;
    end;

    trigger OnOpenPage();
    var
        MapBuffer: Codeunit "Map Buffer";
    begin
        MapBuffer.ClearAll;
        MapVisible := true;
    end;

    local procedure UpdateMap();
    var
        Trip: Record Trip;
        MapShowTrip: Codeunit "Map Show Trip";
    begin
        MapShowTrip.SetMultiple;
        Trip.CopyFilters(Rec);
        if Trip.FindSet then repeat
            MapShowTrip.Run(Trip);
        until Trip.Next = 0;      
    end;


    local procedure FiltersChanged(): Boolean
    begin
        if GetFilters = xFilters then
            exit(false);
        xFilters := GetFilters;
        exit(true);
    end;

    var
        TripBuffer: Record Trip temporary;
        xFilters: Text;
        MapVisible: Boolean;

}