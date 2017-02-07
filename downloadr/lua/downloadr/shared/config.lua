
/*
--config for garrysmod download manager. the table below is sent to clients when they finish spawning in--
==========================================================================================================
--Version 1.4--
simplified config process by adding function to easily add downloads. you can still use your old config however.
file is now shared. client will no longer have to wait for the table to be downloaded
==========================================================================================================
*/
downmgr = downmgr or {}
downmgr.downloads = {}
//DO NOT MODIFY
//==================================================================================
local AddDownload = function(id,crucial)
	if downmgr.downloads~=nil then
		downmgr.downloads[id or 0]={id=id or 0,crucial=crucial or false,downloading = false,downloaded = false,mounted = false}
	end
end
//==================================================================================

//ADD YOUR FILES HERE
AddDownload(117434626,true)
AddDownload(593317634,true)
AddDownload(533111726,true)