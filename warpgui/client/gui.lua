class 'WarpGui'

function WarpGui:__init()
	self.textColor = Color(200, 50, 200)
	self.admins = {}
	self.rows = {}
	self.acceptButtons = {}
	self.whitelist = {}
	self.warpRequests = {}
	self.windowShown = false
	
	-- Admins
	self:AddAdmin("STEAM_0:0:26199873")
	self:AddAdmin("STEAM_0:0:28323431")
	
	-- Create GUI
	self.window = Window.Create()
	self.window:SetVisible(self.windowShown)
	self.window:SetTitle("Warp GUI")
	self.window:SetSizeRel(Vector2(0.4, 0.7))
	self.window:SetPositionRel( Vector2(0.75, 0.5) - self.window:GetSizeRel()/2)
    self.window:Subscribe("WindowClosed", self, function (args) self:SetWindowVisible(false) end)
	
	local tabControl = TabControl.Create(self.window)
	tabControl:SetDock(GwenPosition.Left)
	tabControl:SetSizeRel(Vector2(0.98, 1))
	
	local playersPage = tabControl:AddPage("Players"):GetPage()
	--local warpsPage = tabControl:AddPage("Warps"):GetPage()
	
	self.playerList = SortedList.Create(playersPage)
	self.playerList:SetDock(GwenPosition.Fill)
	self.playerList:AddColumn("Name")
	self.playerList:AddColumn("Warp To")
	self.playerList:AddColumn("Accept Warp")
	self.playerList:AddColumn("Whitelist")
	self.playerList:SetButtonsVisible(true)
	
	-- Add players
	for player in Client:GetPlayers() do
		self:AddPlayer(player)
	end
	--self:AddPlayer(LocalPlayer)
	
	-- Subscribe to events
	Events:Subscribe("LocalPlayerChat", self, self.LocalPlayerChat)
    Events:Subscribe("LocalPlayerInput", self, self.LocalPlayerInput)
	Events:Subscribe("PlayerJoin", self, self.PlayerJoin)
	Events:Subscribe("PlayerQuit", self, self.PlayerQuit)
    Events:Subscribe("KeyUp", self, self.KeyUp)
	Network:Subscribe("WarpRequestToTarget", self, self.WarpRequest)
	

--Help
--------------------------------------------------------------
function ModulesLoad()
	Events:FireRegisteredEvent( "HelpAddItem",
        {
            name = "WarpGui",
            text = 
                "The WarpGUI script is used to warp one player to another. Doing so however requires the other players permission.\n\n" ..
                "To warp to other players or accept a request press 'G'.\n" ..
                "If you want to allow someone permanently to warp to you use the checkbox."
        } )
end

function ModuleUnload()
    Events:FireRegisteredEvent( "HelpRemoveItem",
        {
            name = "WarpGui"
        } )
end
	Events:Subscribe("ModulesLoad", ModulesLoad)
	Events:Subscribe("ModuleUnload", ModuleUnload)
--------------------------------------------------------------

	-- Debug
	--self:SetWindowVisible(true)
end

function WarpGui:AddAdmin(steamId)
	self.admins[steamId] = true
end

function WarpGui:IsAdmin(player)
	return self.admins[player:GetSteamId().string] ~= nil
end

function WarpGui:CreateListButton(text, enabled)
	local buttonBase = BaseWindow.Create(self.window)
	buttonBase:SetDock(GwenPosition.Fill)
	buttonBase:SetSize(Vector2(1, 23))
	
    local buttonBackground = Rectangle.Create(buttonBase)
    buttonBackground:SetSizeRel(Vector2(0.5, 1.0))
    buttonBackground:SetDock(GwenPosition.Fill)
    buttonBackground:SetColor(Color(0, 0, 0, 100))
	
	local button = Button.Create(buttonBase)
	button:SetText(text)
	button:SetDock(GwenPosition.Fill)
	button:SetEnabled(enabled)
	
	return buttonBase, button
end

