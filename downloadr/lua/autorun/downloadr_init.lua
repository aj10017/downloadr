AddCSLuaFile()
AddCSLuaFile("downloadr/client/cl_init.lua")
AddCSLuaFile("downloadr/shared/config.lua")
if CLIENT then
	include('downloadr/client/cl_init.lua')
	include('downloadr/shared/config.lua')
end
