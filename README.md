## Стек
 - Верстка: UIKit
 - Архитектура: MVVM+Combine
## Инструкция по запуску
В проекте нет внешних зависимостей или чего-либо другого, подразумевающего особенности запуска. Запуск по открытию файлы AvitoTechChallenge.xcodeproj в корне проекта.

## Вопросы, особенности, проблемы и их решения:
1. Зачем Combine?
   - Все просто: хотел посмотреть на MVVM "по-взрослому". В целом понравилось, буду применять дальше.
2. Состояния приложений и обработка крайних случаев в ответе
   - Рассмотрим, например, детальную информацию об авторе. Описания автора в lookup-ответе как таковой нет: чесались руки впилить SwiftSoup и распарсить страницу автора в iTunes, но это противоречило бы требованию "без внешних зависимостей".
     Ответ на запрос весьма куцый: только тип автора (Artist много не говорит), его жанр, да ссылка на страницу в iTunes. Поэтому ограничился этой информацией: жанр, имя, ссылка на страницу.
       - К тому же, большинство сущностей медиа контента не имеют id автора для осуществления lookup-запроса. Поэтому прокидываю алерт если осуществить запрос невозможно.
3. Предложение введенных ранее поисковых запросов
    - было ограничение на 5 запросов, но не выделено точно: 5 сохраненных запросов, или 5 предлагаемых. Посчитал, что первый вариант больше подходит.
4. Размер контента на экране подробной информации
    - Так как блок информации мог занимать много места (вместе с картинкой на половину экрана) использовал скроллвью, которая подсчитывает самую нижнюю точку сабвью и корректирует свой размер. Позволяет избежать появления
   огромного пустого участка
5. Верстка и стиль
   - Раз делаю задание в Авито, то пусть интерфейс напоминает Авито.
6. Лимит на условные 30 едининц контента
   - Так как я фильтрую ответы по наличию ссылки на песню/медиа в itunes, то ожидаемое количество полученных медиа может быть ниже. Что я сделал: убрал ограничение в поисковом запросе (без этого ограничения ответ 50), фильтрую эти 50 ответов
     и беру префикс из установленного лимита. Но иногда выходит меньше 30, retry на больший лимит я решил не вводить
       - Хоть я и фильтрую по ссылке на песню/медиа, я не фильтрую по ссылке на автора. Тем самым, я обеспечиваю возможность получить ошибку и отобразить ее, и не лишаюсь большей доли контента которая эту ссылку не имеет 
## Демонстрация работы
Я слабо понял требования о демонстрации запросов в Postman из сообщений на почте, поэтому посчитаю, что шаблон сообщения стандартный и к этому заданию не относится (по крайней мере, о нем ничего не сказано в readme задания).
Видео работы приложения можно найти по [ссылке](https://drive.google.com/file/d/1-uXLEdXEX3gzPAnvM1WHwt5w_uvTWOui/view?usp=sharing). В нем показана реализация требований и использование приложения в целом:
- Таблица предложений сохраняет до 5 введенных запросов: следующий запрос вытесняет предыдущий. При печати в поисковую строку выводятся элемента с совпадением без учета регистра.;
- Демонстрация ошибки при выполнении запроса на главном экране (например, ввели невнятный набор букв и получили 0 ответов);
- Индикатор загрузки контента;
- Отсутствие лагов при скролле;
- Переход на подробную страницу с контентом;
- Загрузка подробной информации об авторе если имеется (если не имеется - алерт);
- Индикатор загрузки подробной информации об авторе;

## Маленькая просьба
Если возможно, напишите пожалуйста замечания по реализации в Issues.
