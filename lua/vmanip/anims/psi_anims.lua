AddCSLuaFile()

VManip:RegisterAnim("cast",
{
["model"]="namje/c_psianims.mdl",
["lerp_peak"]=0.72,
["lerp_speed_in"]=.8,
["lerp_speed_out"]=0.8,
["lerp_curve"]=2.5,
["speed"]=.8,
["startcycle"]=0,
["holdtime"]=0.3,
["sounds"]={},
["loop"]=false
}
)

VManip:RegisterAnim("castself",
{
["model"]="namje/c_psianims.mdl",
["lerp_peak"]=.5,
["lerp_speed_in"]=99,
["lerp_speed_out"]=.4,
["lerp_curve"]=2.5,
["speed"]=.7,
["startcycle"]=0,
["sounds"]={},
["loop"]=false
}
)

VManip:RegisterAnim("useinhaler",
{
["model"]="namje/c_psianims.mdl",
["lerp_peak"]=1.1,
["lerp_speed_in"]=.8,
["lerp_speed_out"]=.4,
["lerp_curve"]=2.5,
["speed"]=.7,
["startcycle"]=0,
["sounds"]={},
["loop"]=false
}
)



