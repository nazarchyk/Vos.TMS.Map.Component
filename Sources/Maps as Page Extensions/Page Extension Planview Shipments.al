pageextension 6188528 "Planview Shipment (Map)" extends "Planview Shipments"
{
    layout
    {
        // addbefore(TableShip)
        // {
        //     part(Map; "Map Component Factbox")
        //     {
        //         ApplicationArea = All;
        //         UpdatePropagation = Both;
        //         Visible = IsMapVisible;
        //     }
        // }

        addlast(FactBoxes)
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

                trigger OnAction()
                begin
                    IsMapVisible := not IsMapVisible;
                end;
            }
        }
    }

    var
        ShipmentBuffer: Record Shipment temporary;
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
        // GetShpmntBuffer(ShipmentBuffer);
        // AddSelectedShipmentsToMap();

        if xFilters <> GetFilters() then begin
            xFilters := GetFilters();

            If IsMapVisible then begin
                RecReference.GetTable(Rec);
                CurrPage.Map.Page.UpdateMapContent(RecReference);
            end;
        end;
    end;

    local procedure AddSelectedShipmentsToMap()
    var
        RouteDetail: Record "Map Route Detail" temporary;
        MapBuffer: Codeunit "Map Buffer";
    begin
        MapBuffer.GetRouteDetails(RouteDetail);
        if ShipmentBuffer.FindSet() then
            repeat
                RouteDetail.SetRange(Id, ShipmentBuffer.Id);
                if RouteDetail.FindFirst then begin
                    if ShipmentBuffer."Plan-ID" = '' then
                        RouteDetail.Selected := RouteDetail.Selected::Clicked
                    else
                        RouteDetail.Selected := RouteDetail.Selected::Selected;
                    RouteDetail.SetMarkerStrokeBasedOnSelected();
                    RouteDetail.Modify();
                end;
            until (ShipmentBuffer.Next() = 0);

        RouteDetail.Reset();
        MapBuffer.SetRouteDetails(RouteDetail);
        CurrPage.Map.Page.GetDataFromBuffer();
    end;
}