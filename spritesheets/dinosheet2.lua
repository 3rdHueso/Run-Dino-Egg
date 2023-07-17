--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:262bdb4670a737dd137bbb79d1db8436:c9d6b29acc9f35493159cd9c4feb40a4:845cc3c2ff40a6431724d738d03c1439$
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
            -- 1
            x=1,
            y=1,
            width=81,
            height=44,

        },
        {
            -- 2
            x=84,
            y=1,
            width=81,
            height=44,

        },
        {
            -- 3
            x=167,
            y=1,
            width=81,
            height=44,

        },
        {
            -- 4
            x=250,
            y=1,
            width=81,
            height=44,

        },
        {
            -- 5
            x=333,
            y=1,
            width=81,
            height=44,

        },
        {
            -- 6
            x=416,
            y=1,
            width=81,
            height=44,

        },
    },
    
    sheetContentWidth = 498,
    sheetContentHeight = 46
}

SheetInfo.frameIndex =
{

    ["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
    ["4"] = 4,
    ["5"] = 5,
    ["6"] = 6,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
