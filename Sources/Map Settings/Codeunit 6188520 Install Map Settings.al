codeunit 6188520 "Install Map Settings"
{
    Subtype = Install;

    procedure SetDefaultMapSettings()
    var
        MapSettingsSetup: Record "Map Settings";
    begin
        if not MapSettingsSetup.Get() then
            MapSettingsSetup.SetDefaultSettings();
    end;
}