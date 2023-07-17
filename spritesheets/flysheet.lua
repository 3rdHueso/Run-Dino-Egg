--
-- created with TexturePacker (http://www.codeandweb.com/texturepacker)
--
-- $TexturePacker:SmartUpdate:4e08f9b2d0d8cb30da2ef7648647980b:6d14d15dff5cefeb8ef09d78d39d4c98:25a0c307cfaffbbb510320359b34dfcb$
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
            width=45,
            height=38,

        },
        {
            -- 2
            x=48,
            y=1,
            width=45,
            height=38,

        },
    },
    
    sheetContentWidth = 94,
    sheetContentHeight = 40
}

SheetInfo.frameIndex =
{

    ["1"] = 1,
    ["2"] = 2,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
