dynmap_config:
    type: data
    configs:
        #Add a map of options in the following format. You can name your config whatever you like.
        kingdomsRaptoran_all:
            #colors: Any hex value is valid.
            color: 159
            fillcolor: 00ffff
            #fillopacity values from 0.0 to 1.0 are valid.
            opacity: 0.9
            #fillopacity values from 0.0 to 1.0 are valid.
            fillopacity: 0.5
            #weight integer values are valid.
            weight: 2
            #If no label is provided, there wont be one.
            #<[area]> will return the relevant AreaObject.
            label:
            - "=-=-= Kingdoms Region =-=-="
            - Owners: "The Republic of Altea"
            #- Flags: <[area].flag[dPrevention.flags].to_pair_lists.parse_tag[<[parse_value].first>:<[parse_value].last>].space_separated.if_null[NONE]>
            ##All configs should have this key.
            #Example: If a marker set was added via "/dmarker addset dPrevention" you should set marker-set to "dPrevention"
            marker-set: kingdoms-region
            ##All config must have this key.
            world: Kingdoms
            ##All config must have this key.
            #Path of the world flags containing a list of area note names.
            #If a path doesn't exist it will skip it.
            path:
            - dynmap.kingdoms.raptoran.outposts
            - dynmap.kingdoms.raptoran.region

        #dPrevention_admin_claims:
            #If options are missing, the default ones will be used.
        #    color: 800000
        #    fillcolor: ff8080
        #    opacity: 1
        #    fillopacity: 0.5
        #    weight: 2
        #    label:
        #    - +--+dPrevention Admin Area+--+
        #   # marker-set: dPrevention
        #    world: world
        #    path:
        #    - dPrevention.areas.admin.cuboids
        #    - dPrevention.areas.admin.polygons