/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh
	name = "Writhing Embrace"
	/// Typepath of a mob we have scanned, we only store one at a time
	var/stored_mob_type
	/// Our current transformation action
	var/datum/action/cooldown/spell/shapeshift/polymorph_belt/flesh_robes/transform_action

	// var/pick = show_radial_menu(user, parent, items, custom_check = CALLBACK(src, PROC_REF(check_reskin_menu), user), radius = 38, require_near = TRUE)
	// if(!pick || !items[pick])
	// 	return

	// set_skin_by_name(pick, user)
	// to_chat(user, span_info("[parent] is now skinned as '[pick].'"))

/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh/Destroy(force)
	QDEL_NULL(transform_action)
	return ..()

/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh/examine(mob/user)
	. = ..()
	if (stored_mob_type)
		var/mob/living/will_become = stored_mob_type
		. += span_notice("It contains digitised [initial(will_become.name)] DNA.")

/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh/attack(mob/living/target_mob, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if (.)
		return
	if (!isliving(target_mob))
		return
	if (!isanimal_or_basicmob(target_mob))
		balloon_alert(user, "target too complex!")
		return TRUE
	if (target_mob.mob_biotypes & (MOB_HUMANOID|MOB_ROBOTIC|MOB_SPECIAL|MOB_SPIRIT|MOB_UNDEAD))
		balloon_alert(user, "incompatible!")
		return TRUE
	if (!target_mob.compare_sentience_type(SENTIENCE_ORGANIC))
		balloon_alert(user, "target too intelligent!")
		return TRUE
	if (stored_mob_type == target_mob.type)
		balloon_alert(user, "already scanned!")
		return TRUE
	if (DOING_INTERACTION_WITH_TARGET(user, target_mob))
		balloon_alert(user, "busy!")
		return TRUE
	balloon_alert(user, "scanning...")
	visible_message(span_notice("[user] begins scanning [target_mob] with [src]."))
	if (!do_after(user, delay = 5 SECONDS, target = target_mob))
		return TRUE
	visible_message(span_notice("[user] scans [target_mob] with [src]."))
	stored_mob_type = target_mob.type
	update_transform_action()
	return TRUE

/// Make sure we can transform into the scanned target
/obj/item/clothing/suit/hooded/cultrobes/eldritch/flesh/proc/update_transform_action()
	if (isnull(stored_mob_type))
		return
	if (isnull(transform_action))
		transform_action = add_item_action(/datum/action/cooldown/spell/shapeshift/polymorph_belt/flesh_robes)
	transform_action.update_type(stored_mob_type)

/// Ability provided by the polymorph belt
/datum/action/cooldown/spell/shapeshift/polymorph_belt/flesh_robes
	name = "Twist Flesh"
	cooldown_time = 15 SECONDS
	school = SCHOOL_UNSET
	invocation_type = INVOCATION_NONE
	possible_shapes = list(/mob/living/basic/cockroach)
	can_be_shared = FALSE
	shapechange_type = /datum/status_effect/shapechange_mob/from_spell/polymorph_belt/flesh_robes
	/// Amount of time it takes us to transform back or forth
	channel_time = 3 SECONDS

/datum/status_effect/shapechange_mob/from_spell/polymorph_belt/flesh_robes

/datum/status_effect/shapechange_mob/from_spell/polymorph_belt/flesh_robes/on_apply()
	.=..()
	ADD_TRAIT(caster_mob, TRAIT_ALLOW_HERETIC_CASTING)



// /// Update what you are transforming to or from
// /datum/action/cooldown/spell/shapeshift/polymorph_belt/flesh_robes/update_type(transform_type)
// 	unshift_owner()
// 	shapeshift_type = transform_type
// 	possible_shapes = list(transform_type)
// 	var/mob/living/will_become = transform_type
// 	desc = "Assume your [initial(will_become.name)] form!"
// 	build_all_button_icons(update_flags = UPDATE_BUTTON_NAME)