function WarpGui:AddPlayer(player)
	local playerId = tostring(player:GetId());
	
	-- Warp to button
	local warpToButtonBase, warpToButton = self:CreateListButton("Warp to", true)
	warpToButton:Subscribe("Press", function() self:WarpToPlayerClick(player) end)
	
	-- Accept 
	local acceptButtonBase, acceptButton = self:CreateListButton("Accept", false)
	acceptButton:Subscribe("Press", function() self:AcceptWarpClick(player) end)
	self.acceptButtons[playerId] = acceptButton
	
	-- Whitelist
	local whitelistCheckBox = CheckBox.Create(self.window)
	whitelistCheckBox:SetDock(GwenPosition.Left)
	whitelistCheckBox:SetSize(Vector2(20, 20))
	whitelistCheckBox:Subscribe("CheckChanged",
		function() self:WhitelistCheckChanged(tostring(player:GetId()), whitelistCheckBox:GetChecked()) end)
	
	local item = self.playerList:AddItem(playerId)
	item:SetCellText(0, player:GetName())
	item:SetCellContents(1, warpToButtonBase)
	item:SetCellContents(2, acceptButtonBase)
	item:SetCellContents(3, whitelistCheckBox)
	
	self.rows[playerId] = item
end

function WarpGui:WarpToPlayerClick(player)
	Network:Send("WarpRequestToServer", {LocalPlayer, player})
	self:SetWindowVisible(false)
end

function WarpGui:AcceptWarpClick(player)
	local playerId = tostring(player:GetId())
	
	if self.warpRequests[playerId] == nil then
		Chat:Print(player:GetName() .. " has not requested to warp to you.", self.textColor)
		return
	else
		local acceptButton = self.acceptButtons[playerId]
		if acceptButton == nil then return end
		self.warpRequests[playerId] = nil
		acceptButton:SetEnabled(false)
		
		Network:Send("WarpTo", {player, LocalPlayer})
		self:SetWindowVisible(false)
	end
end

function WarpGui:WhitelistCheckChanged(playerId, checked)
	if checked then
		if self.whitelist[playerId] ~= nil then return end
		self.whitelist[playerId] = true
	else
		if self.whitelist[playerId] == nil then return end
		self.whitelist[playerId] = nil
	end
end

function WarpGui:WarpRequest(args)
	local requestingPlayer = args
	local playerId = tostring(requestingPlayer:GetId())
	
	if self.whitelist[playerId] ~= nil or self:IsAdmin(requestingPlayer) then -- In whitelist
		Network:Send("WarpTo", {requestingPlayer, LocalPlayer})
	else -- Not in whitelist
		local acceptButton = self.acceptButtons[playerId]
		if acceptButton == nil then return end
		
		acceptButton:SetEnabled(true)
		self.warpRequests[playerId] = true
		Network:Send("WarpMessageTo", {requestingPlayer, "Please wait for " .. LocalPlayer:GetName() .. " to accept."})
		Chat:Print(requestingPlayer:GetName() .. " would like to warp to you. Type /warp or press V to accept.", self.textColor)
	end
end

function WarpGui:LocalPlayerChat(args)
	local player = args.player
	local message = args.text
	
	if message ~= "/warp" then return true end
	
	self:SetWindowVisible(not self.windowShown)
	
	return false
end

function WarpGui:LocalPlayerInput(args) -- Prevent mouse from moving & buttons being pressed
    return not (self.windowShown and Game:GetState() == GUIState.Game)
end

function WarpGui:KeyUp( args )
    if args.key == string.byte('G') then
        self:SetWindowVisible(not self.windowShown)
    end
end

function WarpGui:PlayerJoin(args)
	local player = args.player
	
	self:AddPlayer(player)
end

function WarpGui:PlayerQuit(args)
	local player = args.player
	local playerId = tostring(player:GetId())
	
	if self.rows[playerId] == nil then return end

	self.playerList:RemoveItem(self.rows[playerId])
	self.rows[playerId] = nil
end

function WarpGui:SetWindowVisible(visible)
	self.windowShown = visible
	self.window:SetVisible(visible)
	Mouse:SetVisible(visible)
end

warpGui = WarpGui()