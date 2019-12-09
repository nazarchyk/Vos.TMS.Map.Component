pageextension 6188527 "Trip Card (Map)" extends "Trip Card"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(Map; "Map Component Factbox")
            {
                ApplicationArea = All;
            }
            part(MapDetails; "Map Route Factbox")
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
                    // SuggestShipments();
                end;
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

    // local procedure SuggestShipments()
    // var
    //     RouteDetailBuffer: Record "Map Route Detail" temporary;
    //     MapBuffer: Codeunit "Map Buffer";
    //     ShowTrip: Codeunit "Map Show Trip";
    // begin
    //     MapBuffer.GetRouteDetails(RouteDetailBuffer);
    //     RouteDetailBuffer.SetRange(Type, RouteDetailBuffer.Type::Route);
    //     RouteDetailBuffer.DeleteAll();
    //     MapBuffer.SetRouteDetails(RouteDetailBuffer);

    //     ShowTrip.SetMultiple();
    //     ShowTrip.Run(Rec);

    //     CurrPage.Map.Page.GetDataFromBuffer();
    //     CurrPage.Map.Page.Update();
    // end;
}
