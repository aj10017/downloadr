
/*
-- GarrysMod Download Manager (ClientSide) Version 1.4 --
*/

AddCSLuaFile()
include('downloadr/shared/config.lua')
//concommand.Add("downloadr_configure",function() if LocalPlayer():IsSuperAdmin() then downmgr.admin_menu_init() else print("only super admins can access this menu.") end end)
concommand.Add("downloadr_open",function() downmgr.init_menu() end)

downmgr = downmgr or {}

downmgr.blurmat = Material("pp/blurscreen")
hook.Add("Initialize","downloadmgr",function()
	print("GarrysMod Download Manager Initialized")
end)
hook.Add("InitPostEntity","downloadmgr",function()
	timer.Simple(5,function()
		downmgr.verify_downloads()
		downmgr.init_menu()
	end)

end)
hook.Add("OnPlayerChat","downloadmgr",function(ply,text,team,dead)
	if team then return end
	if string.lower(text) == "!downloads" and ply==LocalPlayer() then
		downmgr.init_menu()
	end
	if string.lower(text) == "/downloads" and ply==LocalPlayer() then
		downmgr.init_menu()
	end
end)


downmgr.recreate_fonts = function()
	surface.CreateFont( "dmgr_l", {
			font = "roboto",
			size = 150/(math.Clamp(1600/ScrW(),1,10)+math.Clamp(900/ScrH(),1,10))/2,
			weight = 500,
			antialias = true,
			additive = false,
			shadow = false,
			outline = false,
			blursize = 0,
			scanlines = 0,
	})
	surface.CreateFont( "dmgr_m", {
			font = "roboto",
			size = 75/(math.Clamp(1600/ScrW(),1,10)+math.Clamp(900/ScrH(),1,10))/2,
			weight = 1500,
			antialias = true,
			additive = false,
			shadow = false,
			outline = false,
			blursize = 0,
			scanlines = 0,
	})
	surface.CreateFont( "dmgr_s", {
			font = "roboto",
			size = 50/(math.Clamp(1600/ScrW(),1,10)+math.Clamp(900/ScrH(),1,10))/2,
			weight = 500,
			antialias = true,
			additive = false,
			shadow = false,
			outline = false,
			blursize = 0,
			scanlines = 0,
	})
end

downmgr.verify_downloads = function()
	if downmgr.downloads~=nil then
		for k, v in pairs(downmgr.downloads) do
			if v.mounted == nil then v.mounted = false end
			if v.downloaded == nil then v.downloaded = false end
			if v.downloading == nil then v.downloading = false end
		end
	end
end

downmgr.init_downloads = function(id)
	if id == nil then
		for k, v in pairs(downmgr.downloads) do
			if v.info==nil then
				steamworks.FileInfo(k,function(res) if res~=nil then v.info = res end end)
			end
			if v.info==nil then
				v.failed = true
				return
			end
			local info = v.info
			if info == nil then return end
			local exists = file.Exists("cache/workshop/"..info.fileid..".cache","GAME")
			if exists then
				game.MountGMA("cache/workshop/"..info.fileid..".cache")
				v.mounted = true
			else
				if !v.crucial then return end
				downmgr.downloadfile(k)
				v.downloading = true
				--print("downloading")
			end
		end
	else
		local v = downmgr.downloads[id]
		local k = id
		if v.info==nil then
			steamworks.FileInfo(k,function(res) if res~=nil then v.info = res end end)
		end
		if v.info==nil then
			v.failed = true
			return
		end
		local info = v.info
		local exists = file.Exists("cache/workshop/"..info.fileid..".cache","GAME")
		if exists then
			game.MountGMA("cache/workshop/"..info.fileid..".cache")
			v.mounted = true
		else
			downmgr.downloadfile(k)
			v.downloading = true
			--print("downloading")
		end
	end
end

downmgr.downloadfile = function(id)
	steamworks.Download( downmgr.downloads[id].info.fileid, true, function( path )
		if path~=nil then
			downmgr.downloads[id].mounted = game.MountGMA(path)
			downmgr.downloads[id].downloaded = true
			downmgr.downloads[id].downloading = false
		else
			downmgr.downloads[id].failed = true
			--PrintTable(downmgr.downloads[id].info)
		end
	end )
end
downmgr.mount = function(id)
	if downmgr.downloads[id].info~=nil then
		if file.Exists("cache/workshop/"..downmgr.downloads[id].info.fileid..".cache","GAME") then
			downmgr.downloads[id].mounted = game.MountGMA("cache/workshop/"..downmgr.downloads[id].info.fileid..".cache")
		end
	end
end

