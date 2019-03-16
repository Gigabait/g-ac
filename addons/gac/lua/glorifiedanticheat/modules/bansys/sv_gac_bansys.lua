
function gAC.GetFormattedBanText( displayReason, banTime )
    local banString = "_____"..gAC.config.BAN_MESSAGE_SYNTAX.."_____\n\nReason: '" .. displayReason .. "'\n\n"
    banTime = tonumber( banTime )
    if( banTime == -1 ) then
        banString = banString .. "Type: Kick"
    elseif( banTime >= 0 ) then
        if( banTime == 0 ) then
            banString = banString .. "Type: Permanent Ban\n\nPlease appeal if you believe this is false"
        else
            banString = banString .. "Type: Temporary Ban\n\nPlease appeal if you believe this is false"
        end
    end

    return banString
end

if gAC.config.BAN_TYPE == "custom_func" then
    function gAC.AddBan( ply, displayReason, banTime )
        gAC.config.BAN_FUNC( ply, displayReason, banTime )
    end
elseif gAC.config.BAN_TYPE == "ulx" then
    function gAC.AddBan( ply, displayReason, banTime )
        RunConsoleCommand( "ulx", "banid", ply:SteamID(), banTime, displayReason )
    end
else
    function gAC.AddBan( ply, displayReason, banTime )
        ply:SetUPDataGAC( "gAC_IsBanned", true )
        ply:SetUPDataGAC( "gAC_BannedAtTime", os.time() )
        ply:SetUPDataGAC( "gAC_BanTime", banTime )
        ply:SetUPDataGAC( "gAC_BanDisplayReason", displayReason )

        ply:Kick( gAC.GetFormattedBanText( displayReason, banTime ) )
    end

    function gAC.RemoveBan( ply )
        ply:SetUPDataGAC( "gAC_IsBanned", false )
        ply:SetUPDataGAC( "gAC_BannedAtTime", 0 )
        ply:SetUPDataGAC( "gAC_BanTime", 1 )
        ply:SetUPDataGAC( "gAC_BanDisplayReason", "nil" )
    end

    function gAC.UnbanCommand( caller, plySID64 )
        if( !gAC.PlayerHasUnbanPerm( caller ) ) then return end
        if( !file.IsDir( "g-AC", "DATA" ) ) then
            file.CreateDir( "g-AC" )
        end

        if( file.Exists( "g-AC/" .. plySID64 .. ".txt", "DATA" ) ) then gAC.ClientMessage( caller, "That player is already due for an unban.", Color( 225, 150, 25 ) ) return end
        file.Write( "g-AC/" .. plySID64 .. ".txt", "" )
        gAC.AdminMessage( plySID64, "Ban removed by " .. caller:Nick() .. "" )
    end

    function gAC.BanCheck( ply )
        if( file.Exists( "g-AC/" .. ply:SteamID64() .. ".txt", "DATA" ) ) then
            file.Delete( "g-AC/" .. ply:SteamID64() .. ".txt" )

            if( ply:GetUPDataGAC( "gAC_IsBanned" ) == true || ply:GetUPDataGAC( "gAC_IsBanned" ) == "true" || ply:GetUPDataGAC( "gAC_IsBanned" ) == 1 ) then
                gAC.RemoveBan( ply )

                gAC.AdminMessage( ply:Nick(), "Player's ban removed upon login (admin manually unbanned)", false )
                return
            end
        end

        if( ply:GetUPDataGAC( "gAC_IsBanned" ) == true || ply:GetUPDataGAC( "gAC_IsBanned" ) == "true" || ply:GetUPDataGAC( "gAC_IsBanned" ) == 1 ) then
            if( ( os.time() >= ( tonumber( ply:GetUPDataGAC( "gAC_BannedAtTime" ) ) + ( tonumber( ply:GetUPDataGAC( "gAC_BanTime" ) ) * 60 ) ) ) && tonumber( ply:GetUPDataGAC( "gAC_BanTime" ) ) != 0 ) then
                gAC.RemoveBan( ply )

                gAC.AdminMessage( ply:Nick(), "Player's ban expired.", false )
            else
                ply:Kick( gAC.GetFormattedBanText( ply:GetUPDataGAC( "gAC_BanDisplayReason" ), ply:GetUPDataGAC( "gAC_BanTime" ) ) )
            end
        end
    end

    hook.Add( "PlayerInitialSpawn", "g-ACPlayerInitialSpawnBanSys", function( ply )
        gAC.BanCheck( ply )
    end )

    concommand.Add( "gac-unban", function( ply, cmd, args )
        if( !gAC.PlayerHasUnbanPerm( ply ) ) then gAC.ClientMessage( ply, "You don't have permission to do that!", Color( 225, 150, 25 ) ) return end

        local steamid64 = args[1]
        
        if( steamid64 == "" || steamid64 == nil ) then gAC.ClientMessage( ply, "Please input a valid SteamID64.", Color( 225, 150, 25 ) ) return end
        if( string.len( steamid64 ) != 17 ) then gAC.ClientMessage( ply, "Please input a valid SteamID64.", Color( 225, 150, 25 ) ) return end
        gAC.UnbanCommand( ply, steamid64 )
    end )
end

--[[concommand.Add( "gac-check", function( ply, cmd, args )
    if( !gAC.PlayerHasAdminMessagePerm( ply ) ) then gAC.ClientMessage( ply, "You don't have permission to do that!", Color( 225, 150, 25 ) ) return end
    if( args[1] == "" || args[1] == nil ) then gAC.ClientMessage( ply, "Please input a valid SteamID.", Color( 225, 150, 25 ) ) return end
    if( string.sub(args[1], 1, 8) != "STEAM_0:" ) then gAC.ClientMessage( ply, "Please input a valid SteamID.", Color( 225, 150, 25 ) ) return end
    gAC.GetLog( args[1], function(data)
        if isstring(data) then
            gAC.ClientMessage( ply, data, Color( 225, 150, 25 ) )
        else
            if data == {} or data == nil then
                gAC.ClientMessage( ply, args[1] .. " has no detections.", Color( 0, 255, 0 ) )
            else
                gAC.PrintMessage(ply, HUD_PRINTCONSOLE, "Detection Log for " .. args[1])
                for k, v in pairs(data) do
                    gAC.PrintMessage(ply, HUD_PRINTCONSOLE, os.date( "[%H:%M:%S %p - %d/%m/%Y]", v["time"] ) .. " - " .. v["detection"])
                end
                gAC.ClientMessage( ply, "Look in console.", Color( 0, 255, 0 ) )
            end
        end
    end)
end )]]

if isfunction(gAC.config.KICK_FUNC) then
    function gAC.Kick( ply, displayReason )
        gAC.config.KICK_FUNC( ply, displayReason )
    end
else
    function gAC.Kick( ply, displayReason )
        ply:Kick( gAC.GetFormattedBanText( displayReason, -1 ) )
    end
end