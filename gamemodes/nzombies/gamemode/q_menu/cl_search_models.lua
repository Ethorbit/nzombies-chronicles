--[[ LICENSE HEADER MANAGED BY add-license-header

Copyright (C) 2014-2015 Alig96
Copyright (C) 2015-2017 Zet0rz
Copyright (C) 2020-2025 Ethorbit

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
--]]


-- A copy paste of the sandbox one, but only for models

local HasCreated = HasCreated or false

local function GetAllFiles( tab, folder, extension, path )

	local files, folders = file.Find( folder .. "/*", path )

	for k, v in pairs( files ) do

		if ( v:EndsWith( extension ) ) then
			table.insert( tab, (folder .. v):lower() )
		end

	end

	for k, v in pairs( folders ) do
		timer.Simple( k * 0.1, function()
			GetAllFiles( tab, folder .. v .. "/", extension, path )
		end )
	end

	if ( folder == "models/" ) then
		hook.Run( "SearchUpdate" )
	end

end


local model_list = nil
--
-- Model Search
--
if !HasCreated then
	search.AddProvider( function( str )

		str = str:PatternSafe()

		if ( model_list == nil ) then

			model_list = {}
			GetAllFiles( model_list, "models/", ".mdl", "GAME" )
			timer.Simple( 1, function() hook.Run( "SearchUpdate" ) end )

		end

		local list = {}

		for k, v in pairs( model_list ) do

			if ( v:find( str ) ) then

				if ( IsUselessModel( v ) ) then continue end
				
				table.insert( list, v )

			end

			if ( #list >= 128 ) then break end

		end

		return list

	end )
end
