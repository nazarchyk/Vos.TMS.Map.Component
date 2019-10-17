pageextension 6188530 "Truck List (Map)" extends "Truck List"
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
        RouteDetails.Latitude := "Last Latitude";
        RouteDetails.Longitude := "Last Longitude";
        RouteDetails."Marker Text" := "Last City";// + ' ' + Street + ' ' + "Post Code" + ' ' + City;
        RouteDetails.Insert;
        RouteDetails.ToBuffer;
        CurrPage.Map.Page.GetDataFromBuffer;
        CurrPage.Map.Page.Update;
    end;
}
