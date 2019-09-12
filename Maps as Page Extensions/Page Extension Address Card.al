pageextension 6188523 "Address Card (Map)" extends "Address Card"
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
        RouteDetails.ToBuffer;
        CurrPage.Map.Page.GetDataFromBuffer;
        CurrPage.Map.Page.Update;
    end;
}