downmgr.init_menu = function()
	downmgr.recreate_fonts()
	downmgr.verify_downloads()
	downmgr.vgui = downmgr.vgui or {}
	local t = table.Copy(downmgr.vgui)
	local w = ScrW()
	local h = ScrH()
	//frame creation
	t.frame = vgui.Create("DFrame")
	t.frame:SetPos(w/4,h/6)
	t.frame:SetSize(w/1.4,h/1.5)
	t.frame:Center()
	t.frame:SetTitle("Download Manager")
	t.frame:SetVisible(true)
	t.frame:SetDraggable(true)
	t.frame:ShowCloseButton(true)
	t.frame:MakePopup()
	t.frame.Paint = function(self,w,h)
		downmgr.blur(self,1,1,200)
		draw.RoundedBox(4,0,0,w,h,Color(25,25,25,225))
		--if downmgr.downloads==nil or #downmgr.downloads == 0 then t.frame:SetTitle("Download Manager - CONFIG ERROR. NO DOWNLOADS FOUND. CHECK DOWNMGR_CONFIG.LUA") else t.frame:SetTitle("Download Manager") end
	end
	t.info = vgui.Create("DLabel",t.frame)
	t.info:Dock(TOP)
	t.info:DockMargin(0,0,0,0)
	t.info:SetFont("dmgr_m")
	t.info:SetContentAlignment(8)
	t.info:SetText("Some addons this server requires were not downloaded while joining.\nPlease select the addons you wish to download by clicking 'download'\nWhile downloading you may experience movement lag and or unstable connection")
	t.info:SetSize(w/2,h/2)
	local size = {}
	size.x, size.y = t.frame:GetSize()
	t.dlbtn = vgui.Create("DButton",t.frame)
	t.dlbtn:SetPos(size.x/40,size.y/7)
	t.dlbtn:SetSize(size.x/5,size.y/25)
	t.dlbtn:SetFont("dmgr_m")
	t.dlbtn:SetText("Download All")
	t.dlbtn.Paint = function(self,w,h)
		if self.a == nil then self.a = 150 end
		if self:IsHovered() then self.a = Lerp(RealFrameTime()*10,self.a,255) else self.a = Lerp(RealFrameTime()*10,self.a,150) end
		draw.RoundedBox(0,0,0,w,h,Color(0,160,255,self.a))
	end
	t.dlbtn.DoClick = function()
		for k, v in pairs(downmgr.downloads or {}) do
			downmgr.init_downloads(v.id)
		end
	end
	//panel creation
	t.panel = vgui.Create("DScrollPanel",t.frame)
	t.panel:Dock(FILL)
	t.panel:DockMargin(w/100,-h/2.5,w/100,h/100)
	t.panel:DockPadding(0,0,0,0)
	t.panel.Paint = function(self,w,h)
		downmgr.blur(self,2,2,100)
		draw.RoundedBox(4,0,0,w,h,Color(25,25,25,125))
		if self.a == nil then self.a = 20 end
		if (select(1,self:LocalCursorPos()) > 0 and select(1,self:LocalCursorPos()) < select(1,self:GetSize())) and (select(2,self:LocalCursorPos()) > 0 and select(2,self:LocalCursorPos()) < select(2,self:GetSize())) then self.a = Lerp(RealFrameTime()*4,self.a,200) else self.a = Lerp(RealFrameTime()*4,self.a,20) end

	end
	local sbar = t.panel:GetVBar()
	function sbar:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w/10, h, Color( 0, 0, 0, t.panel.a ) )
		if sbar.a == nil then sbar.a = 50 end
	end
	function sbar.btnUp:Paint( w, h )

	end
	function sbar.btnDown:Paint( w, h )

	end
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w/8, h, Color( 200, 200, 200,t.panel.a ) )
	end
	for k, v in pairs(downmgr.downloads or {}) do
		local tmp = vgui.Create("DPanel",t.panel)
		if !ispanel(tmp) then return end
		tmp:Dock(TOP)
		tmp:DockMargin(w/100,h/(100),w/100,h/90)
		tmp:DockPadding(0,0,0,h/100)
		tmp:SetSize(select(1,tmp:GetSize())*2,h/6)
		tmp.Paint = function(self,w,h)
			downmgr.blur(self,8,8,100)
			draw.RoundedBox(4,0,0,w,h,Color(75,75,75,100))
			--print(self.info)
			if self.info~=nil then
				self.info.wsid = v.id
				//dlbutton
				local d = self.dlbtn
				if d.state == nil then d.state = 0  end
				if d.mounted or tmp.mounted then d.state = 2 end
				if d.state == 0 then d:SetText("Fetching..") end
				if d.state == 1 then d:SetText("Download") end
				if d.state == 2 then d:SetText("Mounted") end
				if d.state == 3 then d:SetText("Downloading...") end
				if d.state == 4 then d:SetText("Ready to mount") end
				if d.state == 5 then d:SetText("Download Failed") end


				self.title:SetText(string.Left(self.info.title or "Error getting addon details",36))

				self.dl:SetText(math.Round((self.info.size or 0)/1000000,3).."MB")
				local str = self.info.description
				surface.SetFont(self.desc:GetFont())
				self.desc:SetText(str or "Error getting addon details")
			else
				self.info = v.info or {}
			end
		end
		tmp.id = k
		tmp.crucial = v.crucial
		tmp.downloaded = false
		tmp.title = vgui.Create("DLabel",tmp)
		tmp.title:SetFont("dmgr_l")
		tmp.title:Dock(FILL)
		tmp.title:DockMargin(20,-select(2,tmp:GetSize())/1.9,0,0)
		tmp.title:SetSize(select(1,tmp:GetSize()),select(2,tmp:GetSize()))

		tmp.dl = vgui.Create("DLabel",tmp)
		tmp.dl:SetFont("dmgr_m")
		tmp.dl:Dock(FILL)
		tmp.dl:DockMargin(0,-select(2,tmp:GetSize())/3.9,20,0)
		tmp.dl:SetSize(select(1,tmp:GetSize()),select(2,tmp:GetSize()))
		tmp.dl:SetContentAlignment(6)


		tmp.descbox = vgui.Create("DScrollPanel",tmp)
		tmp.descbox:Dock(LEFT)
		tmp.descbox:DockMargin(20,20,20,0)
		tmp.descbox:SetSize(select(1,tmp:GetSize())*3,select(2,tmp:GetSize()))
		tmp.descbox.Paint = function(self,w,h)
			if self.a == nil then self.a = 20 end
			downmgr.blur(self,8,8,100)
			draw.RoundedBox(4,0,0,w,h,Color(25,25,25,100+self.a/2.5))

			if (select(1,self:LocalCursorPos()) > 0 and select(1,self:LocalCursorPos()) < select(1,self:GetSize())) and (select(2,self:LocalCursorPos()) > 0 and select(2,self:LocalCursorPos()) < select(2,self:GetSize())) then self.a = Lerp(RealFrameTime()*4,self.a,200) else self.a = Lerp(RealFrameTime()*4,self.a,20) end

		end
		local sbar = tmp.descbox:GetVBar()
		sbar.parent = tmp.descbox
		function sbar:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w/10, h, Color( 0, 0, 0, tmp.descbox.a ) )
			if sbar.a == nil then sbar.a = 50 end
		end
		function sbar.btnUp:Paint( w, h )

		end
		function sbar.btnDown:Paint( w, h )

		end
		function sbar.btnGrip:Paint( w, h )
			draw.RoundedBox( 0, 0, 0, w/8, h, Color( 200, 200, 200,tmp.descbox.a ) )
		end
		tmp.desc = vgui.Create("DLabel",tmp.descbox)
		tmp.desc:SetFont("dmgr_s")
		tmp.desc:SetWrap(true)
		tmp.desc:SetAutoStretchVertical(true)
		tmp.desc:SetContentAlignment(7)
		tmp.desc:Dock(FILL)
		tmp.desc:DockMargin(5,5,5,5)
		tmp.desc:SetSize(select(1,tmp:GetSize()),select(2,tmp:GetSize()))
		tmp.desc:SetWrap(true)


		tmp.dlbtn = vgui.Create("DButton",tmp)
		tmp.dlbtn:SetFont("dmgr_m")
		tmp.dlbtn:Dock(BOTTOM)

		--tmp.dlbtn:InvalidateLayout()
		--tmp.dlbtn:SetSize(select(1,tmp:GetSize())/10,select(2,tmp:GetSize())/4)
		tmp.dlbtn:DockMargin(0,10,0,-5)

		tmp.dlbtn:SetText("Fetching..")
		tmp.dlbtn.DoClick = function()
			steamworks.FileInfo(v.id,function(result) tmp.info=result downmgr.downloads[tmp.id].info=result end)
			downmgr.downloads[tmp.id].info = tmp.info
			downmgr.downloads[tmp.id].downloading = true
			downmgr.mount(tmp.id)
			downmgr.downloadfile(tmp.id)
			downmgr.failed = false
		end
		tmp.dlbtn.Paint = function(self,w,h)
			if self.sl == nil then self.sl = 0 end
			local col = Color(0,255,0,200)
			if downmgr.downloads[tmp.id].info~=nil and self.state == 0 then
				self.state = 1
			elseif downmgr.downloads[k].mounted then
				self.state = 2
			elseif downmgr.downloads[k].downloading then
				self.state = 3
			elseif downmgr.downloads[k].downloaded then
				self.state = 4
			end

			if downmgr.downloads[k].failed then
				self.state = 5
			end

			if downmgr.downloads[k].mounted then
				downmgr.downloads[k].downloading = false
				downmgr.downloads[k].downloaded = false
			end
			if self.state == 0 then col = Color(50,50,200,255) end
			if self.state == 1 then col = Color(50,170,200,255) end
			if self.state == 2 then col = Color(50,250,50,255) end
			if self.state == 3 then col = Color(0,200+math.sin(CurTime()*2)*55,0,255) self.sl = Lerp(RealFrameTime()*1,self.sl,8) else self.sl = 0 end
			if self.state == 4 then col = Color(200,150,0,255) end
			if self.state == 5 then col = Color(200,50,0,255) end
			draw.RoundedBox(0,20,0,w-40,h,col)
			surface.SetDrawColor(0,50,255,255-self.sl*31.875)
			draw.NoTexture()
			draw.Circle(w/2,h/2,(w-80)*(self.sl/16),32)
			--draw.DrawText(self.sl,"DermaDefault",0,0,Color(255,255,255))

		end

		steamworks.FileInfo(v.id,function(result) if IsValid(tmp) and ispanel(tmp) and tmp~=nil then tmp.info=result downmgr.downloads[v.id].info=result end end)
		if !IsValid(tmp) or !ispanel(tmp) or tmp==nil then return end
		downmgr.downloads[v.id].info = tmp.info or {}
	end
	downmgr.vgui = table.Copy(t)
	timer.Simple(5,function()
		downmgr.init_downloads()
	end)
