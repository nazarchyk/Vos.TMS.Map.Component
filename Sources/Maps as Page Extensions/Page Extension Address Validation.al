pageextension 6188531 "Address Validation (Map)" extends "Address Validation Card"
{
    layout
    {
        addlast(FactBoxes)
        {
            part(Map; "Map Component Factbox") {  }
        }
    }
    
    trigger OnAfterGetCurrRecord();
    var
        RouteDetails: Record "Map Route Detail" temporary;
    begin
        RouteDetails.Reset;
        RouteDetails.DeleteAll;
        RouteDetails."Route No." := 0;
        RouteDetails.Latitude := "Latitude";
        RouteDetails.Longitude := "Longitude";
        RouteDetails."Marker Text" := "City";
        RouteDetails.Insert;
        RouteDetails.ToBuffer;
        CurrPage.Map.Page.GetDataFromBuffer;
        CurrPage.Map.Page.Update;
    end;
}
