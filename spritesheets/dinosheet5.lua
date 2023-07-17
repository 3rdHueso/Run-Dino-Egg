--
-- created with TexturePacker - https://www.codeandweb.com/texturepacker
--
-- $TexturePacker:SmartUpdate:886120f20edca31cbdc3614780eaeaee:826f4c4126c9d0d892e621d5e270eca9:eed59b46396fd62c4e4aa9dd71868b40$
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
            width=54,
            height=29,

        },
        {
            -- 2
            x=57,
            y=1,
            width=54,
            height=29,

        },
        {
            -- 3
            x=113,
            y=1,
            width=54,
            height=29,

        },
        {
            -- 4
            x=169,
            y=1,
            width=54,
            height=29,

        },
        {
            -- 5
            x=225,
            y=1,
            width=54,
            height=29,

        },
        {
            -- 6
            x=281,
            y=1,
            width=54,
            height=29,

        },
    },

    sheetContentWidth = 336,
    sheetContentHeight = 31
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
