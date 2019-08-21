/datum/job/reich
    faction = "Human"

/datum/job/reich/give_random_name(var/mob/living/carbon/human/H)
    H.name = H.species.get_random_german_name(H.gender)
    H.real_name = H.name
