--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:41c312bdadd7afc9008d576f94e93fcb:82a118d8905ab4a0ab49af95da436012:bd606d7fe346e370eccdc4110180480e$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- dino1
            x=0,
            y=0,
            width=65,
            height=45,

        },
        {
            -- dino2
            x=65,
            y=0,
            width=65,
            height=45,

        },
        {
            -- dino3
            x=130,
            y=0,
            width=65,
            height=45,

        },
        {
            -- dino4
            x=195,
            y=0,
            width=65,
            height=45,

        },
        {
            -- dino5
            x=260,
            y=0,
            width=65,
            height=45,

        },
        {
            -- dino6
            x=325,
            y=0,
            width=65,
            height=45,

        },
    },
    
    sheetContentWidth = 390,
    sheetContentHeight = 45
}

SheetInfo.frameIndex =
{

    ["dino1"] = 1,
    ["dino2"] = 2,
    ["dino3"] = 3,
    ["dino4"] = 4,
    ["dino5"] = 5,
    ["dino6"] = 6,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
