//wip wip wup
/obj/structure/mirror
	name = "mirror"
	desc = "A simple mirrror."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "mirror"
	density = FALSE
	anchored = TRUE
	var/shattered = FALSE
	var/list/ui_users = list()
	not_movable = FALSE
	not_disassemblable = FALSE
/obj/structure/mirror/attack_hand(mob/user as mob)

	if (shattered)	return

	if (ishuman(user))
		var/datum/nano_module/appearance_changer/AC = ui_users[user]
		if (!AC)
			AC = new(src, user)
			AC.name = "SalonPro Nano-Mirror&trade;"
			ui_users[user] = AC
		AC.ui_interact(user)

/obj/structure/mirror/proc/shatter()
	if (shattered)	return
	shattered = TRUE
	icon_state = "mirror_broke"
	playsound(src, "shatter", 70, TRUE)
	desc = "Oh no, seven years of bad luck!"


/obj/structure/mirror/bullet_act(var/obj/item/projectile/Proj)

	if (prob(Proj.get_structure_damage() * 2))
		if (!shattered)
			shatter()
		else
			playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
	..()

/obj/structure/mirror/attackby(obj/item/I as obj, mob/user as mob)
	if (shattered)
		playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
		return

	if (prob(I.force * 2))
		visible_message("<span class='warning'>[user] smashes [src] with [I]!</span>")
		shatter()
	else
		visible_message("<span class='warning'>[user] hits [src] with [I]!</span>")
		playsound(loc, 'sound/effects/Glasshit.ogg', 70, TRUE)

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

/obj/structure/mirror/attack_generic(var/mob/user, var/damage)
	attack_animation(user)
	if (shattered)
		playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
		return FALSE

	if (damage)
		user.visible_message("<span class='danger'>[user] smashes [src]!</span>")
		shatter()
	else
		user.visible_message("<span class='danger'>[user] hits [src] and bounces off!</span>")

	user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	return TRUE

/obj/structure/mirror/Destroy()
	for (var/user in ui_users)
		var/datum/nano_module/appearance_changer/AC = ui_users[user]
		qdel(AC)
	ui_users.Cut()
	..()
