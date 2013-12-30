-- Written by Philpax

class 'Help'

function Help:__init()
	self.active = false

	self.window = Window.Create()
	self.window:SetSizeRel( Vector2( 0.4, 0.3 ) )
	self.window:SetPositionRel( 
		Vector2( 0.5, 0.5 ) - self.window:GetSizeRel()/2 )
	self.window:SetTitle( "Help Window" )
	self.window:SetVisible( self.active )

	self.tab_control = TabControl.Create( self.window )
	self.tab_control:SetDock( GwenPosition.Fill )
	self.tab_control:SetTabStripPosition( GwenPosition.Left )

	self.tabs = {}

	Events:Subscribe( "KeyUp", self,
		self.KeyUp )

	Events:Subscribe( "LocalPlayerInput", self,
		self.LocalPlayerInput )

	self.window:Subscribe( "WindowClosed", self, 
		self.WindowClosed )

	Events:Register( "HelpAddItem" )
	Events:Register( "HelpRemoveItem" )

	Events:Subscribe( "HelpAddItem", self, 
		self.AddItem )

	Events:Subscribe( "HelpRemoveItem", self, 
		self.RemoveItem )
end

function Help:GetActive()
	return self.active
end

function Help:SetActive( state )
	self.active = state
	self.window:SetVisible( self.active )
	Mouse:SetVisible( self.active )
end

function Help:KeyUp( args )
	if args.key == VirtualKey.F5 then
		self:SetActive( not self:GetActive() )
	end
end

function Help:LocalPlayerInput( args )
	if self:GetActive() and Game:GetState() == GUIState.Game then
		return false
	end
end

function Help:WindowClosed( args )
	self:SetActive( false )
end

function Help:AddItem( args )
	if self.tabs[args.name] ~= nil then
		self:RemoveItem( args )
	end

	local tab_button = self.tab_control:AddPage( args.name )

	local page = tab_button:GetPage()

	args.text = args.text:gsub( "%[colour=.-%]", "" )

	local scroll_control = ScrollControl.Create( page )
	scroll_control:SetDock( GwenPosition.Fill )
	scroll_control:SetMargin( Vector2( 4, 4 ), Vector2( 4, 4 ) )

	local contents = Label.Create( scroll_control )
	contents:SetText( args.text )
	contents:SizeToContents()

	self.tabs[args.name] = tab_button
end

function Help:RemoveItem( args )
	if self.tabs[args.name] == nil then return end

	self.tabs[args.name]:GetPage():Remove()
	self.tab_control:RemovePage( self.tabs[args.name] )
	self.tabs[args.name] = nil
end

help = Help()