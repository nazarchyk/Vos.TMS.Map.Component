pageextension 6188522 "Address List (Map)" extends "Address List"
{
    layout
    {
        addlast(FactBoxes)
        {
            part(Map; "Map Component Factbox") { }
        }
    }
    trigger OnAfterGetCurrRecord();
    var
        RouteDetails: Record "Map Route Detail" temporary;
    begin
        RouteDetails."Route No." := 0;
        RouteDetails.Latitude := Latitude;
        RouteDetails.Longitude := Longitude;
        RouteDetails."Marker Text" := Description + ' ' + Street + ' ' + "Post Code" + ' ' + City;
        RouteDetails.Insert;
        RouteDetails.ToBuffer;
        CurrPage.Map.Page.GetDataFromBuffer;
        CurrPage.Map.Page.Update;
    end;
}