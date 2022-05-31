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

-- Выведем имена всех магов
local function print_magicians()
    local magicians = box.space.magician:select()
    for _, magician in ipairs(magicians) do
        local name = magician[2]
        print(name)
    end
end
print_magicians()

-- Выведем названия всех заклинаний с четным id
local function print_even_id_spells()
    local spells_amount = box.space.spell:len()
    for i = 2, spells_amount, 2 do
        spell = box.space.spell:get{i}
        local name = spell[2]
        print(name)
    end
end
print_even_id_spells()


-- Выведем названия заклинаний, которые знает маг с id = 1
local function print_spell_by_mag_id(id)
    if type(id) ~= 'number' then
        return nil, error('id should be number')
    end
    local magician_spells = box.space.magician_spell.index.magician_id:select({id})
    for _, magician_spell in ipairs(magician_spells) do
        local spell_id = magician_spell[3]
        spell = box.space.spell:get{spell_id}
        local name = spell[2]
        print(name)
    end
end
print_spell_by_mag_id(1)

-- Удалим всех магов, которые не знают ни одно заклинание
local function delete_magicians_without_spells()
    for _, magician in box.space.magician:pairs() do
        local magician_id = magician[1]
        local magician_name = magician[2]
        local magician_spells = box.space.magician_spell.index.magician_id:select({magician_id})
        if #magician_spells == 0 then
            box.space.magician:delete{magician_id}
            print(magician_name)
        end
    end

end
delete_magicians_without_spells()

-- Переименуем мага с id = 1 в Гарри Поттора
box.space.magicians:update({1}, {{'=', 'name', 'Harry Potter'}})
