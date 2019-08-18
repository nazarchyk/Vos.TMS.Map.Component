table 6188522 "Map Route Detail"
{

    fields
    {
        field(1; "Route No."; Integer) { }
        field(2; "Stop No."; Integer) { }
        field(3; Color; Text[7]) { }
        field(4; Name; Text[250]) { }
        field(5; Type; Option) { OptionMembers = Markers, Route; }
        field(7; Longitude; Decimal) { }
        field(8; Latitude; Decimal) { }
        field(9; "Pop Up"; Text[250]) { }
        field(10; "Marker Text"; Text[250]) { }
        field(12; "Marker Type"; Option) { OptionMembers = Icon, Circle; }
        field(13; Icon; Text[250]) { }
        field(15; "Marker Fill Color"; Text[100]) { InitValue = 'red'; }
        field(18; "Marker Fill Opacity"; Integer) { InitValue = 1; }
        field(20; "Marker Radius"; Integer) { InitValue = 10; }
        field(22; "Marker Stroke Color"; Text[100]) { InitValue = 'black'; }
        field(25; "Marker Stroke Opacity"; Integer) { InitValue = 1; }
        field(28; "Marker Stroke With (Pixels)"; Integer) { InitValue = 3; }
        field(30; Id; Guid) { }
        field(31; Source; Text[30]) { }
        field(32; Selected; Boolean) {}
    }

    keys
    { key(PK; "Route No.", "Stop No.") { Clustered = true; } }
    procedure IsValid(): Boolean
    begin
        if Longitude < -6 then
            exit(false);
        if Longitude > 25 then
            exit(false);
        if Latitude < 38 then
            exit(false);
        if Latitude > 70 then
            exit(false);
        exit(true);
    end;
    procedure SetMarkerRadiusBasedOnLoadingMeters(Value: Decimal)
    begin
        "Marker Radius" := Round(Value, 1, '>');
            // if Shpmnt."Payable Weight (Order)" >= 25000 then
            //     RouteDetails."Marker Radius" := 25
            // else if Shpmnt."Payable Weight (Order)" >= 10000 then 
            //     RouteDetails."Marker Radius" := 20
            // else if Shpmnt."Payable Weight (Order)" >= 5000 then
            //      RouteDetails."Marker Radius" := 15
            // else
            //     RouteDetails."Marker Radius" := 10;
    end;

    procedure GetRoutes(var Route: Record "Map Route");
    var
        MapBuffer: Codeunit "Map Buffer";
    begin
        MapBuffer.GetRoutes(Route);
    end;

    procedure ToBuffer()
    var
        MapBuffer: Codeunit "Map Buffer";
    begin
        MapBuffer.SetRouteDetails(Rec);
    end;

    procedure ShowMarker(IsReady: Boolean): JsonObject
    var
        MapShowMarker: codeunit "Map Show Marker";
    begin
        exit(MapShowMarker.GetMarkerJson(Rec, IsReady));
    end;

    procedure SetColor(Value: text)
    begin
        case Value of
'AliceBlue' : Color := '#f0f8ff';
'AntiqueWhite' : Color := '#faebd7';
'AntiqueWhite1' : Color := '#ffefdb';
'AntiqueWhite2' : Color := '#eedfcc';
'AntiqueWhite3' : Color := '#cdc0b0';
'AntiqueWhite4' : Color := '#8b8378';
'aquamarine1' : Color := '#7fffd4';
'aquamarine2' : Color := '#76eec6';
'aquamarine4' : Color := '#458b74';
'azure1' : Color := '#f0ffff';
'azure2' : Color := '#e0eeee';
'azure3' : Color := '#c1cdcd';
'azure4' : Color := '#838b8b';
'beige' : Color := '#f5f5dc';
'bisque1' : Color := '#ffe4c4';
'bisque2' : Color := '#eed5b7';
'bisque3' : Color := '#cdb79e';
'bisque4' : Color := '#8b7d6b';
'black' : Color := '#000000';
'BlanchedAlmond' : Color := '#ffebcd';
'blue1' : Color := '#0000ff';
'blue2' : Color := '#0000ee';
'blue4' : Color := '#00008b';
'BlueViolet' : Color := '#8a2be2';
'brown' : Color := '#a52a2a';
'brown1' : Color := '#ff4040';
'brown2' : Color := '#ee3b3b';
'brown3' : Color := '#cd3333';
'brown4' : Color := '#8b2323';
'burlywood' : Color := '#deb887';
'burlywood1' : Color := '#ffd39b';
'burlywood2' : Color := '#eec591';
'burlywood3' : Color := '#cdaa7d';
'burlywood4' : Color := '#8b7355';
'CadetBlue' : Color := '#5f9ea0';
'CadetBlue1' : Color := '#98f5ff';
'CadetBlue2' : Color := '#8ee5ee';
'CadetBlue3' : Color := '#7ac5cd';
'CadetBlue4' : Color := '#53868b';
'chartreuse1' : Color := '#7fff00';
'chartreuse2' : Color := '#76ee00';
'chartreuse3' : Color := '#66cd00';
'chartreuse4' : Color := '#458b00';
'chocolate' : Color := '#d2691e';
'chocolate1' : Color := '#ff7f24';
'chocolate2' : Color := '#ee7621';
'chocolate3' : Color := '#cd661d';
'coral' : Color := '#ff7f50';
'coral1' : Color := '#ff7256';
'coral2' : Color := '#ee6a50';
'coral3' : Color := '#cd5b45';
'coral4' : Color := '#8b3e2f';
'CornflowerBlue' : Color := '#6495ed';
'cornsilk1' : Color := '#fff8dc';
'cornsilk2' : Color := '#eee8cd';
'cornsilk3' : Color := '#cdc8b1';
'cornsilk4' : Color := '#8b8878';
'cyan1' : Color := '#00ffff';
'cyan2' : Color := '#00eeee';
'cyan3' : Color := '#00cdcd';
'cyan4' : Color := '#008b8b';
'DarkGoldenrod' : Color := '#b8860b';
'DarkGoldenrod1' : Color := '#ffb90f';
'DarkGoldenrod2' : Color := '#eead0e';
'DarkGoldenrod3' : Color := '#cd950c';
'DarkGoldenrod4' : Color := '#8b6508';
'DarkGreen' : Color := '#006400';
'DarkKhaki' : Color := '#bdb76b';
'DarkOliveGreen' : Color := '#556b2f';
'DarkOliveGreen1' : Color := '#caff70';
'DarkOliveGreen2' : Color := '#bcee68';
'DarkOliveGreen3' : Color := '#a2cd5a';
'DarkOliveGreen4' : Color := '#6e8b3d';
'DarkOrange' : Color := '#ff8c00';
'DarkOrange1' : Color := '#ff7f00';
'DarkOrange2' : Color := '#ee7600';
'DarkOrange3' : Color := '#cd6600';
'DarkOrange4' : Color := '#8b4500';
'DarkOrchid' : Color := '#9932cc';
'DarkOrchid1' : Color := '#bf3eff';
'DarkOrchid2' : Color := '#b23aee';
'DarkOrchid3' : Color := '#9a32cd';
'DarkOrchid4' : Color := '#68228b';
'DarkSalmon' : Color := '#e9967a';
'DarkSeaGreen' : Color := '#8fbc8f';
'DarkSeaGreen1' : Color := '#c1ffc1';
'DarkSeaGreen2' : Color := '#b4eeb4';
'DarkSeaGreen3' : Color := '#9bcd9b';
'DarkSeaGreen4' : Color := '#698b69';
'DarkSlateBlue' : Color := '#483d8b';
'DarkSlateGray' : Color := '#2f4f4f';
'DarkSlateGray1' : Color := '#97ffff';
'DarkSlateGray2' : Color := '#8deeee';
'DarkSlateGray3' : Color := '#79cdcd';
'DarkSlateGray4' : Color := '#528b8b';
'DarkTurquoise' : Color := '#00ced1';
'DarkViolet' : Color := '#9400d3';
'DeepPink1' : Color := '#ff1493';
'DeepPink2' : Color := '#ee1289';
'DeepPink3' : Color := '#cd1076';
'DeepPink4' : Color := '#8b0a50';
'DeepSkyBlue1' : Color := '#00bfff';
'DeepSkyBlue2' : Color := '#00b2ee';
'DeepSkyBlue3' : Color := '#009acd';
'DeepSkyBlue4' : Color := '#00688b';
'DimGray' : Color := '#696969';
'DodgerBlue1' : Color := '#1e90ff';
'DodgerBlue2' : Color := '#1c86ee';
'DodgerBlue3' : Color := '#1874cd';
'DodgerBlue4' : Color := '#104e8b';
'firebrick' : Color := '#b22222';
'firebrick1' : Color := '#ff3030';
'firebrick2' : Color := '#ee2c2c';
'firebrick3' : Color := '#cd2626';
'firebrick4' : Color := '#8b1a1a';
'FloralWhite' : Color := '#fffaf0';
'ForestGreen' : Color := '#228b22';
'gainsboro' : Color := '#dcdcdc';
'GhostWhite' : Color := '#f8f8ff';
'gold1' : Color := '#ffd700';
'gold2' : Color := '#eec900';
'gold3' : Color := '#cdad00';
'gold4' : Color := '#8b7500';
'goldenrod' : Color := '#daa520';
'goldenrod1' : Color := '#ffc125';
'goldenrod2' : Color := '#eeb422';
'goldenrod3' : Color := '#cd9b1d';
'goldenrod4' : Color := '#8b6914';
'gray' : Color := '#bebebe';
'gray1' : Color := '#030303';
'gray10' : Color := '#1a1a1a';
'gray11' : Color := '#1c1c1c';
'gray12' : Color := '#1f1f1f';
'gray13' : Color := '#212121';
'gray14' : Color := '#242424';
'gray15' : Color := '#262626';
'gray16' : Color := '#292929';
'gray17' : Color := '#2b2b2b';
'gray18' : Color := '#2e2e2e';
'gray19' : Color := '#303030';
'gray2' : Color := '#050505';
'gray20' : Color := '#333333';
'gray21' : Color := '#363636';
'gray22' : Color := '#383838';
'gray23' : Color := '#3b3b3b';
'gray24' : Color := '#3d3d3d';
'gray25' : Color := '#404040';
'gray26' : Color := '#424242';
'gray27' : Color := '#454545';
'gray28' : Color := '#474747';
'gray29' : Color := '#4a4a4a';
'gray3' : Color := '#080808';
'gray30' : Color := '#4d4d4d';
'gray31' : Color := '#4f4f4f';
'gray32' : Color := '#525252';
'gray33' : Color := '#545454';
'gray34' : Color := '#575757';
'gray35' : Color := '#595959';
'gray36' : Color := '#5c5c5c';
'gray37' : Color := '#5e5e5e';
'gray38' : Color := '#616161';
'gray39' : Color := '#636363';
'gray4' : Color := '#0a0a0a';
'gray40' : Color := '#666666';
'gray41' : Color := '#696969';
'gray42' : Color := '#6b6b6b';
'gray43' : Color := '#6e6e6e';
'gray44' : Color := '#707070';
'gray45' : Color := '#737373';
'gray46' : Color := '#757575';
'gray47' : Color := '#787878';
'gray48' : Color := '#7a7a7a';
'gray49' : Color := '#7d7d7d';
'gray5' : Color := '#0d0d0d';
'gray50' : Color := '#7f7f7f';
'gray51' : Color := '#828282';
'gray52' : Color := '#858585';
'gray53' : Color := '#878787';
'gray54' : Color := '#8a8a8a';
'gray55' : Color := '#8c8c8c';
'gray56' : Color := '#8f8f8f';
'gray57' : Color := '#919191';
'gray58' : Color := '#949494';
'gray59' : Color := '#969696';
'gray6' : Color := '#0f0f0f';
'gray60' : Color := '#999999';
'gray61' : Color := '#9c9c9c';
'gray62' : Color := '#9e9e9e';
'gray63' : Color := '#a1a1a1';
'gray64' : Color := '#a3a3a3';
'gray65' : Color := '#a6a6a6';
'gray66' : Color := '#a8a8a8';
'gray67' : Color := '#ababab';
'gray68' : Color := '#adadad';
'gray69' : Color := '#b0b0b0';
'gray7' : Color := '#121212';
'gray70' : Color := '#b3b3b3';
'gray71' : Color := '#b5b5b5';
'gray72' : Color := '#b8b8b8';
'gray73' : Color := '#bababa';
'gray74' : Color := '#bdbdbd';
'gray75' : Color := '#bfbfbf';
'gray76' : Color := '#c2c2c2';
'gray77' : Color := '#c4c4c4';
'gray78' : Color := '#c7c7c7';
'gray79' : Color := '#c9c9c9';
'gray8' : Color := '#141414';
'gray80' : Color := '#cccccc';
'gray81' : Color := '#cfcfcf';
'gray82' : Color := '#d1d1d1';
'gray83' : Color := '#d4d4d4';
'gray84' : Color := '#d6d6d6';
'gray85' : Color := '#d9d9d9';
'gray86' : Color := '#dbdbdb';
'gray87' : Color := '#dedede';
'gray88' : Color := '#e0e0e0';
'gray89' : Color := '#e3e3e3';
'gray9' : Color := '#171717';
'gray90' : Color := '#e5e5e5';
'gray91' : Color := '#e8e8e8';
'gray92' : Color := '#ebebeb';
'gray93' : Color := '#ededed';
'gray94' : Color := '#f0f0f0';
'gray95' : Color := '#f2f2f2';
'gray97' : Color := '#f7f7f7';
'gray98' : Color := '#fafafa';
'gray99' : Color := '#fcfcfc';
'green1' : Color := '#00ff00';
'green2' : Color := '#00ee00';
'green3' : Color := '#00cd00';
'green4' : Color := '#008b00';
'GreenYellow' : Color := '#adff2f';
'honeydew1' : Color := '#f0fff0';
'honeydew2' : Color := '#e0eee0';
'honeydew3' : Color := '#c1cdc1';
'honeydew4' : Color := '#838b83';
'HotPink' : Color := '#ff69b4';
'HotPink1' : Color := '#ff6eb4';
'HotPink2' : Color := '#ee6aa7';
'HotPink3' : Color := '#cd6090';
'HotPink4' : Color := '#8b3a62';
'IndianRed' : Color := '#cd5c5c';
'IndianRed1' : Color := '#ff6a6a';
'IndianRed2' : Color := '#ee6363';
'IndianRed3' : Color := '#cd5555';
'IndianRed4' : Color := '#8b3a3a';
'ivory1' : Color := '#fffff0';
'ivory2' : Color := '#eeeee0';
'ivory3' : Color := '#cdcdc1';
'ivory4' : Color := '#8b8b83';
'khaki' : Color := '#f0e68c';
'khaki1' : Color := '#fff68f';
'khaki2' : Color := '#eee685';
'khaki3' : Color := '#cdc673';
'khaki4' : Color := '#8b864e';
'lavender' : Color := '#e6e6fa';
'LavenderBlush1' : Color := '#fff0f5';
'LavenderBlush2' : Color := '#eee0e5';
'LavenderBlush3' : Color := '#cdc1c5';
'LavenderBlush4' : Color := '#8b8386';
'LawnGreen' : Color := '#7cfc00';
'LemonChiffon1' : Color := '#fffacd';
'LemonChiffon2' : Color := '#eee9bf';
'LemonChiffon3' : Color := '#cdc9a5';
'LemonChiffon4' : Color := '#8b8970';
'light' : Color := '#eedd82';
'LightBlue' : Color := '#add8e6';
'LightBlue1' : Color := '#bfefff';
'LightBlue2' : Color := '#b2dfee';
'LightBlue3' : Color := '#9ac0cd';
'LightBlue4' : Color := '#68838b';
'LightCoral' : Color := '#f08080';
'LightCyan1' : Color := '#e0ffff';
'LightCyan2' : Color := '#d1eeee';
'LightCyan3' : Color := '#b4cdcd';
'LightCyan4' : Color := '#7a8b8b';
'LightGoldenrod1' : Color := '#ffec8b';
'LightGoldenrod2' : Color := '#eedc82';
'LightGoldenrod3' : Color := '#cdbe70';
'LightGoldenrod4' : Color := '#8b814c';
'LightGoldenrodYellow' : Color := '#fafad2';
'LightGray' : Color := '#d3d3d3';
'LightPink' : Color := '#ffb6c1';
'LightPink1' : Color := '#ffaeb9';
'LightPink2' : Color := '#eea2ad';
'LightPink3' : Color := '#cd8c95';
'LightPink4' : Color := '#8b5f65';
'LightSalmon1' : Color := '#ffa07a';
'LightSalmon2' : Color := '#ee9572';
'LightSalmon3' : Color := '#cd8162';
'LightSalmon4' : Color := '#8b5742';
'LightSeaGreen' : Color := '#20b2aa';
'LightSkyBlue' : Color := '#87cefa';
'LightSkyBlue1' : Color := '#b0e2ff';
'LightSkyBlue2' : Color := '#a4d3ee';
'LightSkyBlue3' : Color := '#8db6cd';
'LightSkyBlue4' : Color := '#607b8b';
'LightSlateBlue' : Color := '#8470ff';
'LightSlateGray' : Color := '#778899';
'LightSteelBlue' : Color := '#b0c4de';
'LightSteelBlue1' : Color := '#cae1ff';
'LightSteelBlue2' : Color := '#bcd2ee';
'LightSteelBlue3' : Color := '#a2b5cd';
'LightSteelBlue4' : Color := '#6e7b8b';
'LightYellow1' : Color := '#ffffe0';
'LightYellow2' : Color := '#eeeed1';
'LightYellow3' : Color := '#cdcdb4';
'LightYellow4' : Color := '#8b8b7a';
'LimeGreen' : Color := '#32cd32';
'linen' : Color := '#faf0e6';
'magenta' : Color := '#ff00ff';
'magenta2' : Color := '#ee00ee';
'magenta3' : Color := '#cd00cd';
'magenta4' : Color := '#8b008b';
'maroon' : Color := '#b03060';
'maroon1' : Color := '#ff34b3';
'maroon2' : Color := '#ee30a7';
'maroon3' : Color := '#cd2990';
'maroon4' : Color := '#8b1c62';
'medium' : Color := '#66cdaa';
'MediumAquamarine' : Color := '#66cdaa';
'MediumBlue' : Color := '#0000cd';
'MediumOrchid' : Color := '#ba55d3';
'MediumOrchid1' : Color := '#e066ff';
'MediumOrchid2' : Color := '#d15fee';
'MediumOrchid3' : Color := '#b452cd';
'MediumOrchid4' : Color := '#7a378b';
'MediumPurple' : Color := '#9370db';
'MediumPurple1' : Color := '#ab82ff';
'MediumPurple2' : Color := '#9f79ee';
'MediumPurple3' : Color := '#8968cd';
'MediumPurple4' : Color := '#5d478b';
'MediumSeaGreen' : Color := '#3cb371';
'MediumSlateBlue' : Color := '#7b68ee';
'MediumSpringGreen' : Color := '#00fa9a';
'MediumTurquoise' : Color := '#48d1cc';
'MediumVioletRed' : Color := '#c71585';
'MidnightBlue' : Color := '#191970';
'MintCream' : Color := '#f5fffa';
'MistyRose1' : Color := '#ffe4e1';
'MistyRose2' : Color := '#eed5d2';
'MistyRose3' : Color := '#cdb7b5';
'MistyRose4' : Color := '#8b7d7b';
'moccasin' : Color := '#ffe4b5';
'NavajoWhite1' : Color := '#ffdead';
'NavajoWhite2' : Color := '#eecfa1';
'NavajoWhite3' : Color := '#cdb38b';
'NavajoWhite4' : Color := '#8b795e';
'NavyBlue' : Color := '#000080';
'OldLace' : Color := '#fdf5e6';
'OliveDrab' : Color := '#6b8e23';
'OliveDrab1' : Color := '#c0ff3e';
'OliveDrab2' : Color := '#b3ee3a';
'OliveDrab4' : Color := '#698b22';
'orange1' : Color := '#ffa500';
'orange2' : Color := '#ee9a00';
'orange3' : Color := '#cd8500';
'orange4' : Color := '#8b5a00';
'OrangeRed1' : Color := '#ff4500';
'OrangeRed2' : Color := '#ee4000';
'OrangeRed3' : Color := '#cd3700';
'OrangeRed4' : Color := '#8b2500';
'orchid' : Color := '#da70d6';
'orchid1' : Color := '#ff83fa';
'orchid2' : Color := '#ee7ae9';
'orchid3' : Color := '#cd69c9';
'orchid4' : Color := '#8b4789';
'pale' : Color := '#db7093';
'PaleGoldenrod' : Color := '#eee8aa';
'PaleGreen' : Color := '#98fb98';
'PaleGreen1' : Color := '#9aff9a';
'PaleGreen2' : Color := '#90ee90';
'PaleGreen3' : Color := '#7ccd7c';
'PaleGreen4' : Color := '#548b54';
'PaleTurquoise' : Color := '#afeeee';
'PaleTurquoise1' : Color := '#bbffff';
'PaleTurquoise2' : Color := '#aeeeee';
'PaleTurquoise3' : Color := '#96cdcd';
'PaleTurquoise4' : Color := '#668b8b';
'PaleVioletRed' : Color := '#db7093';
'PaleVioletRed1' : Color := '#ff82ab';
'PaleVioletRed2' : Color := '#ee799f';
'PaleVioletRed3' : Color := '#cd6889';
'PaleVioletRed4' : Color := '#8b475d';
'PapayaWhip' : Color := '#ffefd5';
'PeachPuff1' : Color := '#ffdab9';
'PeachPuff2' : Color := '#eecbad';
'PeachPuff3' : Color := '#cdaf95';
'PeachPuff4' : Color := '#8b7765';
'pink' : Color := '#ffc0cb';
'pink1' : Color := '#ffb5c5';
'pink2' : Color := '#eea9b8';
'pink3' : Color := '#cd919e';
'pink4' : Color := '#8b636c';
'plum' : Color := '#dda0dd';
'plum1' : Color := '#ffbbff';
'plum2' : Color := '#eeaeee';
'plum3' : Color := '#cd96cd';
'plum4' : Color := '#8b668b';
'PowderBlue' : Color := '#b0e0e6';
'purple' : Color := '#a020f0';
'rebeccapurple' : Color := '#663399';
'purple1' : Color := '#9b30ff';
'purple2' : Color := '#912cee';
'purple3' : Color := '#7d26cd';
'purple4' : Color := '#551a8b';
'red1' : Color := '#ff0000';
'red2' : Color := '#ee0000';
'red3' : Color := '#cd0000';
'red4' : Color := '#8b0000';
'RosyBrown' : Color := '#bc8f8f';
'RosyBrown1' : Color := '#ffc1c1';
'RosyBrown2' : Color := '#eeb4b4';
'RosyBrown3' : Color := '#cd9b9b';
'RosyBrown4' : Color := '#8b6969';
'RoyalBlue' : Color := '#4169e1';
'RoyalBlue1' : Color := '#4876ff';
'RoyalBlue2' : Color := '#436eee';
'RoyalBlue3' : Color := '#3a5fcd';
'RoyalBlue4' : Color := '#27408b';
'SaddleBrown' : Color := '#8b4513';
'salmon' : Color := '#fa8072';
'salmon1' : Color := '#ff8c69';
'salmon2' : Color := '#ee8262';
'salmon3' : Color := '#cd7054';
'salmon4' : Color := '#8b4c39';
'SandyBrown' : Color := '#f4a460';
'SeaGreen1' : Color := '#54ff9f';
'SeaGreen2' : Color := '#4eee94';
'SeaGreen3' : Color := '#43cd80';
'SeaGreen4' : Color := '#2e8b57';
'seashell1' : Color := '#fff5ee';
'seashell2' : Color := '#eee5de';
'seashell3' : Color := '#cdc5bf';
'seashell4' : Color := '#8b8682';
'sienna' : Color := '#a0522d';
'sienna1' : Color := '#ff8247';
'sienna2' : Color := '#ee7942';
'sienna3' : Color := '#cd6839';
'sienna4' : Color := '#8b4726';
'SkyBlue' : Color := '#87ceeb';
'SkyBlue1' : Color := '#87ceff';
'SkyBlue2' : Color := '#7ec0ee';
'SkyBlue3' : Color := '#6ca6cd';
'SkyBlue4' : Color := '#4a708b';
'SlateBlue' : Color := '#6a5acd';
'SlateBlue1' : Color := '#836fff';
'SlateBlue2' : Color := '#7a67ee';
'SlateBlue3' : Color := '#6959cd';
'SlateBlue4' : Color := '#473c8b';
'SlateGray' : Color := '#708090';
'SlateGray1' : Color := '#c6e2ff';
'SlateGray2' : Color := '#b9d3ee';
'SlateGray3' : Color := '#9fb6cd';
'SlateGray4' : Color := '#6c7b8b';
'snow1' : Color := '#fffafa';
'snow2' : Color := '#eee9e9';
'snow3' : Color := '#cdc9c9';
'snow4' : Color := '#8b8989';
'SpringGreen1' : Color := '#00ff7f';
'SpringGreen2' : Color := '#00ee76';
'SpringGreen3' : Color := '#00cd66';
'SpringGreen4' : Color := '#008b45';
'SteelBlue' : Color := '#4682b4';
'SteelBlue1' : Color := '#63b8ff';
'SteelBlue2' : Color := '#5cacee';
'SteelBlue3' : Color := '#4f94cd';
'SteelBlue4' : Color := '#36648b';
'tan' : Color := '#d2b48c';
'tan1' : Color := '#ffa54f';
'tan2' : Color := '#ee9a49';
'tan3' : Color := '#cd853f';
'tan4' : Color := '#8b5a2b';
'thistle' : Color := '#d8bfd8';
'thistle1' : Color := '#ffe1ff';
'thistle2' : Color := '#eed2ee';
'thistle3' : Color := '#cdb5cd';
'thistle4' : Color := '#8b7b8b';
'tomato1' : Color := '#ff6347';
'tomato2' : Color := '#ee5c42';
'tomato3' : Color := '#cd4f39';
'tomato4' : Color := '#8b3626';
'turquoise' : Color := '#40e0d0';
'turquoise1' : Color := '#00f5ff';
'turquoise2' : Color := '#00e5ee';
'turquoise3' : Color := '#00c5cd';
'turquoise4' : Color := '#00868b';
'violet' : Color := '#ee82ee';
'VioletRed' : Color := '#d02090';
'VioletRed1' : Color := '#ff3e96';
'VioletRed2' : Color := '#ee3a8c';
'VioletRed3' : Color := '#cd3278';
'VioletRed4' : Color := '#8b2252';
'wheat' : Color := '#f5deb3';
'wheat1' : Color := '#ffe7ba';
'wheat2' : Color := '#eed8ae';
'wheat3' : Color := '#cdba96';
'wheat4' : Color := '#8b7e66';
'white' : Color := '#ffffff';
'WhiteSmoke' : Color := '#f5f5f5';
'yellow1' : Color := '#ffff00';
'yellow2' : Color := '#eeee00';
'yellow3' : Color := '#cdcd00';
'yellow4' : Color := '#8b8b00';
'YellowGreen' : Color := '#9acd32';

        else
        Color := Value;
        end
    end;

}