end

downmgr.admin_menu_init = function()
	local t = table.Copy(downmgr.vgui)
	local w = ScrW()
	local h = ScrH()
	t.adminpanel = vgui.Create("DFrame")
	t.adminpanel:SetSize(w/2,h/2)
	t.adminpanel:Center()
	t.adminpanel:SetTitle("DownloadR Admin Configuration")
	t.adminpanel:SetVisible(true)
	t.adminpanel:SetDraggable(true)
	t.adminpanel:ShowCloseButton(true)
	t.adminpanel:MakePopup()
	t.adminpanel.Paint = function(self,w,h)
		downmgr.blur(self,1,1,200)
		draw.RoundedBox(4,0,0,w,h,Color(25,25,25,225))
	end
	t.adminpanel_main = vgui.Create("DPanel",t.adminpanel)
	t.adminpanel_main:Dock(FILL)
	t.adminpanel_main:DockMargin(select(1,t.adminpanel:GetSize())/100,select(2,t.adminpanel:GetSize())/100,select(1,t.adminpanel:GetSize())/100,select(2,t.adminpanel:GetSize())/100)
	t.adminpanel_main.Paint = function(self,w,h)
		downmgr.blur(self,1,4,100)
		draw.RoundedBox(4,0,0,w,h,Color(25,25,25,125))
		if t.adminpanel.count~=nil then t.adminpanel.count:SetText("Total Downloads: "..#downmgr.downloads) end
		surface.SetFont("dmgr_m")
		t.adminpanel.count:SetSize(select(1,surface.GetTextSize(t.adminpanel.count:GetText())),select(2,surface.GetTextSize(t.adminpanel.count:GetText())))
	end
	t.adminpanel.count = vgui.Create("DLabel",t.adminpanel_main)
	t.adminpanel.count:SetFont("dmgr_m")
	t.adminpanel.count:SetPos(10,10)

	t.adminpanel.input = vgui.Create("DTextEntry",t.adminpanel_main)
	t.adminpanel.input:Dock(BOTTOM)
	t.adminpanel.input:DockMargin(select(1,t.adminpanel_main:GetSize())/5,select(2,t.adminpanel_main:GetSize())/5,select(1,t.adminpanel_main:GetSize())/5,select(2,t.adminpanel_main:GetSize())/5)

	downmgr.vgui = table.Copy(t)
end

downmgr.blur = function( panel, layers, density, alpha )
	-- Its a scientifically proven fact that blur improves a script
	local x, y = panel:LocalToScreen(0, 0)
	local blur = downmgr.blurmat
	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetMaterial( blur )

	for i = 1, 3 do
		blur:SetFloat( "$blur", ( i / layers ) * density )
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
	end
end



function draw.Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is need for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end
