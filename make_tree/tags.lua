local EDU = 'Образование'
local ARMY = 'Армия'
local WORK = 'Работа'
local ADDR = 'Адрес'
local GALERY = 'Галерея'
local ADD = 'Дополнительно'

local tags = { 
main='ФИО', photo='Фото', parents='Родители', married='Брак', children='Дети', 
bio='Биография', index='Главная', family='Семья', maindesc='Описание',
when='Когда', where='Где', link='Ссылка'
}

tags.description = {[tags.where]=true, [tags.when]=true, [tags.maindesc]=true, [tags.photo]=true, [tags.link]=true}

tags.heads = {[EDU]=true, [ARMY]=true, [WORK]=true, [ADDR]=true, [GALERY]=true, [ADD]=true}

tags.eng = {[EDU]='edu', [ARMY]='army', [WORK]='work', [ADDR]='addr', [GALERY]='photo', 
[tags.family]='family', [tags.bio]='bio', [tags.index]='main', [ADD]='about'}

return tags
