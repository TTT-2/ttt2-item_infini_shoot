if SERVER then
	AddCSLuaFile()

	resource.AddFile('materials/vgui/ttt/icon_infinishoot')
	resource.AddFile('materials/vgui/ttt/hud_icon_infinishoot.png')
end

ITEM.EquipMenuData = {
	type = 'item_passive',
	name = 'item_infini_shoot',
	desc = 'item_infini_shoot_desc'
}

ITEM.material = 'vgui/ttt/icon_infinishoot'
ITEM.CanBuy = {ROLE_TRAITOR, ROLE_DETECTIVE}
ITEM.hud = Material('vgui/ttt/hud_icon_infinishoot.png')

if SERVER then
	local function IsValidWeapon(wep, is_reset)
		-- no weapon defined
		if not wep then
			return false
		end
		-- prevent grenades
		if wep.Kind == WEAPON_NADE then
			return false
		end

		-- special case for reset since the following checks do not work when the weapon is dropped
		if is_reset then
			return true
		end

		-- prevent most op weapons
		if not wep.HasAmmo or not wep:HasAmmo() or not wep.AutoSpawnable or (wep.Kind == WEAPON_EQUIP1 or wep.Kind == WEAPON_EQUIP2) then
			return false
		end

		return true
	end

	local function InitWeapon(wep)
		if not IsValidWeapon(wep) then return end

		wep.inf_clip_old = wep:Clip1()
		wep:SetClip1(wep:GetMaxClip1())
	end

	local function ResetWeapon(wep)
		if not IsValidWeapon(wep, true) then return end

		if not wep.inf_clip_old then return end

		wep:SetClip1(wep.inf_clip_old)
		wep.inf_clip_old = nil
	end

	local function UpdateWeapon(wep)
		if not IsValidWeapon(wep) then return end

		wep:SetClip1(wep:GetMaxClip1() + 1) --+1 since it is decreased instantly
	end

	-- WEAPON HOOKS
	function ITEM:Equip(buyer)
		InitWeapon(buyer:GetActiveWeapon())
	end

	function ITEM:Reset(buyer)
		ResetWeapon(buyer:GetActiveWeapon())
	end

	hook.Add('PostEntityFireBullets', 'ttt2_infinishoot_handle_fired_bullet', function(ply, data)
		if not ply or not ply:IsPlayer() then return end
		if not ply:HasEquipmentItem('item_ttt_infinishoot') then return end

		UpdateWeapon(ply:GetActiveWeapon())
	end)

	hook.Add('PlayerSwitchWeapon', 'ttt2_infinishoot_handle_weapon_change', function(ply, old_wep, new_wep)
		if not ply or not ply:IsPlayer() then return end
		if not ply:HasEquipmentItem('item_ttt_infinishoot') then return end

		ResetWeapon(old_wep)
		InitWeapon(new_wep)
	end)

	hook.Add('PlayerDroppedWeapon', 'ttt2_infinishoot_handle_weapon_drop', function(ply, wep)
		if not ply or not ply:IsPlayer() then return end
		if not ply:HasEquipmentItem('item_ttt_infinishoot') then return end

		ResetWeapon(wep)
	end)

	hook.Add('TTT2DropAmmo', 'ttt2_infinishoot_handle_ammo_drop', function(ply, hook_data)
		if not ply or not ply:IsPlayer() then return end
		if not ply:HasEquipmentItem('item_ttt_infinishoot') then return end

		-- do not allow ammo drop when this item is used
		return false
	end)
end
