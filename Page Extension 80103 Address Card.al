pageextension 80103 "Address Card (Map)" extends "Address Card"
{
    layout
    {
        addlast(FactBoxes)
        {
            part(Map; "Map Component Factbox")            {            }
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
    end;
}
