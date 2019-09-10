pageextension 80103 "Address Card (Map)" extends "Address Card"
{
    layout
    {
        addlast(FactBoxes)
        {
            part(Map; "Map Component Factbox") { Visible = false; }
        }
    }
    
    trigger OnAfterGetCurrRecord();
    var
        RouteDetails: Record "Map Route Detail" temporary;
    begin
        RouteDetails.Reset;
        RouteDetails.DeleteAll;
        RouteDetails."Route No." := 0;
        RouteDetails.Latitude := Latitude;
        RouteDetails.Longitude := Longitude;
        RouteDetails."Marker Text" := Description + ' ' + Street + ' ' + "Post Code" + ' ' + City;
        RouteDetails.Insert;
        CurrPage.Map.Page.ClearMap;
        RouteDetails.ToBuffer;
        CurrPage.Map.Page.setData();
        CurrPage.Map.Page.ShowMarkerOnMap;
        CurrPage.Map.Page.Update;
    end;
}
