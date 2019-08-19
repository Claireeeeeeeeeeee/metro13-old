/obj/item/weapon/gun/projectile/submachinegun/bastardgun
	name = "Bastard Gun"
	desc = "A fast firing carbine cobbled together from scrap, it is ubiquitous in the metro tunnels for its cheapness and feasability of maintenance."
	icon_state = "bastardgun"
	item_state = "bastardgun"
	base_icon = "bastardgun"
	caliber = "a545x39"
	fire_sound = 'sound/weapons/mosin_shot.ogg'
	magazine_type = /obj/item/ammo_magazine/bastardgun
	weight = 3.47
	equiptimer = 10
	load_delay = 12
	slot_flags = SLOT_SHOULDER
	firemodes = list(
		list(name="semi auto",	burst=1, burst_delay=0.8, recoil=0.7, move_delay=2, dispersion = list(0.3, 0.4, 0.5, 0.6, 0.7)),
		list(name="full auto",	burst=1, burst_delay=1.3, recoil=2, move_delay=2.5, dispersion = list(1.2, 1.2, 1.3, 1.4, 1.8)),
		)
	effectiveness_mod = 1
	sel_mode = 1
	attachment_slots = null