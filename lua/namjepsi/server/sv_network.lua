util.AddNetworkString( "namjepsi_cast" )
util.AddNetworkString( "namjepsi_update_inventory" )
util.AddNetworkString( "namjepsi_init_slots" )
util.AddNetworkString( "namjepsi_update_slot" )
util.AddNetworkString( "namjepsi_stim" )

--singleplayer slowing down time
if game.SinglePlayer() then
	util.AddNetworkString( "namje_slow_time" )
	net.Receive("namje_slow_time", function()
		local slow = net.ReadBool()
		local time
		if slow then time = 0.3 else time = 1 end
		game.SetTimeScale(time)
	end)
end