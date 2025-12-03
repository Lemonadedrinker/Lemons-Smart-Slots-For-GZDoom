class lcs_EventHandler : EventHandler
{
    bool isEditing;
    

    /**
    * Processes keybinds
    */
    override void ConsoleProcess(ConsoleEvent event)
    {
        if(players[Consoleplayer].mo == null) return;
        let playerInventory = players[Consoleplayer].ReadyWeapon.GetClassName();
        
        if (event.Name == "LCS_Edit")
        {
            //Console.MidPrint(smallfont, String.Format("%suwu", "\cg"));

            SendNetworkEvent("LCS_WeaponSwitch");

            //self.IsUiProcessor = true;
            //self.RequireMouse = true;            

            //Console.MidPrint(smallfont, String.Format("%s" .. playerInventory, "\cg"));


            // From https://forum.zdoom.org/viewtopic.php?t=79042
            // Creates an array of weapons that the player currently has
            /*
            bool located;
            int slot;
            int priority;

            let player = players[Consoleplayer];
            for (let i = 0; i < 10; i++)
            {
                let iSize = player.weapons.SlotSize(i);
                for (let x = 0; x < iSize; x++)
                {
                    let wclassType = player.weapons.GetWeapon(i,x);
                    let wclassName = wclassType.GetClassName();
                    //Console.printf(" Weapon:" .. i .. ", ".. x .. " " .. wclassName);

                    [located, slot, priority] = player.weapons.LocateWeapon(wclassName);

                    if (!located) continue;

                    // Check if the player has the weapon
                    if (located)
                    {
                        Console.printf(" HAVE:" .. wclassType.GetClassName());
                    }
                }
		    }
            */

            // Iterates through the player's inventory, looking for weapons
            Let player = players[Consoleplayer];
            Array<Weapon> currentWeapons;
            currentWeapons.Clear();
            bool located;
            int slot = -1;
            int priority;
            for (let item = player.mo.Inv; item != null; item = item.Inv)
            {
                // Cast item as a weapon
                let weapon = Weapon(item);

                // If the cast fails, keep going
                if (!weapon) continue;

                slot = weapon.SlotNumber;

                // Vanilla Doom weapons need to be hardcoded because ZDoom does not
                // automatically assign slots to them (I think)
                if(weapon is 'Fist' || weapon is 'Chainsaw') slot = 1;
				else if (weapon is 'Pistol') slot = 2;
				else if (weapon is 'Shotgun' || weapon is 'SuperShotgun') slot = 3;
				else if (weapon is 'Chaingun') slot = 4;
				else if (weapon is 'RocketLauncher') slot = 5;
				else if (weapon is 'PlasmaRifle') slot = 6;
				else if (weapon is 'BFG9000') slot = 7;

                // Check if the item is on slots 0-9
                if ((slot < 0) || (slot > 9)) continue;
                
                // Weapon found!!
                currentWeapons.Push(weapon);
                //Console.printf(" HAVE: " .. weapon.GetClassName() .. " in slot #" .. slot .. " and priority: " .. priority);
            }

            // Debugging
            int randomWeaponIndex = crandom(0, currentWeapons.Size() - 1);
            String randomWeaponName = currentWeapons[randomWeaponIndex].GetClassName();

            SendNetworkEvent("LCS_WeaponSwitchTo" .. randomWeaponName);
        }
    }

    override bool UiProcess(UiEvent e)
    {
        return false;
    }

    override void NetworkProcess(ConsoleEvent event)
    {
        //self.IsUiProcessor = !self.IsUiProcessor;
        //self.RequireMouse = !self.RequireMouse; 
            
        if(players[event.Player].mo == null) return;
        Let player = players[event.Player].mo;

        if (event.Name.Left(18) == "LCS_WeaponSwitchTo")
        {
            String weaponName = event.Name;
            weaponName.Remove(0, 18);

            Console.printf("%s", weaponName);
            player.A_SelectWeapon(weaponName);
        }
    }
}