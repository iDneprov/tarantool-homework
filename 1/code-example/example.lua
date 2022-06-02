-- Инициализация tarantool
box.cfg{}

-- Создаем спейсы
box.schema.space.create("magician")
box.schema.space.create("spell")
box.schema.space.create("magician_spell")

-- Задаем формат спейсов
box.space.magician:format({
    { name = "id", type = "number" },
    { name = "name", type = "string" },
})

box.space.spell:format({
    { name = "id", type = "number" },
    { name = "name", type = "string" },
    { name = "effect", type = "string" },
})

box.space.magician_spell:format({
    { name = "id", type = "number" },
    { name = "magician_id", type = "number" },
    { name = "spell_id", type = "number" },
})

-- Добавим индексы
box.space.magician:create_index('id', {unique = true,  parts = { 'id' } })
box.space.spell:create_index('id', {unique = true,  parts = { 'id' } })
box.space.magician_spell:create_index('id', {unique = true,  parts = { 'id' } })
box.space.magician_spell:create_index('magician_id', {unique = false, parts = { 'magician_id' } })
box.space.magician_spell:create_index('spell_id', {unique = false, parts = { 'spell_id' } })

-- Вставим данные
box.space.magician:insert({1, 'Harry'})
box.space.magician:insert({2, 'Petr'})
box.space.magician:insert({3, 'Gandalf'})

box.space.spell:insert({1, 'Lumos', 'зажигает нематериальный источник света'})
box.space.spell:insert({2, 'Portus', 'открытие портала для перемещения в пространстве'})
box.space.spell:insert({3, 'Reparo', 'восстанавливает сломанные предметы'})
box.space.spell:insert({4, 'Levicorpus', 'подвесить противника в воздухе вниз головой'})
box.space.spell:insert({5, 'Silencio', 'парализует горло противника'})

box.space.magician_spell:insert({1, 1, 1})
box.space.magician_spell:insert({2, 1, 2})
box.space.magician_spell:insert({3, 1, 3})
box.space.magician_spell:insert({4, 3, 1})
box.space.magician_spell:insert({5, 3, 2})
box.space.magician_spell:insert({6, 3, 3})
box.space.magician_spell:insert({7, 3, 4})
box.space.magician_spell:insert({8, 3, 5})

-- Подключим библиотеки, которые понадобятся для логирования
local log = require('log')
local json = require('json')

-- Подготовим список магов и названий известных им заклинаний
local function magicians_spells()
    local result = {}
    for _, magician in box.space.magician:pairs() do
        local magician_table = {
            id = magician[1],
            name = magician[2],
            spells = {}
        }

        local magician_id = magician[1]
        local magician_spells = box.space.magician_spell.index.magician_id:select({magician_id})
        for _, magician_spell in ipairs(magician_spells) do
            local spell_id = magician_spell[3]
            local spell = box.space.spell:get{spell_id}
            table.insert(magician_table.spells, spell)
        end
        table.insert(result, magician_table)
    end
    return result
end
local magicians_spells_table = magicians_spells()
log.info('Magicians and list of spells they know: %s', json.encode(magicians_spells_table))

-- Удалим всех магов, которые не знают ни одно заклинание и верни списочек
local function delete_magicians_without_spells()
    local result = {}
    for _, magician in box.space.magician:pairs() do
        local magician_id = magician[1]
        local magician_name = magician[2]
        local magician_spells = box.space.magician_spell.index.magician_id:select({magician_id})
        if #magician_spells == 0 then
            local magician = box.space.magician:delete{magician_id}
            table.insert(result, magician)
        end
    end
    return result
end
local magicians_without_spells = delete_magicians_without_spells()
log.info('Magicians without spells: %s', json.encode(magicians_without_spells))

-- Переименуем мага с id = 1 в Гарри Поттора
local function rename_magician(id, name)
    local result = box.space.magician:update({id}, {{'=', 'name', name}})
    return result
end
rename_magician(1, 'Harry Potter')
