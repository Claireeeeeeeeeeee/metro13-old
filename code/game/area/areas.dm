// Areas.dm

/*

### This file contains a list of all the areas in the map. Format is as follows:

/area/CATEGORY/OR/DESCRIPTOR/NAME 	(you can make as many subdivisions as you want)
	name = "NICE NAME" 				(not required but makes things really nice)
	icon = "ICON FILENAME" 			(defaults to areas.dmi)
	icon_state = "NAME OF ICON" 	(defaults to "unknown" (blank))
	requires_power = FALSE 				(defaults to TRUE)

NOTE: there are two lists of areas in the end of this file: centcom and map itself. Please maintain these lists valid. --rastaf0

*/

#define AREA_INSIDE 0
#define AREA_OUTSIDE 1

/area
	var/fire = null
	level = null
	name = "Unknown"
	icon = 'icons/turf/areas.dmi'
	icon_state = "unknown"
	layer = 10
	mouse_opacity = FALSE
	plane = LIGHTING_PLANE
	var/lightswitch = TRUE

	var/eject = null

	var/debug = FALSE
	var/requires_power = TRUE
	var/always_unpowered = FALSE	//this gets overriden to TRUE for space in area/New()

	var/power_equip = TRUE
	var/power_light = TRUE
	var/power_environ = TRUE
	var/used_equip = FALSE
	var/used_light = FALSE
	var/used_environ = FALSE

	var/has_gravity = TRUE
//	var/obj/machinery/power/apc/apc = null
	var/no_air = null
	var/list/ambience = list()
	var/list/forced_ambience = list()
	var/turf/base_turf //The base turf type of the area, which can be used to override the z-level's base turf
	var/sound_env = FOREST

	var/location = AREA_OUTSIDE

	var/weather = WEATHER_NONE
	var/weather_intensity = 1.0

	var/list/snowfall_valid_turfs = list()

	var/is_void_area = FALSE

	var/capturable = TRUE

	var/parent_area_type = null
	var/area/parent_area = null

	var/climate = "temperate" //temperate, desert, jungle, tundra

// ===
/area
	var/global/global_uid = FALSE
	var/uid
	var/tmp/camera_id = FALSE // For automatic c_tag setting
	var/artillery_integrity = 100

/area/New()
	icon = 'icons/effects/weather.dmi'
	icon_state = ""
	layer = 10
	uid = ++global_uid

	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE

	..()

	spawn (100)
		if (parent_area_type)
			parent_area = locate(parent_area_type)

	area_list |= src

/area/proc/initialize()
	power_light = FALSE
	power_equip = FALSE
	power_environ = FALSE

/area/proc/get_contents()
	return contents

/area/proc/get_turfs()
	. = get_contents():Copy()
	. -= typesof(/obj)
	. -= typesof(/mob)

/area/proc/get_mobs()
	. = get_contents():Copy()
	. -= typesof(/turf)
	. -= typesof(/obj)

/area/proc/get_objs()
	. = get_contents():Copy()
	. -= typesof(/turf)
	. -= typesof(/mob)

// due to the efficient way that this works, lift masters cannot be added runtime

/area/proc/get_camera_tag(var/obj/machinery/camera/C)
	return "[name] [camera_id++]"


/area/proc/readyalert()
	if (!eject)
		eject = TRUE
	return

/area/proc/readyreset()
	if (eject)
		eject = FALSE
	return

/*
#define EQUIP TRUE
#define LIGHT 2
#define ENVIRON 3
*/

/area/proc/powered(var/chan)		// return true if the area has power to given channel

	if (!requires_power)
		return TRUE
	if (always_unpowered)
		return FALSE
	switch(chan)
		if (EQUIP)
			return power_equip
		if (LIGHT)
			return power_light
		if (ENVIRON)
			return power_environ

	return FALSE

// called when power status changes
/*
/area/proc/power_change()
	for (var/obj/machinery/M in src)	// for each machine in the area
		M.power_change()			// reverify power status (to update icons etc.)
	if (fire || eject)
		updateicon()*/

/area/proc/usage(var/chan)
	var/used = FALSE
	switch(chan)
		if (LIGHT)
			used += used_light
		if (EQUIP)
			used += used_equip
		if (ENVIRON)
			used += used_environ
		if (TOTAL)
			used += used_light + used_equip + used_environ
	return used

/area/proc/clear_usage()
	used_equip = FALSE
	used_light = FALSE
	used_environ = FALSE

/area/proc/use_power(var/amount, var/chan)
	switch(chan)
		if (EQUIP)
			used_equip += amount
		if (LIGHT)
			used_light += amount
		if (ENVIRON)
			used_environ += amount


var/list/mob/living/forced_ambiance_list = new

