pageextension 80107 "Trip Card (Map)" extends "Trip Card"
{
    layout
    {
        addfirst(FactBoxes)
        {
            part(Map; "Map Component Factbox") { }
            part(MapDetails; "Map Route Factbox") { }
        }
    }
    actions
    {
        addfirst(Processing)
        {
            action(SuggestShipments)
            {
                Caption = 'Suggest Shipments';
                Image = Map;
                trigger OnAction();
                var
                    ShowShipments: Codeunit "Map Show Shipments";
                    ShowTrip: Codeunit "Map Show Trip";
                begin
                    FindImportShipments;
                    ShowTrip.Run(Rec);
                    CurrPage.Map.Page.GetDataFromBuffer;
                    CurrPage.Map.Page.Update;
                end;
            }
        }
    }
    trigger OnAfterGetCurrRecord();
    var
        ShowTrip: Codeunit "Map Show Trip";
    begin
        ShowTrip.Run(Rec);
        CurrPage.Map.Page.GetDataFromBuffer;
        CurrPage.Map.Page.Update;
    end;
}
