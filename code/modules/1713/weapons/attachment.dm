
/*
TODO:
Optimize this code as much as possible
Add Sounds
Replace snowflaked icon manipulation with proper icon mask manipulation
Add more attachments
Add attached bayonet sprite

Current Defines (_defines/attachment.dm)

#define ATTACH_IRONSIGHTS 1
#define ATTACH_SCOPE 2
#define ATTACH_STOCK 4
#define ATTACH_BARREL 8
#define ATTACH_UNDER 16
#define ATTACH_ADV_SCOPE 32
*/

/obj/item/weapon/attachment
	var/attachable = TRUE
	var/attachment_type //Use the 'ATTACH_' defines above (should only use one for this)
	var/A_attached = FALSE //Is attached
	var/overheating_sprite = null
	var/specific_sprite = list() //If you want an attachment to use a specific ongun sprite for a specific gun, put the gun's name into here
	var/unwieldiness = 0.95
	var/accuracy_mod = 1
	var/dispersion_mod = 1
	//When the attachment looks for a layer to add to the guns sprite it will look for "[attachment]_[gun]_ongun"
	w_class = 2

/obj/item/weapon/attachment/proc/attached(mob/user, obj/item/weapon/gun/G)
	user << "<span class = 'notice'>You start to attach [src] to the [G].</span>"
	if (do_after(user, 15, user))
		user.unEquip(src)
		A_attached = TRUE
		G.attachment_slots -= attachment_type
		loc = G
		G.actions += actions
		G.verbs += verbs
		G.attachments += src
		G.update_attachment_actions(user)
		user << "<span class = 'notice'>You attach [src] to the [G].</span>"
	else
		return

/obj/item/weapon/attachment/proc/removed(mob/user, obj/item/weapon/gun/G)
	if (do_after(user, 15, user))
		G.attachments -= src
		G.actions -= actions
		G.verbs -= verbs
		G.attachment_slots += attachment_type
		dropped(user)
		A_attached = FALSE
		loc = get_turf(src)
		user << "You remove [src] from the [G]."
	else
		return

/obj/item/weapon/gun
	var/list/attachments = list()
	var/attachment_slots = null //Use the 'ATTACH_' defines above; can ise in combination Ex. ATTACH_SCOPE|ATTACH_BARREL
	var/attachment_inclusions = list()
	var/attachment_exclusions = list()

/obj/item/weapon/gun/examine(mob/user)
	..()
	if (attachments.len)
		for (var/obj/item/weapon/attachment/A in attachments)
			user << "<span class='notice'>It has [A] attached.</span>"

/obj/item/weapon/gun/dropped(mob/user)
	..()
	if (attachments.len)
		for (var/obj/item/weapon/attachment/A in attachments)
			A.dropped(user)

/obj/item/weapon/gun/pickup(mob/user)
	if (attachments.len)
		for (var/obj/item/weapon/attachment/A in attachments)
			A.pickup(user)

/obj/item/weapon/gun/verb/field_strip()
	set name = "Field Strip"
	set desc = "Removes any attachments."
	set category = null
	var/mob/living/carbon/human/user = usr

	for (var/obj/item/weapon/attachment/A in attachments)
		A.removed(user, src)

//Use this under /New() of weapons if they spawn with attachments
/obj/item/weapon/gun/proc/spawn_add_attachment(obj/item/weapon/attachment/A)
	A.A_attached = TRUE
	attachment_slots -= A.attachment_type
	attachments += A
	actions += A.actions

/obj/item/weapon/gun/proc/update_attachment_actions(mob/user)
	for (var/datum/action/action in actions)
		action.Grant(user)

/obj/item/weapon/gun/proc/try_attach(obj/item/weapon/attachment/A, mob/user)
	if (!A || !user)
		return
	if (user.get_inactive_hand() != src)
		user << "You must be holding the [src] to add attachments."
		return
	attach_A(A, user)

