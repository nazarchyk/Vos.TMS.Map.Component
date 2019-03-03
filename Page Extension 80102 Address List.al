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
        MapRoute: Record "Map Route" temporary;
    begin
        MapRoute."Route No." := 0;
        MapRoute.Latitude := Latitude;
        MapRoute.Longitude := Longitude;
        MapRoute."Marker Text" := Description + ' ' + Street + ' ' + "Post Code" + ' ' + City;
        MapRoute.Insert;
        CurrPage.Map.Page.ClearMap;
        CurrPage.Map.Page.setData(MapRoute);

        CurrPage.Map.Page.ShowMarker;
    end;
}
