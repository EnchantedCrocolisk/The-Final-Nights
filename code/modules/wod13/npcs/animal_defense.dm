

/mob/living/simple_animal/attack_hand(mob/living/carbon/human/M)
	// so that martial arts don't double dip
	if (..())
		return TRUE
	switch(M.a_intent)
		if("help")
			if (stat == DEAD)
				return
			if(HAS_TRAIT(M, TRAIT_ANIMAL_REPULSION))
				playsound(src, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
				var/shove_dir = get_dir(M, src)
				if(!M.client)
					Move(get_step(src, shove_dir), shove_dir)
				visible_message("<span class='notice'>[M] shies away from [src], baring teeth!</span>", \
								"<span class='notice'>[M] feels <b>deeply uncomfortable</b> as they reach for you. You instinctively bare your teeth!</span>", null, null, M)
				to_chat(M, "<span class='notice'>You attempt to [response_help_simple] [src], but they shy from you, baring teeth.</span>")
				return TRUE
			visible_message("<span class='notice'>[M] [response_help_continuous] [src].</span>", \
							"<span class='notice'>[M] [response_help_continuous] you.</span>", null, null, M)
			to_chat(M, "<span class='notice'>You [response_help_simple] [src].</span>")
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
			if(pet_bonus)
				funpet(M)

		if("grab")
			grabbedby(M)
			if(HAS_TRAIT(M, TRAIT_ANIMAL_REPULSION))
				if (stat == DEAD)
					return
				playsound(src, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
				var/shove_dir = get_dir(M, src)
				if(!M.client)
					Move(get_step(src, shove_dir), shove_dir)
				visible_message("<span class='notice'>[M] shies away from [src], baring teeth!</span>", \
								"<span class='notice'>[M] feels <b>deeply uncomfortable</b> as they reach for you. You instinctively bare your teeth!</span>", null, null, M)
				to_chat(M, "<span class='notice'>You attempt to grab [src], but they shy from you, baring teeth.</span>")
				return TRUE

		if("disarm")
			M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
			playsound(src, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
			var/shove_dir = get_dir(M, src)
			if(!Move(get_step(src, shove_dir), shove_dir))
				log_combat(M, src, "shoved", "failing to move it")
				M.visible_message("<span class='danger'>[M.name] shoves [src]!</span>",
					"<span class='danger'>You shove [src]!</span>", "<span class='hear'>You hear aggressive shuffling!</span>", COMBAT_MESSAGE_RANGE, list(src))
				to_chat(src, "<span class='userdanger'>You're shoved by [M.name]!</span>")
				return TRUE
			log_combat(M, src, "shoved", "pushing it")
			M.visible_message("<span class='danger'>[M.name] shoves [src], pushing [p_them()]!</span>",
				"<span class='danger'>You shove [src], pushing [p_them()]!</span>", "<span class='hear'>You hear aggressive shuffling!</span>", COMBAT_MESSAGE_RANGE, list(src))
			to_chat(src, "<span class='userdanger'>You're pushed by [M.name]!</span>")
			return TRUE

		if("harm")
			if(HAS_TRAIT(M, TRAIT_PACIFISM))
				to_chat(M, "<span class='warning'>You don't want to hurt [src]!</span>")
				return
			M.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
			visible_message("<span class='danger'>[M] [response_harm_continuous] [src]!</span>",\
							"<span class='userdanger'>[M] [response_harm_continuous] you!</span>", null, COMBAT_MESSAGE_RANGE, M)
			to_chat(M, "<span class='danger'>You [response_harm_simple] [src]!</span>")
			playsound(loc, attacked_sound, 25, TRUE, -1)
			attack_threshold_check(M.dna.species.punchdamagelow)
			log_combat(M, src, "attacked")
			updatehealth()
			return TRUE

/**
*This is used to make certain mobs (pet_bonus == TRUE) emote when pet, make a heart emoji at their location, and give the petter a moodlet.
*
*/
/mob/living/simple_animal/proc/funpet(mob/petter)
	new /obj/effect/temp_visual/heart(loc)
	if(prob(33))
		manual_emote("[pet_bonus_emote]")
	SEND_SIGNAL(petter, COMSIG_ADD_MOOD_EVENT, src, /datum/mood_event/pet_animal, src)

/mob/living/simple_animal/attack_hulk(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	playsound(loc, "punch", 25, TRUE, -1)
	visible_message("<span class='danger'>[user] punches [src]!</span>", \
					"<span class='userdanger'>You're punched by [user]!</span>", null, COMBAT_MESSAGE_RANGE, user)
	to_chat(user, "<span class='danger'>You punch [src]!</span>")
	adjustBruteLoss(15)

/mob/living/simple_animal/attack_paw(mob/living/carbon/human/M)
	if(..()) //successful monkey bite.
		if(stat != DEAD)
			var/damage = rand(1, 3)
			attack_threshold_check(damage)
			return 1
	if (M.a_intent == INTENT_HELP)
		if (health > 0)
			visible_message("<span class='notice'>[M.name] [response_help_continuous] [src].</span>", \
							"<span class='notice'>[M.name] [response_help_continuous] you.</span>", null, COMBAT_MESSAGE_RANGE, M)
			to_chat(M, "<span class='notice'>You [response_help_simple] [src].</span>")
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)


/mob/living/simple_animal/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(..()) //if harm or disarm intent.
		if(M.a_intent == INTENT_DISARM)
			playsound(loc, 'sound/weapons/pierce.ogg', 25, TRUE, -1)
			visible_message("<span class='danger'>[M] [response_disarm_continuous] [name]!</span>", \
							"<span class='userdanger'>[M] [response_disarm_continuous] you!</span>", null, COMBAT_MESSAGE_RANGE, M)
			to_chat(M, "<span class='danger'>You [response_disarm_simple] [name]!</span>")
			log_combat(M, src, "disarmed")
		else
			var/damage = rand(15, 30)
			visible_message("<span class='danger'>[M] slashes at [src]!</span>", \
							"<span class='userdanger'>You're slashed at by [M]!</span>", null, COMBAT_MESSAGE_RANGE, M)
			to_chat(M, "<span class='danger'>You slash at [src]!</span>")
			playsound(loc, 'sound/weapons/slice.ogg', 25, TRUE, -1)
			attack_threshold_check(damage)
			log_combat(M, src, "attacked")
		return 1

/mob/living/simple_animal/attack_larva(mob/living/carbon/alien/larva/L)
	. = ..()
	if(. && stat != DEAD) //successful larva bite
		var/damage = rand(5, 10)
		. = attack_threshold_check(damage)
		if(.)
			L.amount_grown = min(L.amount_grown + damage, L.max_grown)

/mob/living/simple_animal/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		return attack_threshold_check(damage, M.melee_damage_type)

/mob/living/simple_animal/attack_slime(mob/living/simple_animal/slime/M)
	if(..()) //successful slime attack
		var/damage = rand(15, 25)
		if(M.is_adult)
			damage = rand(20, 35)
		return attack_threshold_check(damage)

/mob/living/simple_animal/attack_drone(mob/living/simple_animal/drone/M)
	if(M.a_intent == INTENT_HARM) //No kicking dogs even as a rogue drone. Use a weapon.
		return
	return ..()

/mob/living/carbon/human/Bump(atom/Obstacle)
	. = ..()
	var/mob/living/simple_animal/animal = locate() in get_turf(Obstacle)
	if(animal)
		if(animal.name == "Cain")
			return //cain will never hate you.
		if(HAS_TRAIT(src, TRAIT_ANIMAL_REPULSION))
			adjustBruteLoss(3)
			visible_message("<span class='danger'>[animal] bites at [name]!</span>", \
							"<span class='userdanger'>[animal] bites you!</span>", null, COMBAT_MESSAGE_RANGE, src)


/mob/living/simple_animal/proc/attack_threshold_check(damage, damagetype = BRUTE, armorcheck = MELEE, actuallydamage = TRUE)
	var/temp_damage = damage
	if(!damage_coeff[damagetype])
		temp_damage = 0
	else
		temp_damage *= damage_coeff[damagetype]

	if(temp_damage >= 0 && temp_damage <= force_threshold)
		visible_message("<span class='warning'>[src] looks unharmed!</span>")
		return FALSE
	else
		if(actuallydamage)
			apply_damage(damage, damagetype, null, getarmor(null, armorcheck))
		return TRUE

/mob/living/simple_animal/bullet_act(obj/projectile/Proj, def_zone, piercing_hit = FALSE)
	apply_damage(Proj.damage, Proj.damage_type)
	Proj.on_hit(src, 0, piercing_hit)
	return BULLET_ACT_HIT

/mob/living/simple_animal/ex_act(severity, target, origin)
	if(origin && istype(origin, /datum/spacevine_mutation) && isvineimmune(src))
		return
	..()
	if(QDELETED(src))
		return
	var/bomb_armor = getarmor(null, BOMB)
	switch (severity)
		if (EXPLODE_DEVASTATE)
			if(prob(bomb_armor))
				adjustBruteLoss(500)
			else
				gib()
				return
		if (EXPLODE_HEAVY)
			var/bloss = 60
			if(prob(bomb_armor))
				bloss = bloss / 1.5
			adjustBruteLoss(bloss)

		if(EXPLODE_LIGHT)
			var/bloss = 30
			if(prob(bomb_armor))
				bloss = bloss / 1.5
			adjustBruteLoss(bloss)

/mob/living/simple_animal/blob_act(obj/structure/blob/B)
	adjustBruteLoss(20)
	return

/mob/living/simple_animal/do_attack_animation(atom/A, visual_effect_icon, used_item, no_effect)
	if(!no_effect && !visual_effect_icon && melee_damage_upper)
		if(melee_damage_upper < 10)
			visual_effect_icon = ATTACK_EFFECT_PUNCH
		else
			visual_effect_icon = ATTACK_EFFECT_SMASH
	..()
