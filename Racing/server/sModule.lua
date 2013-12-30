----------------------------------------------------------------------------------------------------
-- Event to create the RaceManager, as well as misc stuff like global functions.
----------------------------------------------------------------------------------------------------

Events:Subscribe(
	"ModuleLoad" ,
	function()
		Stats.Init()
		raceManager = RaceManager()
		-- courseEditorManager = CourseEditorManager(raceManager)
	end
)

Racing = {}

-- Always returns player id.
Racing.PlayerId = function(playerIdOrPlayer)
	
	if type(playerIdOrPlayer) == "number" then
		return playerIdOrPlayer
	else
		if IsValid(playerIdOrPlayer) then
			return playerIdOrPlayer:GetId()
		end
	end
	
end

-- Always returns Player instance.
Racing.Player = function(playerIdOrPlayer)
	
	if type(playerIdOrPlayer) == "number" then
		return Player.GetById(playerIdOrPlayer)
	else
		return playerIdOrPlayer
	end
	
end

math.randomseed(os.time())
math.tau = math.pi * 2