/area/Entered(A)
	if (!istype(A,/mob/living))	return

	var/mob/living/L = A
	if (!L.ckey)	return

	if (!L.lastarea)
		L.lastarea = get_area(L.loc)

	var/area/newarea = get_area(L.loc)
	var/area/oldarea = L.lastarea
	if ((oldarea.has_gravity == FALSE) && (newarea.has_gravity == TRUE) && (L.m_intent == "run")) // Being ready when you change areas gives you a chance to avoid falling all together.
		thunk(L)
		L.update_floating( L.Check_Dense_Object() )

	var/override_ambience = FALSE

	for (var/typecheck in list(/area/caribbean/british, /area/caribbean/pirates, /area/caribbean/no_mans_land, /area/caribbean/forest, /area/caribbean/void))
		if (istype(oldarea, typecheck))
			if (!istype(newarea, typecheck))
				override_ambience = TRUE

	if (oldarea.is_void_area != newarea.is_void_area)
		override_ambience = TRUE

	if (oldarea.location != newarea.location)
		override_ambience = TRUE

	L.lastarea = newarea
	play_ambience(L, override_ambience)

/area/proc/play_ambience(var/mob/living/L, var/override = FALSE)

    // Ambience goes down here -- make sure to list each area seperately for ease of adding things in later, thanks! Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch
//	if (!(L && L.is_preference_enabled(/datum/client_preference/play_ambiance)))    return
	if (!L || !istype(L) || !L.loc)
		return

	var/client/CL = L.client

	if (!CL)
		return
/*
	if (CL.ambience_playing && !override) // If any ambience already playing
		if (forced_ambience && forced_ambience.len)
			if (CL.ambience_playing in forced_ambience)
				return TRUE
			else
				var/new_ambience = pick(pick(forced_ambience))
				CL.ambience_playing = new_ambience
				L << sound(new_ambience, repeat = TRUE, wait = FALSE, volume = 30, channel = SOUND_CHANNEL_AMBIENCE)
				return TRUE
		if (CL.ambience_playing in ambience)
			return TRUE

	if (ambience.len && prob(35))
		if (world.time >= L.client.played + 600)
			var/sound = pick(ambience)
			CL.ambience_playing = sound
			L << sound(sound, repeat = FALSE, wait = FALSE, volume = 10, channel = SOUND_CHANNEL_AMBIENCE)
			L.client.played = world.time
			return TRUE
	else */

	var/lastsound = CL.ambience_playing
	var/sound = (map && map.ambience.len) ? pick(map.ambience) : null
	var/override_volume = 0

	if (sound && (!CL.ambience_playing || override || sound != lastsound))
		CL.ambience_playing = sound

		var/ideal_x = round(world.maxx/2)
		var/ideal_y = round(world.maxy/2)
		var/area/L_area = get_area(L)

		// war volume will vary from 2% to 22%, depending on where you are (on a 150x150 map)
		// the max() check makes this code forestmap compatible too
		var/warvolume = 21

		warvolume -= ceil(abs(L.x - ideal_x)/15)
		warvolume -= ceil(abs(L.y - ideal_y)/15)

		if (L_area)
			if (L_area.location == AREA_INSIDE)
				warvolume -= 4
			if (L_area.is_void_area)
				warvolume -= 5

		warvolume = max(warvolume, 2)

		L << sound(null, channel = SOUND_CHANNEL_AMBIENCE)
		var/sound/S = sound(sound, repeat = TRUE, wait = FALSE, volume = override_volume ? override_volume : warvolume, channel = SOUND_CHANNEL_AMBIENCE)
		S.environment = 22
		L << S

/proc/stop_ambience(var/mob_or_client)
	var/client/C = isclient(mob_or_client) ? mob_or_client : mob_or_client:client
	if (C)
		C.ambience_playing = null
	mob_or_client << sound(null, channel = SOUND_CHANNEL_AMBIENCE)

/area/proc/gravitychange(var/gravitystate = FALSE, var/area/A)
	A.has_gravity = gravitystate

	for (var/mob/M in A)
		if (has_gravity)
			thunk(M)
		M.update_floating( M.Check_Dense_Object() )

/area/proc/thunk(mob)
	if (istype(mob,/mob/living/carbon/human/))
		var/mob/living/carbon/human/H = mob
		if (istype(H.shoes, /obj/item/clothing/shoes/magboots) && (H.shoes.item_flags & NOSLIP))
			return

		if (H.m_intent == "run")
			H.AdjustStunned(2)
			H.AdjustWeakened(2)
		else
			H.AdjustStunned(1)
			H.AdjustWeakened(1)
		mob << "<span class='notice'>The sudden appearance of gravity makes you fall to the floor!</span>"

/area/proc/has_gravity()
	return has_gravity

/area/proc/arty_act(loss)
	if (prob(25))
		artillery_integrity -= loss * 1.33
	else if (prob(50))
		artillery_integrity -= loss
	else
		artillery_integrity -= loss * 0.75
	if (artillery_integrity > 0)
		return FALSE
	return TRUE

/proc/has_gravity(atom/AT, turf/T)
	return TRUE
