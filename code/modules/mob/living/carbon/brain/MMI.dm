//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/device/mmi
	name = "Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "mmi_empty"
	w_class = 3
	origin_tech = "biotech=3"

	//Revised. Brainmob is now contained directly within object of transfer. MMI in this case.
	var/alien = 0
	var/syndiemmi = 0 //Whether or not this is a Syndicate MMI
	var/mob/living/carbon/brain/brainmob = null//The current occupant.
	var/mob/living/silicon/robot/robot = null//Appears unused.
	var/obj/mecha/mecha = null//This does not appear to be used outside of reference in mecha.dm.
// I'm using this for mechs giving MMIs HUDs now

	attackby(var/obj/item/O as obj, var/mob/user as mob, params)
		if(istype(O, /obj/item/organ/brain/crystal ))
			user << "<span class='warning'> This brain is too malformed to be able to use with the [src].</span>"
			return
		if(istype(O,/obj/item/organ/brain) && !brainmob) //Time to stick a brain in it --NEO
			if(!O:brainmob)
				user << "\red You aren't sure where this brain came from, but you're pretty sure it's a useless brain."
				return
			for(var/mob/V in viewers(src, null))
				V.show_message(text("\blue [user] sticks \a [O] into \the [src]."))
			brainmob = O:brainmob
			O:brainmob = null
			brainmob.loc = src
			brainmob.container = src
			brainmob.stat = 0
			respawnable_list -= brainmob
			dead_mob_list -= brainmob//Update dem lists
			living_mob_list += brainmob

			user.drop_item()
			if(istype(O,/obj/item/organ/brain/xeno))
				name = "Man-Machine Interface: Alien - [brainmob.real_name]"
				icon = 'icons/mob/alien.dmi'
				icon_state = "AlienMMI"
				alien = 1
			else
				name = "Man-Machine Interface: [brainmob.real_name]"
				icon_state = "mmi_full"
				alien = 0
			qdel(O)



			feedback_inc("cyborg_mmis_filled",1)

			return

		if(brainmob)
			O.attack(brainmob, user)//Oh noooeeeee
			// Brainmobs can take damage, but they can't actually die. Maybe should fix.
			return
		..()



	attack_self(mob/user as mob)
		if(!brainmob)
			user << "\red You upend the MMI, but there's nothing in it."
		else
			user << "<span class='notice'>You unlock and upend the MMI, spilling the brain onto the floor.</span>"
			if(alien)
				var/obj/item/organ/brain/xeno/brain = new(user.loc)
				dropbrain(brain,get_turf(user))
			else
				var/obj/item/organ/brain/brain = new(user.loc)
				dropbrain(brain,get_turf(user))
			icon = 'icons/obj/assemblies.dmi'
			icon_state = "mmi_empty"
			name = "Man-Machine Interface"

	proc
		transfer_identity(var/mob/living/carbon/human/H)//Same deal as the regular brain proc. Used for human-->robot people.
			brainmob = new(src)
			brainmob.name = H.real_name
			brainmob.real_name = H.real_name
			brainmob.dna = H.dna.Clone()
			brainmob.container = src

			name = "Man-Machine Interface: [brainmob.real_name]"
			icon_state = "mmi_full"
			return
//I made this proc as a way to have a brainmob be transferred to any created brain, and to solve the
//problem i was having with alien/nonalien brain drops.
		dropbrain(var/obj/item/organ/brain/brain, var/turf/dropspot)
			brainmob.container = null//Reset brainmob mmi var.
			brainmob.loc = brain//Throw mob into brain.
			respawnable_list += brainmob
			living_mob_list -= brainmob//Get outta here
			brain.brainmob = brainmob//Set the brain to use the brainmob
			brain.brainmob.cancel_camera()
			brainmob = null//Set mmi brainmob var to null


/obj/item/device/mmi/radio_enabled
	name = "Radio-enabled Man-Machine Interface"
	desc = "The Warrior's bland acronym, MMI, obscures the true horror of this monstrosity. This one comes with a built-in radio."
	origin_tech = "biotech=4"

	var/obj/item/device/radio/radio = null//Let's give it a radio.

	New()
		..()
		radio = new(src)//Spawns a radio inside the MMI.
		radio.broadcasting = 1//So it's broadcasting from the start.

	verb//Allows the brain to toggle the radio functions.

		Toggle_Listening()
			set name = "Toggle Listening"
			set desc = "Toggle listening channel on or off."
			set category = "MMI"
			set src = usr.loc
			set popup_menu = 0

			if(brainmob.stat)
				brainmob << "Can't do that while incapacitated or dead."

			radio.listening = radio.listening==1 ? 0 : 1
			brainmob << "\blue Radio is [radio.listening==1 ? "now" : "no longer"] receiving broadcast."

/obj/item/device/mmi/emp_act(severity)
	if(!brainmob)
		return
	else
		switch(severity)
			if(1)
				brainmob.emp_damage += rand(20,30)
			if(2)
				brainmob.emp_damage += rand(10,20)
			if(3)
				brainmob.emp_damage += rand(0,10)
	..()

/obj/item/device/mmi/relaymove(var/mob/user, var/direction)
	if(user.stat || user.stunned)
		return
	var/obj/item/weapon/rig/rig = src.get_rig()
	if(rig)
		rig.forced_move(direction, user)

/obj/item/device/mmi/Destroy()
	if(isrobot(loc))
		var/mob/living/silicon/robot/borg = loc
		borg.mmi = null
	if(brainmob)
		qdel(brainmob)
		brainmob = null
	return ..()

/obj/item/device/mmi/syndie
	name = "Syndicate Man-Machine Interface"
	desc = "Syndicate's own brand of MMI. It enforces laws designed to help Syndicate agents achieve their goals upon cyborgs created with it, but doesn't fit in Nanotrasen AI cores."
	syndiemmi = 1