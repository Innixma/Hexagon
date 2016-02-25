execScript("common.lua")

-- pNickBarrage: spawns a single wall
function pNickBarrage(mStep)
	delay = getPerfectDelay(THICKNESS) * 5.6
	
	nickBarrage(mStep)
	
	wait(delay)
	wait(delay)
end