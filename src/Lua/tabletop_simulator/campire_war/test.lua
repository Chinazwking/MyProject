--[[ This is test script for campfire war card game. --]]
-- author:wang.zhuowei@foxmail.com
-- date: Feb 8, 2019
-- license: GPL.v3

--[[ The onLoad event is called after the game save finishes loading. --]]
function onLoad()
    print('Test button onLoad!')
    params = {
        click_function = "click_func",
        function_owner = self,
        label          = "test",
        width          = 600,
        height         = 600,
        font_size      = 340,
        color          = {0.5, 0.5, 0.5},
        font_color     = {1, 1, 1},
        tooltip        = "测试",
    }
    self.createButton(params)
end

function click_func(obj, color, alt_click)
    if Global.call('isDisable') then
        return
    end
    local obj = getObjectFromGUID('58b247')
    local obj1 = getObjectFromGUID('31405f')
    print('deck=', obj.is_face_down)
    print('card=', obj1.is_face_down)
end
