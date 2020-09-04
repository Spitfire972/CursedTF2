global function OnWeaponPrimaryAttack_cloak


var function OnWeaponPrimaryAttack_cloak( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity ownerPlayer = weapon.GetWeaponOwner()

	Assert( IsValid( ownerPlayer) && ownerPlayer.IsPlayer() )

	if ( IsValid( ownerPlayer ) && ownerPlayer.IsPlayer() )
	{
		if ( ownerPlayer.GetCinematicEventFlags() & CE_FLAG_CLASSIC_MP_SPAWNING )
			return false

		if ( ownerPlayer.GetCinematicEventFlags() & CE_FLAG_INTRO )
			return false
	}
	#if SERVER
		array<entity> nearbyEnemies = GetNearbyEnemiesForSonarPulse( ownerPlayer.GetTeam(), attackParams.pos )
		foreach( enemy in nearbyEnemies )
		{
			try
			{
				thread SonarPulseThink( weapon.GetWeaponOwner(), attackParams.pos, enemy.GetTeam(), enemy, true, false)
			} catch(exception)
			{
				print("failed")
			}
		}
	#endif
	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire )
}
