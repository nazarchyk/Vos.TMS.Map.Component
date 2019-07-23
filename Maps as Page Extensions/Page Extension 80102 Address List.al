pageextension 80102 "Address List (Map)" extends "Address List"
{
    layout
    {
        addlast(FactBoxes)
        {
            part(Map; "Map Component Factbox"){ Visible = false; }
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
        CurrPage.Map.Page.ClearMap;
        RouteDetails.ToBuffer;
        CurrPage.Map.Page.setData;

        CurrPage.Map.Page.ShowMarkerOnMap;
    end;
}