//Do not use this; use try_attach instead
/obj/item/weapon/gun/proc/attach_A(obj/item/weapon/attachment/A, mob/user)
	if (A in attachment_exclusions) //Creator of weapon has specified that a specific attachment should NOT go on their weapon
		user << "[A] cannot be attached to the [src]."
		return
	switch(A.attachment_type)
		if (ATTACH_IRONSIGHTS)
			if (attachment_slots & ATTACH_IRONSIGHTS)
				A.attached(user, src)
			else
				user << "You already have iron sights."
		if (ATTACH_SCOPE)
			if (attachment_slots & ATTACH_SCOPE)
				A.attached(user, src, FALSE)
			else
				user << "You fumble around with the attachment."
		if (ATTACH_STOCK)
			if (attachment_slots & ATTACH_STOCK)
				A.attached(user, src, FALSE)
			else
				user << "You fumble around with the attachment."
		if (ATTACH_BARREL)
			if (attachment_slots & ATTACH_BARREL)
				A.attached(user, src, FALSE)
			else
				user << "You fumble around with the attachment."
		if (ATTACH_UNDER)
			if (attachment_slots & ATTACH_UNDER)
				A.attached(user, src, FALSE)
			else
				user << "You fumble around with the attachment."
		if (ATTACH_ADV_SCOPE)
			if (attachment_slots & ATTACH_ADV_SCOPE)
				A.attached(user, src, FALSE)
			else
				user << "You fumble around with the attachment."
		else
			if (A in attachment_inclusions) //Creator of weapon has specified that a specific attachment SHOULD go on their weapon
				A.attached(user, src, FALSE)
			else
				user << "[A] cannot be attached to the [src]."

//ATTACHMENTS

//Scope code is found in code/modules/WW2/weapons/zoom.dm

