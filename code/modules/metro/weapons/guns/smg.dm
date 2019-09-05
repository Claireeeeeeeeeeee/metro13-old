/obj/item/weapon/gun/projectile/submachinegun/bastard
	name = "Bastard Gun"
	desc = "A fast firing carbine cobbled together from scrap, it is ubiquitous in the metro tunnels for its cheapness to produce, and ease of maintenance compared to other makeshift firearms."
	icon_state = "bastard"
	item_state = "bastard"
	base_icon = "bastard"
	caliber = "a545x39"
	fire_sound = list('sound/weapons/guns/fire/shotgun_fire.ogg')
	magazine_type = /obj/item/ammo_magazine/bastard_30
	bad_magazine_types = list(/obj/item/ammo_magazine/kalash_30t)
	weight = 2.5
	equiptimer = 10
	load_delay = 12
	slot_flags = SLOT_SHOULDER
	accuracy = -3
	jam_frequency = 0.5
	jam_severity = 5
	firemodes = list(
		list(name="semi auto", fire_delay=0.1, recoil=0.7, move_delay=2, dispersion = list(0.3, 0.4, 0.5, 0.6, 0.7)),
		list(name="full auto", fire_delay=0.1, recoil=3, move_delay=2.5, dispersion = list(1.2, 1.4, 1.6, 1.8, 2)),
		)
	effectiveness_mod = 1
	sel_mode = 1
	attachment_slots = null //However there should be a surpressor variant you can make

/obj/item/weapon/gun/projectile/submachinegun/kalash
	name = "Kalash"
	desc = "One of the most well known soviet accomplishments in engineering, this rugged pre-war rifle is prized in the Metro for being extremely reliable."
	icon_state = "kalash"
	item_state = "kalash"
	base_icon = "kalash"
	caliber = "a545x39"
	fire_sound = list('sound/weapons/mosin_shot.ogg')
	magazine_type = /obj/item/ammo_magazine/kalash_30t
	bad_magazine_types = list(/obj/item/ammo_magazine/bastard_30)
	weight = 3.47
	equiptimer = 15
	jam_frequency = 0.05
	jam_severity = 0.8 //Reliable, even when it does jam it's not *that* bad
	slot_flags = SLOT_SHOULDER
	firemodes = list(
		list(name="semi auto", fire_delay=7.5, recoil=0.7, move_delay=2, dispersion = list(0.3, 0.4, 0.5, 0.6, 0.7)),
		list(name="burst fire",	burst=3, burst_delay=6, fire_delay=5, recoil=0.9, move_delay=3, dispersion = list(1, 1.1, 1.1, 1.3, 1.5)),
		list(name="full auto", fire_delay=1, recoil=1.3, move_delay=4, recoil=1, dispersion = list(1.2, 1.2, 1.3, 1.4, 1.8)),
		)
	effectiveness_mod = 1
	sel_mode = 1
	attachment_slots = ATTACH_IRONSIGHTS|ATTACH_SCOPE|ATTACH_ADV_SCOPE //You can attach a lot of stuff to the top rail, pretty sure the metro one doesn't accept front attachements though