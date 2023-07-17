--
-- created with TexturePacker - https://www.codeandweb.com/texturepacker
--
-- $TexturePacker:SmartUpdate:c223cfa852c301668fb3d2c43c830536:a2cac193751da1bee17828807512363d:eed59b46396fd62c4e4aa9dd71868b40$
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
            width=73,
            height=49,

        },
        {
            -- 2
            x=76,
            y=1,
            width=73,
            height=49,

        },
        {
            -- 3
            x=151,
            y=1,
            width=73,
            height=49,

        },
        {
            -- 4
            x=226,
            y=1,
            width=73,
            height=49,

        },
        {
            -- 5
            x=301,
            y=1,
            width=73,
            height=49,

        },
        {
            -- 6
            x=376,
            y=1,
            width=73,
            height=49,

        },
    },

    sheetContentWidth = 450,
    sheetContentHeight = 51
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
