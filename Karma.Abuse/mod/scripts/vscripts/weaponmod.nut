global function Mod
global function PrintWeaponMods
global function GiveWM
global function GiveWMWait
global function GiveWeaponMod
global bool bypassPerms = false;

void function Mod()
{
	#if SERVER
	AddClientCommandCallback("mod", GiveWMWait);
	#endif
}

void function PrintWeaponMods(entity weapon)
{
	#if SERVER
	array<string> amods = GetWeaponMods_Global( weapon.GetWeaponClassName() );
	for( int i = 0; i < amods.len(); ++i )
	{
		string modId = amods[i]
		Kprint( CMDsender, "[" + i.tostring() + "] " + modId);
	}
	#endif
}

bool function GiveWMWait(entity player, array<string> args)
{
	#if SERVER
	thread GiveWM(player, args)
	#endif
	return true;
}

bool function GiveWM(entity player, array<string> args)
{
	#if SERVER
	if (player == null)
		return true;

	hadGift_Admin = false;
	CheckAdmin(player);
	if (hadGift_Admin != true && bypassPerms != true)
	{
		Kprint( player, "Admin permission not detected.");
		return true;
	}
	entity weapon = player.GetActiveWeapon();

	if(weapon != null)
	{
		array<string> amods = GetWeaponMods_Global( weapon.GetWeaponClassName() );
		string modId = "";

		if (args.len() == 0)
		{
			Kprint( player, "Give a valid mod.");
			Kprint( player, "DO NOT PUT MORE THAN 4 MODS.");
			Kprint( player, "You can get rid of a mod by typing the same modId.");
			CMDsender = player
			PrintWeaponMods(weapon);
			return true;
		}

		string newString = "";

		foreach (string newmodId in args)
		{
			try
			{
				int a = newmodId.tointeger();
				modId = amods[a];
			} catch(exception2)
			{
				Kprint( player, "Error: Unknown ID, assuming its a modId");
			}
			weapon = player.GetActiveWeapon();
			GiveWeaponMod(player, modId, weapon)
			newString += (modId + " ");
		}
		Kprint( player, "Mods given to " + player.GetPlayerName() + " are " + newString);
		bypassPerms = false;
	} else {
		Kprint( player, "Invalid weapon detected.");
		return true;
	}
	return true;
	#endif
}

void function GiveWeaponMod(entity player, string modId, entity weapon)
{
	#if SERVER
		string weaponId = weapon.GetWeaponClassName();
		bool removed = false;
		array<string> mods = weapon.GetMods();

		// checks if the mods is already on the weapon
		for( int i = 0; i < mods.len(); ++i )
		{
			if( mods[i] == modId )
			{
				mods.remove( i );
				removed = true;
				break;
			}
		}
		if( !removed )
		{
			if (mods.len() < 5 || modId.find("burn_mod") != -1)
				mods.append( modId ); // catch more than 4 mods
			else if (mods.len() > 4) {
				Kprint( player, "Error: More than 4 mods. Consider removing one.");
				return;
			}
		}
		player.TakeWeaponNow( weaponId );
		try {
			player.GiveWeapon( weaponId, mods );
		} catch(exception2) {
			Kprint( player, "Error: Mod conflicts with one another.");
			for( int i = 0; i < mods.len(); ++i )
			{
				if( mods[i] == modId )
				{
					mods.remove( i );
					removed = true;
					break;
				}
			}
			player.GiveWeapon( weaponId, mods);
		}
		player.SetActiveWeaponByName( weaponId );
	#endif
}