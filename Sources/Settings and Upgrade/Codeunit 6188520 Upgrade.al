codeunit 6188520 "Map Install and Upgrade"
{
    Subtype = Install;

    local procedure InstallMap();
    var
        MapSettings: Record "Map Settings";
    begin
        with MapSettings do
        begin
            if Get then
                exit;
            "Account URL" := 'https://xmap-eu-n-test.cloud.ptvgroup.com/xmap';
            Username := 'D3B61519-68F6-4177-B613-01BB1F707496';
            Password := 'GS04m!5M.K';
            Token := '5D1D3D5C-50D0-415B-98EE-8FF4D61FB255';
            Insert;
        end;
    end;
}