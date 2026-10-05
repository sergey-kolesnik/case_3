:- encoding(utf8).
:- dynamic answer/2.

/*
   Экспертная система подбора формата обучения
   в Университете «Синергия».

   Запуск в SWI-Prolog:
   ?- start.
*/

start :-
    setup_call_cleanup(
        clear_answers,
        consultation,
        clear_answers
    ).

consultation :-
    nl,
    writeln('Экспертная система подбора формата обучения'),
    writeln('Отвечайте да/д или нет/н.'),
    nl,
    ask_all,
    choose_format(Result),
    result_text(Result, Name, Explanation),
    format('~nРекомендуемый формат: ~s~n', [Name]),
    format('Пояснение: ~s~n', [Explanation]),
    print_answers.

question(attend_weekdays,
    'Вы можете регулярно посещать занятия в будние дни?').
question(work_full_day,
    'Вы работаете полный день?').
question(need_remote,
    'Вам нужен полностью дистанционный формат обучения?').
question(independent_study,
    'Вы готовы к высокой доле самостоятельной работы?').

ask_all :-
    forall(question(Key, Text), ask(Key, Text)).

ask(Key, Text) :-
    repeat,
    format('~s (д/н): ', [Text]),
    read_line_to_string(user_input, Raw),
    normalize_space(string(Normalized), Raw),
    string_lower(Normalized, Value),
    ( yes_value(Value) ->
        assertz(answer(Key, yes)), !
    ; no_value(Value) ->
        assertz(answer(Key, no)), !
    ; writeln('Введите да/д или нет/н.'),
      fail
    ).

yes_value("да").
yes_value("д").
yes_value("yes").
yes_value("y").

no_value("нет").
no_value("н").
no_value("no").
no_value("n").

/* Правила расположены в порядке приоритета. */
choose_format(online) :-
    answer(need_remote, yes), !.
choose_format(part_time) :-
    answer(work_full_day, yes),
    answer(need_remote, no), !.
choose_format(full_time) :-
    answer(attend_weekdays, yes),
    answer(work_full_day, no), !.
choose_format(correspondence) :-
    answer(independent_study, yes), !.
choose_format(personal_consultation).

result_text(online,
    'онлайн',
    'обучение проходит удаленно через цифровую образовательную среду.').
result_text(part_time,
    'очно-заочный',
    'занятия можно совмещать с работой за счет вечернего или смешанного графика.').
result_text(full_time,
    'очный',
    'регулярное посещение занятий подходит при свободном дневном графике.').
result_text(correspondence,
    'заочный',
    'формат предполагает значительную долю самостоятельной работы.').
result_text(personal_consultation,
    'индивидуальная консультация',
    'ответы не позволяют однозначно выбрать формат; требуется уточнить программу и расписание.').

print_answers :-
    nl,
    writeln('Учтенные ответы:'),
    forall(
        answer(Key, Value),
        ( question(Key, Text),
          answer_text(Value, ValueText),
          format(' - ~s: ~s~n', [Text, ValueText])
        )
    ).

answer_text(yes, 'да').
answer_text(no, 'нет').

clear_answers :-
    retractall(answer(_, _)).
