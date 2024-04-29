##
## The scripts in this file will handle the way that crops will grow differently depending on the
## various environmental factors around them.
##
## @Author: Zyad (@itszyad / ITSZYAD#9280)
## @Date: Apr 2024
## @Script Ver: v1.0
##
##ignorewarning tag_trace_failure
## ------------------------------------------END HEADER-------------------------------------------

CropGrowthConstants:
    type: data
    GlobalConstants:
        # According to ICAO data, on Earth the standard temperature lapse rate is approx. 6.5*C/km.
        # Since altitudes like that are not exactly Minecraft-like, I'll adopt an alternative STLR
        # of 12*C/km for the Minecraft world, which should come out to around 1.2*C per 100 blocks
        # vertically.
        StandardTempLapse: 12

        # This is an amount that temperature values will scale to or around on a semi-random basis.
        # This ensures that temperature values aren't completely uniform all across every y-level
        # of a biome.
        #
        ## NOTE: This may be rolled back upon updating to 1.20.4 / Denizen v1804 since that intro-
        ##       -duces the temperature_at[] method.
        BaseTemperatureWobble: 1.5

        # This is a number between 0 and 1 which multiplies the temperature's effect depending on
        # how high the sun is in the sky.
        HighNoonModifier: 0.65

        # Minecraft's internal system of tracking temperature is pretty weird. A desert biome is
        # marked as having "2" temperature... units? So I went ahead and defined 23 as the standard
        # multiplier for minecraft temp units to celcius. A desert of ~47*C sounds about right.
        MinecraftTempToCelciusMultiplier: 23

        # A map containing some flat numbers to be added for each valid biome name listed.
        BiomeSpecificModifiers:
            swamp: 10

    CropFormulas:
        # Actual Formula: y = 0.55 + chanceBonus + (0.45 + chanceBonus) * sin(0.1(20pi / maxTemp - minTemp)((currTemp * waveStretch) - minTemp) - waveShift)
        BaseFormula: <element[<element[0.1].mul[<element[<util.pi.mul[20]>].div[<[maxTemp].sub[<[minTemp]>]>]>].mul[<[temp].mul[<[waveStretch]>].sub[<[minTemp]>]>].sub[<[waveShift]>]>].sin.mul[<element[0.45].add[<[chanceBonus]>]>].add[0.55].add[<[chanceBonus]>]>

        CropTypes:
            carrots:
                WaveShift: 1.9
                MinTemp: 4.33
                MaxTemp: 23.89

            beetroots:
                WaveShift: 0.7
                MinTemp: -5
                MaxTemp: 30
                ChanceBonus: 0.034
                WaveStretch: 0.863

            potatoes:
                WaveShift: 1.1
                MinTemp: -10
                MaxTemp: 32
                ChanceBonus: 0.11
                WaveStretch: 0.832


TemperatureAtAltitude:
    type: procedure
    debug: false
    definitions: location[LocationTag]
    description:
    - Calculates the temperature of the current location/biome with temperature lapse due to altitude taken into account.
    - ---
    - → [ElementTag(Float)]

    script:
    ## Calculates the temperature of the current location/biome with temperature lapse due to
    ## altitude taken into account.
    ##
    ## location : [LocationTag]
    ##
    ## >>> [ElementTag(Float)]

    - define roundedLocation <[location].with_x[<[location].x.round_to_precision[10]>].with_z[<[location].z.round_to_precision[10]>]>

    - define baseTempWobble <script[CropGrowthConstants].data_key[GlobalConstants.BaseTemperatureWobble]>
    - define tempMultiplier <script[CropGrowthConstants].data_key[GlobalConstants.MinecraftTempToCelciusMultiplier]>
    - define baseTempLapse <script[CropGrowthConstants].data_key[GlobalConstants.StandardTempLapse]>
    - define biomeSpecificMod <script[CropGrowthConstants].data_key[GlobalConstants.BiomeSpecificModifiers.<[roundedLocation].biome.name>].if_null[0]>
    - define baseSunSky <element[1].sub[<[roundedLocation].world.time.sub[7500].abs.div[7000].add[0.1]>]>
    - define baseHighNoonMod <script[CropGrowthConstants].data_key[GlobalConstants.HighNoonModifier]>

    - define tempWobble <[roundedLocation].with_y[<[roundedLocation].world.sea_level>].simplex_3d.mul[<[baseTempWobble]>]>
    - define tempLapse <[roundedLocation].y.sub[<[roundedLocation].world.sea_level>].div[1000].mul[<[baseTempLapse]>]>
    - define HighNoonModifier <[roundedLocation].biome.temperature.mul[<[baseHighNoonMod].mul[<[baseSunSky]>].round_down_to_precision[0.001]>]>

    - determine <[roundedLocation].biome.temperature.mul[<[tempMultiplier]>].add[<[biomeSpecificMod]>].add[<[tempWobble]>].sub[<[tempLapse]>].add[<[HighNoonModifier]>].round_to_precision[0.001]>


ShouldCropGrow:
    type: procedure
    debug: false
    definitions: cropType[ElementTag(String)]|location[LocationTag]
    description:
    - Returns a true/false value on whether the provided crop should grow given its current conditions.
    - ---
    - → [ElementTag(Boolean)]

    script:
    ## Returns a true/false value on whether the provided crop should grow given its current
    ## conditions.
    ##
    ## cropType : [ElementTag(String)]
    ## location : [LocationTag]
    ##
    ## >>> [ElementTag(Boolean)]

    - define cropData <script[CropGrowthConstants].data_key[CropFormulas.CropTypes.<[cropType]>]>
    - define minTemp <[cropData].get[MinTemp]>
    - define maxTemp <[cropData].get[MaxTemp]>
    - define waveShift <[cropData].get[WaveShift]>
    - define chanceBonus <[cropData].get[ChanceBonus].if_null[0]>
    - define waveStretch <[cropData].get[WaveStretch].if_null[1]>
    - define temp <[location].proc[TemperatureAtAltitude]>
    - define temp <[maxTemp]> if:<[temp].is[MORE].than[<[maxTemp]>]>
    - define temp <[minTemp]> if:<[temp].is[LESS].than[<[minTemp]>]>

    - define formula <script[CropGrowthConstants].data_key[CropFormulas.BaseFormula].parsed>

    - if <[cropData].keys.contains[CustomFormula]>:
        - define formula <[cropData].get[CustomFormula].parsed>

    - determine <util.random_chance[<[formula].mul[100]>]>