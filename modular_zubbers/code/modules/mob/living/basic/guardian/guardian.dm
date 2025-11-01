

/mob/living/basic/guardian/Initialize(mapload, datum/guardian_fluff/theme)
	.=..()
	var/datum/action/innate/guardian_recon/recon_mode = new (src)
	recon_mode.Grant(src)

/datum/action/innate/guardian_recon
	name = "Recon Mode"
	desc = "Allows you to become invisible and fly through anything, \
		Furthermore, you won't be attached to your summoner, however \
		you're unable to attack in this mode, but you can't be attacked, either."
//	button_icon = "toggle"

/datum/action/innate/guardian_recon/Activate()
	var/mob/living/basic/guardian/guardian_mob = owner

	if(guardian_mob.is_deployed() && !isnull(guardian_mob.summoner))
		guardian_mob.balloon_alert(guardian_mob, "must not be manifested!")
		return

	animate(guardian_mob, alpha = 0, time = 0.5 SECONDS)
	RegisterSignal(guardian_mob, COMSIG_GUARDIAN_MANIFESTED, PROC_REF(on_manifest))
	RegisterSignal(guardian_mob, COMSIG_GUARDIAN_RECALLED, PROC_REF(on_recall))
	RegisterSignal(guardian_mob, COMSIG_MOB_CLICKON, PROC_REF(on_click))
//	RegisterSignal(guardian_mob, COMSIG_BASICMOB_PRE_ATTACK_RANGED, PROC_REF(on_ranged_attack))

	guardian_mob.unleash()
	to_chat(guardian_mob, span_bolddanger("You enter recon mode."))
	active = TRUE


/datum/action/innate/guardian_recon/Deactivate()
	var/mob/living/basic/guardian/guardian_mob = owner

	if(guardian_mob.is_deployed() && !isnull(guardian_mob.summoner))
		guardian_mob.balloon_alert(guardian_mob, "must not be manifested!")
		return

	animate(guardian_mob, alpha = initial(guardian_mob.alpha), time = 0.5 SECONDS)
	UnregisterSignal(guardian_mob, list(
//		COMSIG_BASICMOB_PRE_ATTACK_RANGED,
		COMSIG_GUARDIAN_MANIFESTED,
		COMSIG_GUARDIAN_RECALLED,
		COMSIG_MOB_CLICKON,
	))

	to_chat(guardian_mob, span_bolddanger("You return to your normal mode."))
	guardian_mob.leash_to(guardian_mob, guardian_mob.summoner)
	active = FALSE


/// Restore incorporeal move when we become corporeal, yes I know that suonds silly
/datum/action/innate/guardian_recon/proc/on_manifest()
	SIGNAL_HANDLER
	var/mob/living/basic/guardian/guardian_mob = owner
	guardian_mob.incorporeal_move = INCORPOREAL_MOVE_BASIC

/// Stop having incorporeal move when we recall so that we can't move
/datum/action/innate/guardian_recon/proc/on_recall()
	SIGNAL_HANDLER
	var/mob/living/basic/guardian/guardian_mob = owner
	guardian_mob.incorporeal_move = FALSE

/// While this is active we can't click anything
/datum/action/innate/guardian_recon/proc/on_click()
	SIGNAL_HANDLER
	var/mob/living/basic/guardian/guardian_mob = owner
	return COMSIG_MOB_CANCEL_CLICKON

/// We can't do any ranged attacks while in scout mode.
// /datum/action/innate/guardian_recon/proc/on_ranged_attack()
//	SIGNAL_HANDLER
//	guardian_mob.balloon_alert(guardian_mob, "need to be in ranged mode!")
//	return COMPONENT_CANCEL_RANGED_ATTACK

// The Guardian scout ability
// Pretty similar to how the ranged guardian scout used to work, except without alert snares
