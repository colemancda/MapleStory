//
//  Wz.swift
//
//
//  Created by Alsey Coleman Miller on 4/24/24.
//

import Foundation

// WZ XML parsing is implemented across the following files:
//
//   WzNode.swift        — core node tree (WzNode / WzValue)
//   WzXMLParser.swift   — SAX XML parser for .img.xml files
//   WzMob.swift         — Mob.wz stat data
//   WzNpc.swift         — Npc.wz hitbox + script data
//   WzMap.swift         — Map.wz info / portals / footholds / life spawns
//   WzItemConsume.swift — Item.wz/Consume price + spec data
//   WzSkill.swift       — Skill.wz per-level stat data
//   WzPhysics.swift     — Map.wz/Physics.img.xml constants
//   WzStringTable.swift — String.wz name/description lookup tables
