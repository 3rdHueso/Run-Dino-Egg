--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:4c21b1448d44392c2892d3839358c5b4:640e9a0302161f7d7cd338719a67769b:007add3c8155287e9991f07e08444510$
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
            x=2,
            y=2,
            width=56,
            height=43,

        },
        {
            -- 2
            x=62,
            y=2,
            width=56,
            height=43,

        },
        {
            -- 3
            x=122,
            y=2,
            width=56,
            height=43,

        },
        {
            -- 4
            x=182,
            y=2,
            width=56,
            height=43,

        },
        {
            -- 5
            x=242,
            y=2,
            width=56,
            height=43,

        },
        {
            -- 6
            x=302,
            y=2,
            width=56,
            height=43,

        },
    },
    
    sheetContentWidth = 360,
    sheetContentHeight = 47
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