/obj/item/weapon/attachment/bayonet
	name = "bayonet"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "bayonet"
	item_state = "knife"
	flags = CONDUCT
	sharp = TRUE
	edge = TRUE
	attack_verb = list("slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	attachment_type = ATTACH_BARREL
	force = 20
	var/attack_sound = 'sound/weapons/slice.ogg'
	var/weakens = 0
	//var/datum/action/bayonet/amelee
	var/atk_mode = SLASH

/obj/item/weapon/attachment/bayonet/attack_self(mob/user)
	..()
	if(atk_mode == SLASH)
		atk_mode = STAB
		user << "<span class='notice'>You will now stab.</span>"
		edge = 0
		sharp = 1
		attack_verb = list("stabbed")
		hitsound = "stab_sound"
		return

	else if(atk_mode == STAB)
		atk_mode = SLASH
		user << "<span class='notice'>You will now slash.</span>"
		attack_verb = list("slashed", "diced")
		hitsound = "slash_sound"
		edge = 1
		sharp = 1
		return
/obj/item/weapon/attachment/bayonet/attached(mob/user, obj/item/weapon/gun/G, var/quick = FALSE)
	if (quick)
		user.unEquip(src)
		A_attached = TRUE
		G.attachment_slots -= attachment_type
		loc = G
		G.actions += actions
		G.verbs += verbs
		G.attachments += src
		user << "<span class = 'notice'>You attach [src] to the [G].</span>"
		G.bayonet = src
		G.overlays += G.bayonet_ico
	else
		user << "<span class = 'notice'>You start to attach [src] to the [G].</span>"
		if (do_after(user, 15, user))
			user.unEquip(src)
			A_attached = TRUE
			G.attachment_slots -= attachment_type
			loc = G
			G.actions += actions
			G.verbs += verbs
			G.attachments += src
			G.update_attachment_actions(user)
			user << "<span class = 'notice'>You attach [src] to the [G].</span>"
			G.bayonet = src
			G.overlays += G.bayonet_ico
		else
			return


/obj/item/weapon/attachment/bayonet/removed(mob/user, obj/item/weapon/gun/G)
	if (do_after(user, 15, user))
		G.attachments -= src
		G.actions -= actions
		G.verbs -= verbs
		G.attachment_slots += attachment_type
		dropped(user)
		A_attached = FALSE
		loc = get_turf(src)
		user << "You remove [src] from the [G]."
		G.bayonet = null
		G.overlays -= G.bayonet_ico
	else
		return


/obj/item/weapon/attachment/bayonet/military
	force = WEAPON_FORCE_ROBUST
//	weakens = 1
	weight = 0.450
	value = 12

/obj/item/weapon/attachment/scope/iron_sights
	name = "iron sights"
	attachment_type = ATTACH_IRONSIGHTS
	zoom_amt = ZOOM_CONSTANT

/obj/item/weapon/attachment/scope/adjustable/sniper_scope
	name = "sniper scope"
	icon_state = "kar_scope"
	desc = "You can attach this to rifles... or use them as binoculars. Amplifies 8x."
	max_zoom = ZOOM_CONSTANT*2

/obj/item/weapon/attachment/scope/adjustable/sniper_scope/removed(mob/user, obj/item/weapon/gun/G)
	if (do_after(user, 15, user))
		G.attachments -= src
		G.actions -= actions
		G.verbs -= verbs
		G.attachment_slots += attachment_type
		dropped(user)
		A_attached = FALSE
		loc = get_turf(src)
		user << "You remove [src] from the [G]."
		//This should only be temporary until more attachment icons are made, then we switch to adding/removing icon masks
		if (istype(G, /obj/item/weapon/gun/projectile))
			var/obj/item/weapon/gun/projectile/W = G
			W.sniper_scope = FALSE
			W.update_icon()
	else
		return

/obj/item/weapon/attachment/scope/adjustable/sniper_scope/attached(mob/user, obj/item/weapon/gun/G, var/quick = FALSE)
	if (quick)
		A_attached = TRUE
		G.attachment_slots -= attachment_type
		loc = G
		G.actions += actions
		G.verbs += verbs
		G.attachments += src
		G.scope = src
		if (istype(G, /obj/item/weapon/gun/projectile))
			var/obj/item/weapon/gun/projectile/W = G
			W.sniper_scope = TRUE
			W.update_icon()
	else
		if (do_after(user, 15, user))
			user.unEquip(src)
			A_attached = TRUE
			G.attachment_slots -= attachment_type
			loc = G
			G.actions += actions
			G.verbs += verbs
			G.scope = src
			G.attachments += src
			G.update_attachment_actions(user)
			user << "<span class = 'notice'>You attach [src] to the [G].</span>"
			if (istype(G, /obj/item/weapon/gun/projectile))
				var/obj/item/weapon/gun/projectile/W = G
				W.sniper_scope = TRUE
				W.update_icon()
		else
			return

/obj/item/weapon/attachment/scope/removed(mob/user, obj/item/weapon/gun/G)
	if (do_after(user, 15, user))
		G.attachments -= src
		G.actions -= actions
		G.verbs -= verbs
		G.scope = null
		G.attachment_slots += attachment_type
		dropped(user)
		A_attached = FALSE
		loc = get_turf(src)
		user << "You remove [src] from the [G]."
		G.accuracy = initial(G.accuracy)
		G.recoil = initial(G.recoil)
	else
		return

/obj/item/weapon/attachment/scope/iron_sights/removed(mob/user, obj/item/weapon/gun/G)
	return

/////////////////ADVANCED OPTICS//////////////////////////////

/obj/item/weapon/attachment/scope/adjustable/advanced
	icon = 'icons/obj/gun_att.dmi'
	icon_state = "acog"
	var/scopeonly = TRUE //if the gun must be on scope mode to give the bonuses, should replace this with a -1,0,1 var which dictates whether it only works when unscoped, both, scopes accordingly
	attachment_type = ATTACH_ADV_SCOPE
	var/image/ongun
	New()
		..()
		ongun = image("icon" = 'icons/obj/gun_att.dmi', "icon_state" = "[icon_state]_ongun")

/obj/item/weapon/attachment/scope/adjustable/advanced/attached(mob/user, obj/item/weapon/gun/G, var/quick = FALSE)
	if (quick)
		A_attached = TRUE
		G.attachment_slots -= attachment_type
		loc = G
		G.actions += actions
		G.verbs += verbs
		G.attachments += src
		G.specialoptics = src
		G.scope = src
		G.optics_ico = ongun
		G.overlays += G.optics_ico
	else
		if (do_after(user, 15, user))
			user.unEquip(src)
			A_attached = TRUE
			G.attachment_slots -= attachment_type
			loc = G
			G.actions += actions
			G.verbs += verbs
			G.attachments += src
			G.update_attachment_actions(user)
			user << "<span class = 'notice'>You attach [src] to the [G].</span>"
			G.specialoptics = src
			G.optics_ico = ongun
			G.overlays += G.optics_ico
		else
			return
/obj/item/weapon/attachment/scope/adjustable/advanced/removed(mob/user, obj/item/weapon/gun/G)
	if (do_after(user, 15, user))
		G.attachments -= src
		G.actions -= actions
		G.verbs -= verbs
		G.attachment_slots += attachment_type
		dropped(user)
		A_attached = FALSE
		loc = get_turf(src)
		G.scope = null
		user << "You remove [src] from the [G]."
		G.specialoptics = null
		G.overlays -= G.optics_ico
	else
		return
/obj/item/weapon/attachment/scope/adjustable/advanced/acog
	name = "4x ACOG scope"
	icon_state = "acog"
	desc = "A 4x scope."
	max_zoom = ZOOM_CONSTANT+4

/obj/item/weapon/attachment/scope/adjustable/advanced/reddot
	name = "red dot sight"
	icon_state = "reddot"
	desc = "A red dot laser sight. Increases accuracy and gives a slight magnification."
	max_zoom = ZOOM_CONSTANT+2
	accuracy_mod = 1.4

/obj/item/weapon/attachment/scope/adjustable/advanced/holographic
	name = "holographic sight"
	desc = "A reflector holographic sight. Does not give magnification but greatly reduces parallax error."
	icon_state = "holographic"
	max_zoom = ZOOM_CONSTANT
	accuracy_mod = 1.5

/obj/item/weapon/attachment/scope/adjustable/advanced/nvs
	name = "night vision scope"
	desc = "A bulky scope that allows images be produced in levels of light approaching total darkness."
	icon_state = "nvs"
	max_zoom = ZOOM_CONSTANT
	accuracy_mod = 0.8

/////////////////UNDERBARREL//////////////////////////////

/obj/item/weapon/attachment/under
	icon = 'icons/obj/gun_att.dmi'
	icon_state = "foregrip"
	var/noscopeonly = FALSE //if the gun must be OFF scope mode to give the bonuses, should replace this with a -1,0,1 var which dictates whether it only works when unscoped, both, scopes accordingly
	attachment_type = ATTACH_UNDER
	var/image/ongun
	New()
		..()
		ongun = image("icon" = 'icons/obj/gun_att.dmi', "icon_state" = "[icon_state]_ongun")

/obj/item/weapon/attachment/under/attached(mob/user, obj/item/weapon/gun/G, var/quick = FALSE)
	if (quick)
		A_attached = TRUE
		G.attachment_slots -= attachment_type
		loc = G
		G.actions += actions
		G.verbs += verbs
		G.attachments += src
		G.under = src
		G.under_ico = ongun
		G.overlays += G.under_ico
	else
		if (do_after(user, 15, user))
			user.unEquip(src)
			A_attached = TRUE
			G.attachment_slots -= attachment_type
			loc = G
			G.actions += actions
			G.verbs += verbs
			G.attachments += src
			G.update_attachment_actions(user)
			user << "<span class = 'notice'>You attach [src] to the [G].</span>"
			G.under = src
			G.under_ico = ongun
			G.overlays += G.under_ico
		else
			return

/obj/item/weapon/attachment/under/removed(mob/user, obj/item/weapon/gun/G)
	if (do_after(user, 15, user))
		G.attachments -= src
		G.actions -= actions
		G.verbs -= verbs
		G.attachment_slots += attachment_type
		dropped(user)
		A_attached = FALSE
		loc = get_turf(src)
		user << "You remove [src] from the [G]."
		G.under = null
		G.overlays -= G.under_ico
	else
		return

/obj/item/weapon/attachment/under/laser
	name = "laser pointer"
	icon_state = "laser"
	desc = "a basic laser pointer, increases accuracy by a bit."
	accuracy_mod = 1.2
	noscopeonly = TRUE

/obj/item/weapon/attachment/under/foregrip
	name = "foregrip"
	icon_state = "foregrip"
	desc = "a foregrip, to increase stability when firing."
	accuracy_mod = 1.4
	noscopeonly = FALSE

/////////////////BARREL ATTACHMENTS//////////////////////////////

/obj/item/weapon/attachment/barrel
	icon = 'icons/obj/gun_att.dmi'
	icon_state = "lightbarrel"

	accuracy_mod = 3
	dispersion_mod = 0.5
	unwieldiness = 1.1

	attachment_type = ATTACH_BARREL
	var/image/ongun

	var/temperature = 0
	var/max_temperature = 50
	var/cool_rate = 0.01
	
	var/suppressing = FALSE //Whether or not the barrel causes the gun to use a suppressed gunshot sound
	var/noise_mod = 1 //Multiplier for the noise of a shot
	var/flash_mod = 1 //Multiplier for muzzle flash
	New()
		..()
		//ongun = image("icon" = 'icons/obj/gun_att.dmi', "icon_state" = "[icon_state]_ongun")

/obj/item/weapon/attachment/barrel/attached(mob/user, obj/item/weapon/gun/G, var/quick = FALSE)
	if (quick)
		if ("[G]" in specific_sprite)
			ongun = image("icon" = 'icons/obj/gun_att.dmi', "icon_state" = "[icon_state]_[G]")
		else
			ongun = image("icon" = 'icons/obj/gun_att.dmi', "icon_state" = "[icon_state]_ongun")
		A_attached = TRUE
		G.attachment_slots -= attachment_type
		loc = G
		G.actions += actions
		G.verbs += verbs
		G.attachments += src
		G.barrel = src
		G.barrel_ico = ongun
		G.overlays += G.barrel_ico
		process()
	else
		if (do_after(user, 15, user))
			user.unEquip(src)
			A_attached = TRUE
			G.attachment_slots -= attachment_type
			loc = G
			G.actions += actions
			G.verbs += verbs
			G.attachments += src
			G.update_attachment_actions(user)
			user << "<span class = 'notice'>You attach [src] to the [G].</span>"
			G.barrel = src
			G.barrel_ico = ongun
			G.overlays += G.barrel_ico
			process()
		else
			return

/obj/item/weapon/attachment/barrel/removed(mob/user, obj/item/weapon/gun/G)
	if (temperature >= 12)
		user << "<span class = 'warning'>You burn your hand on the [src]!</span>"
		if (istype(usr,/mob/living/carbon/human))
			var/mob/living/carbon/human/H = usr
			H.apply_damage(rand(2,4), BURN, pick("l_hand","r_hand"))
		return
	if (do_after(user, 15, user))
		G.attachments -= src
		G.actions -= actions
		G.verbs -= verbs
		G.attachment_slots += attachment_type
		dropped(user)
		A_attached = FALSE
		loc = get_turf(src)
		user << "You remove [src] from the [G]."
		G.barrel = null
		G.overlays -= G.barrel_ico
	else
		return

/obj/item/weapon/attachment/barrel/process(G)
	while(A_attached)
		if (temperature > 0)
			if ((temperature - cool_rate) < 0)
				temperature = 0
			temperature -= cool_rate
		to_world("[temperature]")
		if (temperature > max_temperature)// and prob(10) //Add this in after we get the visual indication going
			melt(src, G)
			spawn (1)
				new/obj/effect/effect/smoke/chem(get_step(src, dir))

/obj/item/weapon/attachment/barrel/melt(mob/user, obj/item/weapon/gun/G)
	G.attachments -= src
	G.actions -= actions
	G.verbs -= verbs
	G.attachment_slots += attachment_type
	A_attached = FALSE
	loc = get_turf(src)
	user << "Your [src] melts off of the [G]!"
	G.stock = null
	G.overlays -= G.stock_ico

/obj/item/weapon/attachment/barrel/lightbarrel
	icon = 'icons/obj/gun_att.dmi'
	icon_state = "lightbarrel"
	
	accuracy_mod = 3
	dispersion_mod = 2
	
	attachment_type = ATTACH_BARREL

	temperature = 0
	max_temperature = 50
	cool_rate = 0.01
	
	suppressing = FALSE //Whether or not the barrel causes the gun to use a suppressed gunshot sound
	noise_mod = 1 //Multiplier for the noise of a shot
	flash_mod = 1 //Multiplier for muzzle flash

/obj/item/weapon/attachment/barrel/lightbarrel
	icon = 'icons/obj/gun_att.dmi'
	icon_state = "suppressor"
	
	accuracy_mod = 3
	dispersion_mod = 2
	
	attachment_type = ATTACH_BARREL

	temperature = 0
	max_temperature = 50
	cool_rate = 0.01
	
	suppressing = FALSE //Whether or not the barrel causes the gun to use a suppressed gunshot sound
	noise_mod = 1 //Multiplier for the noise of a shot
	flash_mod = 1 //Multiplier for muzzle flash

/////////////////STOCK ATTACHMENTS//////////////////////////////

/obj/item/weapon/attachment/stock
	icon = 'icons/obj/gun_att.dmi'
	icon_state = "woodstock"
	accuracy_mod = 3
	
	attachment_type = ATTACH_STOCK
	var/image/ongun

	New()
		..()
		//ongun = image("icon" = 'icons/obj/gun_att.dmi', "icon_state" = "[icon_state]_ongun")

/obj/item/weapon/attachment/stock/attached(mob/user, obj/item/weapon/gun/G, var/quick = FALSE)
	if (quick)
		if ("[G]" in specific_sprite)
			ongun = image("icon" = 'icons/obj/gun_att.dmi', "icon_state" = "[icon_state]_[G]")
		else
			ongun = image("icon" = 'icons/obj/gun_att.dmi', "icon_state" = "[icon_state]_ongun")
		A_attached = TRUE
		G.attachment_slots -= attachment_type
		loc = G
		G.actions += actions
		G.verbs += verbs
		G.attachments += src
		G.stock = src
		G.stock_ico = ongun
		G.overlays += G.stock_ico
		process(G)
	else
		if (do_after(user, 15, user))
			user.unEquip(src)
			A_attached = TRUE
			G.attachment_slots -= attachment_type
			loc = G
			G.actions += actions
			G.verbs += verbs
			G.attachments += src
			G.update_attachment_actions(user)
			user << "<span class = 'notice'>You attach [src] to the [G].</span>"
			G.stock = src
			G.stock_ico = ongun
			G.overlays += G.stock_ico
		else
			return

/obj/item/weapon/attachment/stock/removed(mob/user, obj/item/weapon/gun/G)
	if (do_after(user, 15, user))
		G.attachments -= src
		G.actions -= actions
		G.verbs -= verbs
		G.attachment_slots += attachment_type
		dropped(user)
		A_attached = FALSE
		loc = get_turf(src)
		user << "You remove [src] from the [G]."
		G.stock = null
		G.overlays -= G.stock_ico
	else
		return
