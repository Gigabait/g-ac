AddCSLuaFile("includes/extensions/client/render.lua")

local _BroadcastLua = BroadcastLua
local _hook_Add = hook.Add
local _player_GetHumans = player.GetHumans
local _util_Compress = util.Compress

local _R = debug.getregistry ()

local Entity_IsValid = _R.Entity.IsValid
local Player_SendLua = _R.Player.SendLua

local SendLuas = {}

_G.BroadcastLua = function (code)
	if gAC and gAC.Network and gAC.Network.ReceiveCount then
		code = _util_Compress(code)
		local _IPAIRS_ = _player_GetHumans()
		for k=1, #_IPAIRS_ do
			local v =_IPAIRS_[k]
			if not v.gAC_ClientLoaded then
				if not SendLuas[v] then
					SendLuas[v] = {}
				end
				local tbl = SendLuas[v]
				tbl[#tbl + 1] = code
			else
				gAC.Network:Send ("LoadString", code, v, true)
			end
		end
	else
		_BroadcastLua(code)
	end
end

_R.Player.SendLua = function (ply, code)
	if ply and Entity_IsValid (ply) then
		if gAC and gAC.Network and gAC.Network.ReceiveCount then
			code = _util_Compress(code)
			if not ply.gAC_ClientLoaded then
				if not SendLuas[ply] then
					SendLuas[ply] = {}
				end
				local tbl = SendLuas[ply]
				tbl[#tbl + 1] = code
			else
				gAC.Network:Send ("LoadString", code, ply, true)
			end
		else
			Player_SendLua(ply, code)
		end
	end
end

_hook_Add('gAC.ClientLoaded', 'gAC.SendLua', function(pl)
	local tbl = SendLuas[pl]
	if tbl then
		for i=1, #tbl do
			gAC.Network:Send ("LoadString", tbl[i], pl, true)
		end
		SendLuas[pl] = nil
	end
end)

_hook_Add('PlayerDisconnected', 'gAC.SendLua', function(pl)
	SendLuas[pl] = nil
end)