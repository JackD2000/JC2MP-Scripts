class "MoneySaver"

function MoneySaver:__init()
    Events:Subscribe( "PlayerJoin", self, self.PlayerJoin )
    Events:Subscribe( "PlayerQuit", self, self.PlayerQuit )
    Events:Subscribe( "ModuleUnload", self, self.ModuleUnload )

    SQL:Execute( "create table if not exists moneysaver_players (steamid VARCHAR UNIQUE, money LONG)")
end

function MoneySaver:save(player)
    local cmd = SQL:Command( "insert or replace into moneysaver_players (steamid, money) values (?,?)")
    cmd:Bind( 1, player:GetSteamId().id )
    cmd:Bind( 2, player:GetMoney() )
    cmd:Execute()
end

function MoneySaver:PlayerJoin (args)
    local qry = SQL:Query( "select money from moneysaver_players where steamid = (?)" )
    qry:Bind( 1, args.player:GetSteamId().id )
    local result = qry:Execute()

    if #result > 0 then
        args.player:SetMoney( tonumber(result[1].money) )
    end
end

function MoneySaver:PlayerQuit (args)
        self:save(args.player)
end

function MoneySaver:ModuleUnload ()
 for p in Server:GetPlayers() do
  self:save(p)
 end
end

ms = MoneySaver()