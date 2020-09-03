//untyped

global function OnWeaponPrimaryAttack_lmg

global function OnWeaponActivate_lmg
global function OnWeaponBulletHit_weapon_lmg

const float LMG_SMART_AMMO_TRACKER_TIME = 10.0

void function OnWeaponActivate_lmg( entity weapon )
{
	//PrintFunc()
	SmartAmmo_SetAllowUnlockedFiring( weapon, true )
	SmartAmmo_SetUnlockAfterBurst( weapon, (SMART_AMMO_PLAYER_MAX_LOCKS > 1) )
	SmartAmmo_SetWarningIndicatorDelay( weapon, 9999.0 )
}


var function OnWeaponPrimaryAttack_lmg( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	//if ( weapon.HasMod( "smart_lock_dev" ) )
	//{
	//	int damageFlags = weapon.GetWeaponDamageFlags()
		//printt( "DamageFlags for lmg: " + damageFlags )
	//	return SmartAmmo_FireWeapon( weapon, attackParams, damageFlags, damageFlags )
	//}
	//else
	//{
	//	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	//	weapon.FireWeaponBullet( attackParams.pos, attackParams.dir, 1, weapon.GetWeaponDamageFlags() )
	//}

	entity weaponOwner = weapon.GetOwner()
	//if ( weaponOwner.IsPlayer() )
	//	PlayerUsedOffhand( weaponOwner, weapon )

	#if SERVER
	float duration = 2
	entity inflictor = CreateOncePerTickDamageInflictorHelper( duration )
	#endif

	const float FUSE_TIME = 99.0
	entity projectile = weapon.FireWeaponGrenade( attackParams.pos, attackParams.dir, < 0,0,0 >, FUSE_TIME, damageTypes.projectileImpact, damageTypes.explosive, false, true, true )
	if ( projectile )
	{
		projectile.SetModel( $"models/dev/empty_model.mdl" )
		EmitSoundOnEntity( projectile, "flamewall_flame_start" )
		#if SERVER
			weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.5 )
			thread BeginFlameWave( projectile, 0, inflictor, attackParams, attackParams.dir )
		#endif
	}

	#if CLIENT
		ClientScreenShake( 8.0, 10.0, 1.0, Vector( 0.0, 0.0, 0.0 ) )
	#endif
	return weapon.GetWeaponInfoFileKeyField( "ammo_min_to_fire" )


}

void function OnWeaponBulletHit_weapon_lmg( entity weapon, WeaponBulletHitParams hitParams )
{
	if ( !weapon.HasMod( "smart_lock_dev" ) )
		return

	entity hitEnt = hitParams.hitEnt //Could be more efficient with this and early return out if the hitEnt is not a player, if only smart_ammo_player_targets_must_be_tracked  is set, which is currently true

	if ( IsValid( hitEnt ) )
	{
		weapon.SmartAmmo_TrackEntity( hitEnt, LMG_SMART_AMMO_TRACKER_TIME )

		#if SERVER
			if ( hitEnt.IsPlayer() &&  !hitEnt.IsTitan() ) //Note that there is a max of 10 status effects, which means that if you theoreteically get hit as a pilot 10 times without somehow dying, you could knock out other status effects like emp slow etc
			{
				printt( "Adding status effect" )
				StatusEffect_AddTimed( hitEnt, eStatusEffect.sonar_detected, 1.0, LMG_SMART_AMMO_TRACKER_TIME, 0.0 )
			}
		#endif
	}
}
