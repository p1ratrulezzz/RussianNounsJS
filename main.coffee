﻿
# источники информации:
# - Современный русский язык. Морфология - Камынина А.А., Уч. пос. 1999 - 240 с.
# - Англоязычная википедия: http://en.wikipedia.org/wiki/Russian_grammar

misc = 
requiredString: (v) ->
  if(typeof v != "string")
    throw new Error(v + " is not a string.")

StemUtil =
  ###* Доп. проверки для стеммера ###
  getNounStem: (word) ->
    if _.last(word) is 'л' then return word
    StemUtil.getStem word
  ###* Русский стеммер из Snowball JavaScript Library. ###
  getStem: (word) ->
    stemmer = new Snowball('Russian');
    stemmer.setCurrent(word);
    stemmer.stem();
    stemmer.getCurrent();
  getInit: (s) ->
    if s.length <= 1 then return ''
    s.substring(0, s.length-1)
  getLastTwoChars: (s) ->
    if s.length <= 1 then return ''
    s.substring(s.length-2, s.length)

### Абстракция над справочником слов из БД. ###
class Vocabulary
  ###* является ли слово несклоняемым ###
  isIndeclinable:(word) ->
    # должно спрашивать из базы (их не так уж много)
    false



window.CaseDefinition =
  NOMINATIVE: "Именительный"
  GENITIVE: "Родительный"
  DATIVE: "Дательный"
  ACCUSATIVE: "Винительный"
  INSTRUMENTAL: "Творительный"
  PREPOSITIONAL: "Предложный"

DeclensionDefinition =
  0: 'разносклоняемые "путь" и "дитя"'
  1: 'муж., средний род без окончания'
  2: 'слова на "а", "я" (м., ж. и общий род)'
  3: 'жен. род без окончания, слова на "мя"'

window.Gender =
  "FEMININE": "женский род"
  "MASCULINE": "мужской род"
  "NEUTER": "средний род"
  "COMMON": "общий род"


vocabulary = new Vocabulary()
  
###* 
Определяет склонение существительных
@param word слово в именительном падеже
@param gender пол
@returns {integer} склонение (см. DeclensionDefinition)
###
window.getDeclension = (word, gender) ->
  misc.requiredString(word)
  misc.requiredString(gender)
  
  # todo: избавиться от substr
  if vocabulary.isIndeclinable word
    throw new Error("indeclinable word")
  
  switch gender
    when Gender.FEMININE 
      t = _.last(word)
      `t == "а" || t == "я" ? 2 : 3`
    when Gender.MASCULINE
      t = _.last(word)
      `t == "а" || t == "я" ? 2 :
      word == "путь" ? 0 : 1`
    when Gender.NEUTER
      `word == "дитя" ? 0 :
      word.substr(-2, 2) == "мя" ? 3 : 1`
    when Gender.COMMON then 2  # они все на -а, -я, либо несклоняемые
    else
      throw new Error("incorrect gender")



decline = (word, gender, grCase) ->
  stem = StemUtil.getNounStem word
  head = StemUtil.getInit word
  declension = getDeclension word, gender
  
  switch declension
    when 0
      throw new Error("unsupported")
      #switch grCase
      #  when CaseDefinition.NOMINATIVE
      #  when CaseDefinition.GENITIVE
      #  when CaseDefinition.DATIVE
      #  when CaseDefinition.ACCUSATIVE
      #  when CaseDefinition.INSTRUMENTAL
      #  when CaseDefinition.PREPOSITIONAL
    when 1
      soft = ->
        lastChar = _.last(word)
        lastChar is 'ь' or lastChar is 'e'
      switch grCase
        when CaseDefinition.NOMINATIVE
          word
        when CaseDefinition.GENITIVE
          if soft()
            stem + 'я'
          else if _.last(word) is 'й'
            head + 'я'
          else
            stem + 'а'
        when CaseDefinition.DATIVE
          if soft()
            stem + 'ю'
          else if _.last(word) is 'й'
            head + 'ю'
          else
            stem + 'у'
        when CaseDefinition.ACCUSATIVE
          word # или как GENITIVE
        when CaseDefinition.INSTRUMENTAL
          if soft()
            stem + 'ем'
          else if _.last(word) is 'й'
            head + 'ем'
          else
            stem + 'ом'
        when CaseDefinition.PREPOSITIONAL
          if StemUtil.getLastTwoChars(word) is 'ий'
            head + 'и'
          else if _.last(word) is 'й'
            head + 'е'
          else
            stem + 'е'
    when 2
      throw new Error("unsupported")
      #switch grCase
      #  when CaseDefinition.NOMINATIVE
      #  when CaseDefinition.GENITIVE
      #  when CaseDefinition.DATIVE
      #  when CaseDefinition.ACCUSATIVE
      #  when CaseDefinition.INSTRUMENTAL
      #  when CaseDefinition.PREPOSITIONAL
    when 3
      throw new Error("unsupported")
      #switch grCase
      #  when CaseDefinition.NOMINATIVE
      #  when CaseDefinition.GENITIVE
      #  when CaseDefinition.DATIVE
      #  when CaseDefinition.ACCUSATIVE
      #  when CaseDefinition.INSTRUMENTAL
      #  when CaseDefinition.PREPOSITIONAL

window.decline = decline


test = (data, gender) ->
  _.each CaseDefinition, ((caseValue, caseId) ->
    console.log '\n'+caseValue
    for i in data
      try
        console.log decline i, gender, caseValue
      catch e
        if e.message is "unsupported"
          console.log e.message
        else
          throw e
  )

window.testM = ->
  d = ['стол', 'музей', 'пролетарий', 'лесничий', 'путь', 'парашют', 'вокзал', 'параход', 'дирижабль', 'мармелад', 'вася', 'гвоздь', 'пилот', 'матершиник', 'пистолет', 'вопль', 'закат', 'дядя']
  test d, Gender.MASCULINE

window.testN = ->
  d = ['окно', 'житие', 'сопло', 'арго', 'пальто', 'вино']
  test d, Gender.MASCULINE